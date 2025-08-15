//
//  HomeViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Combine
import Foundation

final class HomeViewModel {
    weak var actionDelegate: (any HomeViewModelAction)?
    weak var navigationDelegate: (any HomeViewModelNavigationDelegate)?
    
    init(activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.activityFetcher = activityFetcher
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private let activityFetcher: ActivityFetcherProtocol
    private(set) lazy var collectionViewModel: HomeCollectionViewModelProtocol = {
        let viewModel: HomeCollectionViewModel = HomeCollectionViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    private(set) lazy var loadingState: HomeLoadingState = HomeLoadingState()
    private(set) lazy var searchBarViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: CocoIcon.icSearchLoop.image,
        placeholderText: "Search...",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icFilterIcon.image,
            didTap: openFilterTray
        ),
        isTypeAble: false,
        delegate: self
    )
    
    private var responseMap: [Int: Activity] = [:]
    private var responseData: [Activity] = []
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var filterDataModel: HomeFilterTrayDataModel?
}

extension HomeViewModel: HomeViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.constructCollectionView(viewModel: collectionViewModel)
        actionDelegate?.constructLoadingState(state: loadingState)
        actionDelegate?.constructNavBar(viewModel: searchBarViewModel)
        
        fetch()
    }
    
    func onSearchDidApply(_ queryText: String) {
        searchBarViewModel.currentTypedText = queryText
        loadingState.percentage = 0
        actionDelegate?.toggleLoadingView(isShown: true, after: 0)
        fetch()
    }
    
    func openFilterTray() {
        guard let filterDataModel = filterDataModel else { return }
        
        // Create a copy with price range for the full filter tray
        let sortedData = responseData.sorted { $0.pricing < $1.pricing }
        let dataMinPrice: Double = sortedData.first?.pricing ?? 0
        let dataMaxPrice: Double = sortedData.last?.pricing ?? 0
        
        // Use existing price range if available, otherwise create new one with full data range
        let priceRangeModel: HomeFilterPriceRangeModel
        if let existingPriceRange = filterDataModel.priceRangeModel {
            // Keep the user's previously selected price range
            priceRangeModel = HomeFilterPriceRangeModel(
                minPrice: existingPriceRange.minPrice,
                maxPrice: existingPriceRange.maxPrice,
                range: dataMinPrice...dataMaxPrice,
                step: 50000 // Step of 50,000 for better UX
            )
        } else {
            // Create new price range model with full data range
            priceRangeModel = HomeFilterPriceRangeModel(
                minPrice: dataMinPrice,
                maxPrice: dataMaxPrice,
                range: dataMinPrice...dataMaxPrice,
                step: 50000
            )
        }
        
        let trayDataModel = HomeFilterTrayDataModel(
            filterPillDataState: filterDataModel.filterPillDataState,
            priceRangeModel: priceRangeModel
        )
        
        let viewModel: HomeFilterTrayViewModel = HomeFilterTrayViewModel(
            dataModel: trayDataModel,
            activities: Array(responseMap.values)
        )
        viewModel.filterDidApplyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newFilterData in
                guard let self else { return }
                // Store the complete filter data model including price range
                self.filterDataModel = newFilterData
                actionDelegate?.dismissTray()
                filterDidApply()
                
                // Update the home view carousel with applied filters (pills only for display)
                actionDelegate?.constructFilterCarousel(filterPillStates: newFilterData.filterPillDataState)
            }
            .store(in: &cancellables)

        actionDelegate?.openFilterTray(viewModel)
    }
    

    
    func onFilterDismiss(_ filterId: Int) {
        // Dismiss a specific filter from the home view carousel
        guard var filterDataModel = filterDataModel else { return }
        
        // Find and deselect the filter
        if let index = filterDataModel.filterPillDataState.firstIndex(where: { $0.id == filterId }) {
            filterDataModel.filterPillDataState[index].isSelected = false
        }
        
        self.filterDataModel = filterDataModel
        
        // Update filter carousel to reflect the change
        actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState)
        
        // Apply current filters immediately
        applyCurrentFilters()
    }
    
    func onResetAllFilters() {
        // Reset all filters including category pills and price range
        guard var filterDataModel = filterDataModel else { return }
        
        // Reset all filter pills to unselected state
        for i in 0..<filterDataModel.filterPillDataState.count {
            filterDataModel.filterPillDataState[i].isSelected = false
        }
        
        // Reset price range to default values
        if let priceRangeModel = filterDataModel.priceRangeModel {
            priceRangeModel.minPrice = priceRangeModel.range.lowerBound
            priceRangeModel.maxPrice = priceRangeModel.range.upperBound
        }
        
        self.filterDataModel = filterDataModel
        
        // Update filter carousel to reflect the change (should be empty now)
        actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState)
        
        // Apply current filters immediately (should show all activities)
        applyCurrentFilters()
    }
    
    func isPriceRangeFilterApplied() -> Bool {
        guard let priceRangeModel = filterDataModel?.priceRangeModel else { return false }
        return !priceRangeModel.isAtFullRange
    }
    
    private func filterDidApply() {
        guard let filterDataModel = filterDataModel else { return }
        
        // Check if all filters are reset (no pills selected and price range at full range)
        let isAllFiltersReset = filterDataModel.filterPillDataState.allSatisfy { !$0.isSelected } &&
                               (filterDataModel.priceRangeModel?.isAtFullRange ?? true)
        
        let tempResponseData: [Activity]
        if isAllFiltersReset {
            // Show all activities when filters are reset
            tempResponseData = responseData
        } else {
            // Apply filters normally
            tempResponseData = HomeFilterUtil.doFilter(
                responseData,
                filterDataModel: filterDataModel
            )
        }
        
        collectionViewModel.updateActivity(
            activity: (
                title: "",
                dataModel: tempResponseData.map {
                    HomeActivityCellDataModel(activity: $0)
                }
            )
        )
        
        // Update filter carousel with current filter states
        actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState)
    }
    
    private func applyCurrentFilters() {
        guard let filterDataModel = filterDataModel else { return }
        
        // Check if all filters are reset (no pills selected and price range at full range)
        let isAllFiltersReset = filterDataModel.filterPillDataState.allSatisfy { !$0.isSelected } &&
                               (filterDataModel.priceRangeModel?.isAtFullRange ?? true)
        
        let filteredActivities: [Activity]
        if isAllFiltersReset {
            // Show all activities when filters are reset
            filteredActivities = responseData
        } else {
            // Use the centralized filtering logic that handles both categories and price range
            filteredActivities = HomeFilterUtil.doFilter(
                responseData,
                filterDataModel: filterDataModel
            )
        }
        
        // Update collection view without title
        collectionViewModel.updateActivity(
            activity: (
                title: "",
                dataModel: filteredActivities.map { HomeActivityCellDataModel(activity: $0) }
            )
        )
        
        let selectedTitles = filterDataModel.filterPillDataState
            .filter { $0.isSelected }
            .map { $0.title }
        
        var filterInfo = "Applied filters: \(selectedTitles.joined(separator: ", "))"
        if let priceRange = filterDataModel.priceRangeModel {
            filterInfo += " | Price: Rp\(Int(priceRange.minPrice).formatted()) - Rp\(Int(priceRange.maxPrice).formatted())"
        }
        print(filterInfo)
    }
}

extension HomeViewModel: HomeCollectionViewModelDelegate {
    func notifyCollectionViewActivityDidTap(_ dataModel: HomeActivityCellDataModel) {
        guard let activity: Activity = responseMap[dataModel.id] else { return }
        let data: ActivityDetailDataModel = ActivityDetailDataModel(activity)
        actionDelegate?.activityDidSelect(data: data)
    }
}

extension HomeViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        guard !isTypeAble else { return }
        
        // TODO: Change with real data
        actionDelegate?.openSearchTray(
            selectedQuery: searchBarViewModel.currentTypedText,
            latestSearches: [
                .init(id: 1, name: "Kepulauan Seribu"),
                .init(id: 2, name: "Nusa Penida"),
                .init(id: 3, name: "Gili Island, Indonesia"),
            ]
        )
    }
}

private extension HomeViewModel {
    func fetch() {
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: searchBarViewModel.currentTypedText)
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.loadingState.percentage = 100
                self.actionDelegate?.toggleLoadingView(isShown: false, after: 1.0)
                
                var sectionData: [HomeActivityCellDataModel] = []
                response.values.forEach {
                    sectionData.append(HomeActivityCellDataModel(activity: $0))
                    self.responseMap[$0.id] = $0
                }
                responseData = response.values
                collectionViewModel.updateActivity(activity: (title: "", dataModel: sectionData))
                
                constructFilterData()
                
                // Only show applied filters in the carousel (initially none)
                if let filterDataModel = filterDataModel {
                    actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState)
                }
            case .failure(let failure):
                break
            }
        }
    }
    
    func constructFilterData() {
        let responseMapActivity: [Activity] = Array(responseMap.values)
        
        // Use only the 3 predefined categories
        let activityValues: [HomeFilterPillState] = [
            HomeFilterPillState(
                id: 1,
                title: "Snorkeling",
                isSelected: false
            ),
            HomeFilterPillState(
                id: 2,
                title: "Diving",
                isSelected: false
            ),
            HomeFilterPillState(
                id: 3,
                title: "Land Exploration",
                isSelected: false
            )
        ]
        
        let filterDataModel: HomeFilterTrayDataModel = HomeFilterTrayDataModel(
            filterPillDataState: activityValues
        )
        
        self.filterDataModel = filterDataModel
    }
}
