//
//  HomeFilterTrayViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Combine
import Foundation
import SwiftUI

final class HomeFilterTrayViewModel: ObservableObject {
    let filterDidApplyPublisher: PassthroughSubject<HomeFilterTrayDataModel, Never> = PassthroughSubject()
    
    @Published var dataModel: HomeFilterTrayDataModel
    @Published var applyButtonTitle: String
    
    private let activities: [Activity]
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(dataModel: HomeFilterTrayDataModel, activities: [Activity]) {
        self.dataModel = dataModel
        self.activities = activities
        
        let tempActivity: [Activity] = HomeFilterUtil.doFilter(activities, filterDataModel: dataModel)
        applyButtonTitle = Self.getTitle(tempActivity)
    }
    
    func filterDidApply() {
        filterDidApplyPublisher.send(dataModel)
    }
    
    func updateApplyButtonTitle() {
        let tempActivity: [Activity] = HomeFilterUtil.doFilter(activities, filterDataModel: dataModel)
        applyButtonTitle = Self.getTitle(tempActivity)
    }
    
    func resetFilters() {
        // Reset filter pills to unselected state
        for i in 0..<dataModel.filterPillDataState.count {
            dataModel.filterPillDataState[i].isSelected = false
        }
        
        // Reset price range to default values
        if let priceRangeModel = dataModel.priceRangeModel {
            priceRangeModel.minPrice = priceRangeModel.range.lowerBound
            priceRangeModel.maxPrice = priceRangeModel.range.upperBound
        }
        
        updateApplyButtonTitle()
    }
}

private extension HomeFilterTrayViewModel {
    static func getTitle(_ activities: [Activity]) -> String {
        activities.isEmpty ? "No Result" : "Apply"
    }
}
