//
//  MyTripViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 02/07/25.
//

import Foundation
import UIKit

final class MyTripViewController: UIViewController {
    init(viewModel: MyTripViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        thisView.delegate = self
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = thisView
        
    }
    
    private let viewModel: MyTripViewModelProtocol
    private let thisView: MyTripView = MyTripView()
    
}



extension MyTripViewController: MyTripViewModelAction {
    func configureView(datas: [MyTripListCardDataModel]) {
        print("🎨 MyTripViewController: Configuring view with \(datas.count) trip(s)")
        thisView.configureView(datas: datas)
    }
    
    func goToBookingDetail(with data: BookingDetails) {
        guard let navigationController else { return }
        let coordinator: MyTripCoordinator = MyTripCoordinator(
            input: .init(
                navigationController: navigationController,
                flow: .bookingDetail(data: data)
            )
        )
        coordinator.parentCoordinator = AppCoordinator.shared
        coordinator.start()
    }
    
    func goToNotificationPage() {
        let notificationVC = NotificationViewController()
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    func showDeleteConfirmation(for index: Int, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Delete Trip",
            message: "Are you sure you want to delete this trip? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension MyTripViewController: MyTripViewDelegate {
    func notifyTripListCardDidTap(at index: Int) {
        viewModel.onTripListDidTap(at: index)
    }
    
    func notifyTripListCardDidDelete(at index: Int) {
        showDeleteConfirmation(for: index) { [weak self] shouldDelete in
            if shouldDelete {
                self?.viewModel.onTripDidDelete(at: index)
            }
        }
    }
    
    func notifyCreateTripDidTap() {
        // Navigate to GroupForm using standard UIKit navigation
       goToCreateTrip()
    }
    
    func notifyDestinationSelected(_ destination: TopDestinationCardDataModel) {
        // Convert TopDestinationCardDataModel to ActivityDetailDataModel for GroupForm
        // Since we don't have full activity details, we'll need to fetch them first
        navigateToGroupFormWithDestination(destination)
    }
    
//    private func navigateToGroupFormWithDestination(_ destination: TopDestinationCardDataModel) {
//        // For now, navigate to GroupForm with a method to pre-select the destination
//        // We'll need to fetch the full activity details first
//        let activityFetcher = ActivityFetcher()
//        
//        // Search for activities in this destination
//        activityFetcher.fetchActivity(request: ActivitySearchRequest(pSearchText: destination.title)) { [weak self] result in
//            Task { @MainActor in
//                switch result {
//                case .success(let activityResponse):
//                    if let firstActivity = activityResponse.values.first {
//                        // Convert to ActivityDetailDataModel using the correct initializer
//                        let activityDetailData = ActivityDetailDataModel(firstActivity)
//                        
//                        // Create GroupFormViewController with pre-selected activity
//                        let groupFormVC = GroupFormViewController(preSelectedActivity: activityDetailData)
//                        groupFormVC.hidesBottomBarWhenPushed = true
//                        self?.navigationController?.pushViewController(groupFormVC, animated: true)
//                    } else {
//                        // Fallback: navigate to regular GroupForm
//                        let groupFormVC = GroupFormViewController()
//                        groupFormVC.hidesBottomBarWhenPushed = true
//                        self?.navigationController?.pushViewController(groupFormVC, animated: true)
//                    }
//                case .failure:
//                    // Fallback: navigate to regular GroupForm
//                    let groupFormVC = GroupFormViewController()
//                    groupFormVC.hidesBottomBarWhenPushed = true
//                    self?.navigationController?.pushViewController(groupFormVC, animated: true)
//                }
//            }
//        }
//    }
    

    private func navigateToGroupFormWithDestination(_ destination: TopDestinationCardDataModel) {
        // For now, navigate to GroupForm with a method to pre-select the destination
        // We'll need to fetch the full activity details first
        let activityFetcher = ActivityFetcher()
        
        // Search for activities in this destination
        activityFetcher.fetchActivity(request: ActivitySearchRequest(pSearchText: destination.title)) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let activityResponse):
                    if let firstActivity = activityResponse.values.first {
                        // Convert to ActivityDetailDataModel using the correct initializer
                        let activityDetailData = ActivityDetailDataModel(firstActivity)
                        
                        // Create GroupFormViewController with pre-selected activity
                        let groupFormVC = GroupFormViewController(preSelectedActivity: activityDetailData)
                        groupFormVC.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(groupFormVC, animated: true)
                    } else {
                        // Fallback: navigate to regular GroupForm
                        let groupFormVC = GroupFormViewController()
                        groupFormVC.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(groupFormVC, animated: true)
                    }
                case .failure:
                    // Fallback: navigate to regular GroupForm
                    let groupFormVC = GroupFormViewController()
                    groupFormVC.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(groupFormVC, animated: true)
                }
            }
        }
    }
}

private extension MyTripViewController {
    func setupNavigationBar() {
        let titleLabel = UILabel()
                titleLabel.text = "My Trip"
                titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                titleLabel.textColor = .black
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        // Add plus button
        let plusButton = UIBarButtonItem(
            image: UIImage(systemName: "plus") ?? UIImage(),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        plusButton.tintColor = .black
        
        // Add notification button  
        let notificationButton = UIBarButtonItem(
            image: UIImage(systemName: "bell") ?? UIImage(),
            style: .plain,
            target: self,
            action: #selector(notificationButtonTapped),
        )
        notificationButton.tintColor = .black
        navigationItem.rightBarButtonItems = [notificationButton, plusButton]
    }
    
    @objc private func plusButtonTapped() {
        // Navigate to GroupForm using standard UIKit navigation
        goToCreateTrip()
    }
    
    @objc private func notificationButtonTapped() {
        viewModel.onNotificationButtonTapped()
    }
    
    func goToCreateTrip() {
        let groupFormVC = GroupFormViewController()
             groupFormVC.hidesBottomBarWhenPushed = true
             navigationController?.pushViewController(groupFormVC, animated: true)
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewTripCreated),
            name: .newTripCreated,
            object: nil
        )
    }
    
    @objc private func handleNewTripCreated() {
        print("🎯 MyTripViewController: Received newTripCreated notification")
        // Refresh the trip data when a new trip is created
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // Add a small delay to ensure the server has processed the booking
            print("🔄 MyTripViewController: Refreshing trip data...")
            self?.viewModel.onViewWillAppear()
        }
    }
}
