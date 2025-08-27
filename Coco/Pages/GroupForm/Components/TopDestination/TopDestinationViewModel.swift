//
//  TopDestinationViewModel.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import Foundation
import Combine

@MainActor
final class TopDestinationViewModel: ObservableObject {
    @Published var topDestinations: [TopDestinationCardDataModel] = []
    @Published var activity: [GroupFormRecommendationDataModel] = []
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
                    
                    // Then fetch detailed information for each destination and collect activities
                    await self.enrichDestinationsWithActivityDetails(topDestinations)
                    
                case .failure:
                    self.isLoading = false
                }
            }
        }
    }
    
    private func enrichDestinationsWithActivityDetails(_ destinations: [ActivityTopDestination]) async {
        var enrichedDestinations: [TopDestinationCardDataModel] = []
        var allActivities: [GroupFormRecommendationDataModel] = []
        
        // Process destinations in batches to avoid overwhelming the API
        for destination in destinations {
            do {
                // Fetch activities for this destination using multiple search strategies
                var allSearchResults: [Activity] = []
                
                // Search with full destination name
                let fullNameResponse = try await withCheckedThrowingContinuation { continuation in
                    activityFetcher.fetchActivity(
                        request: ActivitySearchRequest(pSearchText: destination.name)
                    ) { result in
                        continuation.resume(with: result)
                    }
                }
                allSearchResults.append(contentsOf: fullNameResponse.values)
                
                // Search with just the main location name (before comma)
                let mainLocationName = destination.name.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? destination.name
                if mainLocationName != destination.name {
                    let mainNameResponse = try await withCheckedThrowingContinuation { continuation in
                        activityFetcher.fetchActivity(
                            request: ActivitySearchRequest(pSearchText: mainLocationName)
                        ) { result in
                            continuation.resume(with: result)
                        }
                    }
                    allSearchResults.append(contentsOf: mainNameResponse.values)
                }
                
                // Search with keywords from the description if available
                // You could extend this to use destination.description if available
                
                // Remove duplicates based on activity ID
                let uniqueActivities = Array(Set(allSearchResults.map { $0.id })).compactMap { id in
                    allSearchResults.first { $0.id == id }
                }
                
                let activities = uniqueActivities
                
                if !activities.isEmpty {
                    // Convert all activities to GroupFormRecommendationDataModel
                    let destinationActivities = activities.map { GroupFormRecommendationDataModel(activity: $0) }
                    
                    // Try exact keyword matching in activity title and description
                    let keywordMatches = destinationActivities.filter { activity in
                        let searchKeywords = mainLocationName.lowercased()
                        return activity.title.lowercased().contains(searchKeywords) ||
                               activity.description.lowercased().contains(searchKeywords) ||
                               activity.location.lowercased().contains(searchKeywords)
                    }
                    
                    // Use similarity scoring for location names
                    let locationMatches = destinationActivities.filter { activity in
                        let destWords = mainLocationName.lowercased().components(separatedBy: " ")
                        let activityWords = activity.location.lowercased().components(separatedBy: " ")
                        
                        // Check if any word from destination appears in activity location
                        return destWords.contains { destWord in
                            activityWords.contains { actWord in
                                actWord.contains(destWord) || destWord.contains(actWord)
                            }
                        }
                    }
                    
                    // Combine all matching strategies and remove duplicates by ID
                    let combinedMatches = keywordMatches + locationMatches
                    var uniqueMatchingActivities: [GroupFormRecommendationDataModel] = []
                    var seenIds = Set<Int>()
                    
                    for activity in combinedMatches where !seenIds.contains(activity.id) {
                        uniqueMatchingActivities.append(activity)
                        seenIds.insert(activity.id)
                    }
                    
                    let matchingActivities = uniqueMatchingActivities
                    
                    // If no matches found, use the most relevant activities (first few)
                    var activitiesToUse = matchingActivities.isEmpty ? Array(destinationActivities.prefix(3)) : matchingActivities
                    
                    // Add all matching activities to the global collection
                    allActivities.append(contentsOf: activitiesToUse)
                    
                    // If no exact matches, use all activities from the search (fallback)
                    activitiesToUse = matchingActivities.isEmpty ? destinationActivities : matchingActivities
                    
                    // Add all matching activities to the global collection
                    allActivities.append(contentsOf: activitiesToUse)
                    
                    // Randomly select ONE activity from the activities to use
                    if let randomActivity = activitiesToUse.randomElement() {
                        // Create destination card using the random activity's information
                        let enrichedDestination = TopDestinationCardDataModel(
                            id: destination.id,
                            title: randomActivity.title,
                            location: randomActivity.location,
                            priceText: randomActivity.priceText,
                            imageUrl: randomActivity.imageUrl
                        )
                        enrichedDestinations.append(enrichedDestination)
                    } else {
                        // No activities found at all, use basic destination info
                        let basicDestination = TopDestinationCardDataModel(
                            id: destination.id,
                            title: destination.name,
                            location: destination.name,
                            priceText: "-",
                            imageUrl: nil
                        )
                        enrichedDestinations.append(basicDestination)
                    }
                } else {
                    // If no activities found, keep basic info
                    let basicDestination = TopDestinationCardDataModel(
                        id: destination.id,
                        title: destination.name,
                        location: destination.name,
                        priceText: "-",
                        imageUrl: nil
                    )
                    enrichedDestinations.append(basicDestination)
                }
                
            } catch {
                // Keep basic info if detailed fetch fails
                let basicDestination = TopDestinationCardDataModel(
                    id: destination.id,
                    title: destination.name,
                    location: destination.name,
                    priceText: "-",
                    imageUrl: nil
                )
                enrichedDestinations.append(basicDestination)
            }
        }
        
        // Randomize and limit the activities from all destinations
        let randomizedActivities = Array(allActivities.shuffled().prefix(20)) // Limit to 20 random activities
        
        // Update the published properties
        self.topDestinations = enrichedDestinations
        self.activity = randomizedActivities
        self.isLoading = false
    }
}
