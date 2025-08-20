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
            showTripStylePopup()
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
    
    private func showSignInPopup() {
        let signInPopUpView = SignInPopUpView(
            signInDidTap: { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: {
                    guard let tabBarController = self?.parentCoordinator?.navigationController?.tabBarController as? BaseTabBarViewController else {
                        return
                    }
                    tabBarController.selectedIndex = 2 // Profile Tab
                })
            },
            cancelDidTap: { [weak self] in
                self?.navigationController?.dismiss(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: signInPopUpView)
        let popupViewController = CocoPopupViewController(child: hostingController)
        
        navigationController?.present(popupViewController, animated: true)
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
