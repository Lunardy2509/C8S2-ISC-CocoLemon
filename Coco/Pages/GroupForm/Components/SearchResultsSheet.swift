//
//  SearchResultsSheet.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import SwiftUI

struct SearchResultsSheet: View {
    let searchResults: [HomeActivityCellDataModel]
    let searchQuery: String
    let onResultSelected: (HomeActivityCellDataModel) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Results")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Found \(searchResults.count) results for '\(searchQuery)'")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Search Results List - Single Column
                ScrollView {
                    ResultsListView(searchResults: searchResults, onResultSelected: onResultSelected)
                }
            }
            .background(Color.white)
        }
    }
}

struct ResultsListView: View {
    let searchResults: [HomeActivityCellDataModel]
    let onResultSelected: (HomeActivityCellDataModel) -> Void
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(searchResults, id: \.id) { result in
                SearchResultActivityCard(
                    dataModel: result,
                    onTap: {
                        onResultSelected(result)
                    }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

struct SearchResultActivityCard: View {
    let dataModel: HomeActivityCellDataModel
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            AsyncImage(url: dataModel.imageUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 89, height: 106)
            .clipped()
            .cornerRadius(14)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.gray)
                    
                    Text(dataModel.location)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Title
                Text(dataModel.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Price
                HStack {
                    Text(dataModel.priceText)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("/Person")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    SearchResultsSheet(
        searchResults: [],
        searchQuery: "Nonexistent Place",
        onResultSelected: { _ in },
        onDismiss: {}
    )
}
