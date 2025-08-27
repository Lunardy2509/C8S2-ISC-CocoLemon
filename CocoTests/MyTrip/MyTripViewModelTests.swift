//
//  MyTripViewModelTests.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 28/08/25.
//

//import Testing
//import Foundation
//@testable import Coco
//
//// MARK: - Mock Classes
//
//// Mock for MyTripViewModelAction
//final class MockMyTripViewModelAction: MyTripViewModelAction {
//    var configureViewCalled = false
//    var goToBookingDetailCalled = false
//    var goToLocalBookingDetailCalled = false
//    var goToNotificationPageCalled = false
//    var showDeleteConfirmationCalled = false
//    
//    func configureView(datas: [MyTripListCardDataModel]) {
//        configureViewCalled = true
//    }
//    
//    func goToBookingDetail(with data: BookingDetails) {
//        goToBookingDetailCalled = true
//    }
//    
//    func goToLocalBookingDetail(with data: LocalBookingDetails) {
//        goToLocalBookingDetailCalled = true
//    }
//    
//    func goToNotificationPage() {
//        goToNotificationPageCalled = true
//    }
//    
//    func showDeleteConfirmation(for index: Int, completion: @escaping (Bool) -> Void) {
//        showDeleteConfirmationCalled = true
//        completion(true)  // Simulate confirming delete
//    }
//}
//
//// MARK: - Test Suite
//
//struct MyTripViewModelTests {
//    
//    // MARK: - ViewModel Initialization Tests
//    
//    @Test func testViewModelInitialization() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        
//        // When
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        
//        // Then
//        #expect(viewModel.responses.isEmpty == true)  // Ensure responses are initially empty
//        #expect(viewModel.localBookings.isEmpty == true)  // Ensure localBookings are initially empty
//    }
//    
//    // MARK: - Add Booking Tests
//    
//    @Test func testAddBooking() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        let mockBooking = mockBookingDetails()
//        
//        // When
//        viewModel.addBooking(mockBooking)
//        
//        // Then
//        #expect(viewModel.responses.count == 1)  // Ensure one booking has been added
//    }
//    
//    // MARK: - Add Local Booking Tests
//    
//    @Test func testAddLocalBooking() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        let mockLocalBooking = mockLocalBookingDetails()
//        
//        // When
//        viewModel.addLocalBooking(mockLocalBooking)
//        
//        // Then
//        #expect(viewModel.localBookings.count == 1)  // Ensure one local booking has been added
//    }
//    
//    // MARK: - Trip List Tap Tests
//    
//    @Test func testOnTripListDidTap() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        let mockActionDelegate = MockMyTripViewModelAction()
//        viewModel.actionDelegate = mockActionDelegate
//        
//        let mockBooking = mockBookingDetails()
//        viewModel.addBooking(mockBooking)
//        
//        // When - Tap on trip list
//        viewModel.onTripListDidTap(at: 0)
//        
//        // Then
//        #expect(mockActionDelegate.goToBookingDetailCalled == true)
//    }
//    
//    @Test func testOnLocalTripListDidTap() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        let mockActionDelegate = MockMyTripViewModelAction()
//        viewModel.actionDelegate = mockActionDelegate
//        
//        let mockLocalBooking = mockLocalBookingDetails()
//        viewModel.addLocalBooking(mockLocalBooking)
//        
//        // When - Tap on local trip list
//        viewModel.onTripListDidTap(at: 0)
//        
//        // Then
//        #expect(mockActionDelegate.goToLocalBookingDetailCalled == true)
//    }
//    
//    // MARK: - Trip Deletion Tests
//    
//    @Test func testOnTripDidDelete() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        let mockActionDelegate = MockMyTripViewModelAction()
//        viewModel.actionDelegate = mockActionDelegate
//        
//        let mockBooking = mockBookingDetails()
//        viewModel.addBooking(mockBooking)
//        
//        // When - Deleting the trip
//        viewModel.onTripDidDelete(at: 0)
//        
//        // Then
//        #expect(viewModel.responses.count == 0)  // Ensure booking has been deleted
//    }
//    
//    // MARK: - Notification Button Test
//    
//    @Test func testOnNotificationButtonTapped() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        let mockActionDelegate = MockMyTripViewModelAction()
//        viewModel.actionDelegate = mockActionDelegate
//        
//        // When - Tap on notification button
//        viewModel.onNotificationButtonTapped()
//        
//        // Then
//        #expect(mockActionDelegate.goToNotificationPageCalled == true)
//    }
//    
//    // MARK: - Utility Tests
//    
//    @Test func testShowDeleteConfirmation() async throws {
//        // Given
//        let mockFetcher = MockMyTripBookingListFetcher()
//        let mockActivityFetcher = MockMyTripActivityFetcher()
//        let viewModel = MyTripViewModel(fetcher: mockFetcher, activityFetcher: mockActivityFetcher)
//        let mockActionDelegate = MockMyTripViewModelAction()
//        viewModel.actionDelegate = mockActionDelegate
//        
//        // When - Show delete confirmation
//        viewModel.onTripDidDelete(at: 0)
//        
//        // Then
//        #expect(mockActionDelegate.showDeleteConfirmationCalled == true)
//    }
//}
//
//// MARK: - Mock Data
//
//func mockBookingDetails() -> BookingDetails {
//    return BookingDetails(
//        bookingId: 1,
//        activityTitle: "Trip to Bali",
//        activityDate: "2025-08-25",
//        totalPrice: 1200000,
//        participants: 4,
//        status: "Upcoming",
//        destination: BookingDestination(id: 1, name: "Bali", imageUrl: "https://example.com/image.jpg", description: "A beautiful place")
//    )
//}
//
//func mockLocalBookingDetails() -> LocalBookingDetails {
//    return LocalBookingDetails(
//        id: "local-1",
//        activityTitle: "Local Adventure",
//        activityDate: "2025-08-26",
//        totalPrice: 800000,
//        participants: 3,
//        status: "Completed",
//        destination: BookingDestination(id: 1, name: "Local Park", imageUrl: "https://example.com/local.jpg", description: "Enjoy the park"),
//        address: "Local address"
//    )
//}
