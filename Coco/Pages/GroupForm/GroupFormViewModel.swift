//
//  GroupFormViewModel.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class GroupFormViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tripName: String = ""
    @Published var dateVisit: Date = Date()
    @Published var deadline: Date = Date()
    @Published var showDateVisitCalendar: Bool = false
    @Published var showDeadlineCalendar: Bool = false
    @Published var selectedDestination: GroupFormRecommendationDataModel? {
        didSet {
            updateAvailablePackages()
        }
    }
    @Published var recommendations: [GroupFormRecommendationDataModel] = []
    @Published var teamMembers: [TeamMember] = []
    @Published var availablePackages: [TravelPackage] = []
    @Published var isLoading: Bool = false
    
    // Search Bar Properties
    @Published var showSearchSheet: Bool = false
    @Published var searchHistory: [HomeSearchSearchLocationData] = []
    
    // Navigation callback
    var onNavigateToActivityDetail: ((ActivityDetailDataModel) -> Void)?
    
    // API Fetcher
    private let activityFetcher: ActivityFetcherProtocol
    
    // Date formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var dateVisitString: String {
        dateFormatter.string(from: dateVisit)
    }
    
    var deadlineString: String {
        dateFormatter.string(from: deadline)
    }
    
    lazy var searchBarViewModel: HomeSearchBarViewModel = {
        HomeSearchBarViewModel(
            leadingIcon: CocoIcon.icSearchLoop.image,
            placeholderText: "Search destination...",
            currentTypedText: searchText,
            trailingIcon: ImageHandler(
                image: CocoIcon.icFilterIcon.image,
                didTap: { [weak self] in
                    // Handle filter action if needed
                }
            ),
            isTypeAble: false, // Not typeable, opens sheet on tap
            delegate: self
        )
    }()
    
    var canCreatePlan: Bool {
        !tripName.isEmpty && 
        selectedDestination != nil
    }
    
    init(activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.activityFetcher = activityFetcher
        loadTeamMembers()
        loadRecommendations()
    }
    
    func createPlan() {
        // Handle create plan action
        print("Creating plan for: \(tripName)")
        print("Destination: \(selectedDestination?.title ?? "None")")
        print("Date: \(dateVisit)")
        print("Deadline: \(deadline)")
        print("Team members: \(teamMembers.count)")
    }
    
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
        onNavigateToActivityDetail?(activityDetail)
    }
    
    func removeSearchHistory(_ searchData: HomeSearchSearchLocationData) {
        searchHistory.removeAll { $0.name == searchData.name }
    }
    
    func resetSearch() {
        searchText = ""
        searchBarViewModel.currentTypedText = ""
        loadRecommendations() // Reset to load fresh recommendations from API
    }
    
    func presentDateVisitCalendar() {
        self.showDateVisitCalendar = true
    }
    
    func presentDeadlineCalendar() {
        self.showDeadlineCalendar = true
    }
    
    func onDateVisitCalendarDidChoose(date: Date) {
        dateVisit = date
        self.showDateVisitCalendar = false
    }
    
    func onDeadlineCalendarDidChoose(date: Date) {
        deadline = date
        self.showDeadlineCalendar = false
    }
    
    private func filterRecommendations(by query: String) {
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
    
    private func updateAvailablePackages() {
        if let destination = selectedDestination {
            // Convert real API packages to TravelPackage format
            availablePackages = destination.packages.map { package in
                TravelPackage(
                    id: package.id,
                    name: package.name,
                    description: package.description,
                    price: package.pricePerPerson.toRupiah(),
                    duration: "\(package.startTime) - \(package.endTime)",
                    participants: "Min. \(package.minParticipants) - Max. \(package.maxParticipants)",
                    imageUrlString: package.imageUrl
                )
            }
        } else {
            availablePackages = []
        }
    }
    
    private func loadRecommendations() {
        isLoading = true
        
        // Fetch activities from API - similar to HomeViewModel approach
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: "")
        ) { [weak self] result in
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
    
    private func loadTeamMembers() {
        // Load team members (static data as they represent app contributors)
        teamMembers = [
            TeamMember(
                id: 1,
                name: "Adhis",
                image: Image(uiImage: Contributor.adhis.image)
            ),
            TeamMember(
                id: 2,
                name: "Cynthia",
                image: Image(uiImage: Contributor.cynthia.image)
            ),
            TeamMember(
                id: 3,
                name: "Ferdinand",
                image: Image(uiImage: Contributor.ferdinand.image)
            )
        ]
    }
    
    private func searchActivities(query: String) {
        isLoading = true
        
        // Search for activities using the API
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: query)
        ) { [weak self] result in
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
                    
                case .failure(let error):
                    print("Search failed: \(error)")
                    // Fallback to mock destination
                    let mockDestination = self.createMockDestinationFromSearch(query: query)
                    self.selectDestination(mockDestination)
                }
            }
        }
    }
    
    private func createMockDestinationFromSearch(query: String) -> GroupFormRecommendationDataModel {
        // Create a mock destination based on search query
        let mockActivity = Activity(
            id: Int.random(in: 1000...9999),
            title: "\(query) Adventure Experience",
            images: [
                ActivityImage(
                    id: 1,
                    imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))",
                    imageType: .thumbnail,
                    activityId: 1
                )
            ],
            pricing: Double.random(in: 500000...2000000),
            category: ActivityCategory(id: 1, name: "Adventure", description: ""),
            packages: [
                ActivityPackage(
                    id: 1,
                    name: "Standard Package",
                    endTime: "17:00",
                    startTime: "09:00",
                    activityId: 1,
                    description: "Standard adventure experience",
                    maxParticipants: 8,
                    minParticipants: 2,
                    pricePerPerson: Double.random(in: 500000...1000000),
                    host: ActivityPackage.Host(
                        bio: "Professional guide with extensive local knowledge",
                        name: "Local Guide",
                        profileImageUrl: "https://picsum.photos/50/50?random=guide"
                    ),
                    imageUrl: "https://picsum.photos/150/100?random=package"
                ),
                ActivityPackage(
                    id: 2,
                    name: "Premium Package",
                    endTime: "18:00",
                    startTime: "08:00",
                    activityId: 1,
                    description: "Premium adventure with extra services",
                    maxParticipants: 6,
                    minParticipants: 2,
                    pricePerPerson: Double.random(in: 1000000...2000000),
                    host: ActivityPackage.Host(
                        bio: "Professional guide with extensive local knowledge",
                        name: "Local Guide",
                        profileImageUrl: "https://picsum.photos/50/50?random=guide"
                    ),
                    imageUrl: "https://picsum.photos/150/100?random=package2"
                )
            ],
            cancelable: "Free cancellation up to 24 hours before trip",
            createdAt: "2025-08-25T00:00:00Z",
            accessories: [
                Accessory(id: 1, name: "Professional Equipment"),
                Accessory(id: 2, name: "Safety Gear"),
                Accessory(id: 3, name: "Refreshments")
            ],
            description: "Discover the beauty and adventure of \(query) with our guided experience.",
            destination: Destination(
                id: 1,
                name: query,
                imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))",
                description: "Beautiful destination"
            ),
            durationMinutes: Int.random(in: 240...600)
        )
        
        return GroupFormRecommendationDataModel(activity: mockActivity)
    }
    
    // MARK: - Team Management
    func addTeamMember(name: String, contributorIcon: Icon) {
        let newMember = TeamMember(
            id: teamMembers.count + 1,
            name: name,
            image: Image(uiImage: contributorIcon.image)
        )
        teamMembers.append(newMember)
    }
    
    func removeTeamMember(id: Int) {
        teamMembers.removeAll { $0.id == id }
    }
    
    // Convenience methods for adding specific contributors
    func addAdhis() {
        addTeamMember(name: "Adhis", contributorIcon: Contributor.adhis)
    }
    
    func addCynthia() {
        addTeamMember(name: "Cynthia", contributorIcon: Contributor.cynthia)
    }
    
    func addAhmad() {
        addTeamMember(name: "Ahmad", contributorIcon: Contributor.ahmad)
    }
    
    func addTeuku() {
        addTeamMember(name: "Teuku", contributorIcon: Contributor.teuku)
    }
    
    func addGriselda() {
        addTeamMember(name: "Griselda", contributorIcon: Contributor.griselda)
    }
    
    func addFerdinand() {
        addTeamMember(name: "Ferdinand", contributorIcon: Contributor.ferdinand)
    }
}

// MARK: - HomeSearchBarViewModelDelegate
extension GroupFormViewModel: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        showSearchSheet = true
    }
}
