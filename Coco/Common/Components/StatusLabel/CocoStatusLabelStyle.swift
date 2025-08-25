//
//  CocoStatusLabelStyle.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

struct CocoStatusLabelStyle: Hashable {
    let textColor: UIColor
    let backgroundColor: UIColor
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(textColor.cgColor.components)
        hasher.combine(backgroundColor.cgColor.components)
    }
    
    static func == (lhs: CocoStatusLabelStyle, rhs: CocoStatusLabelStyle) -> Bool {
        return lhs.textColor.cgColor == rhs.textColor.cgColor &&
               lhs.backgroundColor.cgColor == rhs.backgroundColor.cgColor
    }
}

extension CocoStatusLabelStyle {
    static let success: Self = Self(
        textColor: Token.alertsSuccess,
        backgroundColor: UIColor.from("#E6F9F0")
    )
    
    static let failed: Self = Self(
        textColor: Token.alertsError,
        backgroundColor: UIColor.from("#FFEDED")
    )
    
    static let pending: Self = Self(
        textColor: Token.additionalColorsOrange,
        backgroundColor: UIColor.from("#FFF2ED")
    )
    
    static let refund: Self = Self(
        textColor: Token.alertsWarning,
        backgroundColor: UIColor.from("#FFFAE8")
    )
    
    static let unpaid: Self = Self(
        textColor: Token.additionalColorsPurple,
        backgroundColor: UIColor.from("#F4F0FF")
    )
    static let plain: Self = Self(
        textColor: Token.alertsError,
        backgroundColor: UIColor.clear
    )
}
