//
//  TripDetailViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 17/07/25.
//

import Foundation

final class TripDetailViewModel {
    weak var actionDelegate: TripDetailViewModelAction?
    
    init(data: BookingDetails, fetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.data = data
        self.fetcher = fetcher
    }
    
    private let data: BookingDetails
    private let fetcher: ActivityFetcherProtocol
}

extension TripDetailViewModel: TripDetailViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.configureView(dataModel: BookingDetailDataModel(bookingDetail: data))
    }
    
    func onShareButtonTapped() {
        let request = ActivitySearchRequest(pSearchText: data.activityTitle)
        fetcher.fetchActivity(request: request) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let activity = response.values.first(where: { $0.title == self.data.activityTitle }) {
                        let shareData = ShareTripDataModel(bookingDetail: self.data, activity: activity)
                        self.actionDelegate?.shareTripDetail(data: shareData)
                    } else {
                        print("Activity not found for sharing.")
                        self.actionDelegate?.shareTripDetail(data: nil)
                    }
                case .failure(let error):
                    print("Failed to fetch activity details for sharing: \(error)")
                    self.actionDelegate?.shareTripDetail(data: nil)
                }
            }
        }
    }
}
