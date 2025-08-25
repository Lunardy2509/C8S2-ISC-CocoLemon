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
}

extension MyTripViewModel: MyTripViewModelProtocol {
    func onViewWillAppear() {
        actionDelegate?.configureView(datas: [])
        responses = []
        
        Task { @MainActor in
            let response: [BookingDetails] = try await fetcher.fetchTripBookingList(
                request: TripBookingListSpec(userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? "")
            ).values
            
            responses = response
            
            if response.isEmpty {
                actionDelegate?.configureView(datas: [])
            }
            
//            actionDelegate?.configureView(datas: response.map({ listData in
//                MyTripListCardDataModel(bookingDetail: listData)
//            }))
            
            // Always fetch recommendations for empty state
            if response.isEmpty {
                fetchRecommendations()
            }
        }
    }
    
    private func fetchRecommendations() {
        Task { @MainActor in
            do {
                // Fetch top destinations for recommendations
                let topDestinationResponse = try await activityFetcher.fetchTopDestination()
                
                // Get detailed activities for each top destination
                var recommendations: [MyTripRecommendationDataModel] = []
                
                for destination in topDestinationResponse.values.prefix(5) {
                    // Fetch activities for this destination
                    let activityResponse = try await activityFetcher.fetchActivity(
                        request: ActivitySearchRequest(pSearchText: destination.name)
                    ).values
                    
                    // Take the first activity from this destination
                    if let firstActivity = activityResponse.first {
                        let recommendation = MyTripRecommendationDataModel(activity: firstActivity)
                        recommendations.append(recommendation)
                    }
                }
                
                // If we don't have enough recommendations, fill with mock data
                if recommendations.count < 3 {
                    let mockRecommendations = [
                        MyTripRecommendationDataModel(
                            id: 1,
                            title: "Venice Grand Canal Adventure",
                            location: "Bunaken, Papua",
                            priceText: "Rp 750,000 - 950,000",
                            imageUrl: URL(string: "https://picsum.photos/238/180?random=1")
                        ),
                        MyTripRecommendationDataModel(
                            id: 2,
                            title: "Raja Ampat Diving Experience",
                            location: "Raja Ampat, Papua",
                            priceText: "Rp 1,200,000 - 1,500,000",
                            imageUrl: URL(string: "https://picsum.photos/238/180?random=2")
                        ),
                        MyTripRecommendationDataModel(
                            id: 3,
                            title: "Komodo Island Safari",
                            location: "Komodo, NTT",
                            priceText: "Rp 900,000 - 1,100,000",
                            imageUrl: URL(string: "https://picsum.photos/238/180?random=3")
                        )
                    ]
                    
                    // Add mock recommendations to fill the gap
                    let remainingSlots = max(0, 3 - recommendations.count)
                    recommendations.append(contentsOf: Array(mockRecommendations.prefix(remainingSlots)))
                }
                
                actionDelegate?.configureRecommendations(recommendations: recommendations)
            } catch {
                print("Failed to fetch recommendations: \(error)")
                // Provide mock recommendations as fallback
                let mockRecommendations = [
                    MyTripRecommendationDataModel(
                        id: 1,
                        title: "Venice Grand Canal Adventure",
                        location: "Bunaken, Papua",
                        priceText: "Rp 750,000 - 950,000",
                        imageUrl: URL(string: "https://picsum.photos/238/180?random=1")
                    ),
                    MyTripRecommendationDataModel(
                        id: 2,
                        title: "Raja Ampat Diving Experience",
                        location: "Raja Ampat, Papua",
                        priceText: "Rp 1,200,000 - 1,500,000",
                        imageUrl: URL(string: "https://picsum.photos/238/180?random=2")
                    ),
                    MyTripRecommendationDataModel(
                        id: 3,
                        title: "Komodo Island Safari",
                        location: "Komodo, NTT",
                        priceText: "Rp 900,000 - 1,100,000",
                        imageUrl: URL(string: "https://picsum.photos/238/180?random=3")
                    )
                ]
                
                actionDelegate?.configureRecommendations(recommendations: mockRecommendations)
            }
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
        
        // If no trips left after deletion, fetch recommendations
        if responses.isEmpty {
            fetchRecommendations()
        }
        
        // TODO: Uncomment when delete API is ready
        /*
        Task { @MainActor in
            do {
                let deleteRequest = DeleteBookingSpec(
                    bookingId: bookingToDelete.bookingId,
                    userId: UserDefaults.standard.value(forKey: "user-id") as? String ?? ""
                )
                
                let _ = try await fetcher.deleteBooking(request: deleteRequest)
                print("Trip successfully deleted from backend")
            } catch {
                // If API call fails, restore the item
                responses.insert(bookingToDelete, at: index)
                actionDelegate?.configureView(datas: responses.map({ listData in
                    MyTripListCardDataModel(bookingDetail: listData)
                }))
                print("Failed to delete trip: \(error)")
            }
        }
        */
        
        print("Trip deleted at index: \(index)")
    }
    
    func onNotificationButtonTapped() {
        actionDelegate?.goToNotificationPage()
    }
}
