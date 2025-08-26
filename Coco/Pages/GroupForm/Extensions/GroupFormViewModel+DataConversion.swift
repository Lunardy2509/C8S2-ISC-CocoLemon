//
//  GroupFormViewModel+DataConversion.swift
//  Coco
//
//  Created by GitHub Copilot on 26/08/25.
//

import Foundation

// MARK: - Data Conversion
extension GroupFormViewModel {
    // Helper method to convert ActivityDetailDataModel to GroupFormRecommendationDataModel
    func convertActivityDetailToRecommendation(_ activity: ActivityDetailDataModel) -> GroupFormRecommendationDataModel {
        return GroupFormRecommendationDataModel(activity: convertToActivity(activity))
    }
    
    // Helper method to convert ActivityDetailDataModel to Activity
    func convertToActivity(_ activityDetail: ActivityDetailDataModel) -> Activity {
        // Extract packages from ActivityDetailDataModel
        let packages = activityDetail.availablePackages.content.map { package in
            ActivityPackage(
                id: package.id,
                name: package.name,
                endTime: "17:00", // Default values since we don't have them in ActivityDetailDataModel.Package
                startTime: "09:00",
                activityId: Int.random(in: 1000...9999),
                description: package.description,
                maxParticipants: 8,
                minParticipants: 2,
                pricePerPerson: Double(package.price.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)) ?? 0,
                host: ActivityPackage.Host(
                    bio: "Professional guide with extensive local knowledge",
                    name: activityDetail.providerDetail.content.name,
                    profileImageUrl: activityDetail.providerDetail.content.imageUrlString
                ),
                imageUrl: package.imageUrlString
            )
        }
        
        // Create images from the image URLs
        let images = activityDetail.imageUrlsString.enumerated().map { index, url in
            ActivityImage(
                id: index + 1,
                imageUrl: url,
                imageType: index == 0 ? .thumbnail : .gallery,
                activityId: Int.random(in: 1000...9999)
            )
        }
        
        return Activity(
            id: Int.random(in: 1000...9999),
            title: activityDetail.title,
            images: images,
            pricing: packages.first?.pricePerPerson ?? 0,
            category: ActivityCategory(id: 1, name: "Adventure", description: ""),
            packages: packages,
            cancelable: activityDetail.tnc,
            createdAt: "2025-08-25T00:00:00Z",
            accessories: activityDetail.tripFacilities.content.map { name in
                Accessory(id: Int.random(in: 1...100), name: name)
            },
            description: activityDetail.detailInfomation.content,
            destination: Destination(
                id: 1,
                name: activityDetail.location,
                imageUrl: activityDetail.imageUrlsString.first,
                description: "Beautiful destination"
            ),
            durationMinutes: 480 // Default 8 hours
        )
    }
    
    func createMockDestinationFromSearch(query: String) -> GroupFormRecommendationDataModel {
        // Create a mock destination based on search query
        let mockActivity = Activity(
            id: Int.random(in: 1000...9999),
            title: "\(query) Adventure Experience",
            images: [
                ActivityImage(
                    id: 1,
                    imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))",
                    imageType: .thumbnail,
                    activityId: 1
                )
            ],
            pricing: Double.random(in: 500000...2000000),
            category: ActivityCategory(id: 1, name: "Adventure", description: ""),
            packages: [
                ActivityPackage(
                    id: 1,
                    name: "Standard Package",
                    endTime: "17:00",
                    startTime: "09:00",
                    activityId: 1,
                    description: "Standard adventure experience",
                    maxParticipants: 8,
                    minParticipants: 2,
                    pricePerPerson: Double.random(in: 500000...1000000),
                    host: ActivityPackage.Host(
                        bio: "Professional guide with extensive local knowledge",
                        name: "Local Guide",
                        profileImageUrl: "https://picsum.photos/50/50?random=guide"
                    ),
                    imageUrl: "https://picsum.photos/150/100?random=package"
                ),
                ActivityPackage(
                    id: 2,
                    name: "Premium Package",
                    endTime: "18:00",
                    startTime: "08:00",
                    activityId: 1,
                    description: "Premium adventure with extra services",
                    maxParticipants: 6,
                    minParticipants: 2,
                    pricePerPerson: Double.random(in: 1000000...2000000),
                    host: ActivityPackage.Host(
                        bio: "Professional guide with extensive local knowledge",
                        name: "Local Guide",
                        profileImageUrl: "https://picsum.photos/50/50?random=guide"
                    ),
                    imageUrl: "https://picsum.photos/150/100?random=package2"
                )
            ],
            cancelable: "Free cancellation up to 24 hours before trip",
            createdAt: "2025-08-25T00:00:00Z",
            accessories: [
                Accessory(id: 1, name: "Professional Equipment"),
                Accessory(id: 2, name: "Safety Gear"),
                Accessory(id: 3, name: "Refreshments")
            ],
            description: "Discover the beauty and adventure of \(query) with our guided experience.",
            destination: Destination(
                id: 1,
                name: query,
                imageUrl: "https://picsum.photos/238/180?random=\(Int.random(in: 10...99))",
                description: "Beautiful destination"
            ),
            durationMinutes: Int.random(in: 240...600)
        )
        
        return GroupFormRecommendationDataModel(activity: mockActivity)
    }
    
    func calculateTotalPrice() -> Double {
        let selectedPackages = availablePackages.filter { selectedPackageIds.contains($0.id) }
        let packageCost = selectedPackages.reduce(0.0) { total, package in
            // Extract price from string format "Rp 1,200,000"
            let priceString = package.price.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let packagePrice = Double(priceString) ?? 0
            return total + packagePrice
        }
        
        // Multiply by number of participants
        return packageCost * Double(teamMembers.count)
    }
}
