//
//  GroupTripActivityDetailView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 25/08/25.
//

import UIKit

extension GroupTripActivityDetailView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripMembers.count + 1 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < tripMembers.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripMemberCell", for: indexPath) as? TripMemberCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: tripMembers[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddFriendCell", for: indexPath) as? AddFriendCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= tripMembers.count {
            delegate?.notifyAddFriendButtonDidTap()
        }
    }
}
