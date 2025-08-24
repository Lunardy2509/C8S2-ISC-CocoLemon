//
//  TripMember.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 25/08/25.
//

import Foundation

struct TripMember: Hashable {
    let name: String
    let email: String
    let profileImageURL: String?
    let isWaiting: Bool
    
    init(name: String, email: String, profileImageURL: String? = nil, isWaiting: Bool = false) {
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.isWaiting = isWaiting
    }
}
