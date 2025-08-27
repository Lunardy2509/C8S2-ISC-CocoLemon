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
    let filterDidApplyPublisher = PassthroughSubject<HomeFilterTrayDataModel, Never>()

    @Published var dataModel: HomeFilterTrayDataModel
    @Published var applyButtonTitle: String = "See Result"

    private let activities: [Activity]

    // Keep two sets: one for top-level dataModel changes, one for inner field changes
    private var modelChangeCancellables = Set<AnyCancellable>()
    private var fieldChangeCancellables = Set<AnyCancellable>()

    init(dataModel: HomeFilterTrayDataModel, activities: [Activity]) {
        self.dataModel = dataModel
        self.activities = activities
        setupBindings()
        updateApplyButtonTitle()
    }

    // MARK: - Public
    func filterDidApply() {
        filterDidApplyPublisher.send(dataModel)
    }
    
    func clearAllFilters() {
        // Clear all pill selections
        dataModel.filterPillDataState.forEach { pill in
            pill.isSelected = false
        }
        
        // Clear all destination pill selections
        dataModel.filterDestinationPillState.forEach { pill in
            pill.isSelected = false
        }
        
        // Reset price range to full range
        if let priceRangeModel = dataModel.priceRangeModel {
            priceRangeModel.minPrice = priceRangeModel.range.lowerBound
            priceRangeModel.maxPrice = priceRangeModel.range.upperBound
        }
        
        updateApplyButtonTitle()
    }
    
    func updateApplyButtonTitle() {
        let resultsCount = countFilterResults
        let hasActiveFilters = filterAppliedCount > 0

        guard hasActiveFilters else {
            applyButtonTitle = "See Result"
            return
        }

        applyButtonTitle = resultsCount == 1
            ? "See Result (\(resultsCount))"
            : "See Results (\(resultsCount))"
    }

    // MARK: - Private

    var hasActiveFilters: Bool {
        return filterAppliedCount > 0
    }

    private var countFilterResults: Int {
        HomeFilterUtil.doFilter(activities, filterDataModel: dataModel).count
    }

    private var filterAppliedCount: Int {
        let pillCount = dataModel.filterPillDataState.filter { $0.isSelected }.count
        let destCount = dataModel.filterDestinationPillState.filter { $0.isSelected }.count
        let priceCount = isPriceRangeActive(dataModel.priceRangeModel) ? 1 : 0
        return pillCount + destCount + priceCount
    }

    private func isPriceRangeActive(_ priceRangeModel: HomeFilterPriceRangeModel?) -> Bool {
        guard let m = priceRangeModel else { return false }
        let tol = max(m.step / 2.0, 1e-6)
        let atLower = abs(m.minPrice - m.range.lowerBound) <= tol
        let atUpper = abs(m.maxPrice - m.range.upperBound) <= tol
        
        return !(atLower && atUpper)
    }

    private func setupBindings() {
        // Rebind inner listeners whenever the entire dataModel is swapped out
        $dataModel
            .sink { [weak self] _ in
                self?.bindInnerFields()
                self?.updateApplyButtonTitle()
            }
            .store(in: &modelChangeCancellables)

        // Initial bind for the starting model
        bindInnerFields()
    }

    private func bindInnerFields() {
        // Clear old inner subscriptions
        fieldChangeCancellables.removeAll()

        // Observe pill selection changes
        dataModel.filterPillDataState.forEach { pill in
            pill.$isSelected
                .sink { [weak self] _ in self?.updateApplyButtonTitle() }
                .store(in: &fieldChangeCancellables)
        }

        // Observe destination pill selection changes
        dataModel.filterDestinationPillState.forEach { pill in
            pill.$isSelected
                .sink { [weak self] _ in self?.updateApplyButtonTitle() }
                .store(in: &fieldChangeCancellables)
        }

        // Observe price range changes
        dataModel.priceRangeModel?.objectWillChange
            .sink { [weak self] in self?.updateApplyButtonTitle() }
            .store(in: &fieldChangeCancellables)
    }
}
