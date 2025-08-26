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
        title = "My Trip"
        setupNavigationBar()
        thisView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }
    
    override func loadView() {
        view = thisView
    }
    
    private let viewModel: MyTripViewModelProtocol
    private let thisView: MyTripView = MyTripView()
}



extension MyTripViewController: MyTripViewModelAction {
    func configureView(datas: [MyTripListCardDataModel]) {
        thisView.configureView(datas: datas)
    }
    
    func configureRecommendations(recommendations: [MyTripRecommendationDataModel]) {
//        thisView.configureRecommendations(recommendations: recommendations)
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
        let groupFormVC = GroupFormViewController()
        groupFormVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupFormVC, animated: true)
    }
}

private extension MyTripViewController {
    func setupNavigationBar() {
        // Add plus button
        let plusButton = UIBarButtonItem(
            image: UIImage(systemName: "plus") ?? UIImage(),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        
        // Add notification button  
        let notificationButton = UIBarButtonItem(
            image: UIImage(systemName: "bell") ?? UIImage(),
            style: .plain,
            target: self,
            action: #selector(notificationButtonTapped),
        )
        
        navigationItem.rightBarButtonItems = [notificationButton, plusButton]
    }
    
    @objc private func plusButtonTapped() {
        // Navigate to GroupForm using standard UIKit navigation
        let groupFormVC = GroupFormViewController()
        groupFormVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupFormVC, animated: true)
    }
    
    @objc private func notificationButtonTapped() {
        viewModel.onNotificationButtonTapped()
    }
    
    func createMyTripNoTripYetRegistration() -> MyTripNoTripYetRegistration {
        .init { cell, _, itemIdentifier in
            // No need Configuration
        }
    }
    
    typealias MyTripNoTripYetRegistration = UICollectionView.CellRegistration<MyTripNoTripYet,MyTripNoTripYetDataModel>
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
//        let groupFormVC = GroupFormViewController()
//        groupFormVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(groupFormVC, animated: true)
    }
    
    @objc private func notificationButtonTapped() {
        viewModel.onNotificationButtonTapped()
    }
    
//    func createMyTripNoTripYetRegistration() -> MyTripNoTripYetRegistration {
//        .init { cell, _, itemIdentifier in
//            // No need Configuration
//        }
//    }
    
   
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
//        let groupFormVC = GroupFormViewController()
//        groupFormVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(groupFormVC, animated: true)
    }
    
    @objc private func notificationButtonTapped() {
        viewModel.onNotificationButtonTapped()
    }
    
//    func createMyTripNoTripYetRegistration() -> MyTripNoTripYetRegistration {
//        .init { cell, _, itemIdentifier in
//            // No need Configuration
//        }
//    }
    
   
}
