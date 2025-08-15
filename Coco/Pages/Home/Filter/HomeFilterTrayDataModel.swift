//
//  HomeFilterTrayDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Foundation

struct HomeFilterTrayDataModel {
    var filterPillDataState: [HomeFilterPillState] = []
    var priceRangeModel: HomeFilterPriceRangeModel?
    
    init(filterPillDataState: [HomeFilterPillState], priceRangeModel: HomeFilterPriceRangeModel? = nil) {
        self.filterPillDataState = filterPillDataState
        self.priceRangeModel = priceRangeModel
    }
}
