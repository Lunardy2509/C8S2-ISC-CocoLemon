//
//  TopDestinationCard.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import SwiftUI

struct TopDestinationCard: View {
    let destination: TopDestinationCardDataModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                // Destination Image
                AsyncImage(url: destination.imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Token.grayscale30.toColor())
                }
                .frame(width: 92, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    // Activity title
                    Text(destination.title)
                        .font(.jakartaSans(forTextStyle: .title3, weight: .bold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .multilineTextAlignment(.leading)
                    
                    // Location with pin icon
                    HStack(spacing: 4) {
                        Image(uiImage: CocoIcon.icPinPointBlack.image)
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Text(destination.location)
                            .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                            .foregroundColor(Token.grayscale70.toColor())
                    }
                    
                    // Price range
                    Text(destination.priceText)
                        .font(.jakartaSans(forTextStyle: .caption2, weight: .semibold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    onTap()
                }, label: {
                    ZStack {
                        Circle()
                            .fill(Token.mainColorPrimary.toColor())
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Token.additionalColorsWhite.toColor())
                    }
                })
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Token.additionalColorsWhite.toColor())
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Token.additionalColorsLine.toColor(), lineWidth: 1)
        )
    }
}

struct TopDestinationCardDataModel: Hashable, Identifiable {
    let id: Int
    let title: String
    let location: String
    let priceText: String
    let imageUrl: URL?
    
    init(id: Int, title: String, location: String, priceText: String, imageUrl: URL?) {
        self.id = id
        self.title = title
        self.location = location
        self.priceText = priceText
        self.imageUrl = imageUrl
    }
}
