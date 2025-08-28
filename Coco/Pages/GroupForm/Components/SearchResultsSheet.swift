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
                            .font(.jakartaSans(forTextStyle: .title1, weight: .bold))
                            .fontWeight(.bold)
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .padding(.top, 10)
                        
                        Text("Found \(searchResults.count) results for '\(searchQuery)'")
                            .font(.jakartaSans(forTextStyle: .subheadline, weight: .regular))
                            .foregroundColor(Token.grayscale60.toColor())
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
                // Title
                Text(dataModel.title)
                    .font(.jakartaSans(forTextStyle: .headline, weight: .bold))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(4)
                
                // Location
                HStack(spacing: 4) {
                    Image(uiImage: CocoIcon.icPinPointBlack.image)
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                    
                    Text(dataModel.location)
                        .font(.jakartaSans(forTextStyle: .footnote, weight: .regular))
                        .foregroundColor(Token.grayscale90.toColor())
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(4)
                
                // Price
                HStack {
                    Text("\(dataModel.priceText)/Person")
                        .font(.jakartaSans(forTextStyle: .caption2, weight: .bold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .lineLimit(1)
                }
                .padding(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Token.additionalColorsWhite.toColor())
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
