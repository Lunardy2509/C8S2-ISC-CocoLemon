//
//  GroupFormModels.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import Foundation
import SwiftUI

struct TeamMember: Identifiable, Equatable {
    let id: Int
    let name: String
    let image: Image
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
