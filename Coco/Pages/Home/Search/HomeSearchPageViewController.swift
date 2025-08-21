//
//  HomeSearchPageViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/01/25.
//

import Foundation
import SwiftUI
import UIKit

final class HomeSearchPageViewController: UIViewController {
    private let selectedQuery: String
    private let latestSearches: [HomeSearchSearchLocationData]
    private let searchDidApply: ((_ query: String) -> Void)
    private let onSearchHistoryRemove: ((_ searchData: HomeSearchSearchLocationData) -> Void)?
    private let onSearchReset: (() -> Void)?
    
    init(
        selectedQuery: String,
        latestSearches: [HomeSearchSearchLocationData],
        searchDidApply: @escaping (_: String) -> Void,
        onSearchHistoryRemove: ((_ searchData: HomeSearchSearchLocationData) -> Void)? = nil,
        onSearchReset: (() -> Void)? = nil
    ) {
        self.selectedQuery = selectedQuery
        self.latestSearches = latestSearches
        self.searchDidApply = searchDidApply
        self.onSearchHistoryRemove = onSearchHistoryRemove
        self.onSearchReset = onSearchReset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        let searchTrayView = HomeSearchSearchTray(
            selectedQuery: selectedQuery,
            latestSearches: latestSearches,
            searchDidApply: { [weak self] queryText in
                self?.navigationController?.popViewController(animated: true)
                self?.searchDidApply(queryText)
            },
            onSearchHistoryRemove: onSearchHistoryRemove,
            onSearchReset: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.onSearchReset?()
            }
        )
        
        let hostingController = UIHostingController(rootView: searchTrayView)
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
    
    private func setupNavigation() {
        title = ""
        
        // Custom Back Button
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setTitle(" Home", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func backButtonTapped() {
        // Reset search when going back
        onSearchReset?()
        navigationController?.popViewController(animated: true)
    }
}
