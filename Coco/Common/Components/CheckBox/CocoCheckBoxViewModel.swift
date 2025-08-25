//
//  CocoCheckBoxViewModel.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 19/08/25.
//

import Foundation

final class CocoCheckBoxViewModel: ObservableObject {
    @Published var isChecked: Bool = false
    var label: String
    
    init(label: String, isChecked: Bool = false) {
        self.label = label
        self.isChecked = isChecked
    }
    
    func toggle() {
        isChecked.toggle()
    }
}
