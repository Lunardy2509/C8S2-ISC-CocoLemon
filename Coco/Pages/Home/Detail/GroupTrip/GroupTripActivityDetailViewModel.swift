//
//  GroupTripActivityDetailViewModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation

final class GroupTripActivityDetailViewModel {
    weak var actionDelegate: GroupTripActivityDetailViewModelAction?
    weak var navigationDelegate: GroupTripActivityDetailNavigationDelegate?
    
    private let activityFetcher: ActivityFetcherProtocol

    private var tripMembers: [TripMember] = [
        TripMember(name: "Adhis", email: "adhis@example.com", profileImageURL: nil, isWaiting: false)
    ]

    init(data: ActivityDetailDataModel, activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.data = data
        self.activityFetcher = activityFetcher
        self.currentData = data
    }
    
    private var currentData: ActivityDetailDataModel
    
    private let data: ActivityDetailDataModel
    private var selectedPackageIds: Set<Int> = []
    
    private(set) lazy var tripNameInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Enter trip name",
        currentTypedText: "",
        trailingIcon: nil,
        isTypeAble: true,
        delegate: self
    )
    
    private(set) lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "DD/MM/YYYY",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icCalendarIcon.image,
            didTap: openCalendar
        ),
        isTypeAble: false,
        delegate: self
    )
    
    private(set) lazy var dueDateInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "DD/MM/YYYY",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icCalendarIcon.image,
            didTap: openDueDateCalendar
        ),
        isTypeAble: false,
        delegate: self
    )
    
    private var chosenDateInput: Date? {
        didSet {
            guard let chosenDateInput else { return }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            calendarInputViewModel.currentTypedText = dateFormatter.string(from: chosenDateInput)
        }
    }
    
    private var chosenDueDateInput: Date? {
        didSet {
            guard let chosenDueDateInput else { return }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            dueDateInputViewModel.currentTypedText = dateFormatter.string(from: chosenDueDateInput)
        }
    }
}

extension GroupTripActivityDetailViewModel: GroupTripActivityDetailViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.configureView(data: data)
        actionDelegate?.updatePackageData(data: data.availablePackages.content)
        
        // Make sure the view has the default trip members
        // This should be handled by the view's initialization
    }
    
    func onPackageDetailStateDidChange(shouldShowAll: Bool) {
        actionDelegate?.updatePackageData(data: shouldShowAll ? data.availablePackages.content : data.hiddenPackages)
    }
    
    func onPackagesDetailDidTap(with packageId: Int) {
        // Just update the internal selection state, don't navigate
        if selectedPackageIds.contains(packageId) {
            selectedPackageIds.remove(packageId)
        } else {
            selectedPackageIds.insert(packageId)
        }
    }
    
    func onCreateTripTapped() {
        navigationDelegate?.notifyGroupTripCreateTripTapped()
    }
    
    func getSelectedPackageIds() -> Set<Int> {
        return selectedPackageIds
    }
    
    func onCalendarDidChoose(date: Date, for type: CalendarType) {
        switch type {
        case .visitDate:
            chosenDateInput = date
        case .dueDate:
            chosenDueDateInput = date
        }
    }
    
    func onRemoveActivityTapped() {
        actionDelegate?.showSearchBar()
    }
    
    func onSearchActivitySelected(_ newActivity: ActivityDetailDataModel) {
        currentData = newActivity
        actionDelegate?.configureView(data: newActivity)
        actionDelegate?.updatePackageData(data: newActivity.availablePackages.content)
    }

    func onSearchDidApply(_ queryText: String) {
        let activityFetcher = ActivityFetcher()
        activityFetcher.fetchActivity(request: ActivitySearchRequest(pSearchText: queryText)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let activities = response.values
                self.actionDelegate?.showSearchResults(activities)
            case .failure:
                break
            }
        }
    }
}

extension GroupTripActivityDetailViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption(for: .visitDate)
        } else if viewModel === dueDateInputViewModel {
            actionDelegate?.showCalendarOption(for: .dueDate)
        }
    }
}

private extension GroupTripActivityDetailViewModel {
    func openCalendar() {
        actionDelegate?.showCalendarOption(for: .visitDate)
    }
    
    func openDueDateCalendar() {
        actionDelegate?.showCalendarOption(for: .dueDate)
    }
}
