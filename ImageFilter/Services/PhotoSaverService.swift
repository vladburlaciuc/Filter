//
//  PhotoSaverService.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import UIKit
import Photos

class PhotoSaverService: NSObject {
    enum SaveError: Error, LocalizedError {
        case noImage
        case permissionDenied
        case saveFailed(Error)
        case tempSaveFailed(Error)
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .noImage:
                return "No image to save"
            case .permissionDenied:
                return "Permission denied. Please allow access to Photos in Settings."
            case .saveFailed(let error):
                return "Failed to save image: \(error.localizedDescription)"
            case .tempSaveFailed(let error):
                return "Failed to save to temporary folder: \(error.localizedDescription)"
            case .unknownError:
                return "Unknown error occurred while saving"
            }
        }
    }
    
    struct SaveResult {
        let photosSuccess: Bool
        let tempPath: String?
        let tempFilename: String?
    }
    
    func saveImageToPhotosAndTemp(_ image: UIImage) async throws -> SaveResult {
        // Save to temporary folder first
        let tempResult = try await saveImageToTempFolder(image)
        
        // Then try to save to Photos
        var photosSuccess = false
        do {
            try await saveImageToPhotos(image)
            photosSuccess = true
        } catch {
            // Photos save failed, but temp save succeeded
            print("Photos save failed: \(error), but temp save succeeded at: \(tempResult.path)")
        }
        
        return SaveResult(
            photosSuccess: photosSuccess,
            tempPath: tempResult.path,
            tempFilename: tempResult.filename
        )
    }
    
    private func saveImageToTempFolder(_ image: UIImage) async throws -> (path: String, filename: String) {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                do {
                    // Generate random filename
                    let timestamp = Date().timeIntervalSince1970
                    let randomID = UUID().uuidString.prefix(8)
                    let filename = "CPM35_\(Int(timestamp))_\(randomID).jpg"
                    
                    // Get temporary directory
                    let tempDir = FileManager.default.temporaryDirectory
                    let fileURL = tempDir.appendingPathComponent(filename)
                    
                    // Convert image to JPEG data
                    guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                        continuation.resume(throwing: SaveError.tempSaveFailed(NSError(domain: "ImageConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"])))
                        return
                    }
                    
                    // Write to file
                    try imageData.write(to: fileURL)
                    
                    let result = (path: fileURL.path, filename: filename)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: SaveError.tempSaveFailed(error))
                }
            }
        }
    }
    func saveImageToPhotos(_ image: UIImage) async throws {
        // Check authorization status
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .notDetermined:
            // Request permission
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if newStatus != .authorized {
                throw SaveError.permissionDenied
            }
        case .denied, .restricted:
            throw SaveError.permissionDenied
        case .authorized, .limited:
            break
        @unknown default:
            throw SaveError.unknownError
        }
        
        // Save the image
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: SaveError.saveFailed(error))
                } else {
                    continuation.resume(throwing: SaveError.unknownError)
                }
            }
        }
    }
    
    func checkPhotoLibraryPermission() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }
    
    func cleanupTempFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let cpm35Files = tempFiles.filter { $0.lastPathComponent.hasPrefix("CPM35_") }
            
            for file in cpm35Files {
                try? FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Failed to cleanup temp files: \(error)")
        }
    }
}
