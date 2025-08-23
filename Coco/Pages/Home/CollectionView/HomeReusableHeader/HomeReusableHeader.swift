//
//  HomeReusableHeader.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation
import UIKit

final class HomeReusableHeader: UICollectionReusableView {
    var onClearAllTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(title: String, showClearAll: Bool = false) {
        titleLabel.text = title
        clearAllButton.isHidden = !showClearAll
    }
    
    private lazy var titleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title3, weight: .semibold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    
    private lazy var clearAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear All", for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .caption1)
        button.configuration?.baseForegroundColor = Token.mainColorPrimary
        button.addTarget(self, action: #selector(clearAllTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    @objc private func clearAllTapped() {
        onClearAllTap?()
    }
}

private extension HomeReusableHeader {
    func setupView() {
        let containerView = UIView()
        containerView.addSubviews([titleLabel, clearAllButton])
        
        titleLabel.layout {
            $0.leading(to: containerView.leadingAnchor)
            $0.top(to: containerView.topAnchor)
            $0.bottom(to: containerView.bottomAnchor)
        }
        
        clearAllButton.layout {
            $0.trailing(to: containerView.trailingAnchor)
            $0.centerY(to: titleLabel.centerYAnchor)
            $0.leading(to: titleLabel.trailingAnchor, relation: .greaterThanOrEqual, constant: 8.0)
        }
        
        addSubviewAndLayout(containerView, insets: .init(top: 0, left: 0, bottom: 16.0, right: 0))
    }
}
