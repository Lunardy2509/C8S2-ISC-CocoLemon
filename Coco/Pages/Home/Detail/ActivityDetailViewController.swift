//
//  ActivityDetailViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

final class ActivityDetailViewController: UIViewController {
    init(viewModel: ActivityDetailViewModelProtocol) {
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
        
        let createTripButtonVC = CocoButtonHostingController(
            action: { [weak self] in
                self?.viewModel.onCreateTripTapped()
            },
            text: "Create Trip",
            style: .large,
            type: .primary,
            isStretch: true
        )
        addChild(createTripButtonVC)
        thisView.addCreateTripButton(button: createTripButtonVC.view)
        createTripButtonVC.didMove(toParent: self)
    }
    
    private let viewModel: ActivityDetailViewModelProtocol
    private let thisView: ActivityDetailView = ActivityDetailView()
}

extension ActivityDetailViewController: ActivityDetailViewModelAction {
    func configureView(data: ActivityDetailDataModel) {
        thisView.configureView(data)
        
        if data.imageUrlsString.isEmpty {
            thisView.toggleImageSliderView(isShown: false)
        } else {
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
    
    func setupNavigation() {
        // Use native back button with custom text
        let backButton = UIBarButtonItem()
        backButton.title = "Home"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
}

extension ActivityDetailViewController: ActivityDetailViewDelegate {
    func notifyPackagesButtonDidTap(shouldShowAll: Bool) {
        viewModel.onPackageDetailStateDidChange(shouldShowAll: shouldShowAll)
    }
    
    func notifyPackagesDetailDidTap(with packageId: Int) {
        viewModel.onPackagesDetailDidTap(with: packageId)
    }
}
