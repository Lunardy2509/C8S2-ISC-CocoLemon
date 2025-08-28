//
//  HomeFilterTrayViewModelTest.swift
//  CocoTests
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

import Foundation
import Testing
import Combine
@testable import Coco

struct HomeFilterTrayViewModelTest {
    
    // MARK: - Test Context Setup
    struct TestContext {
        let viewModel: HomeFilterTrayViewModel
        let dataModel: HomeFilterTrayDataModel
        let activities: [Activity]
        let cancellables: Set<AnyCancellable> = Set()
        
        static func setup() -> TestContext {
            // --- GIVEN ---
            let activities = createMockActivities()
            let filterPills = createMockFilterPills()
            let destinationPills = createMockDestinationPills()
            let priceRange = createMockPriceRange()
            
            let dataModel = HomeFilterTrayDataModel(
                filterPillDataState: filterPills,
                priceRangeModel: priceRange,
                filterDestinationPillState: destinationPills,
            )
            
            let viewModel = HomeFilterTrayViewModel(
                dataModel: dataModel,
                activities: activities
            )
            
            return TestContext(
                viewModel: viewModel,
                dataModel: dataModel,
                activities: activities
            )
        }
        
        static func createMockActivities() -> [Activity] {
            return [
                Activity(
                    id: 1,
                    title: "Test Activity 1 Adventure Experience",  // Dummy title
                    images: [
                        ActivityImage(
                            id: 1,
                            imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))",
                            imageType: .thumbnail,
                            activityId: 1
                        )
                    ],
                    pricing: Double.random(in: 500000...2000000),
                    category: ActivityCategory(id: 1, name: "Adventure", description: "Exciting outdoor activities."),
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
                    description: "Discover the beauty and adventure of Test Destination 1 with our guided experience.",
                    destination: Destination(id: 1, name: "Test Destination 1", imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))", description: "Beautiful destination"),
                    durationMinutes: Int.random(in: 240...600)
                ),
                Activity(
                    id: 2,
                    title: "Test Activity 2 Cultural Experience",  // Dummy title
                    images: [
                        ActivityImage(
                            id: 2,
                            imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))",
                            imageType: .thumbnail,
                            activityId: 2
                        )
                    ],
                    pricing: Double.random(in: 500000...2000000),
                    category: ActivityCategory(id: 2, name: "Cultural", description: "Learn about local traditions and history."),
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
                    description: "Experience the cultural richness of Test Destination 2 with a local guide.",
                    destination: Destination(id: 2, name: "Test Destination 2", imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))", description: "Rich cultural heritage"),
                    durationMinutes: Int.random(in: 240...600)
                ),
                Activity(
                    id: 3,
                    title: "Test Activity 3 Nature Escape",  // Dummy title
                    images: [
                        ActivityImage(
                            id: 3,
                            imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))",
                            imageType: .thumbnail,
                            activityId: 3
                        )
                    ],
                    pricing: Double.random(in: 500000...2000000),
                    category: ActivityCategory(id: 3, name: "Nature", description: "Relax and reconnect with nature."),
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
                    description: "Unwind and relax with nature walks in Test Destination 3.",
                    destination: Destination(id: 3, name: "Test Destination 3", imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))", description: "Serene nature spots"),
                    durationMinutes: Int.random(in: 240...600)
                )
            ]
        }
        
        static func createMockFilterPills() -> [HomeFilterPillState] {
            return [
                HomeFilterPillState(id: 1, title: "Adventure", isSelected: false),
                HomeFilterPillState(id: 2, title: "Cultural", isSelected: false),
                HomeFilterPillState(id: 3, title: "Nature", isSelected: false)
            ]
        }
        
        static func createMockDestinationPills() -> [HomeFilterDestinationPillState] {
            return [
                HomeFilterDestinationPillState(id: 1, title: "Indonesia", isSelected: false),
                HomeFilterDestinationPillState(id: 2, title: "Bali", isSelected: false),
                HomeFilterDestinationPillState(id: 3, title: "Jakarta", isSelected: false)
            ]
        }
        
        static func createMockPriceRange() -> HomeFilterPriceRangeModel {
            return HomeFilterPriceRangeModel(
                minPrice: 50000.0,
                maxPrice: 300000.0,
                range: 50000.0...300000.0,
                step: 10000.0
            )
        }
    }
    
    // MARK: - Initialization Tests
    @Test("initialization - should set up correctly with provided data")
    func initialization_withProvidedData_shouldSetupCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        let viewModel = context.viewModel
        
        // --- THEN ---
        #expect(viewModel.dataModel.filterPillDataState.count == 3)
        #expect(viewModel.dataModel.filterDestinationPillState.count == 3)
        #expect(viewModel.dataModel.priceRangeModel != nil)
        #expect(viewModel.applyButtonTitle == "See Result")
    }
    
    // MARK: - Filter Application Tests
    @Test("filter application - should send data model when applied")
    func filterApplication_whenApplied_shouldSendDataModel() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        var receivedDataModel: HomeFilterTrayDataModel?
        var cancellables = Set<AnyCancellable>()
        
        context.viewModel.filterDidApplyPublisher
            .sink { dataModel in
                receivedDataModel = dataModel
            }
            .store(in: &cancellables)
        
        // --- WHEN ---
        context.viewModel.filterDidApply()
        
        // --- THEN ---
        #expect(receivedDataModel != nil)
        #expect(receivedDataModel?.filterPillDataState.count == 3)
    }
    
    // MARK: - Clear All Filters Tests
    @Test("clear all filters - should reset all selections")
    func clearAllFilters_whenCalled_shouldResetAllSelections() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // Set some filters to selected state
        context.dataModel.filterPillDataState[0].isSelected = true
        context.dataModel.filterDestinationPillState[0].isSelected = true
        context.dataModel.priceRangeModel?.minPrice = 100000.0
        
        // --- WHEN ---
        context.viewModel.clearAllFilters()
        
        // --- THEN ---
        #expect(context.dataModel.filterPillDataState.allSatisfy { !$0.isSelected })
        #expect(context.dataModel.filterDestinationPillState.allSatisfy { !$0.isSelected })
        #expect(context.dataModel.priceRangeModel?.minPrice == context.dataModel.priceRangeModel?.range.lowerBound)
        #expect(context.dataModel.priceRangeModel?.maxPrice == context.dataModel.priceRangeModel?.range.upperBound)
    }
    
    // MARK: - Apply Button Title Tests
    @Test("apply button title - should show correct title without filters")
    func applyButtonTitle_withoutFilters_shouldShowCorrectTitle() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.updateApplyButtonTitle()
        
        // --- THEN ---
        #expect(context.viewModel.applyButtonTitle == "See Result")
    }
    
//    @Test("apply button title - should show count with single result")
//    func applyButtonTitle_withSingleResult_shouldShowCountSingular() async throws {
//        // --- GIVEN ---
//        let context = TestContext.setup()
//        
//        // Select a filter that would result in 1 activity
//        context.dataModel.filterPillDataState[1].isSelected = true // Cultural - should match 1 activity
//        
//        // --- WHEN ---
//        context.viewModel.updateApplyButtonTitle()
//        
//        // --- THEN ---
//        #expect(context.viewModel.applyButtonTitle.contains("See Result ("))
//        #expect(context.viewModel.applyButtonTitle.contains(")"))
//    }
    
    @Test("apply button title - should show count with multiple results")
    func applyButtonTitle_withMultipleResults_shouldShowCountPlural() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // Select filters that would result in multiple activities
        context.dataModel.filterPillDataState[0].isSelected = true // Adventure - should match 1 activity
        context.dataModel.filterPillDataState[2].isSelected = true // Nature - should match 1 activity (total: 2)
        
        // --- WHEN ---
        context.viewModel.updateApplyButtonTitle()
        
        // --- THEN ---
        #expect(context.viewModel.applyButtonTitle.contains("See Results ("))
        #expect(context.viewModel.applyButtonTitle.contains(")"))
    }
    
    // MARK: - Filter Count Tests
    @Test("filter count - should count selected pills correctly")
    func filterCount_withSelectedPills_shouldCountCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // Select some filters
        context.dataModel.filterPillDataState[0].isSelected = true
        context.dataModel.filterDestinationPillState[0].isSelected = true
        
        // --- WHEN ---
        context.viewModel.updateApplyButtonTitle()
        
        // --- THEN ---
        // Should show result count with 2 filters applied
        #expect(context.viewModel.applyButtonTitle != "See Result")
    }
    
    @Test("filter count - should count price range when modified")
    func filterCount_withModifiedPriceRange_shouldCountPriceFilter() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // Modify price range
        context.dataModel.priceRangeModel?.minPrice = 120000.0
        
        // --- WHEN ---
        context.viewModel.updateApplyButtonTitle()
        
        // --- THEN ---
        // Should show result count with price filter applied
        #expect(context.viewModel.applyButtonTitle != "See Result")
    }
    
    // MARK: - Data Model Update Tests
    @Test("data model update - should rebind inner fields when model changes")
    func dataModelUpdate_whenModelChanges_shouldRebindInnerFields() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let originalTitle = context.viewModel.applyButtonTitle
        
        // --- WHEN ---
        let newDataModel = TestContext.createMockDataModel()
        context.viewModel.dataModel = newDataModel
        
        // --- THEN ---
        // The button title should be recalculated
        #expect(context.viewModel.applyButtonTitle == "See Result")
    }
    
    // MARK: - Price Range Active Tests
    @Test("price range active - should detect when price is at full range")
    func priceRangeActive_whenAtFullRange_shouldReturnFalse() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // Ensure price range is at full range
        context.dataModel.priceRangeModel?.minPrice = context.dataModel.priceRangeModel?.range.lowerBound ?? 0
        context.dataModel.priceRangeModel?.maxPrice = context.dataModel.priceRangeModel?.range.upperBound ?? 0
        
        // --- WHEN ---
        context.viewModel.updateApplyButtonTitle()
        
        // --- THEN ---
        #expect(context.viewModel.applyButtonTitle == "See Result")
    }
    
    @Test("price range active - should detect when price is modified")
    func priceRangeActive_whenModified_shouldReturnTrue() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // Modify price range
        context.dataModel.priceRangeModel?.minPrice = 100000.0
        
        // --- WHEN ---
        context.viewModel.updateApplyButtonTitle()
        
        // --- THEN ---
        #expect(context.viewModel.applyButtonTitle != "See Result")
    }
}

// MARK: - Helper Extensions
private extension HomeFilterTrayViewModelTest.TestContext {
    static func createMockDataModel() -> HomeFilterTrayDataModel {
        return HomeFilterTrayDataModel(
            filterPillDataState: createMockFilterPills(),
            priceRangeModel: createMockPriceRange(),
            filterDestinationPillState: createMockDestinationPills(),
        )
    }
}
