//
//  PathDisplayView.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct PathDisplayView: View {
    let message: String
    let onDismiss: () -> Void
    let onCopyPath: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Image Saved!")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("×") {
                    onDismiss()
                }
                .font(.title2)
                .foregroundColor(.secondary)
            }
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .textSelection(.enabled) // Allows text selection for copying
            
            if onCopyPath != nil {
                Button("Copy Path to Clipboard") {
                    onCopyPath?()
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    PathDisplayView(
        message: "✅ Saved to Photos\n📁 Temp file: CPM35_1234567890_ABC123.jpg\n📍 Path: /tmp/CPM35_1234567890_ABC123.jpg",
        onDismiss: {},
        onCopyPath: {}
    )
    .padding()
}
