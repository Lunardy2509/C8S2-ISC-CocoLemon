//
//  GroupTripActivityDetailViewDelegate.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 25/08/25.
//

import Foundation

protocol GroupTripActivityDetailViewDelegate: AnyObject {
    func notifyPackagesButtonDidTap(shouldShowAll: Bool)
    func notifyPackagesDetailDidTap(with packageId: Int)
    func notifyAddFriendButtonDidTap()
    func notifyRemoveActivityButtonDidTap()
    func notifySearchActivityTapped()
    func notifySearchActivitySelected(_ data: ActivityDetailDataModel)
    func notifySearchBarTapped(with query: String)
}
