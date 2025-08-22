//
//  GroupTripActivityDetailViewModelContract.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation

protocol GroupTripActivityDetailNavigationDelegate: AnyObject {
    func notifyGroupTripActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int)
    func notifyGroupTripCreateTripTapped()
}

protocol GroupTripActivityDetailViewModelAction: AnyObject {
    func configureView(data: ActivityDetailDataModel)
    func updatePackageData(data: [ActivityDetailDataModel.Package])
    func showCalendarOption()
}

protocol GroupTripActivityDetailViewModelProtocol: AnyObject {
    var actionDelegate: GroupTripActivityDetailViewModelAction? { get set }
    var navigationDelegate: GroupTripActivityDetailNavigationDelegate? { get set }
    
    var calendarInputViewModel: HomeSearchBarViewModel { get }
    var paxInputViewModel: HomeSearchBarViewModel { get }
    
    func onViewDidLoad()
    func onPackageDetailStateDidChange(shouldShowAll: Bool)
    func onPackagesDetailDidTap(with packageId: Int)
    func onCreateTripTapped()
    func onCalendarDidChoose(date: Date)
}
