//
//  GroupTripPlanViewModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 26/08/25.
//

import Foundation

final class GroupTripPlanViewModel: GroupTripPlanViewModelProtocol {
    weak var actionDelegate: GroupTripPlanViewModelAction?
    weak var navigationDelegate: GroupTripPlanNavigationDelegate?
    
    private let data: GroupTripPlanDataModel
    
    var tripName: String {
        return data.tripName
    }
    
    init(data: GroupTripPlanDataModel) {
        self.data = data
    }
    
    func onViewDidLoad() {
        actionDelegate?.configureView(data: data)
    }
    
    func onEditTapped() {
        navigationDelegate?.notifyGroupTripPlanEditTapped()
    }
    
    func onBookNowTapped() {
        navigationDelegate?.notifyGroupTripPlanBookNowTapped()
    }
}
