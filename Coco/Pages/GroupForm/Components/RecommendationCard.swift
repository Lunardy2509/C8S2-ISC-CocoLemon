//
//  RecommendationCard.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import SwiftUI

struct RecommendationCard: View {
    let recommendation: GroupFormRecommendationDataModel?
    let isSelected: Bool
    let onTap: () -> Void
    let onDismiss: (() -> Void)?
    
    init(
        recommendation: GroupFormRecommendationDataModel? = nil,
        isSelected: Bool = false,
        onTap: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.recommendation = recommendation
        self.isSelected = isSelected
        self.onTap = onTap
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        if let recommendation = recommendation, isSelected {
            // Selected state - show destination card with X button
            selectedDestinationCard(recommendation: recommendation)
        } else {
            // Add state - show plus button
            addDestinationCard()
        }
    }
    
    @ViewBuilder
    private func selectedDestinationCard(recommendation: GroupFormRecommendationDataModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                // Destination Image
                AsyncImage(url: recommendation.imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Token.grayscale30.toColor())
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // X button to dismiss
                Button {
                    onDismiss?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 24, height: 24)
                        )
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Token.grayscale70.toColor())
                    
                    Text(recommendation.location)
                        .font(.jakartaSans(forTextStyle: .caption1, weight: .regular))
                        .foregroundColor(Token.grayscale90.toColor())
                    
                    Spacer()
                }
                
                // Title
                Text(recommendation.title)
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .bold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Price
                HStack {
                    Text(recommendation.priceText)
                        .font(.jakartaSans(forTextStyle: .caption1, weight: .bold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                    
                    Text("/Person")
                        .font(.jakartaSans(forTextStyle: .caption1, weight: .medium))
                        .foregroundColor(Token.grayscale70.toColor())
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    @ViewBuilder
    private func addDestinationCard() -> some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Spacer()
                
                // Plus icon
                Circle()
                    .fill(Token.mainColorPrimary.toColor())
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    )
                
                Text("Add Destination")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                    .foregroundColor(Token.grayscale70.toColor())
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Token.grayscale30.toColor(), lineWidth: 1)
        )
    }
}
