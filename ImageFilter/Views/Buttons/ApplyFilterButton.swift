//
//  ApplyFilterButton.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct ApplyFilterButton: View {
    let action: () -> Void
    let isEnabled: Bool
    let filterName: String
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "wand.and.stars")
                Text("Apply \(filterName)")
                    .lineLimit(1)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.accentColor : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}
