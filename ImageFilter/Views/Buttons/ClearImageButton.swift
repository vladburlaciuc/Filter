//
//  ClearImageButton.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct ClearImageButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                
                Text("Clear Image")
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(.systemGray5))
            .foregroundColor(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    ClearImageButton(action: {})
        .padding()
}
