//
//  HomeCollectionViewModelTest.swift
//  CocoTests
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

struct HomeCollectionViewModelTest {
    // MARK: - Test Context Setup
    private struct TestContext {
        let viewModel: HomeCollectionViewModel
        let mockActionDelegate: MockHomeCollectionViewModelAction
        let mockDelegate: MockHomeCollectionViewModelDelegate
        
        static func setup() -> TestContext {
            // --- GIVEN ---
            let mockActionDelegate = MockHomeCollectionViewModelAction()
            let mockDelegate = MockHomeCollectionViewModelDelegate()
            
            let viewModel = HomeCollectionViewModel()
            viewModel.actionDelegate = mockActionDelegate
            viewModel.delegate = mockDelegate
            
            return TestContext(
                viewModel: viewModel,
                mockActionDelegate: mockActionDelegate,
                mockDelegate: mockDelegate
            )
        }
        
        static func createMockActivityData() -> HomeActivityCellSectionDataModel {
            let activities = [
                HomeActivityCellDataModel(
                    id: 1,
                    title: "Test Activity 1",
                    location: "Bali, Indonesia",
                    priceText: "Rp 100,000",
                    imageUrl: URL(string: "https://picsum.photos/seed/dest-nusa-penida/800/600"),
                ),
                HomeActivityCellDataModel(
                    id: 2,
                    title: "Test Activity 2",
                    location: "Jakarta, Indonesia",
                    priceText: "Rp 200,000",
                    imageUrl: URL(string: "https://picsum.photos/seed/dest-thousand-islands/800/600"),
                )
            ]
            return ("Popular Activities", activities)
        }
        
        static func createEmptyActivityData() -> HomeActivityCellSectionDataModel {
            return (nil, [])
        }
    }
    
    // MARK: - Mock Delegates
    private class MockHomeCollectionViewModelAction: HomeCollectionViewModelAction {
        var invokedConfigureDataSource = false
        var invokedConfigureDataSourceCount = 0
        
        var invokedApplySnapshot = false
        var invokedApplySnapshotCount = 0
        var invokedApplySnapshotParameters: (snapshot: HomeCollectionViewSnapShot, completion: (() -> Void)?)?
        var invokedApplySnapshotParametersList = [(snapshot: HomeCollectionViewSnapShot, completion: (() -> Void)?)]()
        
        func configureDataSource() {
            invokedConfigureDataSource = true
            invokedConfigureDataSourceCount += 1
        }
        
        func applySnapshot(_ snapshot: HomeCollectionViewSnapShot, completion: (() -> Void)?) {
            invokedApplySnapshot = true
            invokedApplySnapshotCount += 1
            invokedApplySnapshotParameters = (snapshot, completion)
            invokedApplySnapshotParametersList.append((snapshot, completion))
            completion?()
        }
    }
    
    private class MockHomeCollectionViewModelDelegate: HomeCollectionViewModelDelegate {
        var invokedNotifyCollectionViewActivityDidTap = false
        var invokedNotifyCollectionViewActivityDidTapCount = 0
        var invokedNotifyCollectionViewActivityDidTapParameters: HomeActivityCellDataModel?
        var invokedNotifyCollectionViewActivityDidTapParametersList = [HomeActivityCellDataModel]()
        
        var invokedNotifyCollectionViewClearAllFilters = false
        var invokedNotifyCollectionViewClearAllFiltersCount = 0
        
        func notifyCollectionViewActivityDidTap(_ dataModel: HomeActivityCellDataModel) {
            invokedNotifyCollectionViewActivityDidTap = true
            invokedNotifyCollectionViewActivityDidTapCount += 1
            invokedNotifyCollectionViewActivityDidTapParameters = dataModel
            invokedNotifyCollectionViewActivityDidTapParametersList.append(dataModel)
        }
        
        func notifyCollectionViewClearAllFilters() {
            invokedNotifyCollectionViewClearAllFilters = true
            invokedNotifyCollectionViewClearAllFiltersCount += 1
        }
    }
    
    // MARK: - Initialization Tests
    @Test("initialization - should start with empty activity data")
    func initialization_shouldStartWithEmptyActivityData() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        let viewModel = context.viewModel
        
        // --- THEN ---
        #expect(viewModel.activityData.title == nil)
        #expect(viewModel.activityData.dataModel.isEmpty)
        #expect(viewModel.isFromSearch == false)
    }
    
    // MARK: - View Did Load Tests
    @Test("view did load - should configure data source and reload collection")
    func viewDidLoad_shouldConfigureDataSourceAndReloadCollection() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedConfigureDataSource == true)
        #expect(context.mockActionDelegate.invokedConfigureDataSourceCount == 1)
        #expect(context.mockActionDelegate.invokedApplySnapshot == true)
        #expect(context.mockActionDelegate.invokedApplySnapshotCount == 1)
    }
    
    // MARK: - Update Activity Tests
    @Test("update activity - should update activity data and reload collection")
    func updateActivity_shouldUpdateActivityDataAndReloadCollection() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let mockActivityData = TestContext.createMockActivityData()
        
        // --- WHEN ---
        context.viewModel.updateActivity(activity: mockActivityData)
        
        // --- THEN ---
        #expect(context.viewModel.activityData.title == "Popular Activities")
        #expect(context.viewModel.activityData.dataModel.count == 2)
        #expect(context.viewModel.isFromSearch == false)
        #expect(context.mockActionDelegate.invokedApplySnapshot == true)
    }
    
    @Test("update activity - should update with search flag when from search")
    func updateActivity_withSearchFlag_shouldUpdateCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let mockActivityData = TestContext.createMockActivityData()
        
        // --- WHEN ---
        context.viewModel.updateActivity(activity: mockActivityData, isFromSearch: true)
        
        // --- THEN ---
        #expect(context.viewModel.activityData.title == "Popular Activities")
        #expect(context.viewModel.activityData.dataModel.count == 2)
        #expect(context.viewModel.isFromSearch == true)
        #expect(context.mockActionDelegate.invokedApplySnapshot == true)
    }
    
    @Test("update activity - should handle empty activity data")
    func updateActivity_withEmptyData_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let emptyActivityData = TestContext.createEmptyActivityData()
        
        // --- WHEN ---
        context.viewModel.updateActivity(activity: emptyActivityData)
        
        // --- THEN ---
        #expect(context.viewModel.activityData.title == nil)
        #expect(context.viewModel.activityData.dataModel.isEmpty)
        #expect(context.mockActionDelegate.invokedApplySnapshot == true)
    }
    
    // MARK: - Activity Tap Tests
    @Test("activity tap - should notify delegate when activity is tapped")
    func activityTap_shouldNotifyDelegateWhenActivityTapped() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let mockActivity = HomeActivityCellDataModel(
            id: 1,
            title: "Test Activity",
            location: "Test Location",
            priceText: "Rp 100,000",
            imageUrl: URL(string: "https://picsum.photos/seed/dest-nusa-penida/800/600"),
        )
        
        // --- WHEN ---
        context.viewModel.onActivityDidTap(mockActivity)
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTap == true)
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTapCount == 1)
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTapParameters?.id == 1)
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTapParameters?.title == "Test Activity")
    }
    
    @Test("activity tap - should handle multiple activity taps")
    func activityTap_withMultipleTaps_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let activity1 = HomeActivityCellDataModel(
            id: 1, title: "Activity 1",
            location: "Location 1",
            priceText: "Rp 100,000",
            imageUrl: URL(string: "https://picsum.photos/seed/dest-nusa-penida/800/600"),
        )
        let activity2 = HomeActivityCellDataModel(
            id: 2,
            title: "Activity 2",
            location: "Location 2",
            priceText: "Rp 200,000",
            imageUrl: URL(string: "https://picsum.photos/seed/dest-thousand-islands/800/600"),
        )
        
        // --- WHEN ---
        context.viewModel.onActivityDidTap(activity1)
        context.viewModel.onActivityDidTap(activity2)
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTapCount == 2)
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTapParametersList.count == 2)
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTapParametersList[0].id == 1)
        #expect(context.mockDelegate.invokedNotifyCollectionViewActivityDidTapParametersList[1].id == 2)
    }
    
    // MARK: - Clear All Filters Tests
    @Test("clear all filters - should notify delegate when clear all filters is called")
    func clearAllFilters_shouldNotifyDelegateWhenCalled() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onClearAllFilters()
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyCollectionViewClearAllFilters == true)
        #expect(context.mockDelegate.invokedNotifyCollectionViewClearAllFiltersCount == 1)
    }
    
    @Test("clear all filters - should handle multiple clear all filters calls")
    func clearAllFilters_withMultipleCalls_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onClearAllFilters()
        context.viewModel.onClearAllFilters()
        context.viewModel.onClearAllFilters()
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyCollectionViewClearAllFiltersCount == 3)
    }
    
    // MARK: - Snapshot Creation Tests
    @Test("snapshot creation - should create snapshot with activity section when data exists")
    func snapshotCreation_withActivityData_shouldCreateActivitySection() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let mockActivityData = TestContext.createMockActivityData()
        
        // --- WHEN ---
        context.viewModel.updateActivity(activity: mockActivityData)
        
        // --- THEN ---
        let snapshot = context.mockActionDelegate.invokedApplySnapshotParameters?.snapshot
        #expect(snapshot != nil)
        #expect(snapshot?.sectionIdentifiers.count == 1)
        #expect(snapshot?.sectionIdentifiers.first?.type == .activity)
        #expect(snapshot?.itemIdentifiers.count == 2)
    }
    
    @Test("snapshot creation - should create no result section when data is empty")
    func snapshotCreation_withEmptyData_shouldCreateNoResultSection() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let emptyActivityData = TestContext.createEmptyActivityData()
        
        // --- WHEN ---
        context.viewModel.updateActivity(activity: emptyActivityData)
        
        // --- THEN ---
        let snapshot = context.mockActionDelegate.invokedApplySnapshotParameters?.snapshot
        #expect(snapshot != nil)
        #expect(snapshot?.sectionIdentifiers.count == 1)
        #expect(snapshot?.sectionIdentifiers.first?.type == .noResult)
        #expect(snapshot?.itemIdentifiers.count == 1)
    }
    
    // MARK: - Data Persistence Tests
    @Test("data persistence - should maintain activity data after updates")
    func dataPersistence_shouldMaintainActivityDataAfterUpdates() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let mockActivityData = TestContext.createMockActivityData()
        
        // --- WHEN ---
        context.viewModel.updateActivity(activity: mockActivityData, isFromSearch: true)
        
        // --- THEN ---
        #expect(context.viewModel.activityData.title == "Popular Activities")
        #expect(context.viewModel.activityData.dataModel.count == 2)
        #expect(context.viewModel.isFromSearch == true)
        
        // Update with different data
        let newActivityData: HomeActivityCellSectionDataModel = ("New Activities", [])
        context.viewModel.updateActivity(activity: newActivityData, isFromSearch: false)
        
        #expect(context.viewModel.activityData.title == "New Activities")
        #expect(context.viewModel.activityData.dataModel.isEmpty)
        #expect(context.viewModel.isFromSearch == false)
    }
    
    // MARK: - Delegate Weak Reference Tests
    @Test("delegate weak reference - should handle nil delegates gracefully")
    func delegateWeakReference_withNilDelegates_shouldHandleGracefully() async throws {
        // --- GIVEN ---
        let viewModel = HomeCollectionViewModel()
        let mockActivity = HomeActivityCellDataModel(
            id: 1,
            title: "Test",
            location: "Test",
            priceText: "Rp 100,000",
            imageUrl: URL(string: "https://picsum.photos/seed/dest-nusa-penida/800/600"),
        )
        
        // --- WHEN ---
        viewModel.onViewDidLoad()
        viewModel.onActivityDidTap(mockActivity)
        viewModel.onClearAllFilters()
        
        // --- THEN ---
        // Should not crash and complete successfully
        #expect(viewModel.actionDelegate == nil)
        #expect(viewModel.delegate == nil)
    }
}
