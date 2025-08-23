//
//  MyTripListCardDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 14/07/25.
//

import Foundation

struct MyTripListCardDataModel: Hashable {
    let id: String // Add unique identifier for Hashable conformance
    let statusLabel: StatusLabel
    let imageUrl: String
    let dateText: String
    let title: String
    let location: String
    let totalPax: Int
    let price: String
    
    struct StatusLabel: Hashable {
        let text: String
        let style: CocoStatusLabelStyle
    }
    
    init(bookingDetail: BookingDetails) {
        self.id = String(bookingDetail.bookingId) // Use bookingId as unique identifier
        var bookingStatus: String = bookingDetail.status
        var statusStyle: CocoStatusLabelStyle = .pending
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        
        if let targetDate: Date = formatter.date(from: bookingDetail.activityDate) {
            let today: Date = Date()
            
            if targetDate < today {
                bookingStatus = "Completed"
                statusStyle = .success
            }
            else if targetDate > today {
                bookingStatus = "Upcoming"
                statusStyle = .refund
            }
        }
        
        statusLabel = StatusLabel(text: bookingStatus, style: statusStyle)
        imageUrl = bookingDetail.destination.imageUrl ?? ""
        dateText = bookingDetail.activityDate
        title = bookingDetail.activityTitle
        location = bookingDetail.destination.name
        totalPax = bookingDetail.participants
        price = "\(bookingDetail.totalPrice.toRupiah())"
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MyTripListCardDataModel, rhs: MyTripListCardDataModel) -> Bool {
        return lhs.id == rhs.id
    }
}
