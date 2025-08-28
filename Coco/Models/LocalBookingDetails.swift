//
//  LocalBookingDetails.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 26/08/25.
//

import Foundation

struct LocalBookingDetails {
    let id: String
    let status: String
    let bookingId: Int?
    let startTime: String?
    let destination: BookingDestination
    let totalPrice: Double
    let packageName: String
    let participants: Int
    let activityDate: String
    let activityTitle: String
    let bookingCreatedAt: String?
    let address: String
    let userId: String
    
    let selectedPackages: [GroupTripPlanDataModel.VotablePackage]?
    let tripMembers: [TripMember]?
    let dueDateForm: String?
    
    init(from apiResponse: BookingDetails, userId: String) {
        self.id = "\(apiResponse.bookingId)"
        self.status = apiResponse.status
        self.bookingId = apiResponse.bookingId
        self.startTime = apiResponse.startTime
        self.destination = apiResponse.destination
        self.totalPrice = apiResponse.totalPrice
        self.packageName = apiResponse.packageName
        self.participants = apiResponse.participants
        self.activityDate = apiResponse.activityDate
        self.activityTitle = apiResponse.activityTitle
        self.bookingCreatedAt = apiResponse.bookingCreatedAt
        self.address = apiResponse.address
        self.userId = userId
        
        self.selectedPackages = nil
        self.tripMembers = nil
        self.dueDateForm = nil
    }
    
    init(
        id: String,
        userId: String,
        activityTitle: String,
        packageName: String,
        activityDate: String,
        participants: Int,
        totalPrice: Double,
        status: String,
        destination: BookingDestination,
        address: String,
        selectedPackages: [GroupTripPlanDataModel.VotablePackage]?,
        tripMembers: [TripMember]?,
        dueDateForm: String?
    ) {
        self.id = id
        self.status = status
        self.bookingId = nil
        self.startTime = nil
        self.destination = destination
        self.totalPrice = totalPrice
        self.packageName = packageName
        self.participants = participants
        self.activityDate = activityDate
        self.activityTitle = activityTitle
        self.bookingCreatedAt = DateFormatter().string(from: Date())
        self.address = address
        self.userId = userId
        self.selectedPackages = selectedPackages
        self.tripMembers = tripMembers
        self.dueDateForm = dueDateForm
    }
}
