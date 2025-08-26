//
//  HomeCoordinator.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation
import UIKit
import SwiftUI

final class HomeCoordinator: BaseCoordinator {
    struct Input {
        let navigationController: UINavigationController
        let flow: Flow
        
        enum Flow {
            case activityDetail(data: ActivityDetailDataModel)
        }
    }
    
    init(input: Input) {
        self.input = input
        super.init(navigationController: input.navigationController)
    }
    
    override func start() {
        super.start()
        
        switch input.flow {
        case .activityDetail(let data):
            let detailViewModel: ActivityDetailViewModel = ActivityDetailViewModel(
                data: data
            )
            detailViewModel.navigationDelegate = self
            let detailViewController: ActivityDetailViewController = ActivityDetailViewController(viewModel: detailViewModel)
            start(viewController: detailViewController)
        }
    }
    
    private let input: Input
}

extension HomeCoordinator: HomeViewModelNavigationDelegate {
    func notifyHomeDidSelectActivity() {
        
    }
}

extension HomeCoordinator: HomeFormScheduleViewModelDelegate {
    func notifyFormScheduleDidNavigateToCheckout(with response: CreateBookingResponse) {
        let viewModel: CheckoutViewModel = CheckoutViewModel(
            bookingResponse: response.bookingDetails
        )
        viewModel.delegate = self
        let viewController = CheckoutViewController(viewModel: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.start(viewController: viewController)
        }
    }
}

extension HomeCoordinator: CheckoutViewModelDelegate {
    func notifyUserDidCheckout() {
        guard let tabBarController: BaseTabBarViewController = parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController
        else {
            return
        }
        tabBarController.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
    }
}

extension HomeCoordinator: ActivityDetailNavigationDelegate {
    func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
        let viewModel: HomeFormScheduleViewModel = HomeFormScheduleViewModel(
            input: HomeFormScheduleViewModelInput(
                package: package,
                selectedPackageId: selectedPackageId
            )
        )
        viewModel.delegate = self
        let viewController: HomeFormScheduleViewController = HomeFormScheduleViewController(viewModel: viewModel)
        start(viewController: viewController)
    }

    func notifyCreateTripTapped() {
        if UserDefaults.standard.string(forKey: "user-id") != nil {
            navigateToTripStylePage()
        } else {
            guard let tabBarController = parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController else {
                return
            }
            tabBarController.selectedIndex = 2
        }
    }

    private func navigateToTripStylePage() {
        guard case let .activityDetail(data) = input.flow else {
            return
        }

        let tripStyleVC = TripStyleViewController(
            didSelectStyle: { [weak self] style in
                guard let self = self else { return }
                
                // The style selection triggers navigation, so we can pop the current
                // controller before pushing the new one.
                self.navigationController?.popViewController(animated: false)

                switch style {
                case .solo:
                    let soloViewModel = SoloTripActivityDetailViewModel(data: data)
                    soloViewModel.navigationDelegate = self
                    let soloVC = SoloTripActivityDetailViewController(viewModel: soloViewModel)
                    self.start(viewController: soloVC)
                case .group:
                    // Navigate directly to GroupFormView for group trips
                    self.navigateToGroupForm(with: data)
                }
            },
            activityData: data
        )
        start(viewController: tripStyleVC)
    }
    
    private func navigateToGroupForm(with data: ActivityDetailDataModel) {
        Task { @MainActor in
            let groupFormViewModel = GroupFormViewModel(selectedActivity: data)
            groupFormViewModel.navigationDelegate = self
            
            let groupFormVC = UIHostingController(rootView: GroupFormView(viewModel: groupFormViewModel))
            
            // Set navigation title
            groupFormVC.navigationItem.title = "Group Form"
            
            self.start(viewController: groupFormVC)
        }
    }
}

extension HomeCoordinator: SoloTripActivityDetailNavigationDelegate {
    func notifySoloTripActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
        let viewModel: HomeFormScheduleViewModel = HomeFormScheduleViewModel(
            input: HomeFormScheduleViewModelInput(
                package: package,
                selectedPackageId: selectedPackageId
            )
        )
        viewModel.delegate = self
        let viewController: HomeFormScheduleViewController = HomeFormScheduleViewController(viewModel: viewModel)
        start(viewController: viewController)
    }
    
    func notifySoloTripCreateTripTapped() {
     
    }
}

// MARK: - GroupFormNavigationDelegate
extension HomeCoordinator: GroupFormNavigationDelegate {
    func notifyGroupFormNavigateToActivityDetail(_ activityDetail: ActivityDetailDataModel) {
        // Handle navigation back to activity detail if needed
        navigationController?.popViewController(animated: true)
    }
    
    func notifyGroupFormNavigateToTripDetail(_ bookingDetails: BookingDetails) {
        // Navigate to TripDetailView using MyTripCoordinator
        guard let navigationController = self.navigationController else { return }
        let tripCoordinator = MyTripCoordinator(
            input: MyTripCoordinator.Input(
                navigationController: navigationController,
                flow: .bookingDetail(data: bookingDetails)
            )
        )
        tripCoordinator.parentCoordinator = self.parentCoordinator
        tripCoordinator.start()
    }
    
    func notifyGroupFormCreatePlan() {
        // Navigate to MyTrip tab after creating plan
        guard let tabBarController: BaseTabBarViewController = parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController
        else {
            return
        }
        tabBarController.selectedIndex = 1 // MyTrip tab
        navigationController?.popToRootViewController(animated: true)
    }
}
