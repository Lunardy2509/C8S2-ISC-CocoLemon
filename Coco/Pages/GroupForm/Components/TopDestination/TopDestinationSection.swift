//
//  TopDestinationSection.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import SwiftUI

struct TopDestinationSection: View {
    @StateObject private var viewModel = TopDestinationViewModel()
    let onDestinationTap: (TopDestinationCardDataModel, TopDestinationViewModel) -> Void
    let onAddDestinationTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Title
            HStack {
                Text("Place Recommendation")
                    .font(.jakartaSans(forTextStyle: .headline, weight: .semibold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                
                Spacer()
            }
            
            if viewModel.topDestinations.isEmpty {
                // Empty state
                VStack {
                    Image(systemName: "location.slash")
                        .font(.system(size: 32))
                        .foregroundColor(Token.grayscale50.toColor())
                    
                    Text("No Internet Connection")
                        .font(.jakartaSans(forTextStyle: .caption1, weight: .medium))
                        .foregroundColor(Token.grayscale70.toColor())
                        .padding(.top, 8)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            } else {
                // Destination cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Top destination cards
                        ForEach(viewModel.topDestinations) { destination in
                            TopDestinationCard(
                                destination: destination,
                                onTap: {
                                    onDestinationTap(destination, viewModel)
                                }
                            )
                            .frame(width: 280, height: 120)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.horizontal, -12)
            }
        }
        .onAppear {
            if viewModel.topDestinations.isEmpty {
                viewModel.fetchTopDestinations()
            }
        }
    }
}
