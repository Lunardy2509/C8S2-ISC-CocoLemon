//
//  ShareTripView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 17/08/25.
//

import Foundation
import UIKit

final class ShareTripView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ data: ShareTripDataModel) {
        // From TripDetailView
        activityImage.loadImage(from: URL(string: data.imageString))
        activityTitle.text = data.activityName
        activityLocationTitle.text = data.location
        activityDescription.text = data.packageName
        
        bookingDateLabel.text = data.bookingDateText
        paxNumberLabel.text = "\(data.paxNumber)"
        
        priceDetailTitle.text = "Pay During Trip"
        priceDetailPrice.text = data.price.toRupiah()
        
        addressLabel.text = data.address
        
        let statusLabelView = createStatusLabel(text: data.status.text, style: data.status.style)
        configureStatusLabelView(with: statusLabelView)

        // New sections
        let providerView = createProviderDetail(
            imageUrl: data.tripProvider.imageUrlString,
            name: data.tripProvider.name,
            description: data.tripProvider.description
        )
        let tripIncludesView = createBenefitListView(titles: data.tripIncludes)

        contentStackView.addArrangedSubview(createSectionView(title: "Trip Provider", view: providerView))
        contentStackView.addArrangedSubview(createLineDivider())
        contentStackView.addArrangedSubview(createSectionView(title: "This Trip Includes", view: tripIncludesView))
    }
    
    func configureStatusLabelView(with view: UIView) {
        statusLabel.subviews.forEach { $0.removeFromSuperview() }
        statusLabel.addSubview(view)
        view.layout {
            $0.leading(to: statusLabel.leadingAnchor)
                .top(to: statusLabel.topAnchor)
                .trailing(to: statusLabel.trailingAnchor, relation: .lessThanOrEqual)
                .bottom(to: statusLabel.bottomAnchor)
        }
    }

    // MARK: - UI Components (mostly from TripDetailView)
    
    private lazy var activityDetailView: UIView = createActivityDetailView()
    private lazy var activityImage: UIImageView = createImageView()
    private lazy var activityTitle: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title2, weight: .semibold),
        textColor: Token.grayscale90,
        numberOfLines: 0
    )
    private lazy var activityDescription: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 0
    )
    private lazy var activityLocationTitle: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    
    private lazy var contentStackView: UIStackView = createStackView()
    
    private lazy var bookingDateSection: UIView = createSectionTitle(title: "Date Booking", view: bookingDateLabel)
    private lazy var bookingDateLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 0
    )
    
    private lazy var statusSection: UIView = createSectionTitle(title: "Status", view: statusLabel)
    private lazy var statusLabel: UIView = UIView()
    
    private lazy var paxNumberSection: UIView = createSectionTitle(title: "Person", view: paxNumberLabel)
    private lazy var paxNumberLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 0
    )
    
    private lazy var priceDetailTitle: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var priceDetailPrice: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .semibold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    
    private lazy var addressSection: UIView = createSectionTitle(title: "Meeting Point", view: addressLabel)
    private lazy var addressLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 0
    )
    
    private lazy var priceDetailSection: UIView = createLeftRightAlignment(lhs: priceDetailTitle, rhs: priceDetailPrice)
    
    // MARK: - Setup and Private View Creation Methods
    
    private func setupView() {
        addSubview(contentStackView)

        contentStackView.layout {
            $0.top(to: self.safeAreaLayoutGuide.topAnchor, constant: 24.0)
                .leading(to: self.leadingAnchor, constant: 24.0)
                .trailing(to: self.trailingAnchor, constant: -24.0)
                .bottom(to: self.bottomAnchor, relation: .lessThanOrEqual, constant: -24.0)
        }
        
        let dateStatusSection: UIView = UIView()
        dateStatusSection.addSubviews([
            bookingDateSection,
            statusSection
        ])
        
        bookingDateSection.layout {
            $0.leading(to: dateStatusSection.leadingAnchor)
                .centerY(to: dateStatusSection.centerYAnchor)
        }
        
        statusSection.layout {
            $0.leading(to: bookingDateSection.trailingAnchor)
                .leading(to: dateStatusSection.centerXAnchor)
                .trailing(to: dateStatusSection.trailingAnchor)
                .top(to: dateStatusSection.topAnchor)
                .bottom(to: dateStatusSection.bottomAnchor)
        }
        
        contentStackView.addArrangedSubview(activityDetailView)
        contentStackView.addArrangedSubview(dateStatusSection)
        contentStackView.addArrangedSubview(paxNumberSection)
        contentStackView.addArrangedSubview(createLineDivider())
        contentStackView.addArrangedSubview(priceDetailSection)
        contentStackView.addArrangedSubview(createLineDivider())
        contentStackView.addArrangedSubview(addressSection)
        contentStackView.addArrangedSubview(createLineDivider())
        
        backgroundColor = Token.additionalColorsWhite
    }
    
    private func createStatusLabel(text: String, style: CocoStatusLabelStyle) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .light)
        label.textColor = style.textColor
        label.textAlignment = .center
        
        let container = UIView()
        container.backgroundColor = style.backgroundColor
        container.layer.cornerRadius = 4.0
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4.0),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4.0),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.0),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.0)
        ])
        return container
    }

    // From TripDetailView
    private func createActivityDetailView() -> UIView {
        let imageView: UIImageView = UIImageView(image: CocoIcon.icPinPointBlue.image)
        imageView.layout {
            $0.size(20.0)
        }
        
        let imageTextContent: UIView = UIView()
        imageTextContent.addSubviews([
            imageView,
            activityLocationTitle
        ])
        
        imageView.layout {
            $0.leading(to: imageTextContent.leadingAnchor)
                .top(to: imageTextContent.topAnchor)
                .bottom(to: imageTextContent.bottomAnchor)
                .centerY(to: imageTextContent.centerYAnchor)
        }
        
        activityLocationTitle.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 4.0)
                .trailing(to: imageTextContent.trailingAnchor)
                .centerY(to: imageTextContent.centerYAnchor)
        }
        
        let containerView: UIView = UIView()
        containerView.addSubviews([
            activityImage,
            activityTitle,
            activityDescription,
            imageTextContent
        ])
        
        activityImage.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        activityTitle.layout {
            $0.leading(to: activityImage.trailingAnchor, constant: 10.0)
                .top(to: containerView.topAnchor)
                .trailing(to: containerView.trailingAnchor)
        }
        
        activityDescription.layout {
            $0.leading(to: activityTitle.leadingAnchor)
                .top(to: activityTitle.bottomAnchor, constant: 8.0)
                .trailing(to: containerView.trailingAnchor)
        }
        
        imageTextContent.layout {
            $0.leading(to: activityTitle.leadingAnchor)
                .top(to: activityDescription.bottomAnchor, constant: 8.0)
                .trailing(to: containerView.trailingAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        return containerView
    }
    
    private func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.size(92.0)
        }
        imageView.layer.cornerRadius = 14.0
        imageView.clipsToBounds = true
        return imageView
    }
    
    private func createStackView() -> UIStackView {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24.0
          
        return stackView
    }
    
    private func createSectionTitle(title: String, view: UIView) -> UIView {
        let titleView: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .regular),
            textColor: Token.grayscale60,
            numberOfLines: 0
        )
        titleView.text = title
        
        let contentView: UIView = UIView()
        contentView.addSubviews(
            [
                titleView,
                view
            ]
        )
        
        titleView.layout {
            $0.leading(to: contentView.leadingAnchor)
                .top(to: contentView.topAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        view.layout {
            $0.leading(to: contentView.leadingAnchor)
                .top(to: titleView.bottomAnchor, constant: 4.0)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        
        return contentView
    }
    
    private func createLineDivider() -> UIView {
        let contentView: UIView = UIView()
        let divider: UIView = UIView()
        divider.backgroundColor = Token.additionalColorsLine
        divider.layout {
            $0.height(1.0)
        }
        
        contentView.addSubviewAndLayout(divider, insets: .init(vertical: 0, horizontal: 8.0))
        
        return contentView
    }
    
    private func createLeftRightAlignment(
        lhs: UIView,
        rhs: UIView
    ) -> UIView {
        let containerView: UIView = UIView()
        containerView.addSubviews([
            lhs,
            rhs
        ])
        lhs.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        rhs.layout {
            $0.leading(to: lhs.trailingAnchor, relation: .greaterThanOrEqual,  constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        return containerView
    }

    // From ActivityDetailView
    private func createProviderDetail(imageUrl: String, name: String, description: String) -> UIView {
        let contentView: UIView = UIView()
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.size(92.0)
        }
        imageView.layer.cornerRadius = 14.0
        imageView.loadImage(from: URL(string: imageUrl))
        imageView.clipsToBounds = true
        
        let nameLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        nameLabel.text = name
        
        let descriptionLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 0
        )
        descriptionLabel.text = description
        
        contentView.addSubviews([
            imageView,
            nameLabel,
            descriptionLabel,
        ])
        
        imageView.layout {
            $0.leading(to: contentView.leadingAnchor)
                .top(to: contentView.topAnchor)
                .bottom(to: contentView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        nameLabel.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 10.0)
                .top(to: contentView.topAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        descriptionLabel.layout {
            $0.leading(to: nameLabel.leadingAnchor)
                .top(to: nameLabel.bottomAnchor, constant: 8.0)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        return contentView
    }

    private func createBenefitListView(titles: [String]) -> UIView {
        let stackView: UIStackView = UIStackView()
        stackView.spacing = 12.0
        stackView.axis = .vertical
        
        titles.forEach { title in
            stackView.addArrangedSubview(createBenefitView(title: title))
        }
        
        return stackView
    }

    private func createBenefitView(title: String) -> UIView {
        let contentView: UIView = UIView()
        let benefitImageView: UIImageView = UIImageView(image: CocoIcon.icCheckMarkFill.image)
        benefitImageView.layout {
            $0.size(24.0)
        }
        let benefitLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .regular),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 0
        )
        benefitLabel.text = title
        
        contentView.addSubviews([
            benefitImageView,
            benefitLabel
        ])
        
        benefitImageView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .bottom(to: contentView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        benefitLabel.layout {
            $0.leading(to: benefitImageView.trailingAnchor, constant: 4.0)
                .top(to: contentView.topAnchor)
                .bottom(to: contentView.bottomAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        return contentView
    }
    
    private func createSectionView(title: String, view: UIView) -> UIView {
        let contentView: UIView = UIView()
        let titleLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        titleLabel.text = title
        
        contentView.addSubviews([
            titleLabel,
            view
        ])
        
        titleLabel.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        view.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        return contentView
    }
}
