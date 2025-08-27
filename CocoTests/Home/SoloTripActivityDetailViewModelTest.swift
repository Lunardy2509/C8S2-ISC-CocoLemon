//
//  SoloTripActivityDetailViewModelTest.swift
//  CocoTests
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

struct SoloTripActivityDetailViewModelTest {
    
    // MARK: - Test Context Setup
    private struct TestContext {
        let viewModel: SoloTripActivityDetailViewModel
        let mockActionDelegate: MockSoloTripActivityDetailViewModelAction
        let mockNavigationDelegate: MockSoloTripActivityDetailNavigationDelegate
        let activityData: ActivityDetailDataModel
        
        static func setup() -> TestContext {
            // --- GIVEN ---
            let mockActionDelegate = MockSoloTripActivityDetailViewModelAction()
            let mockNavigationDelegate = MockSoloTripActivityDetailNavigationDelegate()
            let activityData = createMockActivityDetailData()
            
            let viewModel = SoloTripActivityDetailViewModel(data: activityData)
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
            let soloPackages = [
                ActivityPackage(
                    id: 1,
                    name: "Solo Basic Package",
                    endTime: "16:00",
                    startTime: "10:00",
                    activityId: 1,
                    description: "Perfect for solo travelers",
                    maxParticipants: 1,
                    minParticipants: 1,
                    pricePerPerson: 150000.0,
                    host: ActivityPackage.Host(
                        bio: "Solo travel expert",
                        name: "Solo Guide 1",
                        profileImageUrl: "solo_guide1.jpg"
                    ),
                    imageUrl: "solo_package1.jpg"
                ),
                ActivityPackage(
                    id: 2,
                    name: "Solo Premium Package",
                    endTime: "17:00",
                    startTime: "09:00",
                    activityId: 1,
                    description: "Premium solo experience",
                    maxParticipants: 1,
                    minParticipants: 1,
                    pricePerPerson: 250000.0,
                    host: ActivityPackage.Host(
                        bio: "Premium solo guide",
                        name: "Solo Guide 2",
                        profileImageUrl: "solo_guide2.jpg"
                    ),
                    imageUrl: "solo_package2.jpg"
                ),
                ActivityPackage(
                    id: 3,
                    name: "Solo Luxury Package",
                    endTime: "18:00",
                    startTime: "08:00",
                    activityId: 1,
                    description: "Luxury solo adventure",
                    maxParticipants: 1,
                    minParticipants: 1,
                    pricePerPerson: 350000.0,
                    host: ActivityPackage.Host(
                        bio: "Luxury solo specialist",
                        name: "Solo Guide 3",
                        profileImageUrl: "solo_guide3.jpg"
                    ),
                    imageUrl: "solo_package3.jpg"
                )
            ]
            
            return ActivityDetailDataModel(
                title: "Solo Adventure Activity",
                location: "Solo Traveler Paradise",
                imageUrlsString: ["solo1.jpg", "solo2.jpg", "solo3.jpg"],
                detailInfomation: ActivitySectionLayout(
                    title: "Solo Trip Details",
                    content: "Detailed information about solo travel experience"
                ),
                providerDetail: ActivitySectionLayout(
                    title: "Solo Travel Provider",
                    content: ActivityDetailDataModel.ProviderDetail(
                        name: "Solo Adventures Co.",
                        description: "Specializing in solo travel experiences",
                        imageUrlString: "solo_provider.jpg"
                    )
                ),
                tripFacilities: ActivitySectionLayout(
                    title: "Solo Facilities",
                    content: ["Personal Guide", "Safety Equipment", "Solo-friendly Accommodations"]
                ),
                tnc: "Solo traveler terms apply. Safety guidelines must be followed.",
                availablePackages: ActivitySectionLayout(
                    title: "Solo Packages",
                    content: [
                        ActivityDetailDataModel.Package(
                            imageUrlString: "solo_basic_package.jpg",
                            name: "Solo Basic",
                            description: "Min.1 - Max.1",
                            price: "Rp 500,000",
                            id: 1,
                            minParticipants: 1,
                            maxParticipants: 1
                        ),
                        ActivityDetailDataModel.Package(
                            imageUrlString: "solo_premium_package.jpg",
                            name: "Solo Premium",
                            description: "Min.1 - Max.1",
                            price: "Rp 750,000",
                            id: 2,
                            minParticipants: 1,
                            maxParticipants: 1
                        )
                    ]
                ),
                hiddenPackages: [
                    ActivityDetailDataModel.Package(
                        imageUrlString: "solo_basic_package.jpg",
                        name: "Solo Basic",
                        description: "Min.1 - Max.1",
                        price: "Rp 500,000",
                        id: 1,
                        minParticipants: 1,
                        maxParticipants: 1
                    ),
                    ActivityDetailDataModel.Package(
                        imageUrlString: "solo_premium_package.jpg",
                        name: "Solo Premium",
                        description: "Min.1 - Max.1",
                        price: "Rp 750,000",
                        id: 2,
                        minParticipants: 1,
                        maxParticipants: 1
                    )
                ]
            )
        }
    }
    
    // MARK: - Mock Delegates
    private class MockSoloTripActivityDetailViewModelAction: SoloTripActivityDetailViewModelAction {
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
        
        func updatePackageData(data: [ActivityPackage]) {
            invokedUpdatePackageData = true
            invokedUpdatePackageDataCount += 1
            invokedUpdatePackageDataParameters = data
        }
    }
    
    private class MockSoloTripActivityDetailNavigationDelegate: SoloTripActivityDetailNavigationDelegate {
        var invokedNotifySoloTripActivityDetailPackageDidSelect = false
        var invokedNotifySoloTripActivityDetailPackageDidSelectCount = 0
        var invokedNotifySoloTripActivityDetailPackageDidSelectParameters: (package: ActivityDetailDataModel, selectedPackageId: Int)?
        
        var invokedNotifySoloTripCreateTripTapped = false
        var invokedNotifySoloTripCreateTripTappedCount = 0
        
        func notifySoloTripActivityDetailPackageDidSelect(package: ActivityDetailDataModel, selectedPackageId: Int) {
            invokedNotifySoloTripActivityDetailPackageDidSelect = true
            invokedNotifySoloTripActivityDetailPackageDidSelectCount += 1
            invokedNotifySoloTripActivityDetailPackageDidSelectParameters = (package, selectedPackageId)
        }
        
        func notifySoloTripCreateTripTapped() {
            invokedNotifySoloTripCreateTripTapped = true
            invokedNotifySoloTripCreateTripTappedCount += 1
        }
    }
    
    // MARK: - Initialization Tests
    @Test("initialization - should set up correctly with provided solo activity data")
    func initialization_withProvidedSoloActivityData_shouldSetupCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        let viewModel = context.viewModel
        
        // --- THEN ---
        #expect(viewModel.actionDelegate === context.mockActionDelegate)
        #expect(viewModel.navigationDelegate === context.mockNavigationDelegate)
    }
    
    // MARK: - View Did Load Tests
    @Test("view did load - should configure view with solo activity data")
    func viewDidLoad_shouldConfigureViewWithSoloActivityData() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedConfigureView == true)
        #expect(context.mockActionDelegate.invokedConfigureViewCount == 1)
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.title == "Solo Adventure Activity")
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.location == "Solo Traveler Paradise")
    }
    
    @Test("view did load - should pass complete solo activity data to action delegate")
    func viewDidLoad_shouldPassCompleteSoloActivityDataToActionDelegate() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        let passedData = context.mockActionDelegate.invokedConfigureViewParameters
        #expect(passedData != nil)
        #expect(passedData?.availablePackages.content.count == 2)
        #expect(passedData?.tripFacilities.content.count == 3)
        #expect(passedData?.imageUrlsString.count == 3)
        #expect(passedData?.detailInfomation.content == "Detailed information about solo travel experience")
    }
    
    // MARK: - Package Detail State Change Tests
    @Test("package detail state change - should show all solo packages when shouldShowAll is true")
    func packageDetailStateChange_whenShouldShowAllIsTrue_shouldShowAllSoloPackages() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedUpdatePackageData == true)
        #expect(context.mockActionDelegate.invokedUpdatePackageDataCount == 1)
        #expect(context.mockActionDelegate.invokedUpdatePackageDataParameters?.count == 3) // All solo packages from ActivityPackage data
        
        // Verify these are solo packages (max participants = 1)
        let packages = context.mockActionDelegate.invokedUpdatePackageDataParameters
        #expect(packages?.allSatisfy { $0.maxParticipants == 1 } == true)
    }
    
    @Test("package detail state change - should show hidden solo packages when shouldShowAll is false")
    func packageDetailStateChange_whenShouldShowAllIsFalse_shouldShowHiddenSoloPackages() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: false)
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedUpdatePackageData == true)
        #expect(context.mockActionDelegate.invokedUpdatePackageDataCount == 1)
        
        // Hidden packages should be the limited set
        let hiddenPackagesCount = context.mockActionDelegate.invokedUpdatePackageDataParameters?.count ?? 0
        #expect(hiddenPackagesCount <= 3) // Should be less than or equal to total packages
        
        // Verify these are still solo packages
        let packages = context.mockActionDelegate.invokedUpdatePackageDataParameters
        #expect(packages?.allSatisfy { $0.maxParticipants == 1 } == true)
    }
    
    @Test("package detail state change - should handle multiple state changes for solo packages")
    func packageDetailStateChange_withMultipleChanges_shouldHandleSoloPackagesCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: false)
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedUpdatePackageDataCount == 3)
    }
    
    // MARK: - Solo Package Selection Tests
    @Test("solo package selection - should notify navigation delegate with correct solo package parameters")
    func soloPackageSelection_shouldNotifyNavigationDelegateWithCorrectSoloPackageParameters() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let selectedSoloPackageId = 2
        
        // --- WHEN ---
        context.viewModel.onPackagesDetailDidTap(with: selectedSoloPackageId)
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripActivityDetailPackageDidSelect == true)
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripActivityDetailPackageDidSelectCount == 1)
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripActivityDetailPackageDidSelectParameters?.selectedPackageId == 2)
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripActivityDetailPackageDidSelectParameters?.package.title == "Solo Adventure Activity")
    }
    
    @Test("solo package selection - should handle different solo package IDs")
    func soloPackageSelection_withDifferentSoloPackageIds_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackagesDetailDidTap(with: 1) // Solo Basic Package
        context.viewModel.onPackagesDetailDidTap(with: 3) // Solo Luxury Package
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripActivityDetailPackageDidSelectCount == 2)
        let finalSelection = context.mockNavigationDelegate.invokedNotifySoloTripActivityDetailPackageDidSelectParameters
        #expect(finalSelection?.selectedPackageId == 3)
    }
    
    // MARK: - Solo Trip Creation Tests
    @Test("solo trip creation - should notify navigation delegate when solo trip is created")
    func soloTripCreation_shouldNotifyNavigationDelegateWhenSoloTripCreated() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onCreateTripTapped()
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripCreateTripTapped == true)
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripCreateTripTappedCount == 1)
    }
    
    @Test("solo trip creation - should handle multiple solo trip creation attempts")
    func soloTripCreation_withMultipleAttempts_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onCreateTripTapped()
        context.viewModel.onCreateTripTapped()
        context.viewModel.onCreateTripTapped()
        
        // --- THEN ---
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripCreateTripTappedCount == 3)
    }
    
    // MARK: - Solo Data Integrity Tests
    @Test("solo data integrity - should maintain solo activity data throughout operations")
    func soloDataIntegrity_shouldMaintainSoloActivityDataThroughoutOperations() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        context.viewModel.onPackagesDetailDidTap(with: 1)
        context.viewModel.onCreateTripTapped()
        
        // --- THEN ---
        // All operations should use the same solo activity data
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.title == "Solo Adventure Activity")
        #expect(context.mockNavigationDelegate.invokedNotifySoloTripActivityDetailPackageDidSelectParameters?.package.title == "Solo Adventure Activity")
    }
    
    // MARK: - Solo Package Validation Tests
    @Test("solo package validation - should ensure packages are suitable for solo travelers")
    func soloPackageValidation_shouldEnsurePackagesAreSuitableForSoloTravelers() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        
        // --- THEN ---
        let packages = context.mockActionDelegate.invokedUpdatePackageDataParameters
        #expect(packages != nil)
        
        // All packages should be suitable for solo travelers
        let allSoloSuitable = packages?.allSatisfy { package in
            package.maxParticipants == 1 && package.minParticipants == 1
        } ?? false
        #expect(allSoloSuitable == true)
    }
    
    // MARK: - Solo Delegate Weak Reference Tests
    @Test("solo delegate weak reference - should handle nil delegates gracefully")
    func soloDellegateWeakReference_withNilDelegates_shouldHandleGracefully() async throws {
        // --- GIVEN ---
        let activityData = TestContext.createMockActivityDetailData()
        let viewModel = SoloTripActivityDetailViewModel(data: activityData)
        
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
    
    // MARK: - Solo Package Data Edge Cases Tests
    @Test("solo package data edge cases - should handle empty solo packages correctly")
    func soloPackageDataEdgeCases_withEmptySoloPackages_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let emptySoloPackageData = ActivityDetailDataModel(
            title: "Solo Activity No Packages",
            location: "Solo Location",
            imageUrlsString: [],
            detailInfomation: ActivitySectionLayout(
                title: "Solo Detail",
                content: "Solo Content"
            ),
            providerDetail: ActivitySectionLayout(
                title: "Solo Provider",
                content: ActivityDetailDataModel.ProviderDetail(
                    name: "Solo Provider",
                    description: "Solo Description",
                    imageUrlString: ""
                )
            ),
            tripFacilities: ActivitySectionLayout(
                title: "Solo Facilities",
                content: []
            ),
            tnc: "Solo terms",
            availablePackages: ActivitySectionLayout(
                title: "Solo Packages",
                content: []
            ),
            hiddenPackages: []
        )
        
        let viewModel = SoloTripActivityDetailViewModel(data: emptySoloPackageData)
        let mockActionDelegate = MockSoloTripActivityDetailViewModelAction()
        viewModel.actionDelegate = mockActionDelegate
        
        // --- WHEN ---
        viewModel.onPackageDetailStateDidChange(shouldShowAll: true)
        
        // --- THEN ---
        #expect(mockActionDelegate.invokedUpdatePackageData == true)
        #expect(mockActionDelegate.invokedUpdatePackageDataParameters?.isEmpty == true)
    }
    
    // MARK: - Solo vs Group Package Differentiation Tests
    @Test("solo vs group differentiation - should maintain solo-specific characteristics")
    func soloVsGroupDifferentiation_shouldMaintainSoloSpecificCharacteristics() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        let configuredData = context.mockActionDelegate.invokedConfigureViewParameters
        #expect(configuredData != nil)
        
        // Verify it's clearly a solo activity
        #expect(configuredData?.title.contains("Solo") == true)
        #expect(configuredData?.location.contains("Solo") == true)
        #expect(configuredData?.detailInfomation.content.contains("solo") == true)
        
        // Verify facilities are solo-oriented
        let facilities = configuredData?.tripFacilities.content ?? []
        #expect(facilities.contains { $0.contains("Personal") || $0.contains("Solo") } == true)
    }
}
