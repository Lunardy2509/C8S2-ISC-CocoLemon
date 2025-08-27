//
//  EmptySearchPopupView.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import SwiftUI

struct EmptySearchPopupView: View {
    let searchQuery: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Popup content
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    // Error icon
                    Image(uiImage: CocoIcon.icErrorCross.image)
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    
                    VStack(spacing: 8) {
                        Text("We couldn't find '\(searchQuery)'")
                            .font(.jakartaSans(forTextStyle: .title3, weight: .semibold))
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .multilineTextAlignment(.center)
                        
                        Text("Explore other keywords to discover more destinations.")
                            .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                            .foregroundColor(Token.grayscale70.toColor())
                            .multilineTextAlignment(.center)
                    }
                    
                    // Try Again Button
                    CocoButton(
                        action: onDismiss,
                        text: "Search Again",
                        style: .normal,
                        type: .primary
                    )
                    .stretch()
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 40)
        }
    }
}
