//
//  GroupInvitationTripViewModelProtocol.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 28/08/25.
//

import Foundation

protocol GroupInvitationTripViewDelegate: AnyObject {
    func didTapBookNow()
    func didTapMember(_ member: TripsMember)
    func didSelectPackage(_ package: TripPackage)
}

protocol GroupInvitationTripViewModelProtocol {
    var tripData: TripInvitationModel { get }
    var onBookNow: (() -> Void)? { get set }
    var onMemberTap: ((TripsMember) -> Void)? { get set }
    var onPackageSelect: ((TripPackage) -> Void)? { get set }
}

final class GroupInvitationTripViewModel: GroupInvitationTripViewModelProtocol {
    let tripData: TripInvitationModel
    var onBookNow: (() -> Void)?
    var onMemberTap: ((TripsMember) -> Void)?
    var onPackageSelect: ((TripPackage) -> Void)?
    
    init(tripData: TripInvitationModel) {
        self.tripData = tripData
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy"
        return formatter.string(from: date)
    }
}
