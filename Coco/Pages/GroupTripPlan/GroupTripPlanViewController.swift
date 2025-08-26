//
//  GroupTripPlanViewController.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 26/08/25.
//

import Foundation
import UIKit

final class GroupTripPlanViewController: UIViewController {
    private let viewModel: GroupTripPlanViewModelProtocol
    private lazy var thisView: GroupTripPlanView = GroupTripPlanView()
    
    init(viewModel: GroupTripPlanViewModelProtocol) {
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
        setupNavigationBar()
        thisView.delegate = self
        viewModel.onViewDidLoad()
        
        // Add Book Now button
        let bookNowButtonVC = CocoButtonHostingController(
            action: { [weak self] in
                self?.viewModel.onBookNowTapped()
            },
            text: "Book Now",
            style: .large,
            type: .primary,
            isStretch: true
        )
        addChild(bookNowButtonVC)
        thisView.addBookNowButton(button: bookNowButtonVC.view)
        bookNowButtonVC.didMove(toParent: self)
    }
    
    private func setupNavigationBar() {
        // Set the title from trip name
        title = viewModel.tripName
        
        // Add Edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            .foregroundColor: Token.mainColorPrimary,
            .font: UIFont.jakartaSans(forTextStyle: .body, weight: .medium)
        ], for: .normal)
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @objc private func editTapped() {
        viewModel.onEditTapped()
    }
}

extension GroupTripPlanViewController: GroupTripPlanViewModelAction {
    func configureView(data: GroupTripPlanDataModel) {
        thisView.configureView(data)
    }
}

extension GroupTripPlanViewController: GroupTripPlanViewDelegate {
    func notifyBookNowTapped() {
        viewModel.onBookNowTapped()
    }
    
    func notifyPackageVoteToggled(packageId: Int) {
        viewModel.onPackageVoteToggled(packageId: packageId)
    }
}
