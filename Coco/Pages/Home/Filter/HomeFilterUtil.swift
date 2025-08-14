//
//  HomeFilterUtil.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Foundation

final class HomeFilterUtil {
    static func doFilter(_ activities: [Activity], filterDataModel: HomeSearchFilterTrayDataModel) -> [Activity] {
        var tempActivities: [Activity] = activities
        
        // filter by pill
        let selectedIds: [Int] = filterDataModel.filterPillDataState
            .filter { $0.isSelected }
            .map { $0.id }
        
        // filter by category (ids 1, 2, 3 are categories)
        let selectedCategoryIds: [Int] = filterDataModel.filterPillDataState
            .filter { $0.isSelected && $0.id > 0 && $0.id <= 3 }
            .map { $0.id }
        
        if !selectedCategoryIds.isEmpty {
            tempActivities = tempActivities.filter { activity in
                selectedCategoryIds.contains(activity.category.id)
            }
        }
        
        // filter by price range (only if priceRangeModel exists)
        if let priceRangeModel = filterDataModel.priceRangeModel {
            tempActivities = tempActivities.filter {
                $0.pricing >= priceRangeModel.minPrice && $0.pricing <= priceRangeModel.maxPrice
            }
        }
        
        return tempActivities
    }
}
