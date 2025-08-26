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
        navigationDelegate?.notifyGroupTripPlanEditTapped()
    }
    
    func onBookNowTapped() {
        navigationDelegate?.notifyGroupTripPlanBookNowTapped()
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
            selectedPackages: updatedPackages
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
