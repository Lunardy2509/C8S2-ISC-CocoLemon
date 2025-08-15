//
//  HomeFilterTray.swift
//  Coco
//
//  Created by Jackie Leonardy on 07/07/25.
//

import Foundation
import SwiftUI

struct HomeFilterTray: View {
    @ObservedObject var viewModel: HomeFilterTrayViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Filters")
                .multilineTextAlignment(.center)
                .font(.jakartaSans(forTextStyle: .body, weight: .semibold))
                .foregroundStyle(Token.additionalColorsBlack.toColor())
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24.0) {
                    if !viewModel.dataModel.filterPillDataState.isEmpty {
                        VStack(alignment: .leading, spacing: 12.0) {
                            Text("Activities")
                                .foregroundStyle(Token.additionalColorsBlack.toColor())
                                .font(.jakartaSans(forTextStyle: .body, weight: .semibold))
                             
                            ScrollView(.horizontal) {
                                HStack(spacing: 12.0) {
                                    ForEach(viewModel.dataModel.filterPillDataState, id: \.id) { state in
                                        HomeFilterPillView(state: state, didTap: {
                                            viewModel.updateApplyButtonTitle()
                                        })
                                    }
                                }
                            }
                        }
                    }
                    
                    if let priceRangeModel = viewModel.dataModel.priceRangeModel {
                        HomeFilterPriceRangeView(model: priceRangeModel, rangeDidChange: {
                            viewModel.updateApplyButtonTitle()
                        })
                    }
                    
                    Spacer()
                    HStack(spacing: 12.0) {
                        // Reset Button
                        CocoButton(
                            action: {
                                viewModel.resetFilters()
                            },
                            text: "Reset",
                            style: .large,
                            type: .secondary
                        )
                        .stretch()
                        
                        // Apply Button - always enabled and primary
                        CocoButton(
                            action: {
                                viewModel.filterDidApply()
                            },
                            text: viewModel.applyButtonTitle,
                            style: .large,
                            type: .primary
                        )
                        .stretch()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24.0)
        .background(Color.white)
        .cornerRadius(16)
    }
}

private extension HomeFilterTray {
    func createSectionView(
        title: String,
        view: (() -> some View)
    ) -> some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(title)
                .font(.jakartaSans(forTextStyle: .body, weight: .semibold))
                .foregroundStyle(Token.additionalColorsBlack.toColor())
            view()
        }
    }
}
