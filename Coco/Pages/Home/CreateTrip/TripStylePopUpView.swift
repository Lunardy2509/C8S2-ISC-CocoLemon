//
//  TripStylePopUpView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 20/08/25.
//

import SwiftUI

enum TripStyle {
    case group
    case solo
}

struct TripStylePopUpView: View {
    let didSelectStyle: (TripStyle) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 24.0) {
            VStack(spacing: 4.0) {
                Text("Trip Style")
                    .font(.jakartaSans(forTextStyle: .title3, weight: .semibold))
                    .foregroundStyle(Token.additionalColorsBlack.toColor())
                    .multilineTextAlignment(.center)
                
                Text("Choose the trip style that fits you best, how do you want to travel?")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .regular))
                    .foregroundStyle(Token.grayscale70.toColor())
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16.0) {
                CocoButton(
                    action: { didSelectStyle(.group) },
                    text: "Group",
                    style: .normal,
                    type: .primary
                )   
                .stretch()
                
                CocoButton(
                    action: { didSelectStyle(.solo) },
                    text: "Solo",
                    style: .normal,
                    type: .primary
                )
                .stretch()
            }
        }
        .padding(32.0)
    }
}
