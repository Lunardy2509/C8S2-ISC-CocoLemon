//
//  ShareTripDataModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 17/08/25.
//

import Foundation
import UIKit

struct ShareTripDataModel {
    // From BookingDetails
    let status: BookingDetailDataModel.StatusLabel
    let bookingDateText: String
    let paxNumber: Int
    let price: Double
    let address: String
    
    // From Activity
    let activityName: String
    let packageName: String
    let location: String
    let imageString: String
    
    // New info from Activity
    let tripProvider: ActivityDetailDataModel.ProviderDetail
    let tripIncludes: [String]
    
    init(bookingDetail: BookingDetails, activity: Activity) {
        let bookingDataModel = BookingDetailDataModel(bookingDetail: bookingDetail)
        
        self.status = bookingDataModel.status
        self.bookingDateText = bookingDataModel.bookingDateText
        self.paxNumber = bookingDataModel.paxNumber
        self.price = bookingDataModel.price
        self.address = bookingDataModel.address
        
        self.activityName = activity.title
        self.packageName = bookingDetail.packageName
        self.location = activity.destination.name
        self.imageString = activity.images.first { $0.imageType == .thumbnail }?.imageUrl ?? bookingDetail.destination.imageUrl ?? ""
        
        let activityDetailDataModel = ActivityDetailDataModel(activity)
        self.tripProvider = activityDetailDataModel.providerDetail.content
        self.tripIncludes = activityDetailDataModel.tripFacilities.content
    }
}
