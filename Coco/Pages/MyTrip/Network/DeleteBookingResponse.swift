//
//  DeleteBookingResponse.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 22/08/25.
//

import Foundation

struct DeleteBookingResponse: JSONDecodable {
    let message: String
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case success
    }
}
