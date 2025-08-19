//
//  HomeActivityCellDataModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation

struct HomeActivityCellDataModel: Hashable {
    let id: Int
    
    let area: String
    let name: String
    let location: String
    let priceText: String
    let imageUrl: URL?
    
    init(id: Int, area: String, name: String, location: String, priceText: String, imageUrl: URL?) {
        self.id = id
        self.area = area
        self.name = name
        self.location = location
        self.priceText = priceText
        self.imageUrl = imageUrl
    }
    
    init(activity: Activity) {
        self.id = activity.id
        self.area = activity.title
        self.name = activity.description
        self.location = activity.destination.name
        self.priceText = activity.pricing.toRupiah()
        self.imageUrl = if let thumbnailURLString = activity.images.first(where: { $0.imageType == .thumbnail })?.imageUrl {
            URL(string: thumbnailURLString)
        } else {
            nil
        }
    }
}

typealias HomeActivityCellSectionDataModel = (title: String?, dataModel: [HomeActivityCellDataModel])
