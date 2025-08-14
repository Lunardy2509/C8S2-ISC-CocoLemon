//
//  HomeFilterCarouselView.swift
//  Coco
//
//  Created by AI Assistant on 13/08/25.
//

import Foundation
import SwiftUI

struct HomeFilterCarouselView: View {
    let filterPillStates: [HomeSearchFilterPillState]
    let onFilterTap: (HomeSearchFilterPillState) -> Void
    
    var body: some View {
        if !filterPillStates.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.0) {
                    ForEach(filterPillStates, id: \.id) { state in
                        HomeSearchFilterPillView(state: state, didTap: {
                            onFilterTap(state)
                        })
                    }
                }
                .padding(.horizontal, 24.0)
            }
            .frame(height: 40.0)
        }
    }
}

#Preview {
    HomeFilterCarouselView(
        filterPillStates: [
            HomeSearchFilterPillState(id: 1, title: "Snorkeling", isSelected: true),
            HomeSearchFilterPillState(id: 2, title: "Certified Guide", isSelected: false),
            HomeSearchFilterPillState(id: 3, title: "Bottled Water", isSelected: false),
            HomeSearchFilterPillState(id: 4, title: "Free Cancellation", isSelected: false)
        ],
        onFilterTap: { _ in }
    )
}
