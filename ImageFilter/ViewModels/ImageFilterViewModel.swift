//
//  ImageFilterViewModel.swift
//  ImageFilter
//
//  Created by Vlad on 20.08.2025.
//

import SwiftUI
import Combine
import PhotosUI

@MainActor
class ImageFilterViewModel: ObservableObject {
    @Published var imageModel: FilteredImageModel?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedFilterType: VintageFilterService.VintageFilterType = .classic
    @Published var isProcessing = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var tempImagePath: String?
    
    private let filterService = VintageFilterService()
    private let photoSaver = PhotoSaverService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupPhotoItemObserver()
    }
    
    // MARK: - Computed Properties
    var displayImage: UIImage? {
        imageModel?.displayImage
    }
    
    var hasOriginalImage: Bool {
        imageModel != nil
    }
    
    var hasFilteredImage: Bool {
        imageModel?.filteredImageData != nil
    }
    
    var canApplyFilter: Bool {
        hasOriginalImage && !isProcessing && !isSaving
    }
    
    var canSaveImage: Bool {
        hasFilteredImage && !isProcessing && !isSaving
    }
    
    var availableFilters: [VintageFilterService.VintageFilterType] {
        VintageFilterService.VintageFilterType.allCases
    }
    
    // MARK: - Public Methods
    func applyFilter() {
        guard let imageData = imageModel?.originalImageData else { return }
        
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                let filteredData = try await filterService.applyVintageFilter(selectedFilterType, to: imageData)
                
                await MainActor.run {
                    if let currentModel = self.imageModel {
                        self.imageModel = FilteredImageModel(
                            originalImageData: currentModel.originalImageData,
                            filteredImageData: filteredData,
                            isProcessing: false
                        )
                    }
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    self.errorMessage = "Failed to apply \(selectedFilterType.rawValue) filter: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func applyLightweightFilter() {
        guard let imageData = imageModel?.originalImageData else { return }
        
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                let filteredData = try await filterService.applyLightweightVintageFilter(selectedFilterType, to: imageData)
                
                await MainActor.run {
                    if let currentModel = self.imageModel {
                        self.imageModel = FilteredImageModel(
                            originalImageData: currentModel.originalImageData,
                            filteredImageData: filteredData,
                            isProcessing: false
                        )
                    }
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    self.errorMessage = "Failed to apply \(selectedFilterType.rawValue) filter: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func changeFilterType(_ newFilterType: VintageFilterService.VintageFilterType) {
        selectedFilterType = newFilterType
        
        // Auto-apply filter if we have an image and aren't processing
        if canApplyFilter {
            applyFilter()
        }
    }
    
    func copyPathToClipboard() {
        guard let tempImagePath = tempImagePath else { return }
        
        #if os(iOS)
        UIPasteboard.general.string = tempImagePath
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(tempImagePath, forType: .string)
        #endif
        
        // Update success message to show path was copied
        successMessage = "📋 Path copied to clipboard!\n📁 \(tempImagePath)"
    }
    
    func resetFilter() {
        guard let originalData = imageModel?.originalImageData else { return }
        imageModel = FilteredImageModel(originalImageData: originalData)
        errorMessage = nil
    }
    
    func clearImage() {
        imageModel = nil
        selectedPhotoItem = nil
        errorMessage = nil
        successMessage = nil
        tempImagePath = nil
    }
    
    func saveImageToPhotos() {
        guard let filteredImage = imageModel?.filteredImage else {
            errorMessage = "No filtered image to save"
            return
        }
        
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let result = try await photoSaver.saveImageToPhotosAndTemp(filteredImage)
                
                await MainActor.run {
                    self.isSaving = false
                    
                    // Store temp path for clipboard copying
                    self.tempImagePath = result.tempPath
                    
                    var message = ""
                    if result.photosSuccess {
                        message = "✅ Saved to Photos"
                    } else {
                        message = "⚠️ Photos save failed, but saved to temp"
                    }
                    
                    if let tempPath = result.tempPath, let filename = result.tempFilename {
                        message += "\n📁 Temp file: \(filename)\n📂 Path: \(tempPath)"
                    }
                    
                    message += "\n🎨 Filter: \(self.selectedFilterType.rawValue)"
                    
                    self.successMessage = message
                    
                    // Print to console for easy copying
                    if let tempPath = result.tempPath {
                        print("🖼️ Vintage Filtered Image Saved:")
                        print("🎨 Filter: \(self.selectedFilterType.rawValue)")
                        print("📂 Full Path: \(tempPath)")
                        print("📁 Filename: \(result.tempFilename ?? "Unknown")")
                    }
                    
                    // Clear success message after 10 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.successMessage = nil
                        self.tempImagePath = nil
                    }
                }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Filter Preview Methods
    func getFilterPreviewName(_ filterType: VintageFilterService.VintageFilterType) -> String {
        filterType.rawValue
    }
    
    func getFilterDescription(_ filterType: VintageFilterService.VintageFilterType) -> String {
        switch filterType {
        case .classic:
            return "Timeless vintage look with warm tones"
        case .sepia:
            return "Classic sepia tones with soft contrast"
        case .film70s:
            return "Retro 70s film aesthetic with orange/teal grading"
        case .polaroid:
            return "Instant camera feel with dreamy colors"
        case .faded:
            return "Sun-bleached, faded memories effect"
        case .warmGlow:
            return "Golden hour warmth with soft glow"
        case .coolTone:
            return "Cool, moody teal and cyan tones"
        case .highContrast:
            return "Dramatic black and white vintage"
        }
    }
    
    func getFilterEmoji(_ filterType: VintageFilterService.VintageFilterType) -> String {
        switch filterType {
        case .classic:
            return "📷"
        case .sepia:
            return "🤎"
        case .film70s:
            return "🕺"
        case .polaroid:
            return "📸"
        case .faded:
            return "☀️"
        case .warmGlow:
            return "🌅"
        case .coolTone:
            return "🌊"
        case .highContrast:
            return "⚫"
        }
    }
    
    // MARK: - Private Methods
    private func setupPhotoItemObserver() {
        $selectedPhotoItem
            .compactMap { $0 }
            .sink { [weak self] photoItem in
                self?.loadImageData(from: photoItem)
            }
            .store(in: &cancellables)
    }
    
    private func loadImageData(from photoItem: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await photoItem.loadTransferable(type: Data.self) else {
                    await MainActor.run {
                        self.errorMessage = "Failed to load image data"
                    }
                    return
                }
                
                // Validate that it's a valid image
                guard UIImage(data: data) != nil else {
                    await MainActor.run {
                        self.errorMessage = "Invalid image format"
                    }
                    return
                }
                
                await MainActor.run {
                    self.imageModel = FilteredImageModel(originalImageData: data)
                    self.errorMessage = nil
                    
                    // Auto-apply the selected filter to the new image
                    if self.canApplyFilter {
                        self.applyFilter()
                    }
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Filter Selection Helpers
extension ImageFilterViewModel {
    func selectNextFilter() {
        let currentIndex = availableFilters.firstIndex(of: selectedFilterType) ?? 0
        let nextIndex = (currentIndex + 1) % availableFilters.count
        changeFilterType(availableFilters[nextIndex])
    }
    
    func selectPreviousFilter() {
        let currentIndex = availableFilters.firstIndex(of: selectedFilterType) ?? 0
        let previousIndex = currentIndex == 0 ? availableFilters.count - 1 : currentIndex - 1
        changeFilterType(availableFilters[previousIndex])
    }
    
    func isFilterSelected(_ filterType: VintageFilterService.VintageFilterType) -> Bool {
        selectedFilterType == filterType
    }
}
