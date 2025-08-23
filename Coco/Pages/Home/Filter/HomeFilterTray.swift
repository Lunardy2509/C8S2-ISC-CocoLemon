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
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Filter")
                    .multilineTextAlignment(.leading)
                    .font(.jakartaSans(forTextStyle: .title1, weight: .bold))
                    .foregroundStyle(Token.additionalColorsBlack.toColor())
                
                Spacer()
                
                customButton
            }
            .padding(.top, 10)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24.0) {
                    if !viewModel.dataModel.filterPillDataState.isEmpty {
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text("Activities")
                                .foregroundStyle(Token.additionalColorsBlack.toColor())
                                .font(.jakartaSans(forTextStyle: .body, weight: .semibold))
                                .padding(.bottom, 10)
                            
                            FlowLayout(spacing: 12.0) {
                                ForEach(viewModel.dataModel.filterPillDataState, id: \.id) { state in
                                    HomeFilterPillView(state: state, didTap: {
                                        viewModel.updateApplyButtonTitle()
                                    })
                                }
                            }
                        }
                    }
                    
                    if !viewModel.dataModel.filterDestinationPillState.isEmpty {
                        VStack(alignment: .leading, spacing: 12.0) {
                            Text("Popular Locations")
                                .foregroundStyle(Token.additionalColorsBlack.toColor())
                                .font(.jakartaSans(forTextStyle: .body, weight: .semibold))
                                .padding(.bottom, 10)
                            
                            FlowLayout(spacing: 12) {
                                ForEach(viewModel.dataModel.filterDestinationPillState, id: \.id) { state in
                                    HomeFilterDestinationPillView(state: state, didTap: {
                                        viewModel.updateApplyButtonTitle()
                                    })
                                }
                            }
                        }
                    }
                    
                    if let priceRangeModel = viewModel.dataModel.priceRangeModel {
                        HomeFilterPriceRangeView(model: priceRangeModel, rangeDidChange: {
                            viewModel.updateApplyButtonTitle()
                        })
                    }
                    
                    HStack(spacing: 12.0) {
                        // Apply Button
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
    
    var customButton: some View {
        Group {
            if viewModel.hasActiveFilters {
                Button(action: {
                    viewModel.clearAllFilters()
                }) {
                    Text("Clear All")
                        .font(.jakartaSans(forTextStyle: .footnote, weight: .regular))
                        .foregroundColor(Token.mainColorPrimary.toColor())
                }
            } else {
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.jakartaSans(forTextStyle: .footnote, weight: .regular))
                        .foregroundColor(Token.mainColorPrimary.toColor())
                }
            }

        }
    }
}
