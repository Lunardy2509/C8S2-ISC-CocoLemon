//
//  GroupFormViewController.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import UIKit
import SwiftUI
import Combine

final class GroupFormViewController: UIViewController {
    
    // MARK: - Properties
    private var hostingController: UIHostingController<GroupFormView>?
    private var viewModel: GroupFormViewModel?
    private var cancellables = Set<AnyCancellable>()
    private var preSelectedActivity: ActivityDetailDataModel?
    
    // MARK: - Initializers
    convenience init(preSelectedActivity: ActivityDetailDataModel) {
        self.init()
        self.preSelectedActivity = preSelectedActivity
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupHostingController()
        setupView()
        setupBindings()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "Group Form"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIBarButtonItem()
        backButton.title = "My Trip"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func setupHostingController() {
        let newViewModel: GroupFormViewModel
        
        // Use pre-selected activity if available
        if let preSelectedActivity = preSelectedActivity {
            newViewModel = GroupFormViewModel(selectedActivity: preSelectedActivity)
        } else {
            newViewModel = GroupFormViewModel()
        }
        
        self.viewModel = newViewModel
        
        // Set up navigation delegate
        newViewModel.navigationDelegate = self
        
        let contentView = GroupFormView(viewModel: newViewModel)
        
        let newHostingController = UIHostingController(rootView: contentView)
        self.hostingController = newHostingController
        newHostingController.view.backgroundColor = .systemBackground
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add hosting controller as child
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Setup constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        guard let viewModel = viewModel else { return }
        
        // Monitor date visit calendar presentation
        viewModel.$showDateVisitCalendar
            .sink { [weak self] shouldShow in
                if shouldShow {
                    self?.showDateVisitCalendar()
                }
            }
            .store(in: &cancellables)
        
        // Monitor deadline calendar presentation
        viewModel.$showDeadlineCalendar
            .sink { [weak self] shouldShow in
                if shouldShow {
                    self?.showDeadlineCalendar()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showDateVisitCalendar() {
        let calendarVC = CocoCalendarViewController()
        calendarVC.delegate = self
        let popup = CocoPopupViewController(child: calendarVC)
        present(popup, animated: true)
    }
    
    private func showDeadlineCalendar() {
        let calendarVC = CocoCalendarViewController()
        calendarVC.delegate = self
        let popup = CocoPopupViewController(child: calendarVC)
        present(popup, animated: true)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - GroupFormNavigationDelegate
extension GroupFormViewController: GroupFormNavigationDelegate {
    func notifyGroupFormNavigateToActivityDetail(_ activityDetail: ActivityDetailDataModel) {
        let activityDetailVM = ActivityDetailViewModel(data: activityDetail)
        let activityDetailVC = ActivityDetailViewController(viewModel: activityDetailVM)
        navigationController?.pushViewController(activityDetailVC, animated: true)
    }
    
    func notifyGroupFormNavigateToTripDetail(_ bookingDetails: BookingDetails) {
        let tripDetailVM = TripDetailViewModel(data: bookingDetails)
        let tripDetailVC = TripDetailViewController(viewModel: tripDetailVM)
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    func notifyGroupFormCreatePlan() {
        // Navigate back after creating plan
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CocoCalendarViewControllerDelegate
extension GroupFormViewController: CocoCalendarViewControllerDelegate {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
        guard let date = date, let viewModel = viewModel else { return }
        
        // Determine which calendar was opened based on the current state
        if viewModel.showDateVisitCalendar {
            viewModel.onDateVisitCalendarDidChoose(date: date)
        } else if viewModel.showDeadlineCalendar {
            viewModel.onDeadlineCalendarDidChoose(date: date)
        }
    }
}
