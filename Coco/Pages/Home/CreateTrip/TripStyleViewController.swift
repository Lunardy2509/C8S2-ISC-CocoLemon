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

    init(didSelectStyle: @escaping (TripStyle) -> Void) {
        self.didSelectStyle = didSelectStyle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Trip"
        view.backgroundColor = .systemBackground
        
        let tripStyleView = TripStylePopUpView { [weak self] style in
            self?.didSelectStyle(style)
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
}
