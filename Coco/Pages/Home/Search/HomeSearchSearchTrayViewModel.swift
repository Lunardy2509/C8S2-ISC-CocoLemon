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
        // Fetch popular destinations from activity data instead of top destination API
        activityFetcher.fetchActivity(
            request: ActivitySearchRequest(pSearchText: "")
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                // Extract unique location parts (after comma) from activity responses
                let uniqueDestinations = Set(response.values.map { $0.destination.name })
                
                // Convert to HomeSearchSearchLocationData and sort alphabetically
                self.popularLocations = Array(uniqueDestinations.enumerated().map { index, name in
                    HomeSearchSearchLocationData(id: index, name: name)
                }
                    .sorted { $0.name < $1.name }
                    .prefix(5)
                )
                    
            case .failure:
                break
            }
        }
    }
}
