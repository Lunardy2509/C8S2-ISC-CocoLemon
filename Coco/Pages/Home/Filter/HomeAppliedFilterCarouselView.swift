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
    let onFilterDismiss: (Int) -> Void
    
    var body: some View {
        if !appliedFilters.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.0) {
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
        onFilterDismiss: { _ in }
    )
}
