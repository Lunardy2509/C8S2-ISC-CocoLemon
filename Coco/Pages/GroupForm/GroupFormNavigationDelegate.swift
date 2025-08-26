//
//  GroupFormNavigationDelegate.swift
//  Coco
//
//  Created by GitHub Copilot on 26/08/25.
//

import Foundation

/// Protocol for handling navigation events from GroupForm
protocol GroupFormNavigationDelegate: AnyObject {
    /// Navigates to activity detail page from group form
    /// - Parameter activityDetail: The activity detail data model
    func notifyGroupFormNavigateToActivityDetail(_ activityDetail: ActivityDetailDataModel)
    
    /// Navigates to trip detail page with booking details
    /// - Parameter bookingDetails: The booking details data model
    func notifyGroupFormNavigateToTripDetail(_ bookingDetails: BookingDetails)
    
    /// Shows the group trip plan after creation
    /// - Parameter planData: The group trip plan data model
    func notifyGroupTripPlanCreated(data: GroupTripPlanDataModel)
    
    /// Navigates to MyTrip tab (fallback for old behavior)
    func notifyGroupFormCreatePlan()
}
