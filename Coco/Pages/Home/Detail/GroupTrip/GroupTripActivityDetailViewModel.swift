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
    
    init(data: ActivityDetailDataModel) {
        self.data = data
    }
    
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
