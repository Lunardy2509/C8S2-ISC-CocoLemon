//
//  TripDetailViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 17/07/25.
//

import Foundation

final class TripDetailViewModel {
    weak var actionDelegate: TripDetailViewModelAction?
    
    private let regularBookingData: BookingDetails?
    private let localBookingData: LocalBookingDetails?
    
    init(data: BookingDetails) {
        self.regularBookingData = data
        self.localBookingData = nil
    }
    
    init(localData: LocalBookingDetails) {
        self.regularBookingData = nil
        self.localBookingData = localData
    }
}

extension TripDetailViewModel: TripDetailViewModelProtocol {
    func onViewDidLoad() {
        if let regularData = regularBookingData {
            actionDelegate?.configureView(dataModel: BookingDetailDataModel(bookingDetail: regularData))
        } else if let localData = localBookingData {
            actionDelegate?.configureView(dataModel: BookingDetailDataModel(localBookingDetail: localData))
        }
    }
}
