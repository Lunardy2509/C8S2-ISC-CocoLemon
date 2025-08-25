//
//  MyTripNoTripYet.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 22/08/25.
//

import UIKit
import SwiftUI

protocol MyTripNoTripYetDelegate: AnyObject {
    func didTapRecommendationItem(_ recommendation: MyTripRecommendationDataModel)
    func didTapCreateTrip()
}

final class MyTripNoTripYet: UICollectionViewCell {
    static let reuseIdentifier = "MyTripNoTripYet"
    weak var delegate: MyTripNoTripYetDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureRecommendations(_ recommendations: [MyTripRecommendationDataModel]) {
        recommendationCarouselView.configureRecommendations(recommendations)
    }
    
    // UI Components
    private lazy var scrollView: UIScrollView = createScrollView()
    private lazy var contentStackView: UIStackView = createContentStackView()
    private lazy var emptyStateView: UIView = createEmptyStateView()
    private lazy var recommendationCarouselView: MyTripRecommendationCarouselView = createRecommendationCarouselView()
    
    private func setupView() {
        contentView.addSubviewAndLayout(scrollView)
        scrollView.addSubviewAndLayout(contentStackView, insets: UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21))
        
        // Set up content stack view
        contentStackView.addArrangedSubview(emptyStateView)
        contentStackView.addArrangedSubview(recommendationCarouselView)
        contentStackView.setCustomSpacing(32, after: emptyStateView)
        
        // Set up delegates
        recommendationCarouselView.delegate = self
    }
    
    private func updateRecommendationCollectionView() {
        // This method is no longer needed as we use the carousel view
    }
}

// MARK: - UI Creation
private extension MyTripNoTripYet {
    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }
    
    func createRecommendationCarouselView() -> MyTripRecommendationCarouselView {
        return MyTripRecommendationCarouselView()
    }
    
    func createEmptyStateView() -> UIView {
        let containerView = UIView()
        
        // Create components using UIKit
        let imageView = UIImageView()
        imageView.image = CocoIcon.logoEmptyStateSymbol.image
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .body, weight: .regular),
            textColor: Token.grayscale70,
            numberOfLines: 0
        )
        titleLabel.text = "No trips yet, let's create your first one!"
        titleLabel.textAlignment = .center
        
        let createTripButton = CocoButtonHostingController(
            action: { [weak self] in
                self?.delegate?.didTapCreateTrip()
            },
            text: "Create Trip",
            style: .large,
            type: .primary
        )
        
        // Create a vertical stack view for centering
        let centerStackView = UIStackView(arrangedSubviews: [imageView, titleLabel, createTripButton.view])
        centerStackView.axis = .vertical
        centerStackView.alignment = .center
        centerStackView.distribution = .fill
        centerStackView.spacing = 12
        
        containerView.addSubview(centerStackView)
        
        centerStackView.layout {
            $0.centerX(to: containerView.centerXAnchor)
            $0.centerY(to: containerView.centerYAnchor)
            $0.leading(to: containerView.leadingAnchor, relation: .greaterThanOrEqual)
            $0.trailing(to: containerView.trailingAnchor, relation: .lessThanOrEqual)
            $0.top(to: containerView.topAnchor, relation: .greaterThanOrEqual)
            $0.bottom(to: containerView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        imageView.layout {
            $0.size(157)
        }
        
        createTripButton.view.layout {
            $0.leading(to: centerStackView.leadingAnchor)
            $0.trailing(to: centerStackView.trailingAnchor)
        }
        
        return containerView
    }
}

// MARK: - MyTripRecommendationCarouselViewDelegate
extension MyTripNoTripYet: MyTripRecommendationCarouselViewDelegate {
    func didTapRecommendationItem(_ recommendation: MyTripRecommendationDataModel) {
        delegate?.didTapRecommendationItem(recommendation)
    }
}
