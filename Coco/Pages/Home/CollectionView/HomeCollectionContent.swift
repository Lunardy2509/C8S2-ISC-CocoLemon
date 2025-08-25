//
//  HomeCollectionContent.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation
import UIKit

typealias HomeCollectionViewDataSource = UICollectionViewDiffableDataSource<HomeCollectionContent.Section, AnyHashable>
typealias HomeCollectionViewSnapShot = NSDiffableDataSourceSnapshot<HomeCollectionContent.Section, AnyHashable>

struct HomeCollectionContent {
    let section: Section
    let items: [AnyHashable]
    
    enum SectionType: Hashable {
        case activity
        case noResult
    }
    
    struct Section: Hashable {
        let type: SectionType
        let title: String?
    }
}

struct NoResultCellDataModel: Hashable {
    let message: String = "No perfect match yet, let’s try another city or activity!"
}
