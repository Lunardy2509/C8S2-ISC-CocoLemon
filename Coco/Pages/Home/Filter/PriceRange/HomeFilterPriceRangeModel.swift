//
//  HomeFilterPriceRangeModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 09/07/25.
//

import Foundation
import SwiftUI

final class HomeFilterPriceRangeModel: ObservableObject {
    @Published var minPrice: Double
    @Published var maxPrice: Double

    let range: ClosedRange<Double>
    let step: Double

    init(minPrice: Double, maxPrice: Double, range: ClosedRange<Double>, step: Double = 1) {
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.range = range
        self.step = step
    }
    
    /// Returns true if the current price range covers the full range (no filtering applied)
    var isAtFullRange: Bool {
        return minPrice == range.lowerBound && maxPrice == range.upperBound
    }
    
    /// Resets the price range to the full range
    func resetToFullRange() {
        minPrice = range.lowerBound
        maxPrice = range.upperBound
    }
}
