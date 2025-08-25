//
//  CreateBookingEndpoint.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

enum CreateBookingEndpoint: EndpointProtocol {
    case create
    case getBookings
    case deleteBooking
    
    var path: String {
        switch self {
        case .create:
            return "rpc/create_booking"
        case .getBookings:
            return "rpc/get_user_bookings"
        case .deleteBooking:
            return "rpc/delete_booking"
        }
    }
}
