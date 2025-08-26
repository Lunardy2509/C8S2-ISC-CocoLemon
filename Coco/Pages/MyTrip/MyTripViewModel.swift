//
//  MyTripViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 14/07/25.
//

import Foundation

final class MyTripViewModel {
    weak var actionDelegate: (any MyTripViewModelAction)?
    
    init(
        fetcher: MyTripBookingListFetcherProtocol = MyTripBookingListFetcher(),
        activityFetcher: MyTripActivityFetcherProtocol = MyTripActivityFetcher()
    ) {
        self.fetcher = fetcher
        self.activityFetcher = activityFetcher
    }
    
    private let fetcher: MyTripBookingListFetcherProtocol
    private let activityFetcher: MyTripActivityFetcherProtocol
    private var responses: [BookingDetails] = []
    
    // Method to add a new booking
    func addBooking(_ booking: BookingDetails) {
        responses.append(booking)
        actionDelegate?.configureView(datas: responses.map({ listData in
            MyTripListCardDataModel(bookingDetail: listData)
        }))
    }
}

extension MyTripViewModel: MyTripViewModelProtocol {
    func onViewWillAppear() {
        print("🔍 MyTripViewModel: onViewWillAppear called, fetching trip data...")
        let userId = UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
        print("👤 MyTripViewModel: Using user ID: '\(userId)'")
        actionDelegate?.configureView(datas: [])
        responses = []
        
        Task { @MainActor in
            let response: [BookingDetails] = try await fetcher.fetchTripBookingList(
                request: TripBookingListSpec(userId: userId)
            ).values
            
            responses = response
            print("📊 MyTripViewModel: Fetched \(response.count) trip(s)")
            
            if response.isEmpty {
                actionDelegate?.configureView(datas: [])
            }
            
            actionDelegate?.configureView(datas: response.map({ listData in
                MyTripListCardDataModel(bookingDetail: listData)
            }))
        }
    }
    
    func onTripListDidTap(at index: Int) {
        guard index < responses.count else { return }
        actionDelegate?.goToBookingDetail(with: responses[index])
    }
    
    func onTripDidDelete(at index: Int) {
        guard index < responses.count else { return }
        
        let bookingToDelete = responses[index]
        
        // Remove from local array first for immediate UI update
        responses.remove(at: index)
        
        // Update UI
        actionDelegate?.configureView(datas: responses.map({ listData in
            MyTripListCardDataModel(bookingDetail: listData)
        }))
        
        Task { @MainActor in
            do {
                let deleteRequest = DeleteBookingSpec(
                    bookingId: bookingToDelete.bookingId,
                    userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
                )
                
                let _ = try await fetcher.deleteBooking(request: deleteRequest)
            } catch {
                // If API call fails, restore the item
                responses.insert(bookingToDelete, at: index)
                actionDelegate?.configureView(datas: responses.map({ listData in
                    MyTripListCardDataModel(bookingDetail: listData)
                }))
            }
        }
    }
    
    func onNotificationButtonTapped() {
        actionDelegate?.goToNotificationPage()
    }
}
