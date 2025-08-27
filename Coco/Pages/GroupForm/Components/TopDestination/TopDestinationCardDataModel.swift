//
//  TopDestinationCardDataModel.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//
import Foundation

struct TopDestinationCardDataModel: Hashable, Identifiable {
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
}
