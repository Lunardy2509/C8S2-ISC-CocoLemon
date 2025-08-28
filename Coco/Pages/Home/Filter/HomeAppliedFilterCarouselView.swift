//
//  HomeAppliedFilterCarouselView.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 14/08/25.
//

import Foundation
import SwiftUI

struct HomeAppliedFilterCarouselView: View {
    let appliedActivityFilters: [HomeFilterPillState]
    let appliedDestinationFilters: [HomeFilterDestinationPillState]
    let isPriceRangeApplied: Bool
    let priceRangeText: String?
    let onFilterDismiss: (Int) -> Void
    
    // Special ID for price range filter
    private let priceRangeFilterId = -1
    
    var body: some View {
        if !appliedActivityFilters.isEmpty || !appliedDestinationFilters.isEmpty || isPriceRangeApplied {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.0) {
                    ForEach(appliedActivityFilters, id: \.id) { filter in
                        HomeFilterDismissPillView(
                            title: filter.title,
                            onDismiss: {
                                onFilterDismiss(filter.id)
                            }
                        )
                    }
                    
                    ForEach(appliedDestinationFilters, id: \.id) { filter in
                        HomeFilterDestinationDismissPillView(
                            title: filter.title,
                            onDismiss: {
                                onFilterDismiss(filter.id)
                            }
                        )
                    }
                    
                    // Price range pill
                    if isPriceRangeApplied, let priceText = priceRangeText {
                        HomeFilterDismissPillView(
                            title: priceText,
                            onDismiss: {
                                onFilterDismiss(priceRangeFilterId)
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
