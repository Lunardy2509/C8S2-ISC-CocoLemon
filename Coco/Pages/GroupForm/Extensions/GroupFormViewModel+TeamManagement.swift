//
//  GroupFormViewModel+TeamManagement.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import Foundation

// MARK: - Team Management
extension GroupFormViewModel {
    func addTeamMember(name: String, email: String, isWaiting: Bool = true) {
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
         // Check if trying to add Adhis (group planner)
        if normalizedEmail == "adhis@example.com" {
            existingMember = "Adhis"
            warningMessage = "Adhis is already added as the group planner."
            showWarningAlert = true
            return
        }
        
        // Check if member is already in the team
        if teamMembers.contains(where: { $0.email.lowercased() == normalizedEmail }) {
            if let existingMemberData = teamMembers.first(where: { $0.email.lowercased() == normalizedEmail }) {
                existingMember = existingMemberData.name
                warningMessage = "\(existingMemberData.name) is already added to this trip."
            } else {
                existingMember = "This member"
                warningMessage = "This member is already added to this trip."
            }
            showWarningAlert = true
            return
        }
        
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
        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if trying to add Adhis (group planner)
        if normalizedEmail == "adhis@example.com" || normalizedEmail == "adhis" {
            existingMember = "Adhis"
            warningMessage = "Adhis is already added as the group planner."
            showWarningAlert = true
            return
        }
        
        // Check if member is already in the team (check both email and name)
        if teamMembers.contains(where: { $0.email.lowercased() == normalizedEmail || $0.name.lowercased() == normalizedEmail }) {
            // Find the member's name for better error message
            if let existingMemberData = teamMembers.first(where: { $0.email.lowercased() == normalizedEmail || $0.name.lowercased() == normalizedEmail }) {
                existingMember = existingMemberData.name
                warningMessage = "\(existingMemberData.name) is already added to this trip."
            } else {
                existingMember = "This member"
                warningMessage = "This member is already added to this trip."
            }
            showWarningAlert = true
            return
        }
        
        // Check if this email corresponds to a known contributor
        if let contributor = availableContributors.first(where: { $0.email.lowercased() == normalizedEmail }) {
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
    
    func dismissWarningAlert() {
        showWarningAlert = false
        warningMessage = ""
        existingMember = ""
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
        // Adhis is already the group planner, show warning
        existingMember = "Adhis"
        warningMessage = "Adhis is already added as the group planner."
        showWarningAlert = true
    }
    
    func addCynthia(isWaiting: Bool = true) {
        if let cynthia = availableContributors.first(where: { $0.name == "Cynthia" }) {
            // Check if already added
            if teamMembers.contains(where: { $0.email.lowercased() == cynthia.email.lowercased() }) {
                existingMember = "Cynthia"
                warningMessage = "Cynthia is already added to this trip."
                showWarningAlert = true
                return
            }
            addTeamMember(cynthia, isWaiting: isWaiting)
        }
    }
    
    func addAhmad(isWaiting: Bool = true) {
        if let ahmad = availableContributors.first(where: { $0.name == "Ahmad" }) {
            // Check if already added
            if teamMembers.contains(where: { $0.email.lowercased() == ahmad.email.lowercased() }) {
                existingMember = "Ahmad"
                warningMessage = "Ahmad is already added to this trip."
                showWarningAlert = true
                return
            }
            addTeamMember(ahmad, isWaiting: isWaiting)
        }
    }
    
    func addTeuku(isWaiting: Bool = true) {
        if let teuku = availableContributors.first(where: { $0.name == "Teuku" }) {
            // Check if already added
            if teamMembers.contains(where: { $0.email.lowercased() == teuku.email.lowercased() }) {
                existingMember = "Teuku"
                warningMessage = "Teuku is already added to this trip."
                showWarningAlert = true
                return
            }
            addTeamMember(teuku, isWaiting: isWaiting)
        }
    }
    
    func addGriselda(isWaiting: Bool = true) {
        if let griselda = availableContributors.first(where: { $0.name == "Griselda" }) {
            // Check if already added
            if teamMembers.contains(where: { $0.email.lowercased() == griselda.email.lowercased() }) {
                existingMember = "Griselda"
                warningMessage = "Griselda is already added to this trip."
                showWarningAlert = true
                return
            }
            addTeamMember(griselda, isWaiting: isWaiting)
        }
    }
    
    func addFerdinand(isWaiting: Bool = true) {
        if let ferdinand = availableContributors.first(where: { $0.name == "Ferdinand" }) {
            // Check if already added
            if teamMembers.contains(where: { $0.email.lowercased() == ferdinand.email.lowercased() }) {
                existingMember = "Ferdinand"
                warningMessage = "Ferdinand is already added to this trip."
                showWarningAlert = true
                return
            }
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
