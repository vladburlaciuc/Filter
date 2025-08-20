//
//  ContentView.swift
//  ImageFilter
//
//  Created by Vlad on 19.08.2025.
//
// Views/ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImageFilterViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderView()
                    
                    ImageDisplayView(
                        displayImage: viewModel.displayImage,
                        isProcessing: viewModel.isProcessing || viewModel.isSaving
                    )
                    
                    ControlsView(viewModel: viewModel)
                    
                    if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage) {
                            viewModel.errorMessage = nil
                        }
                    }
                    
                    if let successMessage = viewModel.successMessage {
                        PathDisplayView(
                            message: successMessage,
                            onDismiss: {
                                viewModel.successMessage = nil
                            },
                            onCopyPath: viewModel.tempImagePath != nil ? {
                                viewModel.copyPathToClipboard()
                            } : nil
                        )
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents split view on iPad
    }
}

#Preview {
    ContentView()
}
