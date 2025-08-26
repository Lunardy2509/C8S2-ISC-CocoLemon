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
    @Published var teamMembers: [TeamMemberModel] = []
    @Published var availablePackages: [TravelPackage] = []
    @Published var selectedPackageIds: Set<Int> = []
    @Published var isLoading: Bool = false
    
    // Search Bar Properties
    @Published var showSearchSheet: Bool = false
    @Published var searchHistory: [HomeSearchSearchLocationData] = []
    @Published var showInviteFriendPopup: Bool = false
    
    // Available contributors for adding to team
    private let availableContributors: [TripMemberData] = [
        TripMemberData(name: "Adhis", email: "adhis@example.com", icon: Contributor.adhis),
        TripMemberData(name: "Ahmad", email: "ahmad@example.com", icon: Contributor.ahmad),
        TripMemberData(name: "Teuku", email: "teuku@example.com", icon: Contributor.teuku),
        TripMemberData(name: "Griselda", email: "griselda@example.com", icon: Contributor.griselda),
        TripMemberData(name: "Ferdinand", email: "ferdinand@example.com", icon: Contributor.ferdinand),
        TripMemberData(name: "Cynthia", email: "cynthia@example.com", icon: Contributor.cynthia)
    ]
    
    // Navigation delegate
    weak var navigationDelegate: GroupFormNavigationDelegate?
    
    // API Fetcher
    private let activityFetcher: ActivityFetcherProtocol
    private let createBookingFetcher: CreateBookingFetcherProtocol
    
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
    
    init(activityFetcher: ActivityFetcherProtocol = ActivityFetcher(), createBookingFetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()) {
        self.activityFetcher = activityFetcher
        self.createBookingFetcher = createBookingFetcher
        loadTeamMembers()
        loadRecommendations()
    }
    
    // Convenience initializer for when user comes from TripDetail with a selected activity
    init(
        selectedActivity: ActivityDetailDataModel,
        activityFetcher: ActivityFetcherProtocol = ActivityFetcher(),
        createBookingFetcher: CreateBookingFetcherProtocol = CreateBookingFetcher()
    ) {
        self.activityFetcher = activityFetcher
        self.createBookingFetcher = createBookingFetcher
        
        // Convert ActivityDetailDataModel to GroupFormRecommendationDataModel
        let convertedActivity = convertActivityDetailToRecommendation(selectedActivity)
        self.selectedDestination = convertedActivity
        
        loadTeamMembers()
        loadRecommendations()
    }
    
    // Helper method to convert ActivityDetailDataModel to GroupFormRecommendationDataModel
    private func convertActivityDetailToRecommendation(_ activity: ActivityDetailDataModel) -> GroupFormRecommendationDataModel {
        return GroupFormRecommendationDataModel(activity: convertToActivity(activity))
    }
    
    // Helper method to convert ActivityDetailDataModel to Activity
    private func convertToActivity(_ activityDetail: ActivityDetailDataModel) -> Activity {
        // Extract packages from ActivityDetailDataModel
        let packages = activityDetail.availablePackages.content.map { package in
            ActivityPackage(
                id: package.id,
                name: package.name,
                endTime: "17:00", // Default values since we don't have them in ActivityDetailDataModel.Package
                startTime: "09:00",
                activityId: Int.random(in: 1000...9999),
                description: package.description,
                maxParticipants: 8,
                minParticipants: 2,
                pricePerPerson: Double(package.price.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0,
                host: ActivityPackage.Host(
                    bio: "Professional guide with extensive local knowledge",
                    name: activityDetail.providerDetail.content.name,
                    profileImageUrl: activityDetail.providerDetail.content.imageUrlString
                ),
                imageUrl: package.imageUrlString
            )
        }
        
        // Create images from the image URLs
        let images = activityDetail.imageUrlsString.enumerated().map { index, url in
            ActivityImage(
                id: index + 1,
                imageUrl: url,
                imageType: index == 0 ? .thumbnail : .gallery,
                activityId: Int.random(in: 1000...9999)
            )
        }
        
        return Activity(
            id: Int.random(in: 1000...9999),
            title: activityDetail.title,
            images: images,
            pricing: packages.first?.pricePerPerson ?? 0,
            category: ActivityCategory(id: 1, name: "Adventure", description: ""),
            packages: packages,
            cancelable: activityDetail.tnc,
            createdAt: "2025-08-25T00:00:00Z",
            accessories: activityDetail.tripFacilities.content.map { name in
                Accessory(id: Int.random(in: 1...100), name: name)
            },
            description: activityDetail.detailInfomation.content,
            destination: Destination(
                id: 1,
                name: activityDetail.location,
                imageUrl: activityDetail.imageUrlsString.first,
                description: "Beautiful destination"
            ),
            durationMinutes: 480 // Default 8 hours
        )
    }
    
    func createPlan() {
        // Validate required data
        guard let destination = selectedDestination,
              !tripName.isEmpty,
              !selectedPackageIds.isEmpty else { return }
        
        print("🚀 GroupFormViewModel: Starting to create plan...")
        // Get selected package details
        guard let selectedPackage = availablePackages.first(where: { selectedPackageIds.contains($0.id) }) else { 
            print("❌ No selected package found")
            return 
        }
        
        let userId = UserDefaults.standard.string(forKey: "user-id") ?? ""
        print("👤 GroupFormViewModel: Using user ID: '\(userId)'")
        print("📦 GroupFormViewModel: Selected package: \(selectedPackage.name)")
        
        Task { @MainActor in
            do {
                // Create booking request
                let request = CreateBookingSpec(
                    packageId: selectedPackage.id,
                    bookingDate: dateVisit,
                    participants: teamMembers.count + 1, // +1 for the user creating the plan
                    userId: UserDefaults.standard.string(forKey: "user-id") ?? ""
                )
                
                // Call the API to create booking
                let response = try await createBookingFetcher.createBooking(request: request)
                
                print("✅ GroupFormViewModel: Booking created successfully, posting notification")
                // Post notification that a new trip was created
                NotificationCenter.default.post(name: .newTripCreated, object: nil)
                
                // Notify that plan creation is complete - this will navigate to MyTrip tab
                navigationDelegate?.notifyGroupFormCreatePlan()
                
            } catch {
                // Handle error - could show an alert or error message
                print("Failed to create booking: \(error)")
                // For now, still navigate but create a local booking details
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let bookingDestination = BookingDestination(
                    id: destination.id,
                    name: destination.location,
                    imageUrl: destination.imageUrl?.absoluteString,
                    description: destination.description
                )
                
                let bookingDetails = BookingDetails(
                    status: "Pending",
                    bookingId: Int.random(in: 1000...9999),
                    startTime: "09:00",
                    destination: bookingDestination,
                    totalPrice: calculateTotalPrice(),
                    packageName: selectedPackage.name,
                    participants: teamMembers.count + 1,
                    activityDate: dateFormatter.string(from: dateVisit),
                    activityTitle: destination.title,
                    bookingCreatedAt: dateFormatter.string(from: Date()),
                    address: "\(destination.location) Meeting Point"
                )
                
                print("⚠️ GroupFormViewModel: API failed, creating local booking data and posting notification")
                // Post notification that a new trip was created (even with local data)
                NotificationCenter.default.post(name: .newTripCreated, object: nil)
                
                // Navigate to MyTrip tab to show the new booking
                navigationDelegate?.notifyGroupFormCreatePlan()
            }
        }
    }
    
    private func calculateTotalPrice() -> Double {
        let selectedPackages = availablePackages.filter { selectedPackageIds.contains($0.id) }
        let packageCost = selectedPackages.reduce(0.0) { total, package in
            // Extract price from string format "Rp 1,200,000"
            let priceString = package.price.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let packagePrice = Double(priceString) ?? 0
            return total + packagePrice
        }
        
        // Multiply by number of participants
        return packageCost * Double(teamMembers.count)
    }
    
    func togglePackageSelection(_ packageId: Int) {
        if selectedPackageIds.contains(packageId) {
            selectedPackageIds.remove(packageId)
        } else {
            selectedPackageIds.insert(packageId)
        }
    }
    
    func getSelectedPackageIds() -> Set<Int> {
        return selectedPackageIds
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
        // Clear previous package selections when destination changes
        selectedPackageIds.removeAll()
        
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
        // Load team members with Adhis as the group planner (cannot be removed)
        teamMembers = [
            TeamMemberModel(
                name: "Adhis",
                email: "adhis@example.com",
                isWaiting: false // Adhis is the group planner, not waiting
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
                    
                case .failure:
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
    func addTeamMember(name: String, email: String, isWaiting: Bool = true) {
        let newMember = TeamMemberModel(
            name: name,
            email: email,
            isWaiting: isWaiting // New members are waiting by default
        )
        teamMembers.append(newMember)
    }
    
    func addTeamMember(_ memberData: TripMemberData, isWaiting: Bool = true) {
        addTeamMember(name: memberData.name, email: memberData.email, isWaiting: isWaiting)
    }
    
    func removeTeamMember(email: String) {
        // Prevent removing Adhis (group planner)
        guard email.lowercased() != "adhis@example.com" else { return }
        teamMembers.removeAll { $0.email == email }
    }
    
    func canRemoveMember(email: String) -> Bool {
        // Adhis cannot be removed as she's the group planner
        return email.lowercased() != "adhis@example.com"
    }
    
    func toggleMemberWaitingStatus(email: String) {
        // Don't allow changing Adhis's waiting status as she's the group planner
        guard email.lowercased() != "adhis@example.com" else { return }
        
        if let index = teamMembers.firstIndex(where: { $0.email == email }) {
            let member = teamMembers[index]
            teamMembers[index] = TeamMemberModel(
                name: member.name,
                email: member.email,
                isWaiting: !member.isWaiting
            )
        }
    }
    
    func presentAddFriendOptions() {
        showInviteFriendPopup = true
    }
    
    func sendInvite(email: String) {
        // Check if this email corresponds to a known contributor
        if let contributor = availableContributors.first(where: { $0.email.lowercased() == email.lowercased() }) {
            // Add the known contributor in waiting state
            addTeamMember(contributor, isWaiting: true)
        } else {
            // Add a new member with the provided email in waiting state
            let name = extractNameFromEmail(email)
            addTeamMember(name: name, email: email, isWaiting: true)
        }
        
        showInviteFriendPopup = false
    }
    
    func dismissInviteFriendPopup() {
        showInviteFriendPopup = false
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        // Extract name from email (part before @)
        let components = email.components(separatedBy: "@")
        return components.first?.capitalized ?? "Friend"
    }
    
    func getAvailableContributors() -> [TripMemberData] {
        return availableContributors.filter { contributor in
            !teamMembers.contains { $0.name.lowercased() == contributor.name.lowercased() }
        }
    }
    
    // Convenience methods for adding specific contributors (all in waiting state except Adhis)
    func addAdhis(isWaiting: Bool = false) {
        if let adhis = availableContributors.first(where: { $0.name == "Adhis" }) {
            addTeamMember(adhis, isWaiting: isWaiting) // Adhis is not waiting as she's the planner
        }
    }
    
    func addCynthia(isWaiting: Bool = true) {
        if let cynthia = availableContributors.first(where: { $0.name == "Cynthia" }) {
            addTeamMember(cynthia, isWaiting: isWaiting)
        }
    }
    
    func addAhmad(isWaiting: Bool = true) {
        if let ahmad = availableContributors.first(where: { $0.name == "Ahmad" }) {
            addTeamMember(ahmad, isWaiting: isWaiting)
        }
    }
    
    func addTeuku(isWaiting: Bool = true) {
        if let teuku = availableContributors.first(where: { $0.name == "Teuku" }) {
            addTeamMember(teuku, isWaiting: isWaiting)
        }
    }
    
    func addGriselda(isWaiting: Bool = true) {
        if let griselda = availableContributors.first(where: { $0.name == "Griselda" }) {
            addTeamMember(griselda, isWaiting: isWaiting)
        }
    }
    
    func addFerdinand(isWaiting: Bool = true) {
        if let ferdinand = availableContributors.first(where: { $0.name == "Ferdinand" }) {
            addTeamMember(ferdinand, isWaiting: isWaiting)
        }
    }
}

// MARK: - HomeSearchBarViewModelDelegate
extension GroupFormViewModel: HomeSearchBarViewModelDelegate {
    nonisolated func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        Task { @MainActor in
            showSearchSheet = true
        }
    }
}
