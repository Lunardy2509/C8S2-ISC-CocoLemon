//
//  GroupTripActivityDetailViewController.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation
import UIKit
import SwiftUI

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
        setupScheduleInputView()
    }
    
    private let viewModel: GroupTripActivityDetailViewModelProtocol
    private let thisView: GroupTripActivityDetailView = GroupTripActivityDetailView()
    
    private func setupScheduleInputView() {
        let inputView = HomeFormScheduleInputView(
            calendarViewModel: viewModel.calendarInputViewModel,
            paxInputViewModel: viewModel.paxInputViewModel,
            actionButtonAction: { },
            showActionButton: false
        )
        let hostingVC = UIHostingController(rootView: inputView)
        addChild(hostingVC)
        thisView.addScheduleInputView(with: hostingVC.view)
        hostingVC.didMove(toParent: self)
    }
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
    
    func showCalendarOption() {
        let calendarVC: CocoCalendarViewController = CocoCalendarViewController()
        calendarVC.delegate = self
        let popup: CocoPopupViewController = CocoPopupViewController(child: calendarVC)
        present(popup, animated: true)
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

extension GroupTripActivityDetailViewController: CocoCalendarViewControllerDelegate {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
        guard let date: Date else { return }
        viewModel.onCalendarDidChoose(date: date)
    }
}
