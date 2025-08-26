//
//  GroupTripPlanViewModelContract.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 26/08/25.
//

import Foundation

protocol GroupTripPlanNavigationDelegate: AnyObject {
    func notifyGroupTripPlanEditTapped()
    func notifyGroupTripPlanBookNowTapped(localBookingDetails: LocalBookingDetails) 
}

protocol GroupTripPlanViewModelAction: AnyObject {
    func configureView(data: GroupTripPlanDataModel)
}

protocol GroupTripPlanViewModelProtocol: AnyObject {
    var actionDelegate: GroupTripPlanViewModelAction? { get set }
    var navigationDelegate: GroupTripPlanNavigationDelegate? { get set }
    
    var tripName: String { get }
    
    func onViewDidLoad()
    func onEditTapped()
    func onBookNowTapped()
    func onPackageVoteToggled(packageId: Int) 
}
