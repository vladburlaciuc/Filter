//
//  ProcessingOverlay.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct ProcessingOverlay: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .frame(width: 120, height: 120)
            
            VStack(spacing: 12) {
                Image(systemName: "camera.filters")
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .rotationEffect(.degrees(rotation))
                    .animation(
                        .linear(duration: 2)
                        .repeatForever(autoreverses: false),
                        value: rotation
                    )
                
                Text("Applying Filter...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            rotation = 360
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()
        
        ProcessingOverlay()
    }
}
