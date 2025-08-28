//
//  BookingSuccessPopUpView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 28/08/25.
//

import SwiftUI

struct BookingSuccessPopupView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 24.0) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.green)
            
            VStack(spacing: 16.0) {
                Text("Booking Confirm")
                    .font(.jakartaSans(forTextStyle: .title2, weight: .bold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                    .multilineTextAlignment(.center)
                
                Text("Please pay to trip povider during your trip.")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .regular))
                    .foregroundColor(Token.grayscale70.toColor())
                    .multilineTextAlignment(.center)
            }
            
            CocoButton(
                action: onContinue,
                text: "Continue",
                style: .normal,
                type: .primary
            )
            .stretch()
        }
        .padding(32.0)
    }
}