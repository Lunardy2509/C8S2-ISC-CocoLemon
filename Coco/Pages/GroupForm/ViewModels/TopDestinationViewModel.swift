//
//  TopDestinationViewModel.swift
//  Coco
//
//  Created by GitHub Copilot on 26/08/25.
//

import Foundation
import Combine

@MainActor
final class TopDestinationViewModel: ObservableObject {
    @Published var topDestinations: [TopDestinationCardDataModel] = []
    @Published var isLoading: Bool = false
    
    private let activityFetcher: ActivityFetcherProtocol
    
    init(activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.activityFetcher = activityFetcher
    }
    
    func fetchTopDestinations() {
        isLoading = true
        
        // First, fetch top destinations
        activityFetcher.fetchTopDestination { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in
                switch result {
                case .success(let topDestinationResponse):
                    let topDestinations = topDestinationResponse.values
                    
                    // Initialize with basic info first
                    self.topDestinations = topDestinations.map { destination in
                        TopDestinationCardDataModel(
                            id: destination.id,
                            title: destination.name,
                            location: destination.name,
                            priceText: "Loading...",
                            imageUrl: nil
                        )
                    }
                    
                    // Then fetch detailed information for each destination
                    await self.enrichDestinationsWithActivityDetails(topDestinations)
                    
                case .failure(let error):
                    print("Failed to fetch top destinations: \(error)")
                    self.isLoading = false
                }
            }
        }
    }
    
    private func enrichDestinationsWithActivityDetails(_ destinations: [ActivityTopDestination]) async {
        var enrichedDestinations: [TopDestinationCardDataModel] = []
        
        // Process destinations in batches to avoid overwhelming the API
        for destination in destinations.prefix(10) { // Limit to top 10 destinations
            do {
                // Fetch activities for this destination
                let activityResponse = try await withCheckedThrowingContinuation { continuation in
                    activityFetcher.fetchActivity(
                        request: ActivitySearchRequest(pSearchText: destination.name)
                    ) { result in
                        continuation.resume(with: result)
                    }
                }
                
                // Use the first activity from this destination to create enriched data
                if let firstActivity = activityResponse.values.first {
                    // Extract price range from activity
                    let prices: [Double] = firstActivity.packages.map { $0.pricePerPerson }
                    let priceText: String
                    if let minPrice = prices.min(), let maxPrice = prices.max() {
                        if minPrice == maxPrice {
                            priceText = "\(minPrice.toRupiah())/person"
                        } else {
                            priceText = "\(minPrice.toRupiah()) - \(maxPrice.toRupiah())/person"
                        }
                    } else {
                        priceText = "-"
                    }
                    
                    // Extract image URL
                    let imageUrl: URL? = if let thumbnailURLString = firstActivity.images.first(where: { $0.imageType == .thumbnail })?.imageUrl {
                        URL(string: thumbnailURLString)
                    } else {
                        nil
                    }
                    
                    // Create destination using direct initializer with TopDestination data
                    let enrichedDestination = TopDestinationCardDataModel(
                        id: destination.id,
                        title: destination.name,
                        location: destination.name,
                        priceText: priceText,
                        imageUrl: imageUrl
                    )
                    enrichedDestinations.append(enrichedDestination)
                } else {
                    // If no activities found, keep basic info
                    let basicDestination = TopDestinationCardDataModel(
                        id: destination.id,
                        title: destination.name,
                        location: destination.name,
                        priceText: "No pricing available",
                        imageUrl: nil
                    )
                    enrichedDestinations.append(basicDestination)
                }
                
            } catch {
                print("Failed to fetch activity details for \(destination.name): \(error)")
                // Keep basic info if detailed fetch fails
                let basicDestination = TopDestinationCardDataModel(
                    id: destination.id,
                    title: destination.name,
                    location: destination.name,
                    priceText: "Price unavailable",
                    imageUrl: nil
                )
                enrichedDestinations.append(basicDestination)
            }
        }
        
        // Update the published property
        self.topDestinations = enrichedDestinations
        self.isLoading = false
    }
}
