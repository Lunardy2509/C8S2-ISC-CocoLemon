//
//  HomeActivityCell.swift
//  Coco
//
//  Created by Jackie Leonardy on 04/07/25.
//

import Foundation
import UIKit

final class HomeActivityCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ dataModel: HomeActivityCellDataModel) {
        imageView.loadImage(from: dataModel.imageUrl)
        areaLabel.text = dataModel.area
        nameLabel.text = dataModel.name
        locationLabel.text = dataModel.location
        
        let attributedString = NSMutableAttributedString(
            string: dataModel.priceText,
            attributes: [
                .font: UIFont.jakartaSans(forTextStyle: .callout, weight: .bold),
                .foregroundColor: Token.additionalColorsBlack
            ]
        )
        
        attributedString.append(
            NSAttributedString(
                string: "/Person",
                attributes: [
                    .font: UIFont.jakartaSans(forTextStyle: .callout, weight: .medium),
                    .foregroundColor: Token.additionalColorsBlack
                ]
            )
        )
        
        priceLabel.attributedText = attributedString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private lazy var imageView: UIImageView = createImageView()
    private lazy var locationView: UIView = createLocationView()
    private lazy var areaView: UIView = createAreaView()
    private lazy var priceView: UIView = createPriceView()
    
    private lazy var areaLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title3, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var nameLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var locationLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
        textColor: Token.grayscale90,
        numberOfLines: 1
    )
    private lazy var priceLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
}

private extension HomeActivityCell {
    func setupView() {
        let stackView: UIStackView = UIStackView(
            arrangedSubviews: [
                imageView,
                locationView,
                areaView,
                priceView
            ]
        )
        stackView.spacing = 8.0
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        stackView.setCustomSpacing(12.0, after: imageView)
        stackView.setCustomSpacing(8.0, after: locationView)
        stackView.setCustomSpacing(4.0, after: areaView)
        
        contentView.addSubviewAndLayout(stackView)
    }
    
    func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.height(238.0)
        }
        imageView.layer.cornerRadius = 12.0
        imageView.clipsToBounds = true
        return imageView
    }
    
    func createLocationView() -> UIView {
        let containerView = UIView()
        let pinIcon = UIImageView(image: CocoIcon.icPinPointBlack.image)
        pinIcon.contentMode = .scaleAspectFit
        
        containerView.addSubviews([pinIcon, locationLabel])
        
        pinIcon.layout {
            $0.leading(to: containerView.leadingAnchor)
            $0.centerY(to: containerView.centerYAnchor)
            $0.size(12)
        }
        
        locationLabel.layout {
            $0.leading(to: pinIcon.trailingAnchor, constant: 4.0)
            $0.trailing(to: containerView.trailingAnchor)
            $0.centerY(to: containerView.centerYAnchor)
        }
        
        return containerView
    }
    
    func createAreaView() -> UIView {
        let containerView = UIView()
        containerView.addSubview(areaLabel)
        
        areaLabel.layout {
            $0.leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        return containerView
    }
    
    func createPriceView() -> UIView {
        let containerView = UIView()
        containerView.addSubview(priceLabel)
        
        priceLabel.layout {
            $0.leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        return containerView
    }
}
