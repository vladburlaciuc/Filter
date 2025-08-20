//
//  FilteredImageModel.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import UIKit

struct FilteredImageModel {
    let originalImageData: Data
    let filteredImageData: Data?
    let isProcessing: Bool
    
    init(originalImageData: Data, filteredImageData: Data? = nil, isProcessing: Bool = false) {
        self.originalImageData = originalImageData
        self.filteredImageData = filteredImageData
        self.isProcessing = isProcessing
    }
    
    var originalImage: UIImage? {
        UIImage(data: originalImageData)
    }
    
    var filteredImage: UIImage? {
        guard let data = filteredImageData else { return nil }
        return UIImage(data: data)
    }
    
    var displayImage: UIImage? {
        filteredImage ?? originalImage
    }
}
