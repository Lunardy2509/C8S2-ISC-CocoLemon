//
//  HomeFilterUtil.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Foundation

final class HomeFilterUtil {
    static func doFilter(_ activities: [Activity], filterDataModel: HomeFilterTrayDataModel) -> [Activity] {
        var filteredActivities: [Activity] = activities
        
        // Filter by category pills first
        let selectedCategoryIds: [Int] = filterDataModel.filterPillDataState
            .filter { $0.isSelected && $0.id > 0 && $0.id <= 3 }
            .map { $0.id }
        
        if !selectedCategoryIds.isEmpty {
            filteredActivities = filteredActivities.filter { activity in
                selectedCategoryIds.contains(activity.category.id)
            }
        }
        
        // Filter by price range if it exists and has been modified
        if let priceRangeModel = filterDataModel.priceRangeModel {
            // Only apply price filter if the user has modified the range from default
            let dataMinPrice = activities.map { $0.pricing }.min() ?? 0
            let dataMaxPrice = activities.map { $0.pricing }.max() ?? 0
            
            // Check if user has changed the price range from the full data range
            let hasCustomRange = priceRangeModel.minPrice > dataMinPrice || priceRangeModel.maxPrice < dataMaxPrice
            
            if hasCustomRange {
                filteredActivities = filteredActivities.filter { activity in
                    activity.pricing >= priceRangeModel.minPrice && activity.pricing <= priceRangeModel.maxPrice
                }
            }
        }
        
        return filteredActivities
    }
}
