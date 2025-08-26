//
//  GroupTripPlanDataModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 26/08/25.
//

import Foundation

struct GroupTripPlanDataModel {
    let tripName: String
    let activity: ActivityInfo
    let tripDetails: TripDetails
    let tripMembers: [TripMember]
    let selectedPackages: [ActivityDetailDataModel.Package]
    
    struct ActivityInfo {
        let imageUrl: String
        let title: String
        let location: String
        let priceRange: String
    }
    
    struct TripDetails {
        let status: StatusInfo
        let personCount: Int
        let dateVisit: String
        let dueDateForm: String
        
        struct StatusInfo {
            let text: String
            let style: CocoStatusLabelStyle
        }
    }
}

extension GroupTripPlanDataModel {
    init(
        tripName: String,
        activityData: ActivityDetailDataModel,
        tripMembers: [TripMember],
        selectedPackageIds: Set<Int>,
        dateVisit: Date,
        dueDate: Date
    ) {
        self.tripName = tripName
        
        // Create activity info
        let priceRange: String
        if !activityData.availablePackages.content.isEmpty {
            let prices = activityData.availablePackages.content.map { $0.price }
            let minPrice = prices.min() ?? ""
            let maxPrice = prices.max() ?? ""
            
            if minPrice == maxPrice {
                priceRange = "\(minPrice)/Person"
            } else {
                priceRange = "\(minPrice) - \(maxPrice)/Person"
            }
        } else {
            priceRange = ""
        }
        
        self.activity = ActivityInfo(
            imageUrl: activityData.imageUrlsString.first ?? "",
            title: activityData.title,
            location: activityData.location,
            priceRange: priceRange
        )
        
        // Create trip details
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        
        self.tripDetails = TripDetails(
            status: TripDetails.StatusInfo(text: "Pending", style: .pending),
            personCount: tripMembers.count,
            dateVisit: formatter.string(from: dateVisit),
            dueDateForm: formatter.string(from: dueDate)
        )
        
        self.tripMembers = tripMembers
        
        // Filter selected packages
        self.selectedPackages = activityData.availablePackages.content.filter { package in
            selectedPackageIds.contains(package.id)
        }
    }
}
