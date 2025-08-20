//
//  UIImage+Extensions.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import UIKit

extension UIImage {
    /// Resize image to specified size while maintaining aspect ratio
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Resize image to fit within maximum dimensions
    func resizedToFit(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        var newSize: CGSize
        
        if self.size.width > self.size.height {
            // Landscape
            newSize = CGSize(width: min(maxWidth, self.size.width),
                           height: min(maxWidth / aspectRatio, maxHeight))
        } else {
            // Portrait or square
            newSize = CGSize(width: min(maxHeight * aspectRatio, maxWidth),
                           height: min(maxHeight, self.size.height))
        }
        
        return resized(to: newSize)
    }
    
    /// Get optimized JPEG data for storage/transmission
    var optimizedJPEGData: Data? {
        let maxDimension: CGFloat = 2048
        let resizedImage = self.resizedToFit(maxWidth: maxDimension, maxHeight: maxDimension)
        return resizedImage?.jpegData(compressionQuality: 0.8)
    }
    
    /// Create thumbnail image
    func thumbnail(size: CGFloat = 150) -> UIImage? {
        return resized(to: CGSize(width: size, height: size))
    }
}
