//
//  TripInvitationModel.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 28/08/25.
//


// MARK: - Models
import UIKit
import ObjectiveC

struct TripInvitationModel {
    let id: String
    let title: String
    let location: String
    let imageURL: String?
    let priceRange: String
    let status: InvitationStatus
    let person: Int
    let visitDate: Date
    let dueDate: Date
    let members: [TripsMember]
    let availablePackages: [TripPackage]
}

struct TripsMember {
    let id: String
    let name: String
    let profileImageURL: String?
    let isCurrentUser: Bool
    let isWaiting: Bool
}

struct TripPackage {
    let id: String
    let name: String
    let price: String
    let imageURL: String?
    let minPerson: Int
    let maxPerson: Int
    let description: String
}

enum InvitationStatus: String, CaseIterable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    
    var style: StatusStyle {
        switch self {
        case .pending: return .warning
        case .accepted: return .success
        case .declined: return .error
        }
    }
}

enum StatusStyle {
    case success, warning, error
}
