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
    private var currentSearchQuery: String = ""
    
    private(set) var filterDataModel: HomeFilterTrayDataModel?
}

extension HomeViewModel: HomeViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.constructCollectionView(viewModel: collectionViewModel)
        actionDelegate?.constructNavBar(viewModel: searchBarViewModel)
        
        fetch()
    }
    
    func onSearchDidApply(_ queryText: String) {
        searchBarViewModel.currentTypedText = queryText
        currentSearchQuery = queryText
        
        // Add search to CoreData history if not empty
        if !queryText.isEmpty {
            SearchHistoryManager.shared.addSearchHistory(queryText)
        }
        fetch()
    }
    
    func onSearchReset() {
        searchBarViewModel.currentTypedText = ""
        currentSearchQuery = ""
        fetch()
    }
    
    func removeSearchFromHistory(_ searchData: HomeSearchSearchLocationData) {
        // Use the search text directly for removal
        SearchHistoryManager.shared.removeSearchHistory(searchData.name)
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
            priceRangeModel: priceRangeModel,
            filterDestinationPillState: filterDataModel.filterDestinationPillState
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
                
                self.filterDidApply()
                    
                self.actionDelegate?.constructFilterCarousel(filterPillStates: newFilterData.filterPillDataState, filterDestinationPillStates: newFilterData.filterDestinationPillState)
            }
            .store(in: &cancellables)

        actionDelegate?.openFilterTray(viewModel)
    }
    
    func onFilterDismiss(_ filterId: Int) {
        // Dismiss a specific filter from the home view carousel
        guard let filterDataModel = filterDataModel else { return }
        
        // Special handling for price range filter
        if filterId == -1 {
            // Reset price range to full range
            filterDataModel.priceRangeModel?.resetToFullRange()
        } else {
            // Find and deselect the filter - check both activity and destination filters
            if let index = filterDataModel.filterPillDataState.firstIndex(where: { $0.id == filterId }) {
                filterDataModel.filterPillDataState[index].isSelected = false
            } else if let index = filterDataModel.filterDestinationPillState.firstIndex(where: { $0.id == filterId }) {
                filterDataModel.filterDestinationPillState[index].isSelected = false
            }
        }
        
        self.filterDataModel = filterDataModel
        
        // Update filter carousel to reflect the change
        actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState, filterDestinationPillStates: filterDataModel.filterDestinationPillState)
        
        // Apply current filters immediately
        applyCurrentFilters()
    }
    
    func onResetAllFilters() {
        // Reset all filters including category pills, destination pills and price range
        guard let filterDataModel = filterDataModel else { return }
        
        // Reset all filter pills to unselected state
        for i in 0..<filterDataModel.filterPillDataState.count {
            filterDataModel.filterPillDataState[i].isSelected = false
        }
        
        // Reset all destination filter pills to unselected state
        for i in 0..<filterDataModel.filterDestinationPillState.count {
            filterDataModel.filterDestinationPillState[i].isSelected = false
        }
        
        // Reset price range to default values
        if let priceRangeModel = filterDataModel.priceRangeModel {
            priceRangeModel.minPrice = priceRangeModel.range.lowerBound
            priceRangeModel.maxPrice = priceRangeModel.range.upperBound
        }
        
        self.filterDataModel = filterDataModel
        
        // Also clear search query and search bar text to completely reset the view
        searchBarViewModel.currentTypedText = ""
        currentSearchQuery = ""
        
        // Update filter carousel to reflect the change (should be empty now)
        actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState, filterDestinationPillStates: filterDataModel.filterDestinationPillState)
        
        fetch()
    }
    
    func isPriceRangeFilterApplied() -> Bool {
        guard let priceRangeModel = filterDataModel?.priceRangeModel else { return false }
        return !priceRangeModel.isAtFullRange
    }
    
    func getPriceRangeText() -> String? {
        guard let priceRangeModel = filterDataModel?.priceRangeModel,
              !priceRangeModel.isAtFullRange else { return nil }
        
        let minPriceText = String(format: "%.0f", priceRangeModel.minPrice)
        let maxPriceText = String(format: "%.0f", priceRangeModel.maxPrice)
        return "Rp\(minPriceText) - Rp\(maxPriceText)"
    }
    
    private func filterDidApply() {
        guard let filterDataModel = filterDataModel else { return }
        
        // Check if all filters are reset (no pills selected and price range at full range)
        let isAllFiltersReset = filterDataModel.filterPillDataState.allSatisfy { !$0.isSelected } &&
                               filterDataModel.filterDestinationPillState.allSatisfy { !$0.isSelected } &&
                               (filterDataModel.priceRangeModel?.isAtFullRange ?? true)
        
        let tempResponseData: [Activity]
        let sectionTitle: String
        if isAllFiltersReset {
            // Show all activities when filters are reset
            tempResponseData = responseData
            sectionTitle = "Most Popular"
        } else {
            // Apply filters normally
            tempResponseData = HomeFilterUtil.doFilter(
                responseData,
                filterDataModel: filterDataModel
            )
            sectionTitle = "Your Result"
        }
        
        collectionViewModel.updateActivity(
            activity: (
                title: sectionTitle,
                dataModel: tempResponseData.map {
                    HomeActivityCellDataModel(activity: $0)
                }
            ),
            isFromSearch: !currentSearchQuery.isEmpty
        )
        
        // Update filter carousel with current filter states
        actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState, filterDestinationPillStates: filterDataModel.filterDestinationPillState)
    }
    
    private func applyCurrentFilters() {
        guard let filterDataModel = filterDataModel else { return }
        
        // Check if all filters are reset (no pills selected and price range at full range)
        let isAllFiltersReset = filterDataModel.filterPillDataState.allSatisfy { !$0.isSelected } &&
                               filterDataModel.filterDestinationPillState.allSatisfy { !$0.isSelected } &&
                               (filterDataModel.priceRangeModel?.isAtFullRange ?? true)
        
        // Check if there's an active search query
        let hasActiveSearch = !currentSearchQuery.isEmpty
        
        let filteredActivities: [Activity]
        let sectionTitle: String
        
        if isAllFiltersReset && !hasActiveSearch {
            // Show all activities when both filters and search are reset
            filteredActivities = responseData
            sectionTitle = "Most Popular"
        } else {
            // Use the centralized filtering logic that handles both categories and price range
            filteredActivities = HomeFilterUtil.doFilter(
                responseData,
                filterDataModel: filterDataModel
            )
            sectionTitle = "Your Result"
        }
        
        // Update collection view with appropriate title
        collectionViewModel.updateActivity(
            activity: (
                title: sectionTitle,
                dataModel: filteredActivities.map { HomeActivityCellDataModel(activity: $0) }
            ),
            isFromSearch: hasActiveSearch
        )
        
        let selectedTitles = filterDataModel.filterPillDataState
            .filter { $0.isSelected }
            .map { $0.title }
        
        var filterInfo = "Applied filters: \(selectedTitles.joined(separator: ", "))"
        if let priceRange = filterDataModel.priceRangeModel {
            filterInfo += " | Price: \(priceRange.minPrice.toRupiah()) - \(priceRange.maxPrice.toRupiah())"
        }
    }
}

extension HomeViewModel: HomeCollectionViewModelDelegate {
    func notifyCollectionViewActivityDidTap(_ dataModel: HomeActivityCellDataModel) {
        guard let activity: Activity = responseMap[dataModel.id] else { return }
        let data: ActivityDetailDataModel = ActivityDetailDataModel(activity)
        actionDelegate?.activityDidSelect(data: data)
    }
    
    func notifyCollectionViewClearAllFilters() {
        onResetAllFilters()
    }
}

extension HomeViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        guard !isTypeAble else { return }
        
        // Use CoreData search history
        let searchHistory = SearchHistoryManager.shared.getSearchHistory()
        actionDelegate?.openSearchTray(
            selectedQuery: searchBarViewModel.currentTypedText,
            latestSearches: searchHistory
        )
    }
}

private extension HomeViewModel {
    func fetch() {
        // Always fetch the full dataset to enable local filtering for location parts
        // This ensures we can search for extracted location parts like "Aceh", "Bali" etc.
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: "")
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                
                // Store the full response data first
                let allActivities = response.values
                
                // Get the current search text for local filtering
                let searchText = currentSearchQuery.isEmpty ? searchBarViewModel.currentTypedText : currentSearchQuery
                
                var sectionData: [HomeActivityCellDataModel] = []
                
                // Filter activities based on search text including destination names
                let filteredActivities = allActivities.filter { activity in
                    if searchText.isEmpty {
                        return true
                    }
                    
                    let searchTextLowercased = searchText.lowercased()
                    let activityTitleMatch = activity.title.lowercased().contains(searchTextLowercased)
                    let destinationNameMatch = activity.destination.name.lowercased().contains(searchTextLowercased)
                    
                    // Also check if search matches the extracted location part (after comma)
                    let extractedLocation = self.extractLocationFromDestination(activity.destination.name)
                    let locationPartMatch = extractedLocation.lowercased().contains(searchTextLowercased)
                    
                    return activityTitleMatch || destinationNameMatch || locationPartMatch
                }
                
                filteredActivities.forEach {
                    sectionData.append(HomeActivityCellDataModel(activity: $0))
                }
                
                // Store all activities in responseMap for detail navigation
                allActivities.forEach {
                    self.responseMap[$0.id] = $0
                }
                
                // Store all activities for filter construction (not just filtered ones)
                responseData = allActivities
                
                // Set section title based on whether there's an active search
                let sectionTitle = searchText.isEmpty ? "Most Popular" : "Your Result"
                collectionViewModel.updateActivity(
                    activity: (title: sectionTitle, dataModel: sectionData),
                    isFromSearch: !searchText.isEmpty
                )
                
                constructFilterData()
                
                // Only show applied filters in the carousel (initially none)
                if let filterDataModel = filterDataModel {
                    actionDelegate?.constructFilterCarousel(filterPillStates: filterDataModel.filterPillDataState, filterDestinationPillStates: filterDataModel.filterDestinationPillState)
                }
            case .failure:
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
        
        // Create destination filter pills from unique locations
        let uniqueDestinations = Set(responseMapActivity.map { extractLocationFromDestination($0.destination.name) })
        let destinationValues: [HomeFilterDestinationPillState] = uniqueDestinations.enumerated().map { index, location in
            HomeFilterDestinationPillState(
                id: index + 100, // Offset to avoid conflicts with activity filter IDs
                title: location,
                isSelected: false
            )
        }
        
        let filterDataModel: HomeFilterTrayDataModel = HomeFilterTrayDataModel(
            filterPillDataState: activityValues,
            filterDestinationPillState: destinationValues
        )
        
        self.filterDataModel = filterDataModel
    }
    
    /// Extracts location from destination name by taking the part after the comma
    /// E.g., "Raja Ampat, West Papua" -> "West Papua"
    private func extractLocationFromDestination(_ destinationName: String) -> String {
        let components = destinationName.components(separatedBy: ",")
        if components.count > 1 {
            return components[1].trimmingCharacters(in: .whitespaces)
        }
        return destinationName.trimmingCharacters(in: .whitespaces)
    }
}
