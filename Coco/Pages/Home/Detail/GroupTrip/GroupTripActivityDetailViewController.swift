//
//  GroupTripActivityDetailViewController.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation
import UIKit
import SwiftUI

final class GroupTripActivityDetailViewController: UIViewController {
    init(viewModel: GroupTripActivityDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self  
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        thisView.delegate = self
        viewModel.onViewDidLoad()
        
        let createTripButtonVC = CocoButtonHostingController(
            action: { [weak self] in
                self?.viewModel.onCreateTripTapped()
            },
            text: "Create Plan",
            style: .large,
            type: .primary,
            isStretch: true
        )
        addChild(createTripButtonVC)
        thisView.addCreateTripButton(button: createTripButtonVC.view)
        
        // Add the schedule input view
        if let groupViewModel = viewModel as? GroupTripActivityDetailViewModel {
            let scheduleInputVC = UIHostingController(rootView: GroupTripFormInputView(
                tripNameViewModel: viewModel.tripNameInputViewModel,
                calendarViewModel: viewModel.calendarInputViewModel,
                dueDateViewModel: viewModel.dueDateInputViewModel,
                GroupViewModel: groupViewModel
            ))
            addChild(scheduleInputVC)
            thisView.addScheduleInputView(with: scheduleInputVC.view)
            scheduleInputVC.didMove(toParent: self)
        }
    }
    
    private func setupNavigationBar() {
        // Set the title
        title = "Create Group Form"
        
        // Customize navigation bar appearance
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Add back button (this should be automatic, but we can customize if needed)
        navigationItem.hidesBackButton = false
        
        // Optional: Custom back button if needed
        // let backButton = UIBarButtonItem(
        //     image: UIImage(systemName: "chevron.left"),
        //     style: .plain,
        //     target: self,
        //     action: #selector(backButtonTapped)
        // )
        // navigationItem.leftBarButtonItem = backButton
    }
    
    // @objc private func backButtonTapped() {
    //     navigationController?.popViewController(animated: true)
    // }
    
    private let viewModel: GroupTripActivityDetailViewModelProtocol
    private let thisView: GroupTripActivityDetailView = GroupTripActivityDetailView()
    private var calendarType: CalendarType?
    
    private func setupScheduleInputView() {
        if let groupViewModel = viewModel as? GroupTripActivityDetailViewModel {
            let inputView = GroupTripFormInputView(
                tripNameViewModel: viewModel.tripNameInputViewModel,
                calendarViewModel: viewModel.calendarInputViewModel,
                dueDateViewModel: viewModel.dueDateInputViewModel,
                GroupViewModel: groupViewModel
            )
            let hostingVC = UIHostingController(rootView: inputView)
            addChild(hostingVC)
            thisView.addScheduleInputView(with: hostingVC.view)
            hostingVC.didMove(toParent: self)
        }
    }
}

extension GroupTripActivityDetailViewController: GroupTripActivityDetailViewModelAction {
    func configureView(data: ActivityDetailDataModel) {
        thisView.configureView(data)
        
        if data.imageUrlsString.isEmpty {
            thisView.toggleImageSliderView(isShown: false)
        }
        else {
            thisView.toggleImageSliderView(isShown: true)
            let sliderVCs: ImageSliderHostingController = ImageSliderHostingController(images: data.imageUrlsString)
            addChild(sliderVCs)
            thisView.addImageSliderView(with: sliderVCs.view)
            sliderVCs.didMove(toParent: self)
        }
    }
    
    func updatePackageData(data: [ActivityDetailDataModel.Package]) {
        thisView.updatePackageData(data)
    }
    
    func showCalendarOption(for type: CalendarType) {
        let calendarVC: CocoCalendarViewController = CocoCalendarViewController()
        calendarVC.delegate = self
        self.calendarType = type
        let popup: CocoPopupViewController = CocoPopupViewController(child: calendarVC)
        present(popup, animated: true)
    }
    
    func showSearchActivityTray() {
        let searchTrayView = HomeSearchSearchTray(
            selectedQuery: "",
            latestSearches: SearchHistoryManager.shared.getSearchHistory(),
            searchDidApply: { [weak self] queryText in
                self?.dismiss(animated: true) {
                    self?.viewModel.onSearchDidApply(queryText)
                }
            },
            onSearchHistoryRemove: { searchData in
                SearchHistoryManager.shared.removeSearchHistory(searchData.name)
            },
            onSearchReset: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: searchTrayView)
        let navController = UINavigationController(rootViewController: hostingController)
        present(navController, animated: true)
    }
    
    func showSearchBar() {
        thisView.showSearchBar()
    }
    
    func showSearchResults(_ activities: [Activity]) {
        // This method is now only called for empty results
        // since onSearchDidApply handles the success case directly
        if activities.isEmpty {
            print("No search results found")
        }
    }
    
    func updateTripMembers(members: [TripMember]) {
        thisView.updateTripMembers(members: members)
    }
}

extension GroupTripActivityDetailViewController: GroupTripActivityDetailViewDelegate {
    func notifyPackagesButtonDidTap(shouldShowAll: Bool) {
        viewModel.onPackageDetailStateDidChange(shouldShowAll: shouldShowAll)
    }
    
    func notifyPackagesDetailDidTap(with packageId: Int) {
        viewModel.onPackagesDetailDidTap(with: packageId)
    }
    
    func notifyAddFriendButtonDidTap() {
        showInviteFriendPopup()
    }
    
    func notifyRemoveActivityButtonDidTap() {
        viewModel.onRemoveActivityTapped()
    }
    
    func notifySearchActivityTapped() {
        // Show the same search tray as home page
        let searchTrayView = HomeSearchSearchTray(
            selectedQuery: "",
            latestSearches: SearchHistoryManager.shared.getSearchHistory(),
            searchDidApply: { [weak self] queryText in
                self?.dismiss(animated: true) {
                    self?.viewModel.onSearchDidApply(queryText)
                }
            },
            onSearchHistoryRemove: { searchData in
                SearchHistoryManager.shared.removeSearchHistory(searchData.name)
            },
            onSearchReset: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: searchTrayView)
        let navController = UINavigationController(rootViewController: hostingController)
        present(navController, animated: true)
    }

    func notifySearchBarTapped(with query: String) {
        // Show the same search tray as home page
        let searchTrayView = HomeSearchSearchTray(
            selectedQuery: query,
            latestSearches: SearchHistoryManager.shared.getSearchHistory(),
            searchDidApply: { [weak self] queryText in
                self?.viewModel.onSearchDidApply(queryText)
            }
        )
        
        let hostingController = UIHostingController(rootView: searchTrayView)
        let navController = UINavigationController(rootViewController: hostingController)
        present(navController, animated: true)
    }
}

extension GroupTripActivityDetailViewController: CocoCalendarViewControllerDelegate {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
        guard let date: Date, let type = self.calendarType else { return }
        viewModel.onCalendarDidChoose(date: date, for: type)
        self.calendarType = nil
    }
}

private extension GroupTripActivityDetailViewController {
    func showInviteFriendPopup() {
        let popupView = InviteFriendPopUpView(
            onSendInvite: { [weak self] email in
                self?.handleSendInvite(email: email)
            },
            onDismiss: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        
        let hostingVC = UIHostingController(rootView: popupView)
        let popupVC = CocoPopupViewController(child: hostingVC)
        present(popupVC, animated: true)
    }
    
    func handleSendInvite(email: String) {
        print("Sending invite to: \(email)")
        
        let name = email.components(separatedBy: "@").first ?? "New Member"

        dismiss(animated: true) { [weak self] in
            self?.viewModel.addTripMember(name: name, email: email)
        }
    }
}
