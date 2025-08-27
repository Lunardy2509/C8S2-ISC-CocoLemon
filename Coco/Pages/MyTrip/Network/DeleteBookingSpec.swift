//
//  DeleteBookingSpec.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 22/08/25.
//

import Foundation

struct DeleteBookingSpec: JSONEncodable {
    let bookingId: Int
    let userId: String
    
    private enum CodingKeys: String, CodingKey {
        case bookingId = "p_booking_id"
        case userId = "p_user_id"
    }
}
