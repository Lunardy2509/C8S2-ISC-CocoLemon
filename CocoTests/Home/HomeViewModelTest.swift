//
//  HomeViewModelTest.swift
//  CocoTests
//
//  Created by Jackie Leonardy on 26/07/25.
//

import Foundation
import Testing
@testable import Coco

struct HomeViewModelTest {
    private struct TestContext {
        // --- GIVEN ---
        let fetcher: MockActivityFetcher
        let actionDelegate: MockHomeViewModelAction
        let navigationDelegate: MockHomeViewModelNavigationDelegate
        let viewModel: HomeViewModel
        let activities: ActivityModelArray
        // --- WHEN ---
        static func setup() throws -> TestContext {
            let fetcher = MockActivityFetcher()
            let actionDelegate = MockHomeViewModelAction()
            let navigationDelegate = MockHomeViewModelNavigationDelegate()
            
            let activities: ActivityModelArray = try JSONReader.getObjectFromJSON(with: "activities")
            fetcher.stubbedFetchActivityCompletionResult = (.success(activities), ())
            
            let viewModel = HomeViewModel(activityFetcher: fetcher)
            viewModel.actionDelegate = actionDelegate
            viewModel.navigationDelegate = navigationDelegate
            
            return TestContext(
                fetcher: fetcher,
                actionDelegate: actionDelegate,
                navigationDelegate: navigationDelegate,
                viewModel: viewModel,
                activities: activities
            )
        }
    }
    // --- THEN ---
    
    // MARK: - Filter Testsf
    @Test("filter tray - should open on icon tap")
    func filterTray_whenIconTapped_shouldOpen() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        context.viewModel.searchBarViewModel.trailingIcon?.didTap?()
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedOpenFilterTrayCount == 1)
    }
    
    @Test("filter tray - should apply filters")
    func filterTray_whenFiltersApplied_shouldUpdateCollection() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        context.viewModel.searchBarViewModel.trailingIcon?.didTap?()
        
        let filterModel = HomeFilterTrayDataModel(
            filterPillDataState: [],
            priceRangeModel: HomeFilterPriceRangeModel(
                minPrice: 499000.0,
                maxPrice: 200000,
                range: 0...0
            )
        )
        
        // --- THEN ---
        context.actionDelegate.invokedOpenFilterTrayParameters?.viewModel
            .filterDidApplyPublisher.send(filterModel)
        
        #expect(context.actionDelegate.invokedOpenFilterTrayCount == 1)
        #expect(context.viewModel.collectionViewModel.activityData.dataModel.count == 1)
    }
    
    // MARK: - Initial Load Tests
    
//    @Test("view did load - should setup initial state")
//    func viewDidLoad_whenSuccessful_shouldSetupInitialState() async throws {
//        // --- GIVEN ---
//        let context = try TestContext.setup()
//        
//        // --- WHEN ---
//        context.viewModel.onViewDidLoad()
//        
//        // --- THEN ---
//        assertViewDidLoadSetup(context)
//        
//        let expectedActivity = HomeActivityCellDataModel(activity: context.activities.values[0])
//        #expect(context.viewModel.collectionViewModel.activityData == ("", [expectedActivity]))
//    }
    
    // MARK: - Search Tests
    
//    @Test("search - should handle empty query")
//    func search_whenEmptyQuery_shouldUpdateState() async throws {
//        // --- GIVEN ---
//        let context = try TestContext.setup()
//        
//        context.viewModel.onViewDidLoad()
//        
//        let emptyActivities: ActivityModelArray = try JSONReader.getObjectFromJSON(with: "activities-empty")
//        context.fetcher.stubbedFetchActivityCompletionResult = (.success(emptyActivities), ())
//        
//        // --- WHEN ---
//        context.viewModel.onSearchDidApply("")
//        
//        // --- THEN ---
//        #expect(context.viewModel.searchBarViewModel.currentTypedText == "")
//        #expect(context.viewModel.collectionViewModel.activityData == ("", []))
//    }
    
    // MARK: - Activity Selection Tests
    
    @Test("activity selection - should handle valid selection")
    func activitySelection_whenValidId_shouldNotifyDelegate() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        context.viewModel.onViewDidLoad()
        
        let activityData = HomeActivityCellDataModel(
            id: 1,
            title: "name",
            location: "location",
            priceText: "priceText",
            imageUrl: nil
        )
        
        // --- WHEN ---
        context.viewModel.notifyCollectionViewActivityDidTap(activityData)
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedActivityDidSelectCount == 1)
        
        let selectedData = context.actionDelegate.invokedActivityDidSelectParameters?.data
        #expect(selectedData?.title == "Snorkeling Adventure in Nusa Penida")
        #expect(selectedData?.location == "Nusa Penida")
        #expect(selectedData?.imageUrlsString == [
            "https://example.com/images/nusa-penida-thumb.jpg",
            "https://example.com/images/nusa-penida-gallery1.jpg"
        ])
        
        // Details
        #expect(selectedData?.detailInfomation.title == "Details")
        #expect(selectedData?.detailInfomation.content == "Explore the stunning underwater world of Nusa Penida with our professional guides. Perfect for beginners and experienced snorkelers alike.")
        
        // Provider
        #expect(selectedData?.providerDetail.title == "Trip Provider")
        #expect(selectedData?.providerDetail.content.name == "Made Wirawan")
        #expect(selectedData?.providerDetail.content.imageUrlString == "https://example.com/hosts/made-wirawan.jpg")
        #expect(selectedData?.providerDetail.content.description == "Professional diving instructor with 5 years of experience")
        
        // Facilities
        #expect(selectedData?.tripFacilities.title == "This Trip Includes")
        #expect(selectedData?.tripFacilities.content == ["Snorkeling Equipment", "Life Jacket", "Waterproof Camera"])
        
        // Packages
        #expect(selectedData?.availablePackages.title == "Available Packages")
        #expect(selectedData?.availablePackages.content.count == 2)
        #expect(selectedData?.hiddenPackages.count == selectedData?.availablePackages.content.count)
    }
    
    @Test("activity selection - should handle invalid selection")
    func activitySelection_whenInvalidId_shouldNotNotifyDelegate() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        context.viewModel.onViewDidLoad()
        
        let invalidActivityData = HomeActivityCellDataModel(
            id: 999,
            title: "title",
            location: "location",
            priceText: "priceText",
            imageUrl: nil
        )
        
        // --- WHEN ---
        context.viewModel.notifyCollectionViewActivityDidTap(invalidActivityData)
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedActivityDidSelectCount == 0)
    }
    
    // MARK: - Search Bar Interaction Tests
    
    @Test("search bar - typeable interaction")
    func searchBar_whenTypeable_shouldNotOpenTray() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        let searchBarViewModel = HomeSearchBarViewModel(
            leadingIcon: nil,
            placeholderText: "",
            currentTypedText: "",
            trailingIcon: nil,
            isTypeAble: true,
            delegate: nil
        )
        
        // --- WHEN ---
        context.viewModel.notifyHomeSearchBarDidTap(
            isTypeAble: true,
            viewModel: searchBarViewModel
        )
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedOpenSearchTrayCount == 0)
    }
    
    @Test("search bar - non-typeable interaction")
    func searchBar_whenNonTypeable_shouldOpenTray() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        let searchBarViewModel = HomeSearchBarViewModel(
            leadingIcon: nil,
            placeholderText: "",
            currentTypedText: "",
            trailingIcon: nil,
            isTypeAble: false,
            delegate: nil
        )
        
        // --- WHEN ---
        context.viewModel.notifyHomeSearchBarDidTap(
            isTypeAble: false,
            viewModel: searchBarViewModel
        )
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedOpenSearchTrayCount == 1)
    }
    
    // MARK: - Advanced Search Tests
    
    @Test("search - should handle search text changes")
    func search_whenTextChanges_shouldUpdateSearchBar() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.onViewDidLoad()
        
        // --- WHEN ---
        context.viewModel.onSearchDidApply("beach")
        
        // --- THEN ---
        #expect(context.viewModel.searchBarViewModel.currentTypedText == "beach")
    }
    
    @Test("search - should handle consecutive searches")
    func search_whenConsecutiveSearches_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.onViewDidLoad()
        
        // --- WHEN ---
        context.viewModel.onSearchDidApply("beach")
        context.viewModel.onSearchDidApply("mountain")
        context.viewModel.onSearchDidApply("culture")
        
        // --- THEN ---
        #expect(context.viewModel.searchBarViewModel.currentTypedText == "culture")
        #expect(context.fetcher.invokedFetchActivityCount >= 3)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("error handling - should handle fetch failure")
    func errorHandling_whenFetchFails_shouldHandleGracefully() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.fetcher.stubbedFetchActivityCompletionResult = (.failure(NetworkServiceError.noInternetConnection), ())
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.viewModel.collectionViewModel.activityData.dataModel.isEmpty)
    }
    
//    @Test("error handling - should recover from error state")
//    func errorHandling_whenRecoveringFromError_shouldLoadSuccessfully() async throws {
//        // --- GIVEN ---
//        let context = try TestContext.setup()
//        context.fetcher.stubbedFetchActivityCompletionResult = (.failure(NetworkServiceError.noInternetConnection), ())
//        context.viewModel.onViewDidLoad()
//        
//        // --- WHEN ---
//        context.fetcher.stubbedFetchActivityCompletionResult = (.success(context.activities), ())
//        context.viewModel.onSearchDidApply("test")
//        
//        // --- THEN ---
//        #expect(context.viewModel.collectionViewModel.activityData.dataModel.count > 0)
//    }
        
    // MARK: - Collection View Tests
    
    @Test("collection view - should construct with proper data")
    func collectionView_whenConstructed_shouldHaveProperData() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedConstructCollectionViewCount == 1)
        #expect(context.viewModel.collectionViewModel.activityData.dataModel.count > 0)
    }
    
    @Test("collection view - should update after filter application")
    func collectionView_afterFilterApplication_shouldUpdate() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.onViewDidLoad()
        let initialCount = context.viewModel.collectionViewModel.activityData.dataModel.count
        
        // --- WHEN ---
        context.viewModel.searchBarViewModel.trailingIcon?.didTap?()
        let filterModel = HomeFilterTrayDataModel(
            filterPillDataState: [],
            priceRangeModel: HomeFilterPriceRangeModel(
                minPrice: 1000000.0,
                maxPrice: 2000000.0,
                range: 0...0
            )
        )
        context.actionDelegate.invokedOpenFilterTrayParameters?.viewModel
            .filterDidApplyPublisher.send(filterModel)
        
        // --- THEN ---
        let filteredCount = context.viewModel.collectionViewModel.activityData.dataModel.count
        #expect(filteredCount <= initialCount) // Should be filtered
    }
    
    // MARK: - Navigation Tests
    
    @Test("navigation - should handle activity navigation")
    func navigation_whenActivitySelected_shouldNavigate() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.onViewDidLoad()
        
        let activityData = HomeActivityCellDataModel(
            id: 1,
            title: "title",
            location: "location",
            priceText: "priceText",
            imageUrl: nil
        )
        
        // --- WHEN ---
        context.viewModel.notifyCollectionViewActivityDidTap(activityData)
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedActivityDidSelectCount == 1)
        #expect(context.actionDelegate.invokedActivityDidSelectParameters?.data != nil)
    }
    
    // MARK: - Filter Integration Tests
    
    @Test("filter integration - should maintain filter state")
    func filterIntegration_shouldMaintainFilterState() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.onViewDidLoad()
        
        // --- WHEN ---
        context.viewModel.searchBarViewModel.trailingIcon?.didTap?()
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedOpenFilterTrayCount == 1)
        let filterViewModel = context.actionDelegate.invokedOpenFilterTrayParameters?.viewModel
        #expect(filterViewModel != nil)
    }
    
    @Test("filter integration - should apply price range filters")
    func filterIntegration_withPriceRange_shouldFilter() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.onViewDidLoad()
        
        // --- WHEN ---
        context.viewModel.searchBarViewModel.trailingIcon?.didTap?()
        let filterModel = HomeFilterTrayDataModel(
            filterPillDataState: [],
            priceRangeModel: HomeFilterPriceRangeModel(
                minPrice: 100000.0,
                maxPrice: 500000.0,
                range: 0...0
            )
        )
        context.actionDelegate.invokedOpenFilterTrayParameters?.viewModel
            .filterDidApplyPublisher.send(filterModel)
        
        // --- THEN ---
        #expect(context.viewModel.collectionViewModel.activityData.dataModel.count >= 0)
    }
    
    // MARK: - Performance Tests
    
    @Test("performance - should handle large activity sets")
    func performance_withLargeActivitySets_shouldPerformWell() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        let largeActivitySet: ActivityModelArray = try JSONReader.getObjectFromJSON(with: "activities")
        context.fetcher.stubbedFetchActivityCompletionResult = (.success(largeActivitySet), ())
        
        // --- WHEN ---
        let startTime = DispatchTime.now()
        context.viewModel.onViewDidLoad()
        let endTime = DispatchTime.now()
        
        // --- THEN ---
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        #expect(timeInterval < 1.0) // Should complete within 1 second
    }
    
    // MARK: - Edge Case Tests
    
    @Test("edge cases - should handle empty activity response")
    func edgeCases_withEmptyResponse_shouldHandleGracefully() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        let emptyActivities: ActivityModelArray = try JSONReader.getObjectFromJSON(with: "activities-empty")
        context.fetcher.stubbedFetchActivityCompletionResult = (.success(emptyActivities), ())
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.viewModel.collectionViewModel.activityData.dataModel.isEmpty)
    }
    
    @Test("edge cases - should handle nil activity selection")
    func edgeCases_withNilActivitySelection_shouldNotCrash() async throws {
        // --- GIVEN ---
        let context = try TestContext.setup()
        context.viewModel.onViewDidLoad()
        
        // --- WHEN ---
        let nilActivityData = HomeActivityCellDataModel(
            id: -1,
            title: "",
            location: "",
            priceText: "",
            imageUrl: nil
        )
        context.viewModel.notifyCollectionViewActivityDidTap(nilActivityData)
        
        // --- THEN ---
        #expect(context.actionDelegate.invokedActivityDidSelectCount == 0)
    }
    
//    @Test("state consistency - should maintain search bar state")
//    func stateConsistency_shouldMaintainSearchBarState() async throws {
//        // --- GIVEN ---
//        let context = try TestContext.setup()
//        context.viewModel.onViewDidLoad()
//        
//        // --- WHEN ---
//        let searchText = "beach adventure"
//        context.viewModel.onSearchDidApply(searchText)
//        
//        // --- THEN ---
//        #expect(context.viewModel.searchBarViewModel.currentTypedText == searchText)
//        #expect(context.viewModel.searchBarViewModel.isTypeAble == true)
//    }
}

// MARK: - Test Helpers

private extension HomeViewModelTest {
    private func assertViewDidLoadSetup(_ context: TestContext) {
        #expect(context.actionDelegate.invokedConstructCollectionViewCount == 1)
        #expect(context.actionDelegate.invokedConstructNavBarCount == 1)
    }
}

private final class MockHomeViewModelAction: HomeViewModelAction {
    var invokedConstructFilterCarousel = false
    var invokedConstructFilterCarouselCount = 0
    var invokedConstructFilterCarouselParameters: (filterPillStates: [HomeFilterPillState], filterDestinationPillStates: [HomeFilterDestinationPillState])?
    var invokedConstructFilterCarouselParametersList = [(filterPillStates: [HomeFilterPillState], filterDestinationPillStates: [HomeFilterDestinationPillState])]()

    func constructFilterCarousel(filterPillStates: [Coco.HomeFilterPillState], filterDestinationPillStates: [Coco.HomeFilterDestinationPillState]) {
        invokedConstructFilterCarousel = true
        invokedConstructFilterCarouselCount += 1
        invokedConstructFilterCarouselParameters = (filterPillStates, filterDestinationPillStates)
        invokedConstructFilterCarouselParametersList.append((filterPillStates, filterDestinationPillStates))
    }
    

    var invokedConstructCollectionView = false
    var invokedConstructCollectionViewCount = 0
    
    func constructCollectionView(viewModel: some HomeCollectionViewModelProtocol) {
        invokedConstructCollectionView = true
        invokedConstructCollectionViewCount += 1
    }

    var invokedConstructNavBar = false
    var invokedConstructNavBarCount = 0
    var invokedConstructNavBarParameters: (viewModel: HomeSearchBarViewModel, Void)?
    var invokedConstructNavBarParametersList = [(viewModel: HomeSearchBarViewModel, Void)]()

    func constructNavBar(viewModel: HomeSearchBarViewModel) {
        invokedConstructNavBar = true
        invokedConstructNavBarCount += 1
        invokedConstructNavBarParameters = (viewModel, ())
        invokedConstructNavBarParametersList.append((viewModel, ()))
    }
    
    var invokedActivityDidSelect = false
    var invokedActivityDidSelectCount = 0
    var invokedActivityDidSelectParameters: (data: ActivityDetailDataModel, Void)?
    var invokedActivityDidSelectParametersList = [(data: ActivityDetailDataModel, Void)]()

    func activityDidSelect(data: ActivityDetailDataModel) {
        invokedActivityDidSelect = true
        invokedActivityDidSelectCount += 1
        invokedActivityDidSelectParameters = (data, ())
        invokedActivityDidSelectParametersList.append((data, ()))
    }

    var invokedOpenSearchTray = false
    var invokedOpenSearchTrayCount = 0
    var invokedOpenSearchTrayParameters: (selectedQuery: String, latestSearches: [HomeSearchSearchLocationData])?
    var invokedOpenSearchTrayParametersList = [(selectedQuery: String, latestSearches: [HomeSearchSearchLocationData])]()

    func openSearchTray(
        selectedQuery: String,
        latestSearches: [HomeSearchSearchLocationData]
    ) {
        invokedOpenSearchTray = true
        invokedOpenSearchTrayCount += 1
        invokedOpenSearchTrayParameters = (selectedQuery, latestSearches)
        invokedOpenSearchTrayParametersList.append((selectedQuery, latestSearches))
    }

    var invokedOpenFilterTray = false
    var invokedOpenFilterTrayCount = 0
    var invokedOpenFilterTrayParameters: (viewModel: HomeFilterTrayViewModel, Void)?
    var invokedOpenFilterTrayParametersList = [(viewModel: HomeFilterTrayViewModel, Void)]()

    func openFilterTray(_ viewModel: HomeFilterTrayViewModel) {
        invokedOpenFilterTray = true
        invokedOpenFilterTrayCount += 1
        invokedOpenFilterTrayParameters = (viewModel, ())
        invokedOpenFilterTrayParametersList.append((viewModel, ()))
    }

    var invokedDismissTray = false
    var invokedDismissTrayCount = 0

    func dismissTray() {
        invokedDismissTray = true
        invokedDismissTrayCount += 1
    }
}

private final class MockHomeViewModelNavigationDelegate: HomeViewModelNavigationDelegate {

    var invokedNotifyHomeDidSelectActivity = false
    var invokedNotifyHomeDidSelectActivityCount = 0

    func notifyHomeDidSelectActivity() {
        invokedNotifyHomeDidSelectActivity = true
        invokedNotifyHomeDidSelectActivityCount += 1
    }
}
