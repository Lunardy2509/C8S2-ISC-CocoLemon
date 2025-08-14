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
    
    private(set) var filterDataModel: HomeSearchFilterTrayDataModel?
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
        let minPrice: Double = sortedData.first?.pricing ?? 0
        let maxPrice: Double = sortedData.last?.pricing ?? 0
        
        let priceRangeModel = HomeSearchFilterPriceRangeModel(
            minPrice: minPrice,
            maxPrice: maxPrice,
            range: minPrice...maxPrice
        )
        
        let trayDataModel = HomeSearchFilterTrayDataModel(
            filterPillDataState: filterDataModel.filterPillDataState,
            priceRangeModel: priceRangeModel
        )
        
        let viewModel: HomeSearchFilterTrayViewModel = HomeSearchFilterTrayViewModel(
            dataModel: trayDataModel,
            activities: Array(responseMap.values)
        )
        viewModel.filterDidApplyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newFilterData in
                guard let self else { return }
                // Keep only the filter pills, not the price range for carousel
                let carouselDataModel = HomeSearchFilterTrayDataModel(
                    filterPillDataState: newFilterData.filterPillDataState,
                    priceRangeModel: nil
                )
                self.filterDataModel = carouselDataModel
                actionDelegate?.dismissTray()
                filterDidApply()
                
                // Update the home view carousel with applied filters
                actionDelegate?.constructFilterCarousel(filterPillStates: carouselDataModel.filterPillDataState)
            }
            .store(in: &cancellables)

        actionDelegate?.openFilterTray(viewModel)
    }
    
    func onCategoryFilterSelected(_ filterState: HomeSearchFilterPillState) {
        // This method is now only used for filter tray interactions
        // Toggle the selected state
        filterState.isSelected.toggle()
        
        // Update the filter data model with the new state
        guard var filterDataModel = filterDataModel else { return }
        
        // Find and update the corresponding filter pill state in the data model
        if let index = filterDataModel.filterPillDataState.firstIndex(where: { $0.id == filterState.id }) {
            filterDataModel.filterPillDataState[index] = filterState
        }
        
        self.filterDataModel = filterDataModel
    }
    
    func onCategoryFilterSelectedById(_ filterId: Int) {
        // This method is now only used for filter tray interactions
        guard var filterDataModel = filterDataModel else { return }
        
        // Find and toggle the filter state by ID
        if let index = filterDataModel.filterPillDataState.firstIndex(where: { $0.id == filterId }) {
            filterDataModel.filterPillDataState[index].isSelected.toggle()
        }
        
        self.filterDataModel = filterDataModel
    }
    
    func onFilterDismiss(_ filterId: Int) {
        // Dismiss a specific filter from the home view carousel
        guard var filterDataModel = filterDataModel else { return }
        
        // Find and deselect the filter
        if let index = filterDataModel.filterPillDataState.firstIndex(where: { $0.id == filterId }) {
            filterDataModel.filterPillDataState[index].isSelected = false
            print("Filter dismissed: \(filterDataModel.filterPillDataState[index].title)")
        }
        
        self.filterDataModel = filterDataModel
        
        // Update filter carousel to reflect the change
        actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState)
        
        // Apply current filters immediately
        applyCurrentFilters()
    }
    
    private func filterDidApply() {
        guard let filterDataModel = filterDataModel else { return }
        let tempResponseData: [Activity] = HomeFilterUtil.doFilter(
            responseData,
            filterDataModel: filterDataModel
        )
        
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
        
        // Get selected categories
        let selectedCategoryIds = filterDataModel.filterPillDataState
            .filter { $0.isSelected }
            .map { $0.id }
        
        var filteredActivities: [Activity] = responseData
        
        // Filter by selected categories if any are selected
        if !selectedCategoryIds.isEmpty {
            filteredActivities = filteredActivities.filter { activity in
                selectedCategoryIds.contains(activity.category.id)
            }
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
        print("Applied filters: \(selectedTitles.joined(separator: ", "))")
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
        let activityValues: [HomeSearchFilterPillState] = [
            HomeSearchFilterPillState(
                id: 1,
                title: "Snorkeling",
                isSelected: false
            ),
            HomeSearchFilterPillState(
                id: 2,
                title: "Diving",
                isSelected: false
            ),
            HomeSearchFilterPillState(
                id: 3,
                title: "Land Exploration",
                isSelected: false
            )
        ]
        
        let filterDataModel: HomeSearchFilterTrayDataModel = HomeSearchFilterTrayDataModel(
            filterPillDataState: activityValues
        )
        
        self.filterDataModel = filterDataModel
    }
}
