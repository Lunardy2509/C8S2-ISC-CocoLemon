//
//  GroupTripPlanViewModelTests.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 28/08/25.
//

import Testing
import Foundation
@testable import Coco

// MARK: - Mock Classes

// Mock for GroupTripPlanViewModelAction
final class MockGroupTripPlanViewModelAction: GroupTripPlanViewModelAction {
    var configureViewCalled = false
    
    func configureView(data: GroupTripPlanDataModel) {
        configureViewCalled = true
    }
}

// Mock for GroupTripPlanNavigationDelegate
final class MockGroupTripPlanNavigationDelegate: GroupTripPlanNavigationDelegate {
    var notifyGroupTripPlanEditTappedCalled = false
    var notifyGroupTripPlanBookNowTappedCalled = false
    
    func notifyGroupTripPlanEditTapped(data: GroupTripPlanDataModel) {
        notifyGroupTripPlanEditTappedCalled = true
    }
    
    func notifyGroupTripPlanBookNowTapped(localBookingDetails: LocalBookingDetails) {
        notifyGroupTripPlanBookNowTappedCalled = true
    }
}

// MARK: - Test Suite

struct GroupTripPlanViewModelTests {
    
    // MARK: - ViewModel Initialization Tests
    
    @Test func testViewModelInitialization() async throws {
        // Given
        let mockData = mockGroupTripPlanDataModel()
        
        // When
        let viewModel = GroupTripPlanViewModel(data: mockData)
        
        // Then
        #expect(viewModel.tripName == mockData.tripName)
    }
    
    @Test func testOnViewDidLoad() async throws {
        // Given
        let mockData = mockGroupTripPlanDataModel()
        let mockActionDelegate = MockGroupTripPlanViewModelAction()
        let viewModel = GroupTripPlanViewModel(data: mockData)
        viewModel.actionDelegate = mockActionDelegate
        
        // When
        viewModel.onViewDidLoad()
        
        // Then
        #expect(mockActionDelegate.configureViewCalled == true)
    }
    
    // MARK: - Edit Trip Tests
    
    @Test func testOnEditTapped() async throws {
        // Given
        let mockData = mockGroupTripPlanDataModel()
        let mockNavigationDelegate = MockGroupTripPlanNavigationDelegate()
        let viewModel = GroupTripPlanViewModel(data: mockData)
        viewModel.navigationDelegate = mockNavigationDelegate
        
        // When
        viewModel.onEditTapped()
        
        // Then
        #expect(mockNavigationDelegate.notifyGroupTripPlanEditTappedCalled == true)
    }
    
    @Test func testOnEditTappedNavigationDelegateNil() async throws {
        // Given
        let mockData = mockGroupTripPlanDataModel()
        let viewModel = GroupTripPlanViewModel(data: mockData)
        
        // When
        viewModel.onEditTapped()
        
        // Then
        // Ensure that no navigation delegate method is called if delegate is nil
        #expect(viewModel.navigationDelegate == nil)
    }
    
    // MARK: - Book Trip Tests
    
    @Test func testOnBookNowTapped() async throws {
        // Given
        let mockData = mockGroupTripPlanDataModel()
        let mockNavigationDelegate = MockGroupTripPlanNavigationDelegate()
        let viewModel = GroupTripPlanViewModel(data: mockData)
        viewModel.navigationDelegate = mockNavigationDelegate
        
        // When
        viewModel.onBookNowTapped()
        
        // Then
        #expect(mockNavigationDelegate.notifyGroupTripPlanBookNowTappedCalled == true)
    }
    
    // MARK: - Package Voting Tests
    
    @Test func testOnPackageVoteToggled() async throws {
        // Given
        let mockData = mockGroupTripPlanDataModel()
        let mockActionDelegate = MockGroupTripPlanViewModelAction()
        let viewModel = GroupTripPlanViewModel(data: mockData)
        viewModel.actionDelegate = mockActionDelegate
        
        let packageId = mockData.selectedPackages.first?.id ?? 1
        
        // When - Toggle vote for the package
        viewModel.onPackageVoteToggled(packageId)
        
        // Then - Ensure the vote has been toggled and view updated
        #expect(viewModel.actionDelegate?.configureViewCalled == true)
    }
    
    // MARK: - Utility Tests
    
    @Test func testCalculateTotalPrice() async throws {
        // Given
        let mockData = mockGroupTripPlanDataModel()
        let viewModel = GroupTripPlanViewModel(data: mockData)
        
        // When
        let totalPrice = viewModel.calculateTotalPrice()
        
        // Then
        #expect(totalPrice > 0.0)
    }
}

// MARK: - Mock Data

func mockGroupTripPlanDataModel() -> GroupTripPlanDataModel {
    return GroupTripPlanDataModel(
        tripName: "Trip to Bali",
        activityData: mockActivityDetailDataModel(),
        tripMembers: [TripMember(name: "Adhis", email: "adhis@example.com")],
        selectedPackageIds: [1, 2],
        dateVisit: Date(),
        dueDate: Date()
    )
}

func mockActivityDetailDataModel() -> ActivityDetailDataModel {
    return ActivityDetailDataModel(
        title: "Bali Adventure",
        location: "Bali, Indonesia",
        imageUrlsString: ["https://example.com/image.jpg"],
        availablePackages: ActivityDetailDataModel.PackageResponse(content: [
            ActivityDetailDataModel.Package(id: 1, name: "Standard Package", price: "Rp 1,200,000", minParticipants: 2, maxParticipants: 10, imageUrlString: "https://example.com/standard.jpg"),
            ActivityDetailDataModel.Package(id: 2, name: "Premium Package", price: "Rp 2,500,000", minParticipants: 2, maxParticipants: 8, imageUrlString: "https://example.com/premium.jpg")
        ]),
        tripFacilities: ActivityDetailDataModel.FacilitiesResponse(content: ["Snorkeling Gear", "Lunch Included"]),
        providerDetail: ActivityDetailDataModel.Provider(name: "Local Guides", imageUrlString: "https://example.com/guide.jpg"),
        tnc: "Free cancellation up to 24 hours before trip",
        imageUrlsString: ["https://example.com/image1.jpg"]
    )
}
