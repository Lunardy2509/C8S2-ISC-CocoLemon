//
//  GroupTripPlanViewModel.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 26/08/25.
//

import Foundation

final class GroupTripPlanViewModel: GroupTripPlanViewModelProtocol {
    weak var actionDelegate: GroupTripPlanViewModelAction?
    weak var navigationDelegate: GroupTripPlanNavigationDelegate?
    
    private var data: GroupTripPlanDataModel 
    private let currentUser: TripMember
    
    var tripName: String {
        return data.tripName
    }
    
    init(data: GroupTripPlanDataModel) {
        self.data = data
        
        self.currentUser = data.tripMembers.first { $0.name == "Adhis" } 
                        ?? data.tripMembers.first 
                        ?? TripMember(name: "Default User", email: "default@example.com", profileImageURL: nil, isWaiting: false)
    }
    
    func onViewDidLoad() {
        actionDelegate?.configureView(data: data)
    }
    
    func onEditTapped() {
        print("DEBUG: onEditTapped called in GroupTripPlanViewModel")
        print("DEBUG: navigationDelegate is \(navigationDelegate != nil ? "set" : "nil")")
        
        if let delegate = navigationDelegate {
            print("DEBUG: Calling notifyGroupTripPlanEditTapped")
            delegate.notifyGroupTripPlanEditTapped(data: data)
        } else {
            print("DEBUG: ❌ navigationDelegate is nil - cannot navigate")
        }
    }
    
    func onBookNowTapped() {
        let selectedPackagesWithVotes = data.selectedPackages.filter { $0.totalVotes > 0 }
        
        let totalPrice = selectedPackagesWithVotes.reduce(0.0) { total, package in
            let priceString = package.price.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            return total + (Double(priceString) ?? 0.0)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let localBookingDetails = LocalBookingDetails(
            id: UUID().uuidString,
            userId: UserDefaults.standard.string(forKey: "user-id") ?? "",
            activityTitle: data.activity.title,
            packageName: selectedPackagesWithVotes.map { $0.name }.joined(separator: ", "),
            activityDate: dateFormatter.string(from: Date()),
            participants: data.tripMembers.count,
            totalPrice: totalPrice,
            status: "Pending", 
            destination: BookingDestination(
                id: 1,
                name: data.activity.location,
                imageUrl: data.activity.imageUrl,
                description: data.activity.title
            ),
            address: data.activity.location,
            selectedPackages: selectedPackagesWithVotes,
            tripMembers: data.tripMembers,
            dueDateForm: data.tripDetails.dueDateForm
        )
        
        navigationDelegate?.notifyGroupTripPlanBookNowTapped(localBookingDetails: localBookingDetails)
    }
    
    func onPackageVoteToggled(packageId: Int) {
        var updatedPackages = data.selectedPackages
        
        if let index = updatedPackages.firstIndex(where: { $0.id == packageId }) {
            var package = updatedPackages[index]
            
            if package.voters.contains(where: { $0.email == currentUser.email }) {
                package = GroupTripPlanDataModel.VotablePackage(
                    id: package.id,
                    name: package.name,
                    description: package.description,
                    price: package.price,
                    imageUrlString: package.imageUrlString,
                    minParticipants: package.minParticipants,
                    maxParticipants: package.maxParticipants,
                    voters: package.voters.filter { $0.email != currentUser.email },
                    isSelected: false
                )
            } else {
                var newVoters = package.voters
                newVoters.append(currentUser)
                
                package = GroupTripPlanDataModel.VotablePackage(
                    id: package.id,
                    name: package.name,
                    description: package.description,
                    price: package.price,
                    imageUrlString: package.imageUrlString,
                    minParticipants: package.minParticipants,
                    maxParticipants: package.maxParticipants,
                    voters: newVoters,
                    isSelected: true
                )
            }
            
            updatedPackages[index] = package
        }
        
        data = GroupTripPlanDataModel(
            tripName: data.tripName,
            activity: data.activity,
            tripDetails: data.tripDetails,
            tripMembers: data.tripMembers,
            selectedPackages: updatedPackages,
            activityDetailData: data.activityDetailData
        )
        
        actionDelegate?.configureView(data: data)
    }
}

private extension GroupTripPlanDataModel.VotablePackage {
    init(id: Int, name: String, description: String, price: String, imageUrlString: String, minParticipants: String, maxParticipants: String, voters: [TripMember], isSelected: Bool) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageUrlString = imageUrlString
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.voters = voters
        self.totalVotes = voters.count
        self.isSelected = isSelected
    }
}
