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
    let selectedPackages: [VotablePackage]
    let activityDetailData: ActivityDetailDataModel
    
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
    
    struct VotablePackage: Identifiable {
        let id: Int
        let name: String
        let description: String
        let price: String
        let imageUrlString: String
        let minParticipants: Int  
        let maxParticipants: Int  
        let voters: [TripMember]
        let totalVotes: Int
        let isSelected: Bool
        
        init(package: ActivityDetailDataModel.Package, voters: [TripMember] = [], isSelected: Bool = false) {
            self.id = package.id
            self.name = package.name
            self.description = package.description
            self.price = package.price
            self.imageUrlString = package.imageUrlString
            self.minParticipants = package.minParticipants ?? 0
            self.maxParticipants = package.maxParticipants ?? 0
            self.voters = voters
            self.totalVotes = voters.count
            self.isSelected = isSelected
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
        self.activityDetailData = activityData
        
        let priceRange: String
        if !activityData.availablePackages.content.isEmpty {
            let numericPrices: [Double] = activityData.availablePackages.content.compactMap { package in
                let priceString = package.price.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                return Double(priceString)
            }
            
            if let minPrice = numericPrices.min(), let maxPrice = numericPrices.max() {
                if minPrice == maxPrice {
                    priceRange = "\(minPrice.toRupiah())/Person"
                } else {
                    priceRange = "\(minPrice.toRupiah()) - \(maxPrice.toRupiah())/Person"
                }
            } else {
                priceRange = "Price not available"
            }
        } else {
            priceRange = "Price not available"
        }
        
        self.activity = ActivityInfo(
            imageUrl: activityData.imageUrlsString.first ?? "",
            title: activityData.title,
            location: activityData.location,
            priceRange: priceRange
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        
        self.tripDetails = TripDetails(
            status: TripDetails.StatusInfo(text: "Pending", style: .pending),
            personCount: tripMembers.count,
            dateVisit: formatter.string(from: dateVisit),
            dueDateForm: formatter.string(from: dueDate)
        )
        
        self.tripMembers = tripMembers
        
        self.selectedPackages = activityData.availablePackages.content.filter { package in
            selectedPackageIds.contains(package.id)
        }.map { package in
            VotablePackage(package: package, voters: [], isSelected: false)
        }
    }
}
