//
//  CreateBookingResponse.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation

struct CreateBookingResponse: JSONDecodable {
    let message: String
    let success: Bool
    let bookingDetails: BookingDetails

    enum CodingKeys: String, CodingKey {
        case message
        case success
        case bookingDetails = "booking_details"
    }
}

struct BookingDetails: JSONDecodable {
    let status: String
    let bookingId: Int
    let startTime: String
    let destination: BookingDestination
    let totalPrice: Double
    let packageName: String
    let participants: Int
    let activityDate: String
    let activityTitle: String
    let bookingCreatedAt: String
    let address: String

    enum CodingKeys: String, CodingKey {
        case status
        case bookingId = "booking_id"
        case startTime = "start_time"
        case destination
        case totalPrice = "total_price"
        case packageName = "package_name"
        case participants
        case activityDate = "activity_date"
        case activityTitle = "activity_title"
        case bookingCreatedAt = "booking_created_at"
        case address
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let statusString = try? container.decode(String.self, forKey: .status) {
            self.status = statusString
        } else {
            let statusValue = try container.decode(AnyCodable.self, forKey: .status)
            self.status = String(describing: statusValue.value)
        }
        
        self.bookingId = try container.decode(Int.self, forKey: .bookingId)
        self.startTime = try container.decode(String.self, forKey: .startTime)
        self.destination = try container.decode(BookingDestination.self, forKey: .destination)
        self.totalPrice = try container.decode(Double.self, forKey: .totalPrice)
        self.packageName = try container.decode(String.self, forKey: .packageName)
        self.participants = try container.decode(Int.self, forKey: .participants)
        self.activityDate = try container.decode(String.self, forKey: .activityDate)
        self.activityTitle = try container.decode(String.self, forKey: .activityTitle)
        self.bookingCreatedAt = try container.decode(String.self, forKey: .bookingCreatedAt)
        self.address = try container.decode(String.self, forKey: .address)
    }
}

struct AnyCodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            value = "unknown"
        }
    }
}

struct BookingDestination: JSONDecodable {
    let id: Int
    let name: String
    let imageUrl: String?
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
        case description
    }
}
