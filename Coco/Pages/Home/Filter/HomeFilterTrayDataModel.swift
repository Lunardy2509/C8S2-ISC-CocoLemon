//
//  HomeFilterTrayDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Foundation

struct HomeFilterTrayDataModel {
    var filterPillDataState: [HomeFilterPillState] = []
    var filterDestinationPillState: [HomeFilterDestinationPillState] = []
    var priceRangeModel: HomeFilterPriceRangeModel?
    
    init(filterPillDataState: [HomeFilterPillState], priceRangeModel: HomeFilterPriceRangeModel? = nil, filterDestinationPillState: [HomeFilterDestinationPillState] = []) {
        self.filterPillDataState = filterPillDataState
        self.filterDestinationPillState = filterDestinationPillState
        self.priceRangeModel = priceRangeModel
    }
}
