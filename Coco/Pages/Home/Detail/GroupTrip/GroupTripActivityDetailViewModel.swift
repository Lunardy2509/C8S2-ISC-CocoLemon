//
//  GroupTripActivityDetailViewModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation

final class GroupTripActivityDetailViewModel: NSObject {
    weak var actionDelegate: GroupTripActivityDetailViewModelAction?
    weak var navigationDelegate: GroupTripActivityDetailNavigationDelegate?
    
    init(data: ActivityDetailDataModel) {
        self.data = data
    }
    
    private let data: ActivityDetailDataModel
    
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
    private(set) lazy var paxInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Input total Pax...",
        currentTypedText: "",
        trailingIcon: nil,
        isTypeAble: true,
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
}

extension GroupTripActivityDetailViewModel: GroupTripActivityDetailViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.configureView(data: data)
    }
    
    func onPackageDetailStateDidChange(shouldShowAll: Bool) {
        actionDelegate?.updatePackageData(data: shouldShowAll ? data.availablePackages.content : data.hiddenPackages)
    }
    
    func onPackagesDetailDidTap(with packageId: Int) {
        navigationDelegate?.notifyGroupTripActivityDetailPackageDidSelect(package: data, selectedPackageId: packageId)
    }
    
    func onCreateTripTapped() {
        navigationDelegate?.notifyGroupTripCreateTripTapped()
    }
    
    func onCalendarDidChoose(date: Date) {
        chosenDateInput = date
    }
}

extension GroupTripActivityDetailViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption()
        }
    }
}

private extension GroupTripActivityDetailViewModel {
    func openCalendar() {
        actionDelegate?.showCalendarOption()
    }
}
