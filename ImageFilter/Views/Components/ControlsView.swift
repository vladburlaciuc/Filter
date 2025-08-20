//
//  VintageControlsView.swift
//  ImageFilter
//
//  Created by Vlad on 20.08.2025.
//

import SwiftUI

struct ControlsView: View {
    @ObservedObject var viewModel: ImageFilterViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Photo Selection
            PhotoSelectionButton(selectedItem: $viewModel.selectedPhotoItem)
            
            if viewModel.hasOriginalImage {
                // Filter Selection
                FilterSelectionView(viewModel: viewModel)
                
                // Main Action Buttons
                HStack(spacing: 12) {
                    ApplyFilterButton(
                        action: viewModel.applyFilter,
                        isEnabled: viewModel.canApplyFilter,
                        filterName: viewModel.selectedFilterType.rawValue
                    )
                    
                    if viewModel.hasFilteredImage {
                        ResetButton(action: viewModel.resetFilter)
                    }
                }
                
                // Save Controls
                if viewModel.hasFilteredImage {
                    VStack(spacing: 8) {
                        SaveImageButton(
                            action: viewModel.saveImageToPhotos,
                            isEnabled: viewModel.canSaveImage
                        )
                    }
                }
                
                ClearImageButton(action: viewModel.clearImage)
            }
        }
    }
}

// MARK: - Filter Selection View
struct FilterSelectionView: View {
    @ObservedObject var viewModel: ImageFilterViewModel
    @State private var showingFilterPicker = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Current Filter Display
            VStack(spacing: 4) {
                Text("Current Filter")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: { showingFilterPicker.toggle() }) {
                    HStack {
                        Text(viewModel.getFilterEmoji(viewModel.selectedFilterType))
                        Text(viewModel.selectedFilterType.rawValue)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .foregroundColor(.primary)
                
                Text(viewModel.getFilterDescription(viewModel.selectedFilterType))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Quick Navigation Buttons
            HStack(spacing: 16) {
                Button(action: viewModel.selectPreviousFilter) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
                .disabled(!viewModel.canApplyFilter)
                
                Button(action: viewModel.selectNextFilter) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
                .disabled(!viewModel.canApplyFilter)
            }
        }
        .sheet(isPresented: $showingFilterPicker) {
            FilterPickerSheet(viewModel: viewModel)
        }
    }
}

// MARK: - Filter Picker Sheet
struct FilterPickerSheet: View {
    @ObservedObject var viewModel: ImageFilterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150), spacing: 12)
                ], spacing: 12) {
                    ForEach(viewModel.availableFilters, id: \.self) { filter in
                        FilterCard(
                            filter: filter,
                            isSelected: viewModel.isFilterSelected(filter),
                            emoji: viewModel.getFilterEmoji(filter),
                            description: viewModel.getFilterDescription(filter)
                        ) {
                            viewModel.changeFilterType(filter)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Filter")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Card
struct FilterCard: View {
    let filter: VintageFilterService.VintageFilterType
    let isSelected: Bool
    let emoji: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.largeTitle)
                
                Text(filter.rawValue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .foregroundColor(.primary)
    }
}

