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
        
        // If status is already "Pending", keep it as is (for newly created plans)
        if bookingDetail.status.lowercased() == "pending" {
            bookingStatus = "Pending"
            statusStyle = .pending
        } else {
            // For other statuses, apply date-based logic
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            
            if let targetDate: Date = formatter.date(from: bookingDetail.activityDate) {
                let today: Date = Date()
                
                if targetDate < today {
                    bookingStatus = "Completed"
                    statusStyle = .success
                } else if targetDate > today {
                    bookingStatus = "Upcoming"
                    statusStyle = .refund
                }
            }
        }
        
        statusLabel = StatusLabel(text: bookingStatus, style: statusStyle)
        imageUrl = bookingDetail.destination.imageUrl ?? ""
        
        // Format the date to display in a user-friendly format like "Tues, 15 March 2025"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: bookingDetail.activityDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "E, d MMMM yyyy"
            outputFormatter.locale = Locale(identifier: "en_US")
            dateText = outputFormatter.string(from: date)
        } else {
            dateText = bookingDetail.activityDate
        }
        
        title = bookingDetail.activityTitle
        location = bookingDetail.destination.name
        totalPax = bookingDetail.participants
        price = "\(bookingDetail.totalPrice.toRupiah())"
    }
    
    init(localBookingDetail: LocalBookingDetails) {
        self.id = localBookingDetail.id
        
        var bookingStatus: String = localBookingDetail.status
        var statusStyle: CocoStatusLabelStyle = .pending
        
        switch localBookingDetail.status.lowercased() {
        case "upcoming":
            bookingStatus = "Upcoming"
            statusStyle = .success
        case "completed":
            bookingStatus = "Completed"
            statusStyle = .success
        default:
            bookingStatus = "Pending"
            statusStyle = .pending
        }
        
        statusLabel = StatusLabel(text: bookingStatus, style: statusStyle)
        imageUrl = localBookingDetail.destination.imageUrl ?? ""
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: localBookingDetail.activityDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "E, d MMMM yyyy"
            dateText = outputFormatter.string(from: date)
        } else {
            dateText = localBookingDetail.activityDate
        }
        
        title = localBookingDetail.activityTitle
        location = localBookingDetail.destination.name
        totalPax = localBookingDetail.participants
        price = localBookingDetail.totalPrice.toRupiah()
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MyTripListCardDataModel, rhs: MyTripListCardDataModel) -> Bool {
        return lhs.id == rhs.id
    }
}
