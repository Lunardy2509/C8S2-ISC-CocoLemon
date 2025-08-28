//
//  HomeViewModelContract.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation

protocol HomeViewModelNavigationDelegate: AnyObject {
   func notifyHomeDidSelectActivity()
}

protocol HomeViewModelAction: AnyObject {
    func constructCollectionView(viewModel: some HomeCollectionViewModelProtocol)
    func constructNavBar(viewModel: HomeSearchBarViewModel)
    func constructFilterCarousel(filterPillStates: [HomeFilterPillState], filterDestinationPillStates: [HomeFilterDestinationPillState])
    
    func activityDidSelect(data: ActivityDetailDataModel)
    
    func openSearchTray(
        selectedQuery: String,
        latestSearches: [HomeSearchSearchLocationData]
    )
    func openFilterTray(_ viewModel: HomeFilterTrayViewModel)
    func dismissTray()
}

protocol HomeViewModelProtocol: AnyObject {
    var actionDelegate: HomeViewModelAction? { get set }
    var navigationDelegate: HomeViewModelNavigationDelegate? { get set }
    
    func onViewDidLoad()
    func onSearchDidApply(_ queryText: String)
    func onSearchReset()
    func removeSearchFromHistory(_ searchData: HomeSearchSearchLocationData)
    func openFilterTray()
    func onFilterDismiss(_ filterId: Int)
    func onResetAllFilters()
    func isPriceRangeFilterApplied() -> Bool
    func getPriceRangeText() -> String?
}
