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
    @Published var showSearchResultsSheet: Bool = false
    @Published var showEmptyStatePopup: Bool = false
    @Published var showFailedToAddContributorPopup: Bool = false
    @Published var searchResults: [HomeActivityCellDataModel] = []
    @Published var currentSearchQuery: String = ""
    
    // Warning/Alert Properties
    @Published var showWarningAlert: Bool = false
    @Published var warningMessage: String = ""
    @Published var existingMember: String = ""
    
    // Available contributors for adding to team
    let availableContributors: [TripMemberData] = [
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
    let activityFetcher: ActivityFetcherProtocol
    let createBookingFetcher: CreateBookingFetcherProtocol
    
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
            placeholderText: "I wanna go to...",
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
    
    func createPlan() {
        // Validate required data
        guard let destination = selectedDestination,
              !tripName.isEmpty,
              !selectedPackageIds.isEmpty else { return }
        
        // Get selected package details
        guard let selectedPackage = availablePackages.first(where: { selectedPackageIds.contains($0.id) }) else { 
            return 
        }
        
        let userId = UserDefaults.standard.string(forKey: "user-id") ?? ""
        
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
                
                // Post notification that a new trip was created
                NotificationCenter.default.post(name: .newTripCreated, object: response.bookingDetails)
                
                let tripMembers = teamMembers.map { teamMember in
                    TripMember(
                        name: teamMember.name,
                        email: teamMember.email,
                        profileImageURL: nil,
                        isWaiting: teamMember.isWaiting
                    )
                }
                
                let planData = GroupTripPlanDataModel(
                    tripName: tripName,
                    activityData: destination.toActivityDetailDataModel(),
                    tripMembers: tripMembers,
                    selectedPackageIds: selectedPackageIds,
                    dateVisit: dateVisit,
                    dueDate: deadline
                )
                
                navigationDelegate?.notifyGroupTripPlanCreated(data: planData)
                
            } catch {
                let tripMembers = teamMembers.map { teamMember in
                    TripMember(
                        name: teamMember.name,
                        email: teamMember.email,
                        profileImageURL: nil,
                        isWaiting: teamMember.isWaiting
                    )
                }
                
                let planData = GroupTripPlanDataModel(
                    tripName: tripName,
                    activityData: destination.toActivityDetailDataModel(),
                    tripMembers: tripMembers,
                    selectedPackageIds: selectedPackageIds,
                    dateVisit: dateVisit,
                    dueDate: deadline
                )
                navigationDelegate?.notifyGroupTripPlanCreated(data: planData)
            }
        }
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
}

// MARK: - Calendar Management
extension GroupFormViewModel {
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
}

// MARK: - HomeSearchBarViewModelDelegate
extension GroupFormViewModel: HomeSearchBarViewModelDelegate {
    nonisolated func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        Task { @MainActor in
            showSearchSheet = true
        }
    }
}
