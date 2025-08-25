//
//  GroupFormView.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import SwiftUI

struct GroupFormView: View {
    @ObservedObject var viewModel: GroupFormViewModel
    let onCreatePlan: (() -> Void)?
    
    init(viewModel: GroupFormViewModel, onCreatePlan: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onCreatePlan = onCreatePlan
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
    }
}

// MARK: - Trip Destination Section
private extension GroupFormView {
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
                
                // Place Recommendation Label
                Text("Place Recommendation")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .medium))
                    .foregroundColor(Token.grayscale70.toColor())
                
                // Recommendation Cards
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding(.vertical, 60)
                        Spacer()
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Add destination card
                            RecommendationCard(
                                recommendation: nil,
                                isSelected: false,
                                onTap: {
                                    viewModel.showSearchSheet = true
                                }
                            )
                            .frame(width: 200, height: 180)
                            
                            // Existing recommendations
                            ForEach(viewModel.recommendations) { recommendation in
                                RecommendationCard(
                                    recommendation: recommendation,
                                    isSelected: false,
                                    onTap: {
                                        viewModel.selectDestination(recommendation)
                                    }
                                )
                                .frame(width: 200, height: 180)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.horizontal, -24)
                }
            } else {
                // Selected destination card
                RecommendationCard(
                    recommendation: viewModel.selectedDestination,
                    isSelected: true,
                    onTap: {
                        viewModel.navigateToDestinationDetail()
                    },
                    onDismiss: {
                        viewModel.dismissSelectedDestination()
                    }
                )
                .frame(height: 200)
            }
        }
    }
}

// MARK: - Trip Detail Section
private extension GroupFormView {
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                            )
                            .onTapGesture {
                                viewModel.presentDateVisitCalendar()
                            }
                        
                        Button {
                            viewModel.presentDateVisitCalendar()
                        } label: {
                            Image(systemName: "calendar")
                                .foregroundColor(Token.grayscale70.toColor())
                                .font(.system(size: 20))
                                .padding(.trailing, 16)
                        }
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Token.mainColorPrimary.toColor(), lineWidth: 1)
                            )
                            .onTapGesture {
                                viewModel.presentDeadlineCalendar()
                            }
                        
                        Button {
                            viewModel.presentDeadlineCalendar()
                        } label: {
                            Image(systemName: "calendar")
                                .foregroundColor(Token.grayscale70.toColor())
                                .font(.system(size: 20))
                                .padding(.trailing, 16)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Team Members Section
private extension GroupFormView {
    var teamMembersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team")
                .font(.jakartaSans(forTextStyle: .headline, weight: .semibold))
                .foregroundColor(Token.additionalColorsBlack.toColor())
            
            FlowLayout(spacing: 12, alignment: .leading) {
                // Current user avatars
                ForEach(viewModel.teamMembers) { member in
                    VStack(spacing: 4) {
                        member.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        Text(member.name)
                            .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .multilineTextAlignment(.center)
                    }
                    .onTapGesture {
                        // Optional: Handle member tap for removal or editing
                        viewModel.removeTeamMember(id: member.id)
                    }
                }
                
                // Add Friend Button
                Button {
                    // Add a random contributor (for demo purposes)
                    let contributors = ["Ahmad", "Teuku", "Griselda"]
                    let availableContributors = contributors.filter { name in
                        !viewModel.teamMembers.contains { $0.name == name }
                    }
                    
                    if let randomName = availableContributors.randomElement() {
                        switch randomName {
                        case "Ahmad": viewModel.addAhmad()
                        case "Teuku": viewModel.addTeuku()
                        case "Griselda": viewModel.addGriselda()
                        default: break
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Token.additionalColorsWhite.toColor())
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(Token.mainColorPrimary.toColor())
                                    .font(.system(size: 20, weight: .medium))
                            )
                        
                        Text("Add Friend")
                            .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
}

// MARK: - Available Packages Section
private extension GroupFormView {
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
                        PackageCard(package: package)
                    }
                }
            }
        }
    }
}

// MARK: - Create Plan Button
private extension GroupFormView {
    var createPlanButton: some View {
        CocoButton(
            action: {
                viewModel.createPlan()
                onCreatePlan?()
            },
            text: "Create Plan",
            style: .large,
            type: viewModel.canCreatePlan ? .primary : .disabled
        )
        .stretch()
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
        .background(
            LinearGradient(
                colors: [Color.clear, Token.additionalColorsWhite.toColor()],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
        )
    }
}
