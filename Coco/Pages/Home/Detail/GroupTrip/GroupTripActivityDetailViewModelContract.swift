//
//  GroupTripActivityDetailViewModelContract.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation

protocol GroupTripActivityDetailNavigationDelegate: AnyObject {
    func notifyGroupTripCreateTripTapped()
}

enum CalendarType {
    case visitDate
    case dueDate
}

protocol GroupTripActivityDetailViewModelAction: AnyObject {
    func configureView(data: ActivityDetailDataModel)
    func updatePackageData(data: [ActivityDetailDataModel.Package])
    func showCalendarOption(for type: CalendarType)
    func showSearchActivityTray()
    func showSearchBar()
    func showSearchResults(_ activities: [Activity])
}

protocol GroupTripActivityDetailViewModelProtocol: AnyObject {
    var actionDelegate: GroupTripActivityDetailViewModelAction? { get set }
    var navigationDelegate: GroupTripActivityDetailNavigationDelegate? { get set }
    
    var tripNameInputViewModel: HomeSearchBarViewModel { get }
    var calendarInputViewModel: HomeSearchBarViewModel { get }
    var dueDateInputViewModel: HomeSearchBarViewModel { get }
    
    func onViewDidLoad()
    func onPackageDetailStateDidChange(shouldShowAll: Bool)
    func onPackagesDetailDidTap(with packageId: Int)
    func onCreateTripTapped()
    func onCalendarDidChoose(date: Date, for type: CalendarType)
    func getSelectedPackageIds() -> Set<Int> 
    func onRemoveActivityTapped()
    func onSearchActivitySelected(_ newActivity: ActivityDetailDataModel)
    func onSearchDidApply(_ queryText: String)
}
