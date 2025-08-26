//
//  GroupFormViewModel+Search.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import Foundation
import SwiftUI

// MARK: - Search Functionality
extension GroupFormViewModel {
    func applySearch(query: String) {
        searchText = query
        searchBarViewModel.currentTypedText = query
        showSearchSheet = false
        
        // Add to search history
        let newSearch = HomeSearchSearchLocationData(id: Int.random(in: 1000...9999), name: query)
        if !searchHistory.contains(where: { $0.name == query }) {
            searchHistory.insert(newSearch, at: 0)
            // Keep only last 10 searches
            if searchHistory.count > 10 {
                searchHistory = Array(searchHistory.prefix(10))
            }
        }
        
        // Use real API search
        searchActivities(query: query)
    }
    
    func selectDestination(_ destination: GroupFormRecommendationDataModel) {
        selectedDestination = destination
        searchText = destination.title
        searchBarViewModel.currentTypedText = destination.title
    }
    
    func dismissSelectedDestination() {
        selectedDestination = nil
        searchText = ""
        searchBarViewModel.currentTypedText = ""
        loadRecommendations() // Reset to show recommendations
    }
    
    func navigateToDestinationDetail() {
        guard let destination = selectedDestination else { return }
        let activityDetail = destination.toActivityDetailDataModel()
        navigationDelegate?.notifyGroupFormNavigateToActivityDetail(activityDetail)
    }
    
    func removeSearchHistory(_ searchData: HomeSearchSearchLocationData) {
        searchHistory.removeAll { $0.name == searchData.name }
    }
    
    func resetSearch() {
        searchText = ""
        searchBarViewModel.currentTypedText = ""
        loadRecommendations() // Reset to load fresh recommendations from API
    }
    
    func selectTopDestination(_ destination: TopDestinationCardDataModel, from topDestinationViewModel: TopDestinationViewModel) {
        // Try to find a matching activity from the TopDestinationViewModel's activities
        if let matchingActivity = topDestinationViewModel.activity.first(where: { activity in
            activity.title.lowercased() == destination.title.lowercased() ||
            activity.location.lowercased().contains(destination.location.lowercased()) ||
            destination.location.lowercased().contains(activity.location.lowercased())
        }) {
            // Directly select the matching activity without opening search sheet
            selectDestination(matchingActivity)
        } else {
            // Fallback: search for the activity by title
            searchActivities(query: destination.title)
        }
    }
    
    // Keep the old method for backward compatibility
    func selectTopDestination(_ destination: TopDestinationCardDataModel) {
        // Convert TopDestinationCardDataModel to GroupFormRecommendationDataModel
        // First, try to find the full activity details
        searchActivities(query: destination.title)
    }
    
    func selectSearchResult(_ searchResult: HomeActivityCellDataModel) {
        // Convert HomeActivityCellDataModel to GroupFormRecommendationDataModel
        // Try to find the full activity details from the searchResults that match this search result
        if let activity = recommendations.first(where: { $0.id == searchResult.id }) {
            selectDestination(activity)
        } else {
            // Fallback: create a basic destination from the search result
            searchActivities(query: searchResult.title)
        }
        showSearchResultsSheet = false
    }
    
    func searchActivities(query: String) {
        isLoading = true
        currentSearchQuery = query
        
        // First fetch all activities to enable local filtering for location parts
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: "")
        ) { [weak self] (result: Result<ActivityModelArray, NetworkServiceError>) in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    let allActivities = response.values
                    
                    // Filter activities based on search text including destination names
                    let filteredActivities = allActivities.filter { activity in
                        if query.isEmpty {
                            return true
                        }
                        
                        let searchTextLowercased = query.lowercased()
                        let activityTitleMatch = activity.title.lowercased().contains(searchTextLowercased)
                        let destinationNameMatch = activity.destination.name.lowercased().contains(searchTextLowercased)
                        
                        // Also check if search matches the extracted location part (after comma)
                        let extractedLocation = self.extractLocationFromDestination(activity.destination.name)
                        let locationPartMatch = extractedLocation.lowercased().contains(searchTextLowercased)
                        
                        return activityTitleMatch || destinationNameMatch || locationPartMatch
                    }
                    
                    if !filteredActivities.isEmpty {
                        // Convert activities to search results for display
                        self.searchResults = filteredActivities.map { HomeActivityCellDataModel(activity: $0) }
                        self.showSearchResultsSheet = true
                        
                        // Store activities as recommendations for later use
                        self.recommendations = filteredActivities.map { GroupFormRecommendationDataModel(activity: $0) }
                    } else {
                        // No results found, show empty state popup instead of sheet
                        self.searchResults = []
                        self.showEmptyStatePopup = true
                    }
                    
                case .failure:
                    // Show empty state popup on failure
                    self.searchResults = []
                    self.showEmptyStatePopup = true
                }
            }
        }
    }
    
    /// Extracts location from destination name by taking the part after the comma
    /// E.g., "Raja Ampat, West Papua" -> "West Papua"
    private func extractLocationFromDestination(_ destinationName: String) -> String {
        let components = destinationName.components(separatedBy: ",")
        if components.count > 1 {
            return components[1].trimmingCharacters(in: .whitespaces)
        }
        return destinationName.trimmingCharacters(in: .whitespaces)
    }
    
    func filterRecommendations(by query: String) {
        if query.isEmpty {
            loadRecommendations()
        } else {
            // Filter existing recommendations based on search query
            let filtered = recommendations.filter { recommendation in
                recommendation.title.localizedCaseInsensitiveContains(query) ||
                recommendation.location.localizedCaseInsensitiveContains(query)
            }
            recommendations = filtered
        }
    }
    

    
    func loadRecommendations() {
        isLoading = true
        
        // Fetch activities from API - similar to HomeViewModel approach
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: "")
        ) { [weak self] (result: Result<ActivityModelArray, NetworkServiceError>) in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    let activities = response.values
                    
                    // Convert to GroupFormRecommendationDataModel
                    self.recommendations = activities.map { GroupFormRecommendationDataModel(activity: $0) }
                    
                    // Load team members
                    self.loadTeamMembers()
                    
                case .failure:
                    // Fallback to empty recommendations
                    self.recommendations = []
                    self.loadTeamMembers()
                }
            }
        }
    }
}
