//
//  GroupFormViewModel+TeamManagement.swift
//  Coco
//
//  Created by GitHub Copilot on 26/08/25.
//

import Foundation

// MARK: - Team Management
extension GroupFormViewModel {
    func addTeamMember(name: String, email: String, isWaiting: Bool = true) {
        let newMember = TeamMemberModel(
            name: name,
            email: email,
            isWaiting: isWaiting // New members are waiting by default
        )
        teamMembers.append(newMember)
    }
    
    func addTeamMember(_ memberData: TripMemberData, isWaiting: Bool = true) {
        addTeamMember(name: memberData.name, email: memberData.email, isWaiting: isWaiting)
    }
    
    func removeTeamMember(email: String) {
        // Prevent removing Adhis (group planner)
        guard email.lowercased() != "adhis@example.com" else { return }
        teamMembers.removeAll { $0.email == email }
    }
    
    func canRemoveMember(email: String) -> Bool {
        // Adhis cannot be removed as she's the group planner
        return email.lowercased() != "adhis@example.com"
    }
    
    func toggleMemberWaitingStatus(email: String) {
        // Don't allow changing Adhis's waiting status as she's the group planner
        guard email.lowercased() != "adhis@example.com" else { return }
        
        if let index = teamMembers.firstIndex(where: { $0.email == email }) {
            let member = teamMembers[index]
            teamMembers[index] = TeamMemberModel(
                name: member.name,
                email: member.email,
                isWaiting: !member.isWaiting
            )
        }
    }
    
    func presentAddFriendOptions() {
        showInviteFriendPopup = true
    }
    
    func sendInvite(email: String) {
        // Check if this email corresponds to a known contributor
        if let contributor = availableContributors.first(where: { $0.email.lowercased() == email.lowercased() }) {
            // Add the known contributor in waiting state
            addTeamMember(contributor, isWaiting: true)
        } else {
            // Add a new member with the provided email in waiting state
            let name = extractNameFromEmail(email)
            addTeamMember(name: name, email: email, isWaiting: true)
        }
        
        showInviteFriendPopup = false
    }
    
    func dismissInviteFriendPopup() {
        showInviteFriendPopup = false
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        // Extract name from email (part before @)
        let components = email.components(separatedBy: "@")
        return components.first?.capitalized ?? "Friend"
    }
    
    func getAvailableContributors() -> [TripMemberData] {
        return availableContributors.filter { contributor in
            !teamMembers.contains { $0.name.lowercased() == contributor.name.lowercased() }
        }
    }
    
    // Convenience methods for adding specific contributors (all in waiting state except Adhis)
    func addAdhis(isWaiting: Bool = false) {
        if let adhis = availableContributors.first(where: { $0.name == "Adhis" }) {
            addTeamMember(adhis, isWaiting: isWaiting) // Adhis is not waiting as she's the planner
        }
    }
    
    func addCynthia(isWaiting: Bool = true) {
        if let cynthia = availableContributors.first(where: { $0.name == "Cynthia" }) {
            addTeamMember(cynthia, isWaiting: isWaiting)
        }
    }
    
    func addAhmad(isWaiting: Bool = true) {
        if let ahmad = availableContributors.first(where: { $0.name == "Ahmad" }) {
            addTeamMember(ahmad, isWaiting: isWaiting)
        }
    }
    
    func addTeuku(isWaiting: Bool = true) {
        if let teuku = availableContributors.first(where: { $0.name == "Teuku" }) {
            addTeamMember(teuku, isWaiting: isWaiting)
        }
    }
    
    func addGriselda(isWaiting: Bool = true) {
        if let griselda = availableContributors.first(where: { $0.name == "Griselda" }) {
            addTeamMember(griselda, isWaiting: isWaiting)
        }
    }
    
    func addFerdinand(isWaiting: Bool = true) {
        if let ferdinand = availableContributors.first(where: { $0.name == "Ferdinand" }) {
            addTeamMember(ferdinand, isWaiting: isWaiting)
        }
    }
    
    func loadTeamMembers() {
        // Load team members with Adhis as the group planner (cannot be removed)
        teamMembers = [
            TeamMemberModel(
                name: "Adhis",
                email: "adhis@example.com",
                isWaiting: false // Adhis is the group planner, not waiting
            )
        ]
    }
}
