//
//  MyTripNoTripYetDataModel.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 22/08/25.
//

import Foundation

struct MyTripNoTripYetDataModel: Hashable {
    let id = "no-trip-placeholder"
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MyTripNoTripYetDataModel, rhs: MyTripNoTripYetDataModel) -> Bool {
        return lhs.id == rhs.id
    }
}
