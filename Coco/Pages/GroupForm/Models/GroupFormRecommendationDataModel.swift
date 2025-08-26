//
//  GroupFormRecommendationDataModel.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 25/08/25.
//

import Foundation

struct GroupFormRecommendationDataModel: Identifiable, Equatable {
    let id: Int
    let title: String
    let location: String
    let priceText: String
    let imageUrl: URL?
    let packages: [Package]
    let category: String
    let description: String
    let accessories: [String]
    let cancelable: String
    let durationMinutes: Int
    
    struct Package: Identifiable, Equatable {
        let id: Int
        let name: String
        let description: String
        let pricePerPerson: Double
        let minParticipants: Int
        let maxParticipants: Int
        let startTime: String
        let endTime: String
        let imageUrl: String
        let host: Host
        
        struct Host: Equatable {
            let name: String
            let bio: String
            let profileImageUrl: String
        }
    }
    
    init(activity: Activity) {
        self.id = activity.id
        self.title = activity.title
        self.location = activity.destination.name
        self.category = activity.category.name
        self.description = activity.description
        self.accessories = activity.accessories.map { $0.name }
        self.cancelable = activity.cancelable
        self.durationMinutes = activity.durationMinutes
        
        // Calculate price range from packages
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
        
        // Get thumbnail image URL
        self.imageUrl = if let thumbnailURLString = activity.images.first(where: { $0.imageType == .thumbnail })?.imageUrl {
            URL(string: thumbnailURLString)
        } else {
            nil
        }
        
        // Map packages
        self.packages = activity.packages.map { package in
            Package(
                id: package.id,
                name: package.name,
                description: package.description,
                pricePerPerson: package.pricePerPerson,
                minParticipants: package.minParticipants,
                maxParticipants: package.maxParticipants,
                startTime: package.startTime,
                endTime: package.endTime,
                imageUrl: package.imageUrl,
                host: Package.Host(
                    name: package.host.name,
                    bio: package.host.bio,
                    profileImageUrl: package.host.profileImageUrl
                )
            )
        }
    }
    
    // Mock initializer for placeholder/add state
    init(isPlaceholder: Bool = true) {
        self.id = -1
        self.title = ""
        self.location = ""
        self.priceText = ""
        self.imageUrl = nil
        self.packages = []
        self.category = ""
        self.description = ""
        self.accessories = []
        self.cancelable = ""
        self.durationMinutes = 0
    }
}

// Extension to convert to ActivityDetailDataModel for navigation
extension GroupFormRecommendationDataModel {
    func toActivityDetailDataModel() -> ActivityDetailDataModel {
        // Convert packages to ActivityDetailDataModel.Package format
        let activityPackages = packages.map { package in
            ActivityDetailDataModel.Package(
                imageUrlString: package.imageUrl,
                name: package.name,
                description: "Min.\(package.minParticipants) - Max.\(package.maxParticipants)",
                price: package.pricePerPerson.toRupiah(),
                id: package.id
            )
        }
        
        // Create Package Activity object to initialize ActivityDetailDataModel
        let packageActivity = Activity(
            id: id,
            title: title,
            images: imageUrl != nil ? [
                ActivityImage(
                    id: 1,
                    imageUrl: imageUrl?.absoluteString ?? "",
                    imageType: .thumbnail,
                    activityId: id
                )
            ] : [],
            pricing: packages.first?.pricePerPerson ?? 0,
            category: ActivityCategory(id: 1, name: category, description: ""),
            packages: packages.map { package in
                ActivityPackage(
                    id: package.id,
                    name: package.name,
                    endTime: package.endTime,
                    startTime: package.startTime,
                    activityId: id,
                    description: package.description,
                    maxParticipants: package.maxParticipants,
                    minParticipants: package.minParticipants,
                    pricePerPerson: package.pricePerPerson,
                    host: ActivityPackage.Host(
                        bio: package.host.bio,
                        name: package.host.name,
                        profileImageUrl: package.host.profileImageUrl
                    ),
                    imageUrl: package.imageUrl
                )
            },
            cancelable: cancelable,
            createdAt: "",
            accessories: accessories.enumerated().map { index, name in
                Accessory(id: index, name: name)
            },
            description: description,
            destination: Destination(
                id: 1,
                name: location,
                imageUrl: imageUrl?.absoluteString,
                description: ""
            ),
            durationMinutes: durationMinutes
        )
        
        return ActivityDetailDataModel(packageActivity)
    }
}
