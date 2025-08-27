//
//  CheckoutViewModelTest.swift
//  CocoTests
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

import Foundation
import Testing
@testable import Coco

struct CheckoutViewModelTest {
    
    // MARK: - Test Context Setup
    private struct TestContext {
        let viewModel: CheckoutViewModel
        let mockDelegate: MockCheckoutViewModelDelegate
        let mockActionDelegate: MockCheckoutViewModelAction
        let bookingResponse: BookingDetails
        
        static func setup() -> TestContext {
            // --- GIVEN ---
            let mockDelegate = MockCheckoutViewModelDelegate()
            let mockActionDelegate = MockCheckoutViewModelAction()
            let bookingResponse = createMockBookingDetails()
            
            let viewModel = CheckoutViewModel(bookingResponse: bookingResponse)
            viewModel.delegate = mockDelegate
            viewModel.actionDelegate = mockActionDelegate
            
            return TestContext(
                viewModel: viewModel,
                mockDelegate: mockDelegate,
                mockActionDelegate: mockActionDelegate,
                bookingResponse: bookingResponse
            )
        }
        
        static func createMockBookingDetails() -> BookingDetails {
            return BookingDetails(
                id: "BOOK123456",
                activityName: "Amazing Beach Adventure",
                activityLocation: "Bali, Indonesia",
                activityDate: "2025-09-15",
                packageName: "Premium Package",
                participants: 4,
                pricePerPerson: 250000.0,
                totalPrice: 1000000.0,
                bookingStatus: "confirmed",
                customerName: "John Doe",
                customerEmail: "john.doe@example.com",
                customerPhone: "+62812345678",
                packageDescription: "Premium beach adventure with professional guide",
                activityImageUrl: "https://example.com/beach.jpg",
                packageDuration: "8 hours",
                packageStartTime: "08:00",
                packageEndTime: "16:00",
                cancellationPolicy: "Free cancellation up to 24 hours before",
                facilities: ["Professional Guide", "Equipment", "Lunch", "Transportation"],
                meetingPoint: "Bali Beach Resort Lobby",
                notes: "Please bring sunscreen and comfortable shoes",
                createdAt: "2025-08-27T10:00:00Z",
                updatedAt: "2025-08-27T10:00:00Z"
            )
        }
        
        static func createMinimalBookingDetails() -> BookingDetails {
            return BookingDetails(
                id: "BOOK000001",
                activityName: "Simple Activity",
                activityLocation: "Simple Location",
                activityDate: "2025-09-01",
                packageName: "Basic Package",
                participants: 1,
                pricePerPerson: 100000.0,
                totalPrice: 100000.0,
                bookingStatus: "pending",
                customerName: "Jane Smith",
                customerEmail: "jane.smith@example.com",
                customerPhone: "+62812345679",
                packageDescription: "Basic activity package",
                activityImageUrl: "",
                packageDuration: "4 hours",
                packageStartTime: "10:00",
                packageEndTime: "14:00",
                cancellationPolicy: "No cancellation",
                facilities: [],
                meetingPoint: "Main Gate",
                notes: "",
                createdAt: "2025-08-27T09:00:00Z",
                updatedAt: "2025-08-27T09:00:00Z"
            )
        }
    }
    
    // MARK: - Mock Delegates
    private class MockCheckoutViewModelDelegate: CheckoutViewModelDelegate {
        var invokedNotifyUserDidCheckout = false
        var invokedNotifyUserDidCheckoutCount = 0
        
        func notifyUserDidCheckout() {
            invokedNotifyUserDidCheckout = true
            invokedNotifyUserDidCheckoutCount += 1
        }
    }
    
    private class MockCheckoutViewModelAction: CheckoutViewModelAction {
        var invokedConfigureView = false
        var invokedConfigureViewCount = 0
        var invokedConfigureViewParameters: BookingDetails?
        
        var invokedShowPopUpSuccess = false
        var invokedShowPopUpSuccessCount = 0
        var invokedShowPopUpSuccessCompletionCalled = false
        
        func configureView(bookingData: BookingDetails) {
            invokedConfigureView = true
            invokedConfigureViewCount += 1
            invokedConfigureViewParameters = bookingData
        }
        
        func showPopUpSuccess(completion: @escaping () -> Void) {
            invokedShowPopUpSuccess = true
            invokedShowPopUpSuccessCount += 1
            
            // Simulate popup completion
            DispatchQueue.main.async {
                self.invokedShowPopUpSuccessCompletionCalled = true
                completion()
            }
        }
    }
    
    // MARK: - Initialization Tests
    @Test("initialization - should set up correctly with provided booking response")
    func initialization_withProvidedBookingResponse_shouldSetupCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        let viewModel = context.viewModel
        
        // --- THEN ---
        #expect(viewModel.delegate === context.mockDelegate)
        #expect(viewModel.actionDelegate === context.mockActionDelegate)
    }
    
    @Test("initialization - should accept different booking response types")
    func initialization_withDifferentBookingResponseTypes_shouldAcceptCorrectly() async throws {
        // --- GIVEN ---
        let minimalBooking = TestContext.createMinimalBookingDetails()
        let viewModel = CheckoutViewModel(bookingResponse: minimalBooking)
        
        // --- WHEN ---
        let mockActionDelegate = MockCheckoutViewModelAction()
        viewModel.actionDelegate = mockActionDelegate
        viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(mockActionDelegate.invokedConfigureView == true)
        #expect(mockActionDelegate.invokedConfigureViewParameters?.id == "BOOK000001")
    }
    
    // MARK: - View Did Load Tests
    @Test("view did load - should configure view with booking data")
    func viewDidLoad_shouldConfigureViewWithBookingData() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedConfigureView == true)
        #expect(context.mockActionDelegate.invokedConfigureViewCount == 1)
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.id == "BOOK123456")
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.activityName == "Amazing Beach Adventure")
    }
    
    @Test("view did load - should pass complete booking details to action delegate")
    func viewDidLoad_shouldPassCompleteBookingDetailsToActionDelegate() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        let passedData = context.mockActionDelegate.invokedConfigureViewParameters
        #expect(passedData != nil)
        #expect(passedData?.activityLocation == "Bali, Indonesia")
        #expect(passedData?.activityDate == "2025-09-15")
        #expect(passedData?.packageName == "Premium Package")
        #expect(passedData?.participants == 4)
        #expect(passedData?.totalPrice == 1000000.0)
        #expect(passedData?.customerName == "John Doe")
        #expect(passedData?.customerEmail == "john.doe@example.com")
    }
    
    @Test("view did load - should handle multiple view did load calls")
    func viewDidLoad_withMultipleCalls_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        context.viewModel.onViewDidLoad()
        context.viewModel.onViewDidLoad()
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedConfigureViewCount == 3)
        // Each call should pass the same booking data
        #expect(context.mockActionDelegate.invokedConfigureViewParameters?.id == "BOOK123456")
    }
    
    // MARK: - Book Now Tests
    @Test("book now - should show success popup and notify delegate")
    func bookNow_shouldShowSuccessPopupAndNotifyDelegate() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.bookNowDidTap()
        
        // Wait for async completion
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedShowPopUpSuccess == true)
        #expect(context.mockActionDelegate.invokedShowPopUpSuccessCount == 1)
        #expect(context.mockActionDelegate.invokedShowPopUpSuccessCompletionCalled == true)
        #expect(context.mockDelegate.invokedNotifyUserDidCheckout == true)
        #expect(context.mockDelegate.invokedNotifyUserDidCheckoutCount == 1)
    }
    
    @Test("book now - should handle multiple book now taps")
    func bookNow_withMultipleTaps_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.bookNowDidTap()
        context.viewModel.bookNowDidTap()
        context.viewModel.bookNowDidTap()
        
        // Wait for async completions
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // --- THEN ---
        #expect(context.mockActionDelegate.invokedShowPopUpSuccessCount == 3)
        #expect(context.mockDelegate.invokedNotifyUserDidCheckoutCount == 3)
    }
    
    @Test("book now - should execute completion callback correctly")
    func bookNow_shouldExecuteCompletionCallbackCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        var completionExecuted = false
        
        // Override the action delegate to track completion execution
        let customActionDelegate = MockCheckoutViewModelAction()
        context.viewModel.actionDelegate = customActionDelegate
        
        // Custom implementation to verify completion flow
        customActionDelegate.invokedShowPopUpSuccess = false
        
        // --- WHEN ---
        context.viewModel.bookNowDidTap()
        
        // Wait for async operation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // --- THEN ---
        #expect(customActionDelegate.invokedShowPopUpSuccess == true)
        #expect(context.mockDelegate.invokedNotifyUserDidCheckout == true)
    }
    
    // MARK: - Booking Data Integrity Tests
    @Test("booking data integrity - should maintain booking data throughout process")
    func bookingDataIntegrity_shouldMaintainBookingDataThroughoutProcess() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onViewDidLoad()
        context.viewModel.bookNowDidTap()
        
        // Wait for async operation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // --- THEN ---
        // View configuration should have the same data
        let configuredData = context.mockActionDelegate.invokedConfigureViewParameters
        #expect(configuredData?.id == "BOOK123456")
        #expect(configuredData?.totalPrice == 1000000.0)
        #expect(configuredData?.participants == 4)
    }
    
    // MARK: - Different Booking Scenarios Tests
    @Test("different booking scenarios - should handle minimal booking details")
    func differentBookingScenarios_withMinimalBookingDetails_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let minimalBooking = TestContext.createMinimalBookingDetails()
        let viewModel = CheckoutViewModel(bookingResponse: minimalBooking)
        let mockActionDelegate = MockCheckoutViewModelAction()
        let mockDelegate = MockCheckoutViewModelDelegate()
        
        viewModel.actionDelegate = mockActionDelegate
        viewModel.delegate = mockDelegate
        
        // --- WHEN ---
        viewModel.onViewDidLoad()
        viewModel.bookNowDidTap()
        
        // Wait for async operation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // --- THEN ---
        #expect(mockActionDelegate.invokedConfigureView == true)
        #expect(mockActionDelegate.invokedConfigureViewParameters?.id == "BOOK000001")
        #expect(mockActionDelegate.invokedConfigureViewParameters?.participants == 1)
        #expect(mockActionDelegate.invokedConfigureViewParameters?.totalPrice == 100000.0)
        #expect(mockActionDelegate.invokedShowPopUpSuccess == true)
        #expect(mockDelegate.invokedNotifyUserDidCheckout == true)
    }
    
    @Test("different booking scenarios - should handle high value bookings")
    func differentBookingScenarios_withHighValueBookings_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let highValueBooking = BookingDetails(
            id: "BOOK999999",
            activityName: "Luxury Safari Experience",
            activityLocation: "Serengeti, Tanzania",
            activityDate: "2025-12-25",
            packageName: "VIP Luxury Package",
            participants: 8,
            pricePerPerson: 5000000.0,
            totalPrice: 40000000.0,
            bookingStatus: "confirmed",
            customerName: "Luxury Customer",
            customerEmail: "luxury@example.com",
            customerPhone: "+628123456789",
            packageDescription: "Ultimate luxury safari experience",
            activityImageUrl: "https://example.com/safari.jpg",
            packageDuration: "3 days",
            packageStartTime: "06:00",
            packageEndTime: "18:00",
            cancellationPolicy: "Flexible cancellation",
            facilities: ["Private Guide", "Luxury Accommodation", "All Meals", "Private Transport"],
            meetingPoint: "Luxury Lodge",
            notes: "VIP treatment throughout",
            createdAt: "2025-08-27T15:00:00Z",
            updatedAt: "2025-08-27T15:00:00Z"
        )
        
        let viewModel = CheckoutViewModel(bookingResponse: highValueBooking)
        let mockActionDelegate = MockCheckoutViewModelAction()
        let mockDelegate = MockCheckoutViewModelDelegate()
        
        viewModel.actionDelegate = mockActionDelegate
        viewModel.delegate = mockDelegate
        
        // --- WHEN ---
        viewModel.onViewDidLoad()
        viewModel.bookNowDidTap()
        
        // Wait for async operation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // --- THEN ---
        #expect(mockActionDelegate.invokedConfigureViewParameters?.totalPrice == 40000000.0)
        #expect(mockActionDelegate.invokedConfigureViewParameters?.participants == 8)
        #expect(mockActionDelegate.invokedShowPopUpSuccess == true)
        #expect(mockDelegate.invokedNotifyUserDidCheckout == true)
    }
    
    // MARK: - Delegate Weak Reference Tests
    @Test("delegate weak reference - should handle nil delegates gracefully")
    func delegateWeakReference_withNilDelegates_shouldHandleGracefully() async throws {
        // --- GIVEN ---
        let bookingResponse = TestContext.createMockBookingDetails()
        let viewModel = CheckoutViewModel(bookingResponse: bookingResponse)
        
        // --- WHEN ---
        viewModel.onViewDidLoad()
        viewModel.bookNowDidTap()
        
        // --- THEN ---
        // Should not crash and complete successfully
        #expect(viewModel.delegate == nil)
        #expect(viewModel.actionDelegate == nil)
    }
    
    // MARK: - Completion Flow Tests
    @Test("completion flow - should execute completion flow in correct order")
    func completionFlow_shouldExecuteCompletionFlowInCorrectOrder() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        var executionOrder: [String] = []
        
        // Create custom action delegate to track execution order
        let customActionDelegate = MockCheckoutViewModelAction()
        context.viewModel.actionDelegate = customActionDelegate
        
        // Override to track execution order
        let originalShowPopUp = customActionDelegate.showPopUpSuccess
        customActionDelegate.showPopUpSuccess = { completion in
            executionOrder.append("showPopUpSuccess")
            DispatchQueue.main.async {
                executionOrder.append("completion_called")
                completion()
            }
        }
        
        // --- WHEN ---
        context.viewModel.bookNowDidTap()
        
        // Wait for async operations
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // --- THEN ---
        #expect(executionOrder.contains("showPopUpSuccess"))
        #expect(executionOrder.contains("completion_called"))
        #expect(context.mockDelegate.invokedNotifyUserDidCheckout == true)
    }
    
    // MARK: - Data Validation Tests
    @Test("data validation - should handle booking with all required fields")
    func dataValidation_withAllRequiredFields_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let completeBooking = TestContext.createMockBookingDetails()
        let viewModel = CheckoutViewModel(bookingResponse: completeBooking)
        let mockActionDelegate = MockCheckoutViewModelAction()
        viewModel.actionDelegate = mockActionDelegate
        
        // --- WHEN ---
        viewModel.onViewDidLoad()
        
        // --- THEN ---
        let configuredData = mockActionDelegate.invokedConfigureViewParameters
        #expect(configuredData?.id.isEmpty == false)
        #expect(configuredData?.activityName.isEmpty == false)
        #expect(configuredData?.activityLocation.isEmpty == false)
        #expect(configuredData?.customerName.isEmpty == false)
        #expect(configuredData?.customerEmail.isEmpty == false)
        #expect(configuredData?.totalPrice ?? 0 > 0)
        #expect(configuredData?.participants ?? 0 > 0)
    }
}
