//
//  SoloTripActivityDetailViewModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation

final class SoloTripActivityDetailViewModel {
    weak var actionDelegate: SoloTripActivityDetailViewModelAction?
    weak var navigationDelegate: SoloTripActivityDetailNavigationDelegate?
    
    init(data: ActivityDetailDataModel) {
        self.data = data
    }
    
    private let data: ActivityDetailDataModel
}

extension SoloTripActivityDetailViewModel: SoloTripActivityDetailViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.configureView(data: data)
    }
    
    func onPackageDetailStateDidChange(shouldShowAll: Bool) {
        actionDelegate?.updatePackageData(data: shouldShowAll ? data.availablePackages.content : data.hiddenPackages)
    }
    
    func onPackagesDetailDidTap(with packageId: Int) {
        navigationDelegate?.notifySoloTripActivityDetailPackageDidSelect(package: data, selectedPackageId: packageId)
    }
    
    func onCreateTripTapped() {
        navigationDelegate?.notifySoloTripCreateTripTapped()
    }
}
