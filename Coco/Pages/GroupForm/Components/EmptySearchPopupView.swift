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
                        Text("Oops, there are no destination for '\(searchQuery)'")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Try another keywords")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Try Again Button
                    CocoButton(
                        action: onDismiss,
                        text: "Try Again",
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

#Preview {
    EmptySearchPopupView(
        searchQuery: "lol",
        onDismiss: {}
    )
}
