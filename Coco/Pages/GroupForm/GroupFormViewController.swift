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
    private var hostingController: UIHostingController<GroupFormView>!
    private var viewModel: GroupFormViewModel!
    private var cancellables = Set<AnyCancellable>()
    
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
        viewModel = GroupFormViewModel()
        
        // Set up navigation callback
        viewModel.onNavigateToActivityDetail = { [weak self] activityDetailData in
            self?.navigateToActivityDetail(activityDetailData)
        }
        
        let contentView = GroupFormView(
            viewModel: viewModel,
            onCreatePlan: { [weak self] in
                self?.handleCreatePlan()
            }
        )
        
        hostingController = UIHostingController(rootView: contentView)
        hostingController.view.backgroundColor = .systemBackground
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add hosting controller as child
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
    
    private func handleCreatePlan() {
        // Navigate back after creating plan
        navigationController?.popViewController(animated: true)
    }
    
    private func navigateToActivityDetail(_ activityDetailData: ActivityDetailDataModel) {
        let activityDetailVM = ActivityDetailViewModel(data: activityDetailData)
        let activityDetailVC = ActivityDetailViewController(viewModel: activityDetailVM)
        navigationController?.pushViewController(activityDetailVC, animated: true)
    }
}

// MARK: - CocoCalendarViewControllerDelegate
extension GroupFormViewController: CocoCalendarViewControllerDelegate {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
        guard let date = date else { return }
        
        // Determine which calendar was opened based on the current state
        if viewModel.showDateVisitCalendar {
            viewModel.onDateVisitCalendarDidChoose(date: date)
        } else if viewModel.showDeadlineCalendar {
            viewModel.onDeadlineCalendarDidChoose(date: date)
        }
    }
}
