//
//  TripMember.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import Foundation

struct TripMember {
    let name: String
    let email: String
    let profileImageURL: String?
    let isWaiting: Bool
    
    var image: Icon? {
        switch name.lowercased() {
        case "adhis":
            return isWaiting ? Contributor.waitingAdhis : Contributor.adhis
        case "cynthia":
            return isWaiting ? Contributor.waitingCynthia : Contributor.cynthia
        case "ahmad":
            return isWaiting ? Contributor.waitingAhmad : Contributor.ahmad
        case "teuku":
            return isWaiting ? Contributor.waitingTeuku : Contributor.teuku
        case "griselda":
            return isWaiting ? Contributor.waitingGriselda : Contributor.griselda
        case "ferdinand":
            return isWaiting ? Contributor.waitingFerdinand : Contributor.ferdinand
        default:
            return nil
        }
    }
    
    init(name: String, email: String, profileImageURL: String? = nil, isWaiting: Bool = false) {
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.isWaiting = isWaiting
    }
}

// Extension to convert from TeamMemberModel
extension TripMember {
    init(from teamMember: TeamMemberModel) {
        self.name = teamMember.name
        self.email = teamMember.email
        self.profileImageURL = nil
        self.isWaiting = teamMember.isWaiting
    }
}
