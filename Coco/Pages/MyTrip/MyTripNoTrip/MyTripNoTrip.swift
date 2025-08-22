//
//  MyTripNoTrip.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 22/08/25.
//

import UIKit

final class MyTripNoTrip: UICollectionViewCell {
    static let reuseIdentifier: String = "MyTripNoTrip"
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.image = CocoIcon.logoEmptyStateSymbol.image
        return image
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No trips yet, let’s create your first one!"
        label.textColor = Token.grayscale70
        label.font = UIFont.jakartaSans(forTextStyle: .body, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.title = "Create Trip"
        button.configuration?.baseForegroundColor = Token.additionalColorsWhite
        button.configuration?.baseBackgroundColor = Token.mainColorPrimary
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, messageLabel, button])
        stack.axis  = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    private var didSetup = false
    private func configureView() {
        guard !didSetup else { return }
        didSetup = true
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            imageView.widthAnchor.constraint(equalToConstant: 157),
            imageView.heightAnchor.constraint(equalToConstant: 157)
        ])
        
        // Accessibility
        isAccessibilityElement = true
        accessibilityLabel = messageLabel.text
    }
}
