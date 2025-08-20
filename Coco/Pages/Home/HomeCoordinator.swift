//
//  HomeCoordinator.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation
import UIKit
import SwiftUI
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
            showSignInPopup()
        }
    }
    
    private func showTripStylePopup() {
        guard case let .activityDetail(data) = input.flow else {
            return
        }

        let tripStylePopUpView = TripStylePopUpView { [weak self] style in
            self?.navigationController?.dismiss(animated: true, completion: {
                guard let self = self else { return }
                switch style {
                case .solo:
                    let soloViewModel = SoloTripActivityDetailViewModel(data: data)
                    soloViewModel.navigationDelegate = self
                    let soloVC = SoloTripActivityDetailViewController(viewModel: soloViewModel)
                    self.start(viewController: soloVC)
                case .group:
                    let createTripViewController = CreateTripViewController()
                    self.start(viewController: createTripViewController)
                }
            })
        }
        
        let hostingController = UIHostingController(rootView: tripStylePopUpView)
        let popupViewController = CocoPopupViewController(child: hostingController)
        
        navigationController?.present(popupViewController, animated: true)
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
    
    func notifyGroupTripCreateTripTapped(planData: GroupTripPlanDataModel) {
        let viewModel = GroupTripPlanViewModel(data: planData)
        viewModel.navigationDelegate = self
        let viewController = GroupTripPlanViewController(viewModel: viewModel)
        start(viewController: viewController)
    }
    
    func notifyGroupTripPlanCreated(data: GroupTripPlanDataModel) {
        let viewModel = GroupTripPlanViewModel(data: data)
        viewModel.navigationDelegate = self
        let viewController = GroupTripPlanViewController(viewModel: viewModel)
        start(viewController: viewController)
    }
}

extension HomeCoordinator: GroupTripPlanNavigationDelegate {
    func notifyGroupTripPlanEditTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func notifyGroupTripPlanBookNowTapped() {
        // Handle booking flow - this could navigate to a booking confirmation
        // or checkout page depending on your app's flow
        print("Book Now tapped - implement booking flow")
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
        // This will not be called as the button is removed from SoloTripActivityDetailViewController
    }
}
