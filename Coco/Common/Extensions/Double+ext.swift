//
//  Double+ext.swift
//  Coco
//
//  Created by Teuku Fazariz Bas
ya on 14/08/25
//

import Foundation

extension Double {
    func toRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.currencySymbol = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "IDR 0"
    }
}
