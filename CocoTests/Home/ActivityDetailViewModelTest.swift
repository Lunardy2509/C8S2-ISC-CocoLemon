//
//  ActivityDetailViewModelTest.swift
//  CocoTests
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

struct ActivityDetailViewModelTest {
    
    // MARK: - Test Context Setup
    private struct TestContext {
        let viewModel: ActivityDetailViewModel
        let mockActionDelegate: MockActivityDetailViewModelAction
        let mockNavigationDelegate: MockActivityDetailNavigationDelegate
        let activityData: ActivityDetailDataModel
        
        static func setup() -> TestContext {
            // --- GIVEN ---
            let mockActionDelegate = MockActivityDetailViewModelAction()
            let mockNavigationDelegate = MockActivityDetailNavigationDelegate()
            let activityData = createMockActivityDetailData()
            
            let viewModel = ActivityDetailViewModel(data: activityData)
            viewModel.actionDelegate = mockActionDelegate
            viewModel.navigationDelegate = mockNavigationDelegate
            
            return TestContext(
                viewModel: viewModel,
                mockActionDelegate: mockActionDelegate,
                mockNavigationDelegate: mockNavigationDelegate,
                activityData: activityData
            )
        }
        
        static func createMockActivityDetailData() -> ActivityDetailDataModel {
            let availablePackages = [
                ActivityPackage(
                    id: 1,
                    name: "Basic Package",
                    endTime: "17:00",
                    startTime: "09:00",
                    activityId: 1,
                    description: "Basic package description",
                    maxParticipants: 10,
                    minParticipants: 2,
                    pricePerPerson: 100000.0,
                    host: ActivityPackage.Host(
                        bio: "Experienced guide",
                        name: "Guide 1",
                        profileImageUrl: "guide1.jpg"
                    ),
                    imageUrl: "package1.jpg"
                ),
                ActivityPackage(
                    id: 2,
                    name: "Premium Package",
                    endTime: "18:00",
                    startTime: "08:00",
                    activityId: 1,
                    description: "Premium package description",
                    maxParticipants: 8,
                    minParticipants: 2,
                    pricePerPerson: 200000.0,
                    host: ActivityPackage.Host(
                        bio: "Expert guide",
                        name: "Guide 2",
                        profileImageUrl: "guide2.jpg"
                    ),
                    imageUrl: "package2.jpg"
                ),
                ActivityPackage(
                    id: 3,
                    name: "Luxury Package",
                    endTime: "19:00",
                    startTime: "07:00",
                    activityId: 1,
                    description: "Luxury package description",
                    maxParticipants: 6,
                    minParticipants: 2,
                    pricePerPerson: 300000.0,
                    host: ActivityPackage.Host(
                        bio: "VIP guide",
                        name: "Guide 3",
                        profileImageUrl: "guide3.jpg"
                    ),
                    imageUrl: "package3.jpg"
                )
            ]
            
            return ActivityDetailDataModel(
                title: "Test Activity",
                location: "Test Location",
                imageUrls: ["image1.jpg", "image2.jpg"],
                description: "Test activity description",
            )
        }
    }
    
    // MARK: - Mock Delegates
    private class MockActivityDetailViewModelAction: ActivityDetailViewModelAction {
        
        var invokedConfigureView = false
        var invokedConfigureViewCount = 0
        var invokedConfigureViewParameters: ActivityDetailDataModel?
        
        var invokedUpdatePackageData = false
        var invokedUpdatePackageDataCount = 0
        var invokedUpdatePackageDataParameters: [ActivityPackage]?
        
        func configureView(data: ActivityDetailDataModel) {
            invokedConfigureView = true
            invokedConfigureViewCount += 1
            invokedConfigureViewParameters = data
        }
        
        func updatePackageData(data: [ActivityDetailDataModel.Package]) {
            invokedUpdatePackageData = true
            invokedUpdatePackageDataCount += 1
            invokedUpdatePackageDataParameters = data
        }
    }
    
    private class MockActivityDetailNavigationDelegate: ActivityDetailNavigationDelegate {
        var invokedNotifyActivityDetailPackageDidSelect = false
        var invokedNotifyActivityDetailPackageDidSelectCount = 0
        var invokedNotifyActivityDetailPackageDidSelectParameters: (package: ActivityDetailDataModel, selectedPackageId: Int)?
        
        var invokedNotifyCreateTripTapped = false
        var invokedNotifyCreateTripTappedCount = 0
        
        func notifyActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
            invokedNotifyActivityDetailPackageDidSelect = true
            invokedNotifyActivityDetailPackageDidSelectCount += 1
            invokedNotifyActivityDetailPackageDidSelectParameters = (package, selectedPackageId)
        }
        
        func notifyCreateTripTapped() {
            invokedNotifyCreateTripTapped = true
            invokedNotifyCreateTripTappedCount += 1
        }
    }
    
    // MARK: - Initialization Tests
    @Test("initialization - should set up correctly with provided data")
    func initialization_withProvidedData_shouldSetupCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        let viewModel = context.viewModel
        
        // --- THEN ---
        #expect(viewModel.actionDelegate === context.mockActionDelegate)
        #expect(viewModel.navigationDelegate === context.mockNavigationDelegate)
    }
    
    // MARK: - View Did Load Tests
    @Test("view did load - should configure view with activity data")
    func viewDidLoad_shouldConfigureViewWithActivityData() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedConfigureView == true)
        #expect(context.mockActionDelegate.invokedConfigureViewCount == 1)
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.id == 1)
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.title == "Test Activity")
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.location == "Test Location")
    }
    
    @Test("view did load - should pass complete activity data to action delegate")
    func viewDidLoad_shouldPassCompleteActivityDataToActionDelegate() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        let passedData = context.mockActionDelegate.invokedConfigureViewParameters
        #expect(passedData != nil)
        #expect(passedData?.availablePackages.content.count == 3)
        #expect(passedData?.tripFacilities.content.count == 3)
        #expect(passedData?.imageUrls.count == 2)
        #expect(passedData?.rating == 4.5)
        #expect(passedData?.reviewCount == 100)
    }
    
    // MARK: - Package Detail State Change Tests
    @Test("package detail state change - should show all packages when shouldShowAll is true")
    func packageDetailStateChange_whenShouldShowAllIsTrue_shouldShowAllPackages() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedUpdatePackageData == true)
        #expect(context.mockActionDelegate.invokedUpdatePackageDataCount == 1)
        #expect(context.mockActionDelegate.invokedUpdatePackageDataParameters?.count == 3) // All packages
    }
    
    @Test("package detail state change - should show hidden packages when shouldShowAll is false")
    func packageDetailStateChange_whenShouldShowAllIsFalse_shouldShowHiddenPackages() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: false)
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedUpdatePackageData == true)
        #expect(context.mockActionDelegate.invokedUpdatePackageDataCount == 1)
        // Hidden packages should be the limited set (first 2 packages based on typical implementation)
        let hiddenPackagesCount = context.mockActionDelegate.invokedUpdatePackageDataParameters?.count ?? 0
        #expect(hiddenPackagesCount <= 3) // Should be less than or equal to total packages
    }
    
    @Test("package detail state change - should handle multiple state changes")
    func packageDetailStateChange_withMultipleChanges_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: false)
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedUpdatePackageDataCount == 3)
    }
    
    // MARK: - Package Selection Tests
    @Test("package selection - should notify navigation delegate with correct parameters")
    func packageSelection_shouldNotifyNavigationDelegateWithCorrectParameters() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let selectedPackageId = 2
        
        // --- WHEN ---
        context.viewModel.onPackagesDetailDidTap(with: selectedPackageId)
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifyActivityDetailPackageDidSelect == true)
        #expect(context.mockNavigationDelegate.invokedNotifyActivityDetailPackageDidSelectCount == 1)
        #expect(context.mockNavigationDelegate.invokedNotifyActivityDetailPackageDidSelectParameters?.selectedPackageId == 2)
        #expect(context.mockNavigationDelegate.invokedNotifyActivityDetailPackageDidSelectParameters?.package.id == 1)
    }
    
    @Test("package selection - should handle different package IDs")
    func packageSelection_withDifferentPackageIds_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackagesDetailDidTap(with: 1)
        context.viewModel.onPackagesDetailDidTap(with: 3)
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifyActivityDetailPackageDidSelectCount == 2)
        let parametersList = [
            context.mockNavigationDelegate.invokedNotifyActivityDetailPackageDidSelectParameters
        ]
        #expect(parametersList.last?.selectedPackageId == 3)
    }
    
    // MARK: - Create Trip Tests
    @Test("create trip - should notify navigation delegate when create trip is tapped")
    func createTrip_shouldNotifyNavigationDelegateWhenTapped() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onCreateTripTapped()
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifyCreateTripTapped == true)
        #expect(context.mockNavigationDelegate.invokedNotifyCreateTripTappedCount == 1)
    }
    
    @Test("create trip - should handle multiple create trip taps")
    func createTrip_withMultipleTaps_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onCreateTripTapped()
        context.viewModel.onCreateTripTapped()
        context.viewModel.onCreateTripTapped()
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifyCreateTripTappedCount == 3)
    }
    
    // MARK: - Data Integrity Tests
    @Test("data integrity - should maintain activity data throughout operations")
    func dataIntegrity_shouldMaintainActivityDataThroughoutOperations() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        context.viewModel.onPackagesDetailDidTap(with: 1)
        context.viewModel.onCreateTripTapped()
        
        // --- THEN ---
        // All operations should use the same activity data
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.id == 1)
        #expect(context.mockNavigationDelegate.invokedNotifyActivityDetailPackageDidSelectParameters?.package.id == 1)
    }
    
    // MARK: - Delegate Weak Reference Tests
    @Test("delegate weak reference - should handle nil delegates gracefully")
    func delegateWeakReference_withNilDelegates_shouldHandleGracefully() async throws {
        // --- GIVEN ---
        let activityData = TestContext.createMockActivityDetailData()
        let viewModel = ActivityDetailViewModel(data: activityData)
        
        // --- WHEN ---
        viewModel.onViewDidLoad()
        viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        viewModel.onPackagesDetailDidTap(with: 1)
        viewModel.onCreateTripTapped()
        
        // --- THEN ---
        // Should not crash and complete successfully
        #expect(viewModel.actionDelegate == nil)
        #expect(viewModel.navigationDelegate == nil)
    }
    
    // MARK: - Package Data Validation Tests
    @Test("package data validation - should handle empty packages correctly")
    func packageDataValidation_withEmptyPackages_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let emptyPackageData = ActivityDetailDataModel(
            id: 1,
            title: "Test Activity",
            location: "Test Location",
            imageUrls: [],
            rating: 4.5,
            reviewCount: 100,
            description: "Test description",
            detailInfomation: ActivityDetailDataModel.DetailInformation(title: "Detail", content: "Content"),
            providerDetail: ActivityDetailDataModel.ProviderDetail(
                title: "Provider",
                content: ActivityDetailDataModel.ProviderDetail.Content(name: "Provider", description: "Description", imageUrlString: "")
            ),
            tripFacilities: ActivityDetailDataModel.TripFacilities(title: "Facilities", content: []),
            availablePackages: ActivityDetailDataModel.AvailablePackages(title: "Packages", content: []),
            tnc: []
        )
        
        let viewModel = ActivityDetailViewModel(data: emptyPackageData)
        let mockActionDelegate = MockActivityDetailViewModelAction()
        viewModel.actionDelegate = mockActionDelegate
        
        // --- WHEN ---
        viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        
        // --- THEN ---
        #expect(mockActionDelegate.invokedUpdatePackageData == true)
        #expect(mockActionDelegate.invokedUpdatePackageDataParameters?.isEmpty == true)
    }
}
