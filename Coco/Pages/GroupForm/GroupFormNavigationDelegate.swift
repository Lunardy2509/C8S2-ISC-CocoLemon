//
//  GroupFormNavigationDelegate.swift
//  Coco
//
//  Created by GitHub Copilot on 26/08/25.
//

import Foundation

/// Protocol for handling navigation events from GroupForm
protocol GroupFormNavigationDelegate: AnyObject {
    /// Called when user wants to navigate back to activity detail
    /// - Parameter activityDetail: The activity detail data model
    func notifyGroupFormNavigateToActivityDetail(_ activityDetail: ActivityDetailDataModel)
    
    /// Called when user wants to navigate to trip detail
    /// - Parameter bookingDetails: The booking details data model
    func notifyGroupFormNavigateToTripDetail(_ bookingDetails: BookingDetails)
    
    /// Called when user creates a plan successfully
    func notifyGroupFormCreatePlan()
}
