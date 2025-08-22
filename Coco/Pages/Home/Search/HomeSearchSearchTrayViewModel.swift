//
//  HomeSearchSearchTrayViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 08/07/25.
//

import Foundation
import SwiftUI

struct HomeSearchSearchLocationData {
    let id: Int
    let name: String
}

final class HomeSearchSearchTrayViewModel: ObservableObject {
    @Published var searchBarViewModel: HomeSearchBarViewModel
    @Published var popularLocations: [HomeSearchSearchLocationData] = []
    
    private let activityFetcher: ActivityFetcherProtocol
    
    init(searchBarViewModel: HomeSearchBarViewModel, activityFetcher: ActivityFetcherProtocol = ActivityFetcher()) {
        self.searchBarViewModel = searchBarViewModel
        self.activityFetcher = activityFetcher
    }
    
    @MainActor
    func onAppear() {
        // Fetch popular destinations from top destination API
        activityFetcher.fetchTopDestination { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                // Convert top destinations directly to HomeSearchSearchLocationData
                self.popularLocations = response.values.map { destination in
                    HomeSearchSearchLocationData(id: destination.id, name: destination.name)
                }
                .sorted { $0.name < $1.name }
                    
            case .failure:
                break
            }
        }
    }
}
