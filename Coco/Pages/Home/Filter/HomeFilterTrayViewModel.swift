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
    @Published var applyButtonTitle: String = "Apply Filter (0)"
    
    private let activities: [Activity]
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(dataModel: HomeFilterTrayDataModel, activities: [Activity]) {
        self.dataModel = dataModel
        self.activities = activities
        
        setupBindings()
        applyButtonTitle = "Apply Filter (\(countFilter))"
    }
    
    private var countFilter: Int {
        let pillCount = dataModel.filterPillDataState.filter { $0.isSelected }.count
        let destinationPillCount = dataModel.filterDestinationPillState.filter { $0.isSelected }.count
        let priceCount = (dataModel.priceRangeModel?.isAtFullRange == false) ? 1 : 0
        return pillCount + destinationPillCount + priceCount
    }
    
    func filterDidApply() {
        filterDidApplyPublisher.send(dataModel)
    }
    
    func updateApplyButtonTitle() {
        applyButtonTitle = "Apply Filter (\(countFilter))"
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
