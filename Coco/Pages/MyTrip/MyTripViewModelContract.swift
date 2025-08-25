//
//  MyTripViewModelContract.swift
//  Coco
//
//  Created by Jackie Leonardy on 14/07/25.
//

import Foundation

protocol MyTripViewModelAction: AnyObject {
    func configureView(datas: [MyTripListCardDataModel])
    func configureRecommendations(recommendations: [MyTripRecommendationDataModel])
    func goToBookingDetail(with data: BookingDetails)
    func goToNotificationPage()
    func showDeleteConfirmation(for index: Int, completion: @escaping (Bool) -> Void)
}

protocol MyTripViewModelProtocol: AnyObject {
    var actionDelegate: MyTripViewModelAction? { get set }
    
    func onViewWillAppear()
    func onTripListDidTap(at index: Int)
    func onTripDidDelete(at index: Int)
    func onNotificationButtonTapped()
}
