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
    @Published var applyButtonTitle: String = "See 0 Results"
    
    private let activities: [Activity]
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(dataModel: HomeFilterTrayDataModel, activities: [Activity]) {
        self.dataModel = dataModel
        self.activities = activities
        
        setupBindings()
        let resultsCount = HomeFilterUtil.doFilter(activities, filterDataModel: dataModel).count
        if resultsCount == 1 {
            applyButtonTitle = "See \(resultsCount) Result"
        } else {
            applyButtonTitle = "See \(resultsCount) Results"
        }
    }
    
    private var countFilterResults: Int {
        let filteredActivities = HomeFilterUtil.doFilter(activities, filterDataModel: dataModel)
        return filteredActivities.count
    }
    
    func filterDidApply() {
        filterDidApplyPublisher.send(dataModel)
    }
    
    func updateApplyButtonTitle() {
        let resultsCount = countFilterResults
        if resultsCount == 1 {
            applyButtonTitle = "See \(resultsCount) Result"
        } else {
            applyButtonTitle = "See \(resultsCount) Results"
        }
    }
    
    private func setupBindings() {
        // Observe pill selection
        dataModel.filterPillDataState.forEach { pill in
            pill.$isSelected
                .sink { [weak self] _ in
                    self?.updateApplyButtonTitle()
                }
                .store(in: &cancellables)
        }
        
        // Observe destination pill selection
        dataModel.filterDestinationPillState.forEach { pill in
            pill.$isSelected
                .sink { [weak self] _ in
                    self?.updateApplyButtonTitle()
                }
                .store(in: &cancellables)
        }
        
        // Observe price range changes
        dataModel.priceRangeModel?.objectWillChange
            .sink { [weak self] in
                self?.updateApplyButtonTitle()
            }
            .store(in: &cancellables)
    }
}
