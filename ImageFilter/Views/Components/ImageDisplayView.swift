//
//  ImageDisplayView.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct ImageDisplayView: View {
    let displayImage: UIImage?
    let isProcessing: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .frame(height: 400)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )
            
            if let displayImage = displayImage {
                Image(uiImage: displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            } else {
                PlaceholderView()
            }
            
            if isProcessing {
                ProcessingOverlay()
            }
        }
    }
}

#Preview {
    VStack {
        ImageDisplayView(displayImage: nil, isProcessing: false)
        ImageDisplayView(displayImage: nil, isProcessing: true)
    }
    .padding()
}
