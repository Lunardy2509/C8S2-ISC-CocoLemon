//
//  NoResultCell.swift
//  Coco
//
//  Created by AI Assistant on 15/08/25.
//

import UIKit

final class NoResultCell: UICollectionViewCell {
    static let reuseIdentifier = "NoResultCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = CocoIcon.logoSymbolGray.image
        return iv
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No perfect match yet, let’s try another city or activity!"
        label.textColor = Token.grayscale70
        label.font = UIFont.jakartaSans(forTextStyle: .body, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [imageView, messageLabel])
        s.axis = .vertical
        s.alignment = .center
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
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
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            imageView.widthAnchor.constraint(equalToConstant: 93.07),
            imageView.heightAnchor.constraint(equalToConstant: 83.89)
        ])
        // Accessibility
        isAccessibilityElement = true
        accessibilityLabel = messageLabel.text
    }
}
