//
//  MyTripNoTripDataModel.swift
//  Coco
//
//  Created by Assistant on 22/08/25.
//

import Foundation

struct MyTripNoTripDataModel: Hashable {
    let id = "no-trip-placeholder"
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MyTripNoTripDataModel, rhs: MyTripNoTripDataModel) -> Bool {
        return lhs.id == rhs.id
    }
}
