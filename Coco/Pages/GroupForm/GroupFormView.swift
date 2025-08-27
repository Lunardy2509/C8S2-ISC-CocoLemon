//
//  GroupFormView.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import SwiftUI

struct GroupFormView: View {
    @ObservedObject var viewModel: GroupFormViewModel
    
    init(viewModel: GroupFormViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scroll content
            ScrollView {
                VStack(spacing: 24) {
                    // Trip Destination Section
                    tripDestinationSection
                    
                    // Trip Detail Section
                    tripDetailSection
                    
                    // Team Members Section
                    teamMembersSection
                    
                    // Available Packages Section
                    availablePackagesSection
                    
                    // Bottom padding for the fixed button
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            
            // Fixed Create Plan Button
            createPlanButton
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $viewModel.showSearchSheet) {
            HomeSearchSearchTray(
                selectedQuery: viewModel.searchText,
                latestSearches: viewModel.searchHistory,
                searchDidApply: { query in
                    viewModel.applySearch(query: query)
                },
                onSearchHistoryRemove: { searchData in
                    viewModel.removeSearchHistory(searchData)
                },
                onSearchReset: {
                    viewModel.resetSearch()
                }
            )
        }
        .sheet(isPresented: $viewModel.showSearchResultsSheet) {
            SearchResultsSheet(
                searchResults: viewModel.searchResults,
                searchQuery: viewModel.currentSearchQuery,
                onResultSelected: { searchResult in
                    viewModel.selectSearchResult(searchResult)
                },
                onDismiss: {
                    viewModel.showSearchResultsSheet = false
                }
            )
        }
        .overlay(popupOverlays)
    }
}

private extension GroupFormView {
    // MARK: - Popup Overlays
    @ViewBuilder
    var popupOverlays: some View {
        // Empty Search State Popup
        if viewModel.showEmptyStatePopup {
            emptySearchPopupOverlay
        }
        
        // Invite Friend Popup
        if viewModel.showInviteFriendPopup {
            inviteFriendPopupOverlay
        }
        
        // Failed To Add Contributor Popup
        if viewModel.showWarningAlert {
            failedToAddContributorPopupOverlay
        }
    }
    
    var emptySearchPopupOverlay: some View {
        EmptySearchPopupView(
            searchQuery: viewModel.currentSearchQuery,
            onDismiss: {
                viewModel.showEmptyStatePopup = false
                viewModel.showSearchSheet = true
            }
        )
    }
    
    var inviteFriendPopupOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.dismissInviteFriendPopup()
                }
            
            InviteFriendPopUpView(
                onSendInvite: { email in
                    viewModel.sendInvite(email: email)
                },
                onDismiss: {
                    viewModel.dismissInviteFriendPopup()
                }
            )
            .cornerRadius(16)
            .padding(.horizontal, 32)
        }
    }
    
    var failedToAddContributorPopupOverlay: some View {
        FailedToAddContributor(
            viewModel: viewModel,
            onDismiss: {
                viewModel.dismissWarningAlert()
                // Optionally reopen the invite friend popup to let user try again
                viewModel.showInviteFriendPopup = true
            }
        )
    }
    
    // MARK: - Trip Destination Section
    var tripDestinationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trip Destination")
                .font(.jakartaSans(forTextStyle: .headline, weight: .semibold))
                .foregroundColor(Token.additionalColorsBlack.toColor())
            
            if viewModel.selectedDestination == nil {
                // Search Bar (only show when no destination selected)
                HomeSearchBarView(
                    viewModel: viewModel.searchBarViewModel,
                    onReturnKeyAction: nil,
                    onClearAction: {
                        viewModel.resetSearch()
                    },
                    shouldAutoFocus: false
                )
                
                // Show TopDestinationSection when no destination is selected
                TopDestinationSection(
                    onDestinationTap: { destination, topDestinationViewModel in
                        viewModel.selectTopDestination(destination, from: topDestinationViewModel)
                    },
                    onAddDestinationTap: {
                        viewModel.showSearchSheet = true
                    }
                )
            } else if let selectedDestination = viewModel.selectedDestination {
                // Activity Cell View for selected destination
                ActivityCellView(
                    recommendation: selectedDestination,
                    onRemove: {
                        viewModel.dismissSelectedDestination()
                    },
                    onTap: {
                        viewModel.navigateToDestinationDetail()
                    }
                )
            }
        }
    }
    
    // MARK: - Trip Detail Section
    var tripDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trip detail")
                .font(.jakartaSans(forTextStyle: .headline, weight: .semibold))
                .foregroundColor(Token.additionalColorsBlack.toColor())
            
            VStack(spacing: 16) {
                // Trip Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Name")
                        .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                    
                    TextField("Enter Trip's Name", text: $viewModel.tripName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                        )
                        .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                }
                
                // Date Visit
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date Visit")
                        .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                    
                    HStack {
                        Text(viewModel.dateVisitString)
                            .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(8)
                        Button(action: {
                            viewModel.presentDateVisitCalendar()
                        }, label: {
                            Image(systemName: "calendar")
                                .foregroundColor(Token.grayscale70.toColor())
                                .font(.system(size: 20))
                                .padding(.trailing, 16)
                        })
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                    )
                    .onTapGesture {
                        viewModel.presentDateVisitCalendar()
                    }
                }
                
                // Package Contributor's Deadline
                VStack(alignment: .leading, spacing: 8) {
                    Text("Package Contributor's Deadline")
                        .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                    
                    HStack {
                        Text(viewModel.deadlineString)
                            .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(8)
                        Button(action: {
                            viewModel.presentDeadlineCalendar()
                        }, label: {
                            Image(systemName: "calendar")
                                .foregroundColor(Token.grayscale70.toColor())
                                .font(.system(size: 20))
                                .padding(.trailing, 16)
                        })
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                    )
                    .onTapGesture {
                        viewModel.presentDeadlineCalendar()
                    }
                }
            }
        }
    }
    
    // MARK: - Team Members Section
    var teamMembersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trip Member")
                .font(.jakartaSans(forTextStyle: .headline, weight: .semibold))
                .foregroundColor(Token.additionalColorsBlack.toColor())
            
            FlowLayout(spacing: 12, alignment: .leading) {
                // Current team members
                ForEach(viewModel.teamMembers, id: \.email) { member in
                    TeamMemberCardView(
                        member: member,
                        canRemove: viewModel.canRemoveMember(email: member.email)
                    ) {
                        viewModel.removeTeamMember(email: member.email)
                    }
                }
                
                // Add Friend Button
                AddFriendCardView {
                    viewModel.presentAddFriendOptions()
                }
            }
        }
    }
    
    // MARK: - Available Packages Section
    var availablePackagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Packages")
                .font(.jakartaSans(forTextStyle: .headline, weight: .semibold))
                .foregroundColor(Token.additionalColorsBlack.toColor())
            
            if viewModel.selectedDestination == nil {
                // Empty state
                VStack(spacing: 16) {
                    Image("logoEmptyStateSymbol")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 8) {
                        Text("Looks like your package list is empty")
                            .font(.jakartaSans(forTextStyle: .body, weight: .medium))
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .multilineTextAlignment(.center)
                        
                        Text("Pick a trip destination to unlock the options!")
                            .font(.jakartaSans(forTextStyle: .footnote, weight: .regular))
                            .foregroundColor(Token.grayscale70.toColor())
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Show packages for selected destination
                VStack(spacing: 12) {
                    ForEach(viewModel.availablePackages) { package in
                        SelectablePackageCard(
                            package: package,
                            isSelected: viewModel.selectedPackageIds.contains(package.id),
                            onToggle: {
                                viewModel.togglePackageSelection(package.id)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Create Plan Button
    var createPlanButton: some View {
        CocoButton(
            action: {
                viewModel.createPlan()
            },
            text: "Create Plan",
            style: .large,
            type: viewModel.canCreatePlan ? .primary : .disabled
        )
        .stretch()
        .padding(.horizontal, 24)
        .background(Token.additionalColorsWhite.toColor()
            .frame(height: 125)
        )
        .shadow(
            color: Token.grayscale10.toColor(),
            radius: 4,
            x: 0,
            y: -2
        )
    }
}

// MARK: - Activity Cell View Component
struct ActivityCellView: View {
    let recommendation: GroupFormRecommendationDataModel
    let onRemove: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Activity Image
                AsyncImage(url: recommendation.imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Token.grayscale30.toColor())
                }
                .frame(width: 92, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Text Content
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(recommendation.title)
                        .font(.jakartaSans(forTextStyle: .title3, weight: .bold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Location with pin icon
                    HStack(spacing: 4) {
                        Image("pinPointBlack")
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        Text(recommendation.location)
                            .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                            .foregroundColor(Token.grayscale70.toColor())
                            .lineLimit(1)
                    }
                    
                    // Price
                    Text(recommendation.priceText)
                        .font(.jakartaSans(forTextStyle: .caption2, weight: .semibold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Token.additionalColorsWhite.toColor())
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Token.additionalColorsLine.toColor(), lineWidth: 1)
            )
            .overlay(
                // Remove button positioned on top-right corner
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Token.additionalColorsWhite.toColor())
                        .frame(width: 20, height: 20)
                        .background(Token.grayscale40.toColor())
                        .clipShape(Circle())
                }
                .offset(x: 6, y: -6),
                alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Selectable Package Card Component
struct SelectablePackageCard: View {
    let package: TravelPackage
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .center, spacing: 13) {
                // Package Image
                AsyncImage(url: URL(string: package.imageUrlString)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Package Info
                VStack(alignment: .leading, spacing: 4) {
                    // Package Name
                    Text(package.name)
                        .font(.jakartaSans(forTextStyle: .headline, weight: .bold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .lineLimit(1)
                    
                    // Package Description & Participants
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.description)
                            .font(.jakartaSans(forTextStyle: .caption1, weight: .medium))
                            .foregroundColor(Token.grayscale70.toColor())
                            .lineLimit(2)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.system(size: 10))
                                .foregroundColor(Token.grayscale70.toColor())
                            
                            Text(package.participants)
                                .font(.jakartaSans(forTextStyle: .caption1, weight: .medium))
                                .foregroundColor(Token.grayscale70.toColor())
                        }
                    }
                    
                    // Price
                    Text("\(package.price)/Person")
                        .font(.jakartaSans(forTextStyle: .subheadline, weight: .bold))
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? Token.mainColorPrimary.toColor() : .gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Token.mainColorPrimary.toColor() : Color(red: 0.89, green: 0.91, blue: 0.93),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Team Member Components
struct TeamMemberCardView: View {
    let member: TeamMemberModel
    let canRemove: Bool
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Member avatar - show the appropriate image based on waiting state
                if let memberIcon = member.image {
                    Image(uiImage: memberIcon.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    // Fallback avatar for unknown members
                    Circle()
                        .fill(Token.grayscale20.toColor())
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(member.name.prefix(1)).uppercased())
                                .font(.jakartaSans(forTextStyle: .headline, weight: .medium))
                                .foregroundColor(Token.additionalColorsBlack.toColor())
                        )
                }
                
                // Remove button (X) for removable members
                if canRemove {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onRemove) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .background(Color.gray)
                                    .clipShape(Circle())
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 50, height: 50)
                }
            }
            
            // Show member name as caption
            Text(member.name)
                .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                .foregroundColor(Token.additionalColorsBlack.toColor())
                .multilineTextAlignment(.center)
        }
    }
}

struct AddFriendCardView: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: onAdd) {
                Circle()
                    .fill(Token.mainColorPrimary.withAlphaComponent(0.1).toColor())
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Token.mainColorPrimary.toColor(), lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundColor(Token.mainColorPrimary.toColor())
                            .font(.system(size: 16, weight: .medium))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Add Friend")
                .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                .foregroundColor(Token.mainColorPrimary.toColor())
                .multilineTextAlignment(.center)
        }
    }
}
