//
//  MyTripRecommendationDataModel.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 23/08/25.
//

import Foundation

struct MyTripRecommendationDataModel: Hashable {
    let id: Int
    let title: String
    let location: String
    let priceText: String
    let imageUrl: URL?
    
    init(id: Int, title: String, location: String, priceText: String, imageUrl: URL?) {
        self.id = id
        self.title = title
        self.location = location
        self.priceText = priceText
        self.imageUrl = imageUrl
    }
    
    init(activity: Activity) {
        self.id = activity.id
        self.title = activity.title
        self.location = activity.destination.name
        
        let prices: [Double] = activity.packages.map { $0.pricePerPerson }
        if let minPrice = prices.min(), let maxPrice = prices.max() {
            if minPrice == maxPrice {
                self.priceText = minPrice.toRupiah()
            } else {
                self.priceText = "\(minPrice.toRupiah()) - \(maxPrice.toRupiah())"
            }
        } else {
            self.priceText = "-"
        }
        
        self.imageUrl = if let thumbnailURLString = activity.images.first(where: { $0.imageType == .thumbnail })?.imageUrl {
            URL(string: thumbnailURLString)
        } else {
            nil
        }
    }
}

typealias MyTripRecommendationSectionDataModel = (title: String?, dataModel: [MyTripRecommendationDataModel])
