//
//  FailedToAddContributor.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

import SwiftUI

struct FailedToAddContributor: View {
    @ObservedObject var viewModel: GroupFormViewModel
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
                        Text(extractMemberNameFromWarning(viewModel.warningMessage))
                            .font(.jakartaSans(forTextStyle: .title3, weight: .semibold))
                            .foregroundColor(Token.additionalColorsBlack.toColor())
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.warningMessage)
                            .font(.jakartaSans(forTextStyle: .footnote, weight: .medium))
                            .foregroundColor(Token.grayscale70.toColor())
                            .multilineTextAlignment(.center)
                    }
                    
                    // Try Again Button
                    CocoButton(
                        action: onDismiss,
                        text: "Add Another",
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
    
    private func extractMemberNameFromWarning(_ warningMessage: String) -> String {
        // Extract member name from warning messages like:
        // "Adhis is already added as the group planner."
        // "Cynthia is already added to this trip."
        
        if warningMessage.contains("is already added") {
            if let memberName = warningMessage.components(separatedBy: " is already added").first {
                return "We couldn't add '\(memberName)'"
            }
        }
        
        // Fallback for other warning message formats
        return "We couldn't add this member"
    }
}
