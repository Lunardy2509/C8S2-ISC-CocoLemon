import SwiftUI

struct BookingConfirmationPopupView: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 24.0) {
            VStack(spacing: 16.0) {
                Text("Confirm Your Booking?")
                    .font(.jakartaSans(forTextStyle: .title2, weight: .bold))
                    .foregroundColor(Token.additionalColorsBlack.toColor())
                    .multilineTextAlignment(.center)
                
                Text("Once you confirm, we'll secure your spot instantly.")
                    .font(.jakartaSans(forTextStyle: .subheadline, weight: .regular))
                    .foregroundColor(Token.grayscale70.toColor())
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12.0) {
                CocoButton(
                    action: onConfirm,
                    text: "Confirm",
                    style: .normal,
                    type: .primary,
                )
                .stretch()
                
                CocoButton(
                    action: onCancel,
                    text: "Back",
                    style: .normal,
                    type: .tertiary
                )
                .stretch()
            }
        }
        .padding(32.0)
    }
}
