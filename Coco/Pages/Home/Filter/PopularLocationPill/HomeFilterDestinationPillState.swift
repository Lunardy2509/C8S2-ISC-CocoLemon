//
//  HomeFilterDestinationPillState.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 19/08/25.
//

import Foundation
import SwiftUI

final class HomeFilterDestinationPillState: ObservableObject, Identifiable {
    var id: Int
    var title: String
    @Published var isSelected: Bool
    
    init(id: Int, title: String, isSelected: Bool) {
        self.id = id
        self.title = title
        self.isSelected = isSelected
    }
    
    var textColor: Color {
        isSelected ? Token.mainColorPrimary.toColor() : Token.additionalColorsBlack.toColor()
    }
    
    var borderColor: Color {
        isSelected ? Token.mainColorPrimary.toColor() : Token.additionalColorsLine.toColor()
    }
}
