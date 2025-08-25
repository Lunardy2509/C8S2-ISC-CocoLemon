//
//  Icon.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

final class Icon {
    var image: UIImage {
        guard let image: UIImage = UIImage(named: iconName) else {
            print("Warning: image \(iconName) can't be loaded, using fallback")
            return UIImage()
        }
        
        return image
    }
    
    func getImageWithTintColor(_ color: UIColor) -> UIImage {
        let imageTemplate: UIImage = image.withRenderingMode(.alwaysOriginal)
        return imageTemplate.withTintColor(color)
    }
    
    init(iconName: String) {
        self.iconName = iconName
    }
    
    private let iconName: String
}
