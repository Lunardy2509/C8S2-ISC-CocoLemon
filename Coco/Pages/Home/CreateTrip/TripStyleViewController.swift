//
//  TripStylePopUpView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 24/08/25.
//

import UIKit
import SwiftUI

final class TripStyleViewController: UIViewController {
    private let didSelectStyle: (TripStyle) -> Void
    private let activityData: ActivityDetailDataModel?

    init(didSelectStyle: @escaping (TripStyle) -> Void, activityData: ActivityDetailDataModel? = nil) {
        self.didSelectStyle = didSelectStyle
        self.activityData = activityData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Trip"
        setupNavigation()
        view.backgroundColor = .systemBackground
        
        let tripStyleView = TripStylePopUpView { [weak self] style in
            self?.handleTripStyleSelection(style)
        }
        
        let hostingController = UIHostingController(rootView: tripStyleView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupNavigation() {
        let backButton = UIBarButtonItem()
        backButton.title = "Detail"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func handleTripStyleSelection(_ style: TripStyle) {
        switch style {
        case .group:
            // Navigate to GroupFormViewController with pre-selected activity data
            let groupFormVC: GroupFormViewController
            
            if let activityData = activityData {
                // Pass the activity data to pre-select the destination
                groupFormVC = GroupFormViewController(preSelectedActivity: activityData)
            } else {
                // No activity data, create normal GroupForm
                groupFormVC = GroupFormViewController()
            }
            
            groupFormVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(groupFormVC, animated: true)
        case .solo:
            // Handle solo trip selection - call the original callback
            didSelectStyle(style)
        }
    }
}
