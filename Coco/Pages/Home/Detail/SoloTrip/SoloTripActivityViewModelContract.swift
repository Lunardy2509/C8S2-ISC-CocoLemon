//
//  SoloTripActivityViewModelContract.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation

protocol SoloTripActivityDetailNavigationDelegate: AnyObject {
    func notifySoloTripActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int)
    func notifySoloTripCreateTripTapped()
}

protocol SoloTripActivityDetailViewModelAction: AnyObject {
    func configureView(data: ActivityDetailDataModel)
    func updatePackageData(data: [ActivityDetailDataModel.Package])
}

protocol SoloTripActivityDetailViewModelProtocol: AnyObject {
    var actionDelegate: SoloTripActivityDetailViewModelAction? { get set }
    var navigationDelegate: SoloTripActivityDetailNavigationDelegate? { get set }
    
    func onViewDidLoad()
    func onPackageDetailStateDidChange(shouldShowAll: Bool)
    func onPackagesDetailDidTap(with packageId: Int)
    func onCreateTripTapped()
}
