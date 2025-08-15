//
//  HomeAppliedFilterCarouselView.swift
//  Coco
//
//  Created by AI Assistant on 14/08/25.
//

import Foundation
import SwiftUI

struct HomeAppliedFilterCarouselView: View {
    let appliedFilters: [HomeFilterPillState]
    let isPriceRangeApplied: Bool
    let onFilterDismiss: (Int) -> Void
    let onResetAll: () -> Void
    
    var body: some View {
        if !appliedFilters.isEmpty || isPriceRangeApplied {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.0) {
                    // Reset All Button - X mark with text label
                    Button(action: {
                        withAnimation {
                            onResetAll()
                        }
                    }) {
                        HStack(spacing: 8.0) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Token.grayscale70.toColor())
                            
                            Text("Reset Filters")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Token.grayscale70.toColor())
                        }
                        .padding(.horizontal, 12.0)
                        .padding(.vertical, 8.0)
                        .background(Token.grayscale20.toColor())
                        .clipShape(Capsule())
                    }
                    
                    ForEach(appliedFilters, id: \.id) { filter in
                        HomeFilterDismissPillView(
                            title: filter.title,
                            onDismiss: {
                                onFilterDismiss(filter.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24.0)
            }
            .frame(height: 40.0)
        }
    }
}

#Preview {
    HomeAppliedFilterCarouselView(
        appliedFilters: [
            HomeFilterPillState(id: 1, title: "Snorkeling", isSelected: true),
            HomeFilterPillState(id: 2, title: "Diving", isSelected: true)
        ],
        isPriceRangeApplied: false,
        onFilterDismiss: { _ in },
        onResetAll: { }
    )
}
