//
//  GroupFormModels.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import Foundation
import SwiftUI

struct TeamMember: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let email: String
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
    
    var swiftUIImage: Image? {
        guard let icon = image else { return nil }
        return Image(uiImage: icon.image)
    }
    
    init(id: Int, name: String, email: String, isWaiting: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.isWaiting = isWaiting
    }
    
    // Convenience initializer for compatibility
    init(id: Int, name: String, contributorIcon: Icon, isWaiting: Bool = false) {
        self.id = id
        self.name = name
        self.email = "\(name.lowercased())@example.com"
        self.isWaiting = isWaiting
    }
}

struct TripMemberData {
    let name: String
    let email: String
    let icon: Icon
}

struct TravelPackage: Identifiable, Equatable {
    let id: Int
    let name: String
    let description: String
    let price: String
    let duration: String
    let participants: String
    let imageUrlString: String 
    
    // Additional constructor for API data
    init(id: Int, name: String, description: String, price: String, duration: String, participants: String, imageUrlString: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.duration = duration
        self.participants = participants
        self.imageUrlString = imageUrlString
    }
}
