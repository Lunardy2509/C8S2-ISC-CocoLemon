//
//  StatusLabel.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 28/08/25.
//

import Foundation
import UIKit
import Combine

final class StatusLabel: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(titleLabel)
        layer.cornerRadius = 12
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            heightAnchor.constraint(equalToConstant: 24),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func updateStyle(_ style: StatusStyle) {
        switch style {
        case .success:
            backgroundColor = .systemGreen.withAlphaComponent(0.1)
            titleLabel.textColor = .systemGreen
        case .warning:
            backgroundColor = .systemOrange.withAlphaComponent(0.1)
            titleLabel.textColor = .systemOrange
        case .error:
            backgroundColor = .systemRed.withAlphaComponent(0.1)
            titleLabel.textColor = .systemRed
        }
    }
}
