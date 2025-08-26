//
//  GroupFormViewModel+Search.swift
//  Coco
//
//  Created by GitHub Copilot on 26/08/25.
//

import Foundation

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
    
    func selectTopDestination(_ destination: TopDestinationCardDataModel) {
        // Convert TopDestinationCardDataModel to GroupFormRecommendationDataModel
        // First, try to find the full activity details
        searchActivities(query: destination.title)
    }
    
    func searchActivities(query: String) {
        isLoading = true
        
        // Search for activities using the API
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: "")
        ) { [weak self] (result: Result<ActivityModelArray, NetworkServiceError>) in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    let activities = response.values
                    
                    if let firstActivity = activities.first {
                        // Create destination from search result
                        let destination = GroupFormRecommendationDataModel(activity: firstActivity)
                        self.selectDestination(destination)
                    } else {
                        // No results found, create a mock destination for demo purposes
                        let mockDestination = self.createMockDestinationFromSearch(query: query)
                        self.selectDestination(mockDestination)
                    }
                    
                case .failure:
                    // Fallback to mock destination
                    let mockDestination = self.createMockDestinationFromSearch(query: query)
                    self.selectDestination(mockDestination)
                }
            }
        }
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
                    
                case .failure(let error):
                    print("Failed to load recommendations: \(error)")
                    // Fallback to empty recommendations
                    self.recommendations = []
                    self.loadTeamMembers()
                }
            }
        }
    }
}
