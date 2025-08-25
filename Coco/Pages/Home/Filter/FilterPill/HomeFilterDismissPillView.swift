//
//  HomeFilterDismissPillView.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 14/08/25.
//

import Foundation
import SwiftUI

struct HomeFilterDismissPillView: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 8.0) {
            Text(title)
                .lineLimit(1)
                .font(.jakartaSans(forTextStyle: .footnote, weight: .semibold))
                .foregroundStyle(Token.mainColorPrimary.toColor())
            
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Token.mainColorPrimary.toColor())
        }
        .padding(.vertical, 8.0)
        .padding(.horizontal, 16.0)
        .background(Token.additionalColorsWhite.toColor())
        .overlay {
            RoundedRectangle(cornerRadius: 24.0)
                .stroke(
                    Token.mainColorPrimary.toColor(),
                    lineWidth: 1.0
                )
        }
        .cornerRadius(24.0)
        .onTapGesture {
            withAnimation {
                onDismiss()
            }
        }
    }
}
