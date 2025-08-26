//
//  MyTripViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 14/07/25.
//

import Foundation

final class MyTripViewModel {
    weak var actionDelegate: (any MyTripViewModelAction)?
    
    private let fetcher: MyTripBookingListFetcherProtocol
    private let activityFetcher: MyTripActivityFetcherProtocol
    private var responses: [BookingDetails] = []
    private var localBookings: [LocalBookingDetails] = [] 
    
    init(
        fetcher: MyTripBookingListFetcherProtocol = MyTripBookingListFetcher(),
        activityFetcher: MyTripActivityFetcherProtocol = MyTripActivityFetcher()
    ) {
        self.fetcher = fetcher
        self.activityFetcher = activityFetcher
    }
    
    func addBooking(_ booking: BookingDetails) {
        responses.append(booking)
        refreshView()
    }
    
    func addLocalBooking(_ localBooking: LocalBookingDetails) {
        localBookings.append(localBooking)
        refreshView()
    }
    
    private func refreshView() {
        let regularCards = responses.map { MyTripListCardDataModel(bookingDetail: $0) }
        let localCards = localBookings.map { MyTripListCardDataModel(localBookingDetail: $0) }
        
        let allCards = regularCards + localCards
        actionDelegate?.configureView(datas: allCards)
    }
}

extension MyTripViewModel: MyTripViewModelProtocol {
    func onViewWillAppear() {
        refreshView() 
        
        print("🔍 MyTripViewModel: onViewWillAppear called, fetching trip data...")
        let userId = UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
        print("👤 MyTripViewModel: Using user ID: '\(userId)'")
        
        Task { @MainActor in
            do {
                let response: [BookingDetails] = try await fetcher.fetchTripBookingList(
                    request: TripBookingListSpec(userId: userId)
                ).values
                
                responses = response
                print("📊 MyTripViewModel: Fetched \(response.count) trip(s)")
                refreshView()
            } catch {
                print("❌ MyTripViewModel: Error fetching trips: \(error)")
                refreshView()
            }
        }
    }
    
    func onTripListDidTap(at index: Int) {
        let allCards = responses.map { MyTripListCardDataModel(bookingDetail: $0) } + 
                      localBookings.map { MyTripListCardDataModel(localBookingDetail: $0) }
        
        guard index < allCards.count else { return }
        
        if index < responses.count {
            let booking = responses[index]
            actionDelegate?.goToBookingDetail(with: booking)
        } else {
            let localIndex = index - responses.count
            if localIndex < localBookings.count {
                let localBooking = localBookings[localIndex]
                actionDelegate?.goToLocalBookingDetail(with: localBooking)
            }
        }
    }
    
    func onTripDidDelete(at index: Int) {
        let totalRegularBookings = responses.count
        
        if index < totalRegularBookings {
            responses.remove(at: index)
        } else {
            let localIndex = index - totalRegularBookings
            if localIndex < localBookings.count {
                localBookings.remove(at: localIndex)
            }
        }
        refreshView()
    }
    
    func onNotificationButtonTapped() {
        actionDelegate?.goToNotificationPage()
    }
}
