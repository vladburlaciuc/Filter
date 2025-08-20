//
//  HeaderView.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("CPM35 Filter Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Vintage Film Effect")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.top, 8)
        }
    }
}

#Preview {
    HeaderView()
        .padding()
}
