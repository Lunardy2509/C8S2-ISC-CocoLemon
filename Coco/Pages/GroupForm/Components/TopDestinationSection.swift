//
//  TopDestinationSection.swift
//  Coco
//
//  Created by GitHub Copilot on 26/08/25.
//

import SwiftUI

struct TopDestinationSection: View {
    @StateObject private var viewModel = TopDestinationViewModel()
    let onDestinationTap: (TopDestinationCardDataModel) -> Void
    let onAddDestinationTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title
            HStack {
                Text("Place Recommendation")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.topDestinations.isEmpty {
                // Empty state
                VStack {
                    Image(systemName: "location.slash")
                        .font(.system(size: 32))
                        .foregroundColor(Token.grayscale50.toColor())
                    
                    Text("No destinations available")
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
                                    onDestinationTap(destination)
                                }
                            )
                            .frame(width: 280, height: 120)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24)
            }
        }
        .onAppear {
            if viewModel.topDestinations.isEmpty {
                viewModel.fetchTopDestinations()
            }
        }
    }
}
