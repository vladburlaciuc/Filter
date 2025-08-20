//
//  PhotoSelectionButton.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI
import PhotosUI

struct PhotoSelectionButton: View {
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Select Photo")
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    PhotoSelectionButton(selectedItem: .constant(nil))
        .padding()
}
