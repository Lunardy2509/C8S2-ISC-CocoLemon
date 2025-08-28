//
//  GroupInvitationTripCoordinatorDelegate.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 28/08/25.
//
import Foundation
import UIKit


// MARK: - Coordinator Protocol
protocol GroupInvitationTripCoordinatorDelegate: AnyObject {
    func didFinishGroupInvitationTrip()
    func didRequestBooking(for trip: TripInvitationModel)
    func didRequestMemberProfile(for member: TripsMember)
}

// MARK: - Coordinator
final class GroupInvitationTripCoordinator {
    weak var delegate: GroupInvitationTripCoordinatorDelegate?
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(with tripData: TripInvitationModel) {
        let viewModel = GroupInvitationTripViewModel(tripData: tripData)
        let viewController = GroupInvitationTripViewController(viewModel: viewModel)
        
        // Bind coordinator actions to view model
        viewModel.onBookNow = { [weak self] in
            self?.delegate?.didRequestBooking(for: tripData)
        }
        
        viewModel.onMemberTap = { [weak self] member in
            self?.delegate?.didRequestMemberProfile(for: member)
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
