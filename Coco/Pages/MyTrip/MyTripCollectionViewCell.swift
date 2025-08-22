//
//  MyTripCollectionViewCell.swift
//  Coco
//
//  Created by Assistant on 22/08/25.
//

import Foundation
import UIKit
import SwiftUI

protocol MyTripCollectionViewCellDelegate: AnyObject {
    func notifyTripListCardDidTap(at index: Int)
}

final class MyTripCollectionViewCell: UICollectionViewCell {
    weak var delegate: MyTripCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with dataModel: MyTripListCardDataModel, index: Int) {
        self.index = index
        statusLabelView.updateTitle(dataModel.statusLabel.text)
        statusLabelView.updateStyle(dataModel.statusLabel.style)
        dateLabel.text = dataModel.dateText
        tripLabel.text = dataModel.title
        locationLabel.text = dataModel.location
        totalPaxLabel.text = "\(dataModel.totalPax) person"
        totalPriceLabel.text = dataModel.price
        imageView.loadImage(from: URL(string: dataModel.imageUrl))
    }
    
    private lazy var imageView: UIImageView = createImageView()
    private lazy var statusLabelView: CocoStatusLabelHostingController = CocoStatusLabelHostingController(
        title: "",
        style: .pending
    )
    private lazy var dateLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var tripLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .headline, weight: .semibold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var locationLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    private lazy var totalPaxLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .semibold),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    private lazy var totalPriceLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .subheadline, weight: .semibold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var detailButtonContainer: CocoButtonHostingController = CocoButtonHostingController(
        action: { [weak self] in
            guard let self else { return }
            delegate?.notifyTripListCardDidTap(at: index)
        },
        text: "Detail",
        style: .normal,
        type: .primary,
        isStretch: true
    )
    
    private var index: Int = 0
}

private extension MyTripCollectionViewCell {
    func setupView() {
        contentView.backgroundColor = Token.additionalColorsWhite
        contentView.layer.cornerRadius = 16.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = Token.additionalColorsLine.cgColor
        
        let dateContentView: UIView = UIView()
        dateContentView.addSubviews([
            statusLabelView.view,
            dateLabel
        ])
        
        statusLabelView.view
            .layout {
                $0.leading(to: dateContentView.leadingAnchor)
                    .top(to: dateContentView.topAnchor)
                    .bottom(to: dateContentView.bottomAnchor)
            }
        
        dateLabel.layout {
            $0.leading(to: statusLabelView.view.trailingAnchor, relation: .greaterThanOrEqual, constant: 4.0)
                .top(to: dateContentView.topAnchor)
                .bottom(to: dateContentView.bottomAnchor)
                .trailing(to: dateContentView.trailingAnchor)
        }
        
        let locationContentView: UIView = UIView()
        let locationIconImageView: UIImageView = UIImageView(image: CocoIcon.icPinPointBlue.getImageWithTintColor(Token.additionalColorsBlack))
        locationIconImageView.contentMode = .scaleAspectFill
        locationIconImageView.layout {
            $0.size(12)
        }
        locationContentView.addSubviews([
            locationIconImageView,
            locationLabel
        ])
        
        locationIconImageView
            .layout {
                $0.leading(to: locationContentView.leadingAnchor)
                    .top(to: locationContentView.topAnchor)
                    .bottom(to: locationContentView.bottomAnchor)
            }
        
        locationLabel.layout {
            $0.leading(to: locationIconImageView.trailingAnchor, constant: 4.0)
                .centerY(to: locationContentView.centerYAnchor)
                .trailing(to: locationContentView.trailingAnchor)
        }
        
        let paxContentView: UIView = UIView()
        paxContentView.addSubviews([
            totalPaxLabel,
            totalPriceLabel
        ])
        
        totalPaxLabel
            .layout {
                $0.leading(to: paxContentView.leadingAnchor)
                    .top(to: paxContentView.topAnchor)
                    .bottom(to: paxContentView.bottomAnchor)
            }
        
        totalPriceLabel.layout {
            $0.leading(to: totalPaxLabel.trailingAnchor, relation: .greaterThanOrEqual, constant: 4.0)
                .top(to: paxContentView.topAnchor)
                .bottom(to: paxContentView.bottomAnchor)
                .trailing(to: paxContentView.trailingAnchor)
        }
        
        let leftSideContentView: UIView = UIView()
        leftSideContentView.addSubviews([
            dateContentView,
            tripLabel,
            locationContentView,
            paxContentView
        ])
        dateContentView
            .layout {
                $0.leading(to: leftSideContentView.leadingAnchor)
                    .top(to: leftSideContentView.topAnchor)
                    .trailing(to: leftSideContentView.trailingAnchor)
            }
        
        tripLabel.layout {
            $0.top(to: dateContentView.bottomAnchor, constant: 6.0)
                .leading(to: leftSideContentView.leadingAnchor)
                .trailing(to: leftSideContentView.trailingAnchor)
        }
        
        locationContentView.layout {
            $0.top(to: tripLabel.bottomAnchor, constant: 4.0)
                .leading(to: leftSideContentView.leadingAnchor)
                .trailing(to: leftSideContentView.trailingAnchor)
        }
        
        paxContentView.layout {
            $0.top(to: locationContentView.bottomAnchor, constant: 8.0)
                .leading(to: leftSideContentView.leadingAnchor)
                .trailing(to: leftSideContentView.trailingAnchor)
                .bottom(to: leftSideContentView.bottomAnchor)
        }
        
        let headerView: UIView = UIView()
        headerView.addSubviews([
            imageView,
            leftSideContentView
        ])
        imageView.layout {
            $0.leading(to: headerView.leadingAnchor)
                .top(to: headerView.topAnchor)
                .bottom(to: headerView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        leftSideContentView.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 12.0)
                .top(to: headerView.topAnchor)
                .trailing(to: headerView.trailingAnchor)
                .bottom(to: headerView.bottomAnchor)
        }
        
        let cardContentView: UIView = UIView()
        cardContentView.addSubviews([
            headerView,
            detailButtonContainer.view
        ])
        headerView.layout {
            $0.leading(to: cardContentView.leadingAnchor)
                .top(to: cardContentView.topAnchor)
                .trailing(to: cardContentView.trailingAnchor)
        }
        
        detailButtonContainer.view.layout {
            $0.top(to: headerView.bottomAnchor, constant: 12.0)
                .leading(to: cardContentView.leadingAnchor)
                .trailing(to: cardContentView.trailingAnchor)
                .bottom(to: cardContentView.bottomAnchor)
        }
        
        contentView.addSubviewAndLayout(cardContentView, insets: UIEdgeInsets(edges: 12.0))
    }
    
    func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14.0
        imageView.layout {
            $0.width(89)
                .height(106)
        }
        
        return imageView
    }
}
