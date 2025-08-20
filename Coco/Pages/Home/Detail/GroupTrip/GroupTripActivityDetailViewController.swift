//
//  GroupTripActivityDetailViewController.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation
import UIKit

final class GroupTripActivityDetailViewController: UIViewController {
    init(viewModel: GroupTripActivityDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thisView.delegate = self
        viewModel.onViewDidLoad()
    }
    
    private let viewModel: GroupTripActivityDetailViewModelProtocol
    private let thisView: GroupTripActivityDetailView = GroupTripActivityDetailView()
}

extension GroupTripActivityDetailViewController: GroupTripActivityDetailViewModelAction {
    func configureView(data: ActivityDetailDataModel) {
        thisView.configureView(data)
        
        if data.imageUrlsString.isEmpty {
            thisView.toggleImageSliderView(isShown: false)
        }
        else {
            thisView.toggleImageSliderView(isShown: true)
            let sliderVCs: ImageSliderHostingController = ImageSliderHostingController(images: data.imageUrlsString)
            addChild(sliderVCs)
            thisView.addImageSliderView(with: sliderVCs.view)
            sliderVCs.didMove(toParent: self)
        }
    }
    
    func updatePackageData(data: [ActivityDetailDataModel.Package]) {
        thisView.updatePackageData(data)
    }
}

extension GroupTripActivityDetailViewController: GroupTripActivityDetailViewDelegate {
    func notifyPackagesButtonDidTap(shouldShowAll: Bool) {
        viewModel.onPackageDetailStateDidChange(shouldShowAll: shouldShowAll)
    }
    
    func notifyPackagesDetailDidTap(with packageId: Int) {
        viewModel.onPackagesDetailDidTap(with: packageId)
    }
}
