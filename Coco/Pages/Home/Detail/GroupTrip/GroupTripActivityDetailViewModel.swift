//
//  GroupTripActivityDetailViewModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation

final class GroupTripActivityDetailViewModel: ObservableObject, GroupTripActivityDetailViewModelProtocol, HomeSearchBarViewModelDelegate {
    
    @Published var searchText: String = ""
    @Published var tripName: String = ""
    @Published var dateVisit: Date = Date()
    @Published var deadline: Date = Date()
    @Published var showDateVisitCalendar: Bool = false
    @Published var showDeadlineCalendar: Bool = false
    @Published var showSearchSheet: Bool = false
    @Published var searchHistory: [HomeSearchSearchLocationData] = []
    @Published var isLoading: Bool = false
    @Published var availablePackages: [TravelPackage] = []
    @Published var selectedDestination: GroupFormRecommendationDataModel? {
        didSet {
            updateAvailablePackages()
        }
    }
    
    weak var actionDelegate: GroupTripActivityDetailViewModelAction?
    weak var navigationDelegate: GroupTripActivityDetailNavigationDelegate?
    
    private let activityFetcher: ActivityFetcherProtocol
    
    private var tripMembers: [TripMember] = [
        TripMember(name: "Adhis", email: "adhis@example.com", profileImageURL: nil, isWaiting: false)
    ]

    private var currentData: ActivityDetailDataModel
    
    private let data: ActivityDetailDataModel
    private var selectedPackageIds: Set<Int> = []
    
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
    
    private(set) lazy var tripNameInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Enter trip name",
        currentTypedText: "",
        trailingIcon: nil,
        isTypeAble: true,
        delegate: self
    )
    
    private(set) lazy var calendarInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "DD/MM/YYYY",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icCalendarIcon.image,
            didTap: openCalendar
        ),
        isTypeAble: false,
        delegate: self
    )
    
    private(set) lazy var dueDateInputViewModel: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "DD/MM/YYYY",
        currentTypedText: "",
        trailingIcon: (
            image: CocoIcon.icCalendarIcon.image,
            didTap: openDueDateCalendar
        ),
        isTypeAble: false,
        delegate: self
    )
    
    private var chosenDateInput: Date? {
        didSet {
            guard let chosenDateInput else { return }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            calendarInputViewModel.currentTypedText = dateFormatter.string(from: chosenDateInput)
        }
    }
    
    private var chosenDueDateInput: Date? {
        didSet {
            guard let chosenDueDateInput else { return }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            dueDateInputViewModel.currentTypedText = dateFormatter.string(from: chosenDueDateInput)
        }
    }

    init(data: ActivityDetailDataModel, activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.data = data
        self.activityFetcher = activityFetcher
        self.currentData = data
    }
    
    func onViewDidLoad() {
        actionDelegate?.configureView(data: data)
        actionDelegate?.updatePackageData(data: data.availablePackages.content)
    }
    
    func onPackageDetailStateDidChange(shouldShowAll: Bool) {
        actionDelegate?.updatePackageData(data: shouldShowAll ? data.availablePackages.content : data.hiddenPackages)
    }
    
    func onPackagesDetailDidTap(with packageId: Int) {
        if selectedPackageIds.contains(packageId) {
            selectedPackageIds.remove(packageId)
        } else {
            selectedPackageIds.insert(packageId)
        }
    }
    
    func onCreateTripTapped() {
        navigationDelegate?.notifyGroupTripCreateTripTapped()
    }
    
    func getSelectedPackageIds() -> Set<Int> {
        return selectedPackageIds
    }
    
    func onCalendarDidChoose(date: Date, for type: CalendarType) {
        switch type {
        case .visitDate:
            chosenDateInput = date
        case .dueDate:
            chosenDueDateInput = date
        }
    }
    
    func presentDateVisitCalendar() {
        self.showDateVisitCalendar = true
    }
    
    func presentDeadlineCalendar() {
        self.showDeadlineCalendar = true
    }
    
    func onRemoveActivityTapped() {
        actionDelegate?.showSearchBar()
    }
    
    func onSearchActivitySelected(_ newActivity: ActivityDetailDataModel) {
        print("onSearchActivitySelected called with activity: \(newActivity.title)")
        currentData = newActivity
        
        // Ensure UI updates are on main thread
        Task { @MainActor in
            print("Updating UI with activity: \(newActivity.title)")
            actionDelegate?.configureView(data: newActivity)
            actionDelegate?.updatePackageData(data: newActivity.availablePackages.content)
            
            // Also update the selectedDestination to reflect the search result
            let destination = GroupFormRecommendationDataModel(activity: convertToActivity(newActivity))
            selectDestination(destination)
        }
    }
    
    func onSearchDidApply(_ queryText: String) {
        print("Search initiated for query: '\(queryText)'")
        let activityFetcher = ActivityFetcher()
        activityFetcher.fetchActivity(request: ActivitySearchRequest(pSearchText: queryText)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let activities = response.values
                print("Search returned \(activities.count) activities for query: '\(queryText)'")
                
                // Directly select the first activity if available
                if let firstActivity = activities.first {
                    print("Selecting first activity: \(firstActivity.title)")
                    let activityDetailData = ActivityDetailDataModel(firstActivity)
                    Task { @MainActor in
                        self.onSearchActivitySelected(activityDetailData)
                    }
                } else {
                    print("No activities found for query: '\(queryText)'")
                    // Show empty results if no activities found
                    self.actionDelegate?.showSearchResults([])
                }
            case .failure(let error):
                print("Search failed with error: \(error)")
                self.actionDelegate?.showSearchResults([])
            }
        }
    }
    
    func selectDestination(_ destination: GroupFormRecommendationDataModel) {
        selectedDestination = destination
        searchText = destination.title
        searchBarViewModel.currentTypedText = destination.title
    }
    
    func applySearch(query: String) {
        searchText = query
        searchBarViewModel.currentTypedText = query
        showSearchSheet = false
        
        let newSearch = HomeSearchSearchLocationData(id: Int.random(in: 1000...9999), name: query)
        if !searchHistory.contains(where: { $0.name == query }) {
            searchHistory.insert(newSearch, at: 0)
            if searchHistory.count > 10 {
                searchHistory = Array(searchHistory.prefix(10))
            }
        }
        
        searchActivities(query: query)
    }

    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        if viewModel === calendarInputViewModel {
            actionDelegate?.showCalendarOption(for: .visitDate)
        } else if viewModel === dueDateInputViewModel {
            actionDelegate?.showCalendarOption(for: .dueDate)
        }
    }

    private func openCalendar() {
        actionDelegate?.showCalendarOption(for: .visitDate)
    }
    
    private func openDueDateCalendar() {
        actionDelegate?.showCalendarOption(for: .dueDate)
    }
    
    private func searchActivities(query: String) {
        isLoading = true
        
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
                        let destination = GroupFormRecommendationDataModel(activity: firstActivity)
                        self.selectDestination(destination)
                    } else {
                        let mockDestination = self.createMockDestinationFromSearch(query: query)
                        self.selectDestination(mockDestination)
                    }
                    
                case .failure(let error):
                    print("Search failed: \(error)")
                    let mockDestination = self.createMockDestinationFromSearch(query: query)
                    self.selectDestination(mockDestination)
                }
            }
        }
    }
    
    private func updateAvailablePackages() {
        if let destination = selectedDestination {
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
    
   private func createMockDestinationFromSearch(query: String) -> GroupFormRecommendationDataModel {
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
    
    // Helper method to convert ActivityDetailDataModel back to Activity
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
}