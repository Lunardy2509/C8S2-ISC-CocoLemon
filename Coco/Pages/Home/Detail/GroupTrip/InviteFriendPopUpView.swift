//
//  InviteFriendPopUpView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 24/08/25.
//

import SwiftUI

struct InviteFriendPopUpView: View {
    @State private var friendEmail: String = ""
    let onSendInvite: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 32.0) {
            VStack(spacing: 16.0) {
                Text("Invite a friend to join your trip using their email.")
                    .font(.jakartaSans(forTextStyle: .body, weight: .regular))
                    .foregroundStyle(Token.grayscale70.toColor())
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
           
            CocoInputTextField(
                leadingIcon: nil,
                currentTypedText: $friendEmail,
                trailingIcon: nil,
                placeholder: "Enter friend's email"
            )
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
           
            Button(action: {
                if !friendEmail.isEmpty {
                    onSendInvite(friendEmail)
                }
            }) {
                Text("Send Invite")
                    .font(.jakartaSans(forTextStyle: .body, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 16.0)
                    .padding(.horizontal, 48.0)
                    .background(
                        Token.mainColorPrimary.toColor()
                    )
                    .cornerRadius(20.0)
            }
            .disabled(friendEmail.isEmpty)
        }
        .padding(.horizontal, 32.0)
        .padding(.vertical, 40.0)
        .background(Token.additionalColorsWhite.toColor())
    }
}
