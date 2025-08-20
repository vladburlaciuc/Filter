//
//  ResetButton.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct ResetButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
                
                Text("Reset")
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(width: 80, height: 50)
            .background(Color(.systemGray))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    ResetButton(action: {})
        .padding()
}
