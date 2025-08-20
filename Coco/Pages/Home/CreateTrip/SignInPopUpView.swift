//
//  SignInPopUpView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 20/08/25.
//

import SwiftUI

struct SignInPopUpView: View {
    let signInDidTap: () -> Void
    let cancelDidTap: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 24.0) {
            VStack(spacing: 4.0) {
                Text("Create Your Own Trip")
                    .font(.jakartaSans(forTextStyle: .title3, weight: .semibold))
                    .foregroundStyle(Token.additionalColorsBlack.toColor())
                    .multilineTextAlignment(.center)
                
                Text("Please sign in first to create your own trip and enjoy the holiday.")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .regular))
                    .foregroundStyle(Token.grayscale70.toColor())
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16.0) {
                CocoButton(
                    action: signInDidTap,
                    text: "Sign In",
                    style: .normal,
                    type: .primary
                )
                .stretch()
                
                CocoButton(
                    action: cancelDidTap,
                    text: "Cancel",
                    style: .normal,
                    type: .secondary
                )
                .stretch()
            }
        }
        .padding(32.0)
    }
}
    
