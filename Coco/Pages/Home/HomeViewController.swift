//
//  HomeViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 02/07/25.
//

import Foundation
import SwiftUI
import UIKit

final class HomeViewController: UIViewController {
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
    }
    
    override func loadView() {
        view = thisView
    }
    
    private let thisView: HomeView = HomeView()
    private let viewModel: HomeViewModelProtocol
}

extension HomeViewController: HomeViewModelAction {
    func constructCollectionView(viewModel: some HomeCollectionViewModelProtocol) {
        let collectionViewController: HomeCollectionViewController = HomeCollectionViewController(viewModel: viewModel)
        addChild(collectionViewController)
        thisView.addSearchResultView(from: collectionViewController.view)
        collectionViewController.didMove(toParent: self)
    }
    
    func constructLoadingState(state: HomeLoadingState) {
        let viewController: UIHostingController = UIHostingController(rootView: HomeLoadingView(state: state))
        addChild(viewController)
        thisView.addLoadingView(from: viewController.view)
        viewController.didMove(toParent: self)
        
        thisView.toggleLoadingView(isShown: true)
    }
    
    func constructNavBar(viewModel: HomeSearchBarViewModel) {
        let viewController: HomeSearchBarHostingController = HomeSearchBarHostingController(
            viewModel: viewModel,
            onReturnKeyAction: { [weak self] in
                // Handle return key press if needed - could trigger search or open search tray
                if !viewModel.currentTypedText.isEmpty {
                    self?.viewModel.onSearchDidApply(viewModel.currentTypedText)
                }
            },
            onClearAction: { [weak self] in
                self?.viewModel.onSearchReset()
            }
        )
        addChild(viewController)
        thisView.addSearchBarView(from: viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func constructFilterCarousel(filterPillStates: [HomeFilterPillState], filterDestinationPillStates: [HomeFilterDestinationPillState]) {
        // Only show applied filters (isSelected = true) in the home view carousel
        let appliedActivityFilters = filterPillStates.filter { $0.isSelected }
        let appliedDestinationFilters = filterDestinationPillStates.filter { $0.isSelected }
        let isPriceRangeApplied = viewModel.isPriceRangeFilterApplied()
        let priceRangeText = viewModel.getPriceRangeText()
        
        let appliedFilterCarouselView = HomeAppliedFilterCarouselView(
            appliedActivityFilters: appliedActivityFilters,
            appliedDestinationFilters: appliedDestinationFilters,
            isPriceRangeApplied: isPriceRangeApplied,
            priceRangeText: priceRangeText,
            onFilterDismiss: { [weak self] filterId in
                self?.viewModel.onFilterDismiss(filterId)
            }
        )
        let viewController: UIHostingController = UIHostingController(rootView: appliedFilterCarouselView)
        addChild(viewController)
        thisView.addFilterView(from: viewController.view)
        viewController.didMove(toParent: self)
        
        thisView.toggleFilterView(isShown: !appliedActivityFilters.isEmpty || !appliedDestinationFilters.isEmpty || isPriceRangeApplied)
    }
    
    func toggleLoadingView(isShown: Bool, after: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: { [weak self] in
            guard let self = self else { return }
            self.thisView.toggleLoadingView(isShown: isShown)
        })
    }
    
    func activityDidSelect(data: ActivityDetailDataModel) {
        guard let navigationController = navigationController else { return }
        let coordinator: HomeCoordinator = HomeCoordinator(
            input: .init(
                navigationController: navigationController,
                flow: .activityDetail(data: data)
            )
        )
        coordinator.parentCoordinator = AppCoordinator.shared
        coordinator.start()
    }
    
    func openSearchTray(
        selectedQuery: String,
        latestSearches: [HomeSearchSearchLocationData]
    ) {
        let searchTrayView = HomeSearchSearchTray(
            selectedQuery: selectedQuery,
            latestSearches: latestSearches,
            searchDidApply: { [weak self] queryText in
                self?.dismiss(animated: true) {
                    self?.viewModel.onSearchDidApply(queryText)
                }
            },
            onSearchHistoryRemove: { [weak self] searchData in
                self?.viewModel.removeSearchFromHistory(searchData)
            },
            onSearchReset: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.viewModel.onSearchReset()
                }
            }
        )
        
        presentTray(view: searchTrayView)
    }
    
    func openFilterTray(_ viewModel: HomeFilterTrayViewModel) {
        presentTray(view: HomeFilterTray(viewModel: viewModel))
    }
    
    func dismissTray() {
        dismiss(animated: true)
    }
}

private extension HomeViewController {
    func presentTray(view: some View) {
        let trayVC: UIHostingController = UIHostingController(rootView: view)
        if let sheet: UISheetPresentationController = trayVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 32.0
        }
        present(trayVC, animated: true)
    }
}
