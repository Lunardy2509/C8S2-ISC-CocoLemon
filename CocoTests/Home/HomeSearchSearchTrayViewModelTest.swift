//
//  HomeSearchSearchTrayViewModelTest.swift
//  CocoTests
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

//import Foundation
//import Testing
//import SwiftUI
//@testable import Coco
//
//struct HomeSearchSearchTrayViewModelTest {
//    
//    // MARK: - Test Context Setup
//    private struct TestContext {
//        let viewModel: HomeSearchSearchTrayViewModel
//        let mockSearchBarViewModel: HomeSearchBarViewModel
//        let mockActivityFetcher: MockActivityFetcher
//        
//        static func setup() -> TestContext {
//            // --- GIVEN ---
//            let mockActivityFetcher = MockActivityFetcher()
//            let mockDelegate = MockHomeSearchBarViewModelDelegate()
//            
//            let mockSearchBarViewModel = HomeSearchBarViewModel(
//                leadingIcon: UIImage(systemName: "magnifyingglass"),
//                placeholderText: "Search destinations...",
//                currentTypedText: "",
//                trailingIcon: nil,
//                isTypeAble: true,
//                delegate: mockDelegate
//            )
//            
//            let viewModel = HomeSearchSearchTrayViewModel(
//                searchBarViewModel: mockSearchBarViewModel,
//                activityFetcher: mockActivityFetcher
//            )
//            
//            return TestContext(
//                viewModel: viewModel,
//                mockSearchBarViewModel: mockSearchBarViewModel,
//                mockActivityFetcher: mockActivityFetcher
//            )
//        }
//        
//        static func createMockTopDestinations() -> ActivityTopDestinationModelArray {
//            let destinations = [
//                ActivityTopDestination(id: 1, name: "Bali, Indonesia"),
//                ActivityTopDestination(id: 2, name: "Jakarta, Indonesia"),
//                ActivityTopDestination(id: 3, name: "Yogyakarta, Indonesia"),
//                ActivityTopDestination(id: 4, name: "Bandung, Indonesia"),
//                ActivityTopDestination(id: 5, name: "Surabaya, Indonesia")
//            ]
//            return ActivityTopDestinationModelArray(values: destinations)
//        }
//    }
//    
//    // MARK: - Mock Delegate
//    private class MockHomeSearchBarViewModelDelegate: HomeSearchBarViewModelDelegate {
//        var invokedNotifyHomeSearchBarDidTap = false
//        var invokedNotifyHomeSearchBarDidTapCount = 0
//        
//        func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
//            invokedNotifyHomeSearchBarDidTap = true
//            invokedNotifyHomeSearchBarDidTapCount += 1
//        }
//    }
//    
//    // MARK: - Initialization Tests
//    @Test("initialization - should set up correctly with provided search bar view model")
//    func initialization_withProvidedSearchBarViewModel_shouldSetupCorrectly() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        
//        // --- WHEN ---
//        let viewModel = context.viewModel
//        
//        // --- THEN ---
//        #expect(viewModel.searchBarViewModel.placeholderText == "Search destinations...")
//        #expect(viewModel.searchBarViewModel.isTypeAble == true)
//        #expect(viewModel.popularLocations.isEmpty)
//    }
//    
//    @Test("initialization - should start with empty popular locations")
//    func initialization_shouldStartWithEmptyPopularLocations() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        
//        // --- WHEN ---
//        let viewModel = context.viewModel
//        
//        // --- THEN ---
//        #expect(viewModel.popularLocations.isEmpty)
//    }
//    
//    // MARK: - OnAppear Tests
//    @Test("on appear - should fetch top destinations successfully")
//    func onAppear_shouldFetchTopDestinationsSuccessfully() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        let mockTopDestinations = TestContext.createMockTopDestinations()
//        context.mockActivityFetcher.stubbedFetchTopDestinationCompletionResult = (.success(mockTopDestinations), ())
//        
//        // --- WHEN ---
//        await context.viewModel.onAppear()
//        
//        // Wait for async operation to complete
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        // --- THEN ---
//        #expect(context.mockActivityFetcher.invokedFetchTopDestination == true)
//        #expect(context.mockActivityFetcher.invokedFetchTopDestinationCount == 1)
//        #expect(context.viewModel.popularLocations.count == 5)
//    }
//    
//    @Test("on appear - should sort popular locations alphabetically")
//    func onAppear_shouldSortPopularLocationsAlphabetically() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        let unsortedDestinations = ActivityTopDestinationModelArray(values: [
//            ActivityTopDestination(id: 1, name: "Yogyakarta, Indonesia"),
//            ActivityTopDestination(id: 2, name: "Bali, Indonesia"),
//            ActivityTopDestination(id: 3, name: "Jakarta, Indonesia")
//        ])
//        context.mockActivityFetcher.stubbedFetchTopDestinationCompletionResult = (.success(unsortedDestinations), ())
//        
//        // --- WHEN ---
//        await context.viewModel.onAppear()
//        
//        // Wait for async operation to complete
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        // --- THEN ---
//        #expect(context.viewModel.popularLocations.count == 3)
//        #expect(context.viewModel.popularLocations[0].name == "Bali, Indonesia")
//        #expect(context.viewModel.popularLocations[1].name == "Jakarta, Indonesia")
//        #expect(context.viewModel.popularLocations[2].name == "Yogyakarta, Indonesia")
//    }
//    
//    @Test("on appear - should handle fetch failure gracefully")
//    func onAppear_withFetchFailure_shouldHandleGracefully() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        context.mockActivityFetcher.stubbedFetchTopDestinationCompletionResult = (.failure(.invalidRequest), ())
//        
//        // --- WHEN ---
//        await context.viewModel.onAppear()
//        
//        // Wait for async operation to complete
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        // --- THEN ---
//        #expect(context.mockActivityFetcher.invokedFetchTopDestination == true)
//        #expect(context.viewModel.popularLocations.isEmpty)
//    }
//    
//    @Test("on appear - should convert destinations to search location data correctly")
//    func onAppear_shouldConvertDestinationsToSearchLocationDataCorrectly() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        let mockTopDestinations = ActivityTopDestinationModelArray(values: [
//            ActivityTopDestination(id: 123, name: "Test Destination"),
//            ActivityTopDestination(id: 456, name: "Another Place")
//        ])
//        context.mockActivityFetcher.stubbedFetchTopDestinationCompletionResult = (.success(mockTopDestinations), ())
//        
//        // --- WHEN ---
//        await context.viewModel.onAppear()
//        
//        // Wait for async operation to complete
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        // --- THEN ---
//        #expect(context.viewModel.popularLocations.count == 2)
//        #expect(context.viewModel.popularLocations[0].id == 456) // "Another Place" comes first alphabetically
//        #expect(context.viewModel.popularLocations[0].name == "Another Place")
//        #expect(context.viewModel.popularLocations[1].id == 123)
//        #expect(context.viewModel.popularLocations[1].name == "Test Destination")
//    }
//    
//    // MARK: - Multiple OnAppear Tests
//    @Test("on appear - should handle multiple calls correctly")
//    func onAppear_withMultipleCalls_shouldHandleCorrectly() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        let mockTopDestinations = TestContext.createMockTopDestinations()
//        context.mockActivityFetcher.stubbedFetchTopDestinationCompletionResult = (.success(mockTopDestinations), ())
//        
//        // --- WHEN ---
//        await context.viewModel.onAppear()
//        await context.viewModel.onAppear()
//        await context.viewModel.onAppear()
//        
//        // Wait for async operations to complete
//        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
//        
//        // --- THEN ---
//        #expect(context.mockActivityFetcher.invokedFetchTopDestinationCount == 3)
//        #expect(context.viewModel.popularLocations.count == 5) // Should still have 5 locations
//    }
//    
//    // MARK: - Search Bar View Model Integration Tests
//    @Test("search bar integration - should maintain search bar view model reference")
//    func searchBarIntegration_shouldMaintainSearchBarViewModelReference() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        let originalPlaceholder = context.viewModel.searchBarViewModel.placeholderText
//        
//        // --- WHEN ---
//        context.viewModel.searchBarViewModel.currentTypedText = "new search text"
//        
//        // --- THEN ---
//        #expect(context.viewModel.searchBarViewModel.placeholderText == originalPlaceholder)
//        #expect(context.viewModel.searchBarViewModel.currentTypedText == "new search text")
//        #expect(context.viewModel.searchBarViewModel === context.mockSearchBarViewModel)
//    }
//    
//    // MARK: - Empty State Tests
//    @Test("empty state - should handle empty top destinations response")
//    func emptyState_withEmptyTopDestinationsResponse_shouldHandleCorrectly() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        let emptyDestinations = ActivityTopDestinationModelArray(values: [])
//        context.mockActivityFetcher.stubbedFetchTopDestinationCompletionResult = (.success(emptyDestinations), ())
//        
//        // --- WHEN ---
//        await context.viewModel.onAppear()
//        
//        // Wait for async operation to complete
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        // --- THEN ---
//        #expect(context.mockActivityFetcher.invokedFetchTopDestination == true)
//        #expect(context.viewModel.popularLocations.isEmpty)
//    }
//    
//    // MARK: - Data Consistency Tests
//    @Test("data consistency - should maintain data integrity across operations")
//    func dataConsistency_shouldMaintainDataIntegrityAcrossOperations() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        let initialDestinations = TestContext.createMockTopDestinations()
//        context.mockActivityFetcher.stubbedFetchTopDestinationCompletionResult = (.success(initialDestinations), ())
//        
//        // --- WHEN ---
//        await context.viewModel.onAppear()
//        
//        // Wait for async operation to complete
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        let firstLoadCount = context.viewModel.popularLocations.count
//        let firstLoadNames = context.viewModel.popularLocations.map { $0.name }
//        
//        // Load again with same data
//        await context.viewModel.onAppear()
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        // --- THEN ---
//        #expect(context.viewModel.popularLocations.count == firstLoadCount)
//        #expect(context.viewModel.popularLocations.map { $0.name } == firstLoadNames)
//        #expect(context.viewModel.popularLocations.count == 5)
//    }
//    
//    // MARK: - Activity Fetcher Integration Tests
//    @Test("activity fetcher integration - should use provided activity fetcher")
//    func activityFetcherIntegration_shouldUseProvidedActivityFetcher() async throws {
//        // --- GIVEN ---
//        let customMockFetcher = MockActivityFetcher()
//        let mockSearchBarViewModel = HomeSearchBarViewModel(
//            leadingIcon: nil,
//            placeholderText: "Test",
//            currentTypedText: "",
//            trailingIcon: nil,
//            isTypeAble: true,
//            delegate: nil
//        )
//        
//        let viewModel = HomeSearchSearchTrayViewModel(
//            searchBarViewModel: mockSearchBarViewModel,
//            activityFetcher: customMockFetcher
//        )
//        
//        let mockDestinations = TestContext.createMockTopDestinations()
//        customMockFetcher.stubbedFetchTopDestinationCompletionResult = (.success(mockDestinations), ())
//        
//        // --- WHEN ---
//        await viewModel.onAppear()
//        
//        // Wait for async operation to complete
//        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
//        
//        // --- THEN ---
//        #expect(customMockFetcher.invokedFetchTopDestination == true)
//        #expect(customMockFetcher.invokedFetchTopDestinationCount == 1)
//        #expect(viewModel.popularLocations.count == 5)
//    }
//}
