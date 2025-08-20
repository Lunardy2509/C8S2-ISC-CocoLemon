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
}
