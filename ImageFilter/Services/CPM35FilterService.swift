//
//  VintageFilterService.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import UIKit
import CoreImage

class VintageFilterService {
    enum VintageFilterType: String, CaseIterable {
        case classic = "Classic Vintage"
        case sepia = "Sepia Dreams"
        case film70s = "70s Film"
        case polaroid = "Polaroid"
        case faded = "Faded Glory"
        case warmGlow = "Warm Glow"
        case coolTone = "Cool Vintage"
        case highContrast = "High Contrast"
    }
    
    enum FilterError: Error, LocalizedError {
        case imageProcessingFailed
        case invalidInputData
        case coreImageFilterFailed
        case cgImageCreationFailed
        case dataConversionFailed
        
        var errorDescription: String? {
            switch self {
            case .imageProcessingFailed:
                return "Image processing failed"
            case .invalidInputData:
                return "Invalid input image data"
            case .coreImageFilterFailed:
                return "Core Image filter failed"
            case .cgImageCreationFailed:
                return "Failed to create final image"
            case .dataConversionFailed:
                return "Failed to convert image to data"
            }
        }
    }
    
    private let context = CIContext(options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        .cacheIntermediates: false
    ])
    
    // MARK: - Main Filter Application
    func applyVintageFilter(_ filterType: VintageFilterType, to imageData: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try self.processImageWithVintageFilter(filterType, imageData: imageData)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func processImageWithVintageFilter(_ filterType: VintageFilterType, imageData: Data) throws -> Data {
        // Convert Data to UIImage
        guard let uiImage = UIImage(data: imageData) else {
            throw FilterError.invalidInputData
        }
        
        // Convert to CIImage
        guard let ciImage = CIImage(image: uiImage) else {
            throw FilterError.invalidInputData
        }
        
        // Apply the selected vintage filter
        let processedImage = try applySpecificVintageFilter(filterType, to: ciImage)
        
        // Convert back to CGImage
        guard let cgImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            throw FilterError.cgImageCreationFailed
        }
        
        // Convert to UIImage and then to Data
        let finalUIImage = UIImage(cgImage: cgImage)
        guard let resultData = finalUIImage.jpegData(compressionQuality: 0.92) else {
            throw FilterError.dataConversionFailed
        }
        
        return resultData
    }
    
    // MARK: - Specific Filter Implementations
    private func applySpecificVintageFilter(_ filterType: VintageFilterType, to image: CIImage) throws -> CIImage {
        switch filterType {
        case .classic:
            return try applyClassicVintage(to: image)
        case .sepia:
            return try applySepiaVintage(to: image)
        case .film70s:
            return try apply70sFilm(to: image)
        case .polaroid:
            return try applyPolaroidEffect(to: image)
        case .faded:
            return try applyFadedGlory(to: image)
        case .warmGlow:
            return try applyWarmGlow(to: image)
        case .coolTone:
            return try applyCoolVintage(to: image)
        case .highContrast:
            return try applyHighContrastVintage(to: image)
        }
    }
    
    // MARK: - Classic Vintage Filter
    private func applyClassicVintage(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: Base vintage effect using PhotoEffectInstant
        if let photoEffect = CIFilter(name: "CIPhotoEffectInstant") {
            photoEffect.setValue(outputImage, forKey: kCIInputImageKey)
            if let result = photoEffect.outputImage {
                outputImage = result
            }
        }
        
        // Step 2: Color adjustments
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 0.7,
                                              brightness: 0.05,
                                              contrast: 1.15)
        
        // Step 3: Warm temperature
        outputImage = try applyTemperatureShift(to: outputImage,
                                              temperature: 5400,
                                              tint: 150)
        
        // Step 4: Add subtle vignette
        outputImage = try addVignette(to: outputImage, intensity: 0.3, radius: 1.5)
        
        return outputImage
    }
    
    // MARK: - Sepia Dreams Filter
    private func applySepiaVintage(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: Strong sepia tone
        if let sepiaFilter = CIFilter(name: "CISepiaTone") {
            sepiaFilter.setValue(outputImage, forKey: kCIInputImageKey)
            sepiaFilter.setValue(0.8, forKey: kCIInputIntensityKey)
            if let result = sepiaFilter.outputImage {
                outputImage = result
            }
        }
        
        // Step 2: Soft contrast
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 1.1,
                                              brightness: 0.08,
                                              contrast: 1.2)
        
        // Step 3: Add film grain
        outputImage = try addFilmGrain(to: outputImage, intensity: 0.05)
        
        // Step 4: Vintage vignette
        outputImage = try addVignette(to: outputImage, intensity: 0.4, radius: 1.2)
        
        return outputImage
    }
    
    // MARK: - 70s Film Filter
    private func apply70sFilm(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: Use PhotoEffectTransfer as base
        if let photoEffect = CIFilter(name: "CIPhotoEffectTransfer") {
            photoEffect.setValue(outputImage, forKey: kCIInputImageKey)
            if let result = photoEffect.outputImage {
                outputImage = result
            }
        }
        
        // Step 2: 70s color grading (more orange/teal)
        outputImage = try apply70sColorGrading(to: outputImage)
        
        // Step 3: Higher saturation and contrast
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 1.25,
                                              brightness: 0.02,
                                              contrast: 1.3)
        
        // Step 4: Film grain
        outputImage = try addFilmGrain(to: outputImage, intensity: 0.08)
        
        return outputImage
    }
    
    // MARK: - Polaroid Effect
    private func applyPolaroidEffect(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: Instant photo effect
        if let photoEffect = CIFilter(name: "CIPhotoEffectInstant") {
            photoEffect.setValue(outputImage, forKey: kCIInputImageKey)
            if let result = photoEffect.outputImage {
                outputImage = result
            }
        }
        
        // Step 2: Polaroid color characteristics
        outputImage = try applyPolaroidColors(to: outputImage)
        
        // Step 3: Soft, dreamy look
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 0.8,
                                              brightness: 0.12,
                                              contrast: 0.9)
        
        // Step 4: Strong vignette (Polaroid characteristic)
        outputImage = try addVignette(to: outputImage, intensity: 0.6, radius: 1.0)
        
        return outputImage
    }
    
    // MARK: - Faded Glory Filter
    private func applyFadedGlory(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: Fade effect using PhotoEffectFade
        if let photoEffect = CIFilter(name: "CIPhotoEffectFade") {
            photoEffect.setValue(outputImage, forKey: kCIInputImageKey)
            if let result = photoEffect.outputImage {
                outputImage = result
            }
        }
        
        // Step 2: Desaturated, faded look
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 0.5,
                                              brightness: 0.15,
                                              contrast: 0.8)
        
        // Step 3: Cool temperature for faded feel
        outputImage = try applyTemperatureShift(to: outputImage,
                                              temperature: 7000,
                                              tint: -50)
        
        // Step 4: Subtle vignette
        outputImage = try addVignette(to: outputImage, intensity: 0.25, radius: 2.0)
        
        return outputImage
    }
    
    // MARK: - Warm Glow Filter
    private func applyWarmGlow(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: Warm base
        outputImage = try applyTemperatureShift(to: outputImage,
                                              temperature: 4800,
                                              tint: 200)
        
        // Step 2: Glowing effect
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 1.1,
                                              brightness: 0.1,
                                              contrast: 1.1)
        
        // Step 3: Golden hour color grading
        outputImage = try applyGoldenHourColors(to: outputImage)
        
        // Step 4: Soft glow
        outputImage = try addSoftGlow(to: outputImage)
        
        return outputImage
    }
    
    // MARK: - Cool Vintage Filter
    private func applyCoolVintage(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: Cool temperature
        outputImage = try applyTemperatureShift(to: outputImage,
                                              temperature: 8000,
                                              tint: -100)
        
        // Step 2: Teal/cyan tinting
        outputImage = try applyCoolColorGrading(to: outputImage)
        
        // Step 3: Adjusted contrast
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 0.9,
                                              brightness: 0.03,
                                              contrast: 1.2)
        
        // Step 4: Subtle grain
        outputImage = try addFilmGrain(to: outputImage, intensity: 0.04)
        
        return outputImage
    }
    
    // MARK: - High Contrast Vintage
    private func applyHighContrastVintage(to image: CIImage) throws -> CIImage {
        var outputImage = image
        
        // Step 1: PhotoEffectNoir for dramatic base
        if let photoEffect = CIFilter(name: "CIPhotoEffectNoir") {
            photoEffect.setValue(outputImage, forKey: kCIInputImageKey)
            if let result = photoEffect.outputImage {
                outputImage = result
            }
        }
        
        // Step 2: High contrast settings
        outputImage = try applyColorAdjustments(to: outputImage,
                                              saturation: 0.6,
                                              brightness: 0.0,
                                              contrast: 1.8)
        
        // Step 3: Dramatic curves
        outputImage = try applyDramaticTones(to: outputImage)
        
        // Step 4: Strong vignette
        outputImage = try addVignette(to: outputImage, intensity: 0.5, radius: 1.3)
        
        return outputImage
    }
    
    // MARK: - Helper Methods
    private func applyColorAdjustments(to image: CIImage, saturation: Double, brightness: Double, contrast: Double) throws -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else {
            throw FilterError.coreImageFilterFailed
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(saturation, forKey: kCIInputSaturationKey)
        filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter.setValue(contrast, forKey: kCIInputContrastKey)
        
        guard let output = filter.outputImage else {
            throw FilterError.coreImageFilterFailed
        }
        
        return output
    }
    
    private func applyTemperatureShift(to image: CIImage, temperature: Double, tint: Double) throws -> CIImage {
        guard let filter = CIFilter(name: "CITemperatureAndTint") else {
            throw FilterError.coreImageFilterFailed
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
        filter.setValue(CIVector(x: temperature, y: tint), forKey: "inputTargetNeutral")
        
        guard let output = filter.outputImage else {
            throw FilterError.coreImageFilterFailed
        }
        
        return output
    }
    
    private func addVignette(to image: CIImage, intensity: Double, radius: Double) throws -> CIImage {
        guard let filter = CIFilter(name: "CIVignette") else {
            return image // Return original if vignette filter fails
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let output = filter.outputImage else {
            return image
        }
        
        return output
    }
    
    private func addFilmGrain(to image: CIImage, intensity: Double) throws -> CIImage {
        // Generate noise
        guard let noiseFilter = CIFilter(name: "CIRandomGenerator"),
              let noiseImage = noiseFilter.outputImage else {
            return image
        }
        
        // Scale and crop noise to match image
        let transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        let scaledNoise = noiseImage.transformed(by: transform)
        let croppedNoise = scaledNoise.cropped(to: image.extent)
        
        // Make noise grayscale
        guard let monoFilter = CIFilter(name: "CIColorMonochrome") else {
            return image
        }
        
        monoFilter.setValue(croppedNoise, forKey: kCIInputImageKey)
        monoFilter.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5), forKey: kCIInputColorKey)
        monoFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        
        guard let grainImage = monoFilter.outputImage else {
            return image
        }
        
        // Blend with original image
        guard let blendFilter = CIFilter(name: "CIMultiplyBlendMode") else {
            return image
        }
        
        // Adjust grain opacity
        guard let opacityFilter = CIFilter(name: "CIColorMatrix") else {
            return image
        }
        
        opacityFilter.setValue(grainImage, forKey: kCIInputImageKey)
        opacityFilter.setValue(CIVector(x: 1, y: 1, z: 1, w: intensity), forKey: "inputAVector")
        
        guard let adjustedGrain = opacityFilter.outputImage else {
            return image
        }
        
        blendFilter.setValue(adjustedGrain, forKey: kCIInputImageKey)
        blendFilter.setValue(image, forKey: kCIInputBackgroundImageKey)
        
        guard let output = blendFilter.outputImage else {
            return image
        }
        
        return output
    }
    
    private func apply70sColorGrading(to image: CIImage) throws -> CIImage {
        guard let filter = CIFilter(name: "CIColorMatrix") else {
            return image
        }
        
        // Orange/teal color grading typical of 70s
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 1.1, y: 0.05, z: 0.0, w: 0), forKey: "inputRVector")
        filter.setValue(CIVector(x: 0.02, y: 1.0, z: 0.02, w: 0), forKey: "inputGVector")
        filter.setValue(CIVector(x: 0.0, y: 0.1, z: 1.2, w: 0), forKey: "inputBVector")
        filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        filter.setValue(CIVector(x: 0.02, y: -0.01, z: -0.02, w: 0), forKey: "inputBiasVector")
        
        guard let output = filter.outputImage else {
            return image
        }
        
        return output
    }
    
    private func applyPolaroidColors(to image: CIImage) throws -> CIImage {
        guard let filter = CIFilter(name: "CIColorMatrix") else {
            return image
        }
        
        // Polaroid characteristic color response
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 1.05, y: 0.02, z: 0.01, w: 0), forKey: "inputRVector")
        filter.setValue(CIVector(x: 0.01, y: 0.95, z: 0.01, w: 0), forKey: "inputGVector")
        filter.setValue(CIVector(x: 0.02, y: 0.05, z: 1.1, w: 0), forKey: "inputBVector")
        filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        filter.setValue(CIVector(x: 0.03, y: 0.02, z: 0.01, w: 0), forKey: "inputBiasVector")
        
        guard let output = filter.outputImage else {
            return image
        }
        
        return output
    }
    
    private func applyGoldenHourColors(to image: CIImage) throws -> CIImage {
        guard let filter = CIFilter(name: "CIColorMatrix") else {
            return image
        }
        
        // Golden hour color grading
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 1.15, y: 0.05, z: 0.0, w: 0), forKey: "inputRVector")
        filter.setValue(CIVector(x: 0.05, y: 1.05, z: 0.0, w: 0), forKey: "inputGVector")
        filter.setValue(CIVector(x: 0.0, y: 0.02, z: 0.9, w: 0), forKey: "inputBVector")
        filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        filter.setValue(CIVector(x: 0.05, y: 0.03, z: 0.0, w: 0), forKey: "inputBiasVector")
        
        guard let output = filter.outputImage else {
            return image
        }
        
        return output
    }
    
    private func applyCoolColorGrading(to image: CIImage) throws -> CIImage {
        guard let filter = CIFilter(name: "CIColorMatrix") else {
            return image
        }
        
        // Cool teal/cyan grading
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0.95, y: 0.0, z: 0.02, w: 0), forKey: "inputRVector")
        filter.setValue(CIVector(x: 0.0, y: 1.05, z: 0.05, w: 0), forKey: "inputGVector")
        filter.setValue(CIVector(x: 0.05, y: 0.1, z: 1.15, w: 0), forKey: "inputBVector")
        filter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        filter.setValue(CIVector(x: -0.02, y: 0.01, z: 0.05, w: 0), forKey: "inputBiasVector")
        
        guard let output = filter.outputImage else {
            return image
        }
        
        return output
    }
    
    private func addSoftGlow(to image: CIImage) throws -> CIImage {
        // Create a blurred version for the glow
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            return image
        }
        
        blurFilter.setValue(image, forKey: kCIInputImageKey)
        blurFilter.setValue(5.0, forKey: kCIInputRadiusKey)
        
        guard let blurredImage = blurFilter.outputImage else {
            return image
        }
        
        // Blend the blurred version with the original using soft light
        guard let blendFilter = CIFilter(name: "CISoftLightBlendMode") else {
            return image
        }
        
        blendFilter.setValue(blurredImage, forKey: kCIInputImageKey)
        blendFilter.setValue(image, forKey: kCIInputBackgroundImageKey)
        
        guard let output = blendFilter.outputImage else {
            return image
        }
        
        return output
    }
    
    private func applyDramaticTones(to image: CIImage) throws -> CIImage {
        guard let filter = CIFilter(name: "CIHighlightShadowAdjust") else {
            return image
        }
        
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0.7, forKey: "inputHighlightAmount")  // Compress highlights
        filter.setValue(1.3, forKey: "inputShadowAmount")     // Lift shadows
        filter.setValue(1.0, forKey: "inputRadius")
        
        guard let output = filter.outputImage else {
            return image
        }
        
        return output
    }
}

// MARK: - Lightweight Implementation
extension VintageFilterService {
    /// Simplified version for faster processing
    func applyLightweightVintageFilter(_ filterType: VintageFilterType, to imageData: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try self.processImageLightweight(filterType, imageData: imageData)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func processImageLightweight(_ filterType: VintageFilterType, imageData: Data) throws -> Data {
        guard let uiImage = UIImage(data: imageData),
              let ciImage = CIImage(image: uiImage) else {
            throw FilterError.invalidInputData
        }
        
        var outputImage = ciImage
        
        // Apply basic effect based on filter type
        switch filterType {
        case .classic, .warmGlow:
            if let effect = CIFilter(name: "CIPhotoEffectInstant") {
                effect.setValue(outputImage, forKey: kCIInputImageKey)
                if let result = effect.outputImage { outputImage = result }
            }
        case .sepia:
            if let effect = CIFilter(name: "CISepiaTone") {
                effect.setValue(outputImage, forKey: kCIInputImageKey)
                effect.setValue(0.8, forKey: kCIInputIntensityKey)
                if let result = effect.outputImage { outputImage = result }
            }
        case .film70s:
            if let effect = CIFilter(name: "CIPhotoEffectTransfer") {
                effect.setValue(outputImage, forKey: kCIInputImageKey)
                if let result = effect.outputImage { outputImage = result }
            }
        case .polaroid:
            if let effect = CIFilter(name: "CIPhotoEffectInstant") {
                effect.setValue(outputImage, forKey: kCIInputImageKey)
                if let result = effect.outputImage { outputImage = result }
            }
        case .faded:
            if let effect = CIFilter(name: "CIPhotoEffectFade") {
                effect.setValue(outputImage, forKey: kCIInputImageKey)
                if let result = effect.outputImage { outputImage = result }
            }
        case .coolTone:
            if let temp = CIFilter(name: "CITemperatureAndTint") {
                temp.setValue(outputImage, forKey: kCIInputImageKey)
                temp.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
                temp.setValue(CIVector(x: 8000, y: -100), forKey: "inputTargetNeutral")
                if let result = temp.outputImage { outputImage = result }
            }
        case .highContrast:
            if let effect = CIFilter(name: "CIPhotoEffectNoir") {
                effect.setValue(outputImage, forKey: kCIInputImageKey)
                if let result = effect.outputImage { outputImage = result }
            }
        }
        
        // Basic color adjustments
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(outputImage, forKey: kCIInputImageKey)
            colorControls.setValue(0.85, forKey: kCIInputSaturationKey)
            colorControls.setValue(0.05, forKey: kCIInputBrightnessKey)
            colorControls.setValue(1.1, forKey: kCIInputContrastKey)
            
            if let result = colorControls.outputImage {
                outputImage = result
            }
        }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw FilterError.cgImageCreationFailed
        }
        
        let finalUIImage = UIImage(cgImage: cgImage)
        guard let resultData = finalUIImage.jpegData(compressionQuality: 0.9) else {
            throw FilterError.dataConversionFailed
        }
        
        return resultData
    }
}
