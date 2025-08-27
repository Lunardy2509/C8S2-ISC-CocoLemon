//
//  VotablePackageCardView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 24/08/25.
//

import SwiftUI

struct VotablePackageCardView: View {
    let package: GroupTripPlanDataModel.VotablePackage
    let totalMembers: Int
    let onVoteToggled: () -> Void
    let onDetailTapped: () -> Void 
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: package.imageUrlString)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(package.name)
                    .font(.jakartaSans(forTextStyle: .body, weight: .bold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                    .lineLimit(1)
                
                Text("Min. \(package.minParticipants) - Max. \(package.maxParticipants)")
                    .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                    .foregroundColor(Token.grayscale70.toColor())
                
                Text("\(package.price)/Person")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .bold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                
                HStack(spacing: 8) {
                    if let firstVoter = package.voters.first {
                        Button(action: onDetailTapped) { 
                            VoterAvatarView(voter: firstVoter)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text("\(package.totalVotes)/\(totalMembers)")
                        .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                        .foregroundColor(Token.grayscale70.toColor())
                    
                    Button(action: onDetailTapped) { 
                        Text(">")
                            .font(.jakartaSans(forTextStyle: .caption2, weight: .medium))
                            .foregroundColor(Token.grayscale70.toColor())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            Button(action: onVoteToggled) {
                Image(systemName: package.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(package.isSelected ? Token.mainColorPrimary.toColor() : Token.grayscale50.toColor())
                    .font(.system(size: 24))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(Token.additionalColorsWhite.toColor())
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Token.additionalColorsLine.toColor(), lineWidth: 1)
        )
    }
}

struct VoterAvatarView: View {
    let voter: TripMember
    
    var body: some View {
        Group {
            if let profileImageURL = voter.profileImageURL, !profileImageURL.isEmpty {
                AsyncImage(url: URL(string: profileImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    avatarPlaceholder
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 20, height: 20)
        .clipShape(Circle())
    }
    
    private var avatarPlaceholder: some View {
        ZStack {
            Token.mainColorPrimary.toColor()
            Text(String(voter.name.prefix(1)).uppercased())
                .font(.jakartaSans(forTextStyle: .caption2, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
