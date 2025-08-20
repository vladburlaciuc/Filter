//
//  SaveImageButton.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct SaveImageButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Save to Photos")
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? Color.green : Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

#Preview {
    VStack {
        SaveImageButton(action: {}, isEnabled: true)
        SaveImageButton(action: {}, isEnabled: false)
    }
    .padding()
}
