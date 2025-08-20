//
//  PlaceholderView.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text("No Image Selected")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Choose a photo to apply the vintage filter")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlaceholderView()
        .frame(height: 400)
        .background(Color(.systemGray6))
}
