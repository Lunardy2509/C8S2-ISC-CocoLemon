//
//  GroupTripPlanView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 26/08/25.
//

import Foundation
import UIKit

protocol GroupTripPlanViewDelegate: AnyObject {
    func notifyBookNowTapped()
}

final class GroupTripPlanView: UIView {
    weak var delegate: GroupTripPlanViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ data: GroupTripPlanDataModel) {
        // Configure activity section
        activityImageView.loadImage(from: URL(string: data.activity.imageUrl))
        activityTitleLabel.text = data.activity.title
        activityLocationLabel.text = data.activity.location
        activityPriceLabel.text = data.activity.priceRange
        
        // Configure trip details
        statusLabel.updateTitle(data.tripDetails.status.text)
        statusLabel.updateStyle(data.tripDetails.status.style)
        personCountLabel.text = "\(data.tripDetails.personCount)"
        dateVisitLabel.text = data.tripDetails.dateVisit
        dueDateFormLabel.text = data.tripDetails.dueDateForm
        
        // Configure trip members
        setupTripMembers(data.tripMembers)
        
        // Configure packages
        setupAvailablePackages(data.selectedPackages)
    }
    
    func addBookNowButton(button: UIView) {
        bookNowButtonContainer.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layout {
            $0.top(to: bookNowButtonContainer.topAnchor, constant: 16)
                .leading(to: bookNowButtonContainer.leadingAnchor, constant: 24)
                .trailing(to: bookNowButtonContainer.trailingAnchor, constant: -24)
                .bottom(to: bookNowButtonContainer.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        }
    }
    
    // MARK: - UI Components
    private lazy var contentStackView: UIStackView = createStackView(spacing: 24.0)
    
    // Activity Section
    private lazy var activitySection: UIView = createActivitySection()
    private lazy var activityImageView: UIImageView = UIImageView()
    private lazy var activityTitleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title3, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var activityLocationLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 1
    )
    private lazy var activityPriceLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .semibold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
    
    // Trip Details Section
    private lazy var tripDetailSection: UIView = createTripDetailSection()
    private lazy var statusLabel: CocoStatusLabelHostingController = CocoStatusLabelHostingController(title: "", style: .success)
    private lazy var personCountLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
    private lazy var dateVisitLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
    private lazy var dueDateFormLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .medium),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 1
    )
    
    // Trip Members Section
    private lazy var tripMembersSection: UIView = createTripMembersSection()
    private lazy var tripMembersContainer: UIView = UIView()
    
    // Available Packages Section
    private lazy var availablePackagesSection: UIView = createAvailablePackagesSection()
    private lazy var packagesContainer: UIStackView = createStackView(spacing: 12.0)
    
    // Book Now Button Container
    private lazy var bookNowButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .init(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
}

// MARK: - Setup Methods
private extension GroupTripPlanView {
    func setupView() {
        backgroundColor = Token.additionalColorsWhite
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        
        addSubview(scrollView)
        addSubview(bookNowButtonContainer)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bookNowButtonContainer.topAnchor)
        ])
        
        bookNowButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bookNowButtonContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bookNowButtonContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bookNowButtonContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        scrollView.addSubviewAndLayout(contentView)
        contentView.layout {
            $0.widthAnchor(to: scrollView.widthAnchor)
        }
        
        contentView.addSubview(contentStackView)
        contentStackView.layout {
            $0.top(to: contentView.topAnchor, constant: 20.0)
                .leading(to: contentView.leadingAnchor, constant: 24.0)
                .trailing(to: contentView.trailingAnchor, constant: -24.0)
                .bottom(to: contentView.bottomAnchor, constant: -24.0)
        }
        
        // Add sections to stack view
        contentStackView.addArrangedSubview(activitySection)
        contentStackView.addArrangedSubview(tripDetailSection)
        contentStackView.addArrangedSubview(tripMembersSection)
        contentStackView.addArrangedSubview(availablePackagesSection)
    }
    
    func createStackView(spacing: CGFloat, axis: NSLayoutConstraint.Axis = .vertical) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    
    func createSectionView(title: String, view: UIView) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .title3, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        titleLabel.text = title
        
        containerView.addSubviews([titleLabel, view])
        
        titleLabel.layout {
            $0.top(to: containerView.topAnchor)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
        }
        
        view.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 16.0)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        return containerView
    }
}

// MARK: - Section Creation Methods
private extension GroupTripPlanView {
    func createActivitySection() -> UIView {
        let cardContainer = UIView()
        cardContainer.backgroundColor = Token.additionalColorsWhite
        cardContainer.layer.cornerRadius = 16.0
        cardContainer.layer.borderWidth = 1.0
        cardContainer.layer.borderColor = Token.additionalColorsLine.cgColor
        
        let contentStackView = createStackView(spacing: 12.0, axis: .horizontal)
        
        activityImageView.contentMode = .scaleAspectFill
        activityImageView.layout {
            $0.size(92.0)
        }
        activityImageView.layer.cornerRadius = 14.0
        activityImageView.clipsToBounds = true
        activityImageView.backgroundColor = Token.grayscale30
        
        let textStackView = createStackView(spacing: 6.0)
        
        let locationContainer = UIView()
        let pinIcon = UIImageView(image: CocoIcon.icPinPointBlue.image)
        pinIcon.layout { $0.size(16.0) }
        
        locationContainer.addSubviews([pinIcon, activityLocationLabel])
        
        pinIcon.layout {
            $0.leading(to: locationContainer.leadingAnchor)
                .centerY(to: locationContainer.centerYAnchor)
        }
        
        activityLocationLabel.layout {
            $0.leading(to: pinIcon.trailingAnchor, constant: 4.0)
                .trailing(to: locationContainer.trailingAnchor)
                .centerY(to: locationContainer.centerYAnchor)
                .top(to: locationContainer.topAnchor)
                .bottom(to: locationContainer.bottomAnchor)
        }
        
        textStackView.addArrangedSubview(activityTitleLabel)
        textStackView.addArrangedSubview(locationContainer)
        textStackView.addArrangedSubview(activityPriceLabel)
        
        contentStackView.addArrangedSubview(activityImageView)
        contentStackView.addArrangedSubview(textStackView)
        
        cardContainer.addSubview(contentStackView)
        contentStackView.layout {
            $0.top(to: cardContainer.topAnchor, constant: 12.0)
                .leading(to: cardContainer.leadingAnchor, constant: 12.0)
                .trailing(to: cardContainer.trailingAnchor, constant: -12.0)
                .bottom(to: cardContainer.bottomAnchor, constant: -12.0)
        }
        
        return cardContainer
    }
    
    func createTripDetailSection() -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .title3, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        titleLabel.text = "Trip detail"
        
        let detailsStackView = createStackView(spacing: 16.0)
        
        // Status row
        let statusRow = createDetailRow(
            icon: CocoIcon.icCheckMarkFill.image,
            label: "Status",
            valueView: statusLabel.view
        )
        
        // Person row
        let personRow = createDetailRow(
            icon: CocoIcon.icuserIcon.image,
            label: "Person",
            valueView: personCountLabel
        )
        
        // Date Visit row
        let dateVisitRow = createDetailRow(
            icon: CocoIcon.icCalendarIcon.image,
            label: "Date Visit",
            valueView: dateVisitLabel
        )
        
        // Due Date Form row
        let dueDateFormRow = createDetailRow(
            icon: CocoIcon.icCalendarIcon.image,
            label: "Due Date Form",
            valueView: dueDateFormLabel
        )
        
        detailsStackView.addArrangedSubview(statusRow)
        detailsStackView.addArrangedSubview(personRow)
        detailsStackView.addArrangedSubview(dateVisitRow)
        detailsStackView.addArrangedSubview(dueDateFormRow)
        
        containerView.addSubviews([titleLabel, detailsStackView])
        
        titleLabel.layout {
            $0.top(to: containerView.topAnchor)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
        }
        
        detailsStackView.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 16.0)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        return containerView
    }
    
    func createDetailRow(icon: UIImage?, label: String, valueView: UIView) -> UIView {
        let rowView = UIView()
        
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = Token.grayscale70
        iconView.layout { $0.size(20.0) }
        
        let labelView = UILabel(
            font: .jakartaSans(forTextStyle: .body, weight: .medium),
            textColor: Token.grayscale70,
            numberOfLines: 1
        )
        labelView.text = label
        
        rowView.addSubviews([iconView, labelView, valueView])
        
        iconView.layout {
            $0.leading(to: rowView.leadingAnchor)
                .centerY(to: rowView.centerYAnchor)
        }
        
        labelView.layout {
            $0.leading(to: iconView.trailingAnchor, constant: 12.0)
                .centerY(to: rowView.centerYAnchor)
        }
        
        valueView.layout {
            $0.trailing(to: rowView.trailingAnchor)
                .centerY(to: rowView.centerYAnchor)
                .top(to: rowView.topAnchor)
                .bottom(to: rowView.bottomAnchor)
        }
        
        return rowView
    }
    
    func createTripMembersSection() -> UIView {
        return createSectionView(title: "Trip Members", view: tripMembersContainer)
    }
    
    func createAvailablePackagesSection() -> UIView {
        return createSectionView(title: "Available Packages", view: packagesContainer)
    }
}

// MARK: - Data Configuration Methods
private extension GroupTripPlanView {
    func setupTripMembers(_ members: [TripMember]) {
        tripMembersContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 70, height: 90)
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.minimumLineSpacing = 16
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TripMemberCell.self, forCellWithReuseIdentifier: "TripMemberCell")
        
        tripMembersContainer.addSubview(collectionView)
        collectionView.layout {
            $0.edges(to: tripMembersContainer)
                .height(90)
        }
        
        // Configure collection view with members data
        // You'll need to implement the data source methods
    }
    
    func setupAvailablePackages(_ packages: [ActivityDetailDataModel.Package]) {
        packagesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for package in packages {
            let packageView = createPackageView(data: package)
            packagesContainer.addArrangedSubview(packageView)
        }
    }
    
    func createPackageView(data: ActivityDetailDataModel.Package) -> UIView {
        let containerStackView = createStackView(spacing: 12.0, axis: .horizontal)
        let contentStackView = createStackView(spacing: 8.0)
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout { $0.size(92.0) }
        imageView.layer.cornerRadius = 14.0
        imageView.clipsToBounds = true
        imageView.loadImage(from: URL(string: data.imageUrlString))
        
        let nameLabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 2
        )
        nameLabel.text = data.name
        
        let descriptionLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 2
        )
        descriptionLabel.text = ""
        
        let priceLabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .semibold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        priceLabel.text = data.price
        
        let minMaxLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption2, weight: .medium),
            textColor: Token.grayscale70,
            numberOfLines: 1
        )
        minMaxLabel.text = data.description
        
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(priceLabel)
        contentStackView.addArrangedSubview(minMaxLabel)
        
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(contentStackView)
        
        let cardContainer = UIView()
        cardContainer.backgroundColor = Token.additionalColorsWhite
        cardContainer.layer.cornerRadius = 16.0
        cardContainer.layer.borderWidth = 1.0
        cardContainer.layer.borderColor = Token.additionalColorsLine.cgColor
        
        cardContainer.addSubview(containerStackView)
        containerStackView.layout {
            $0.top(to: cardContainer.topAnchor, constant: 12.0)
                .leading(to: cardContainer.leadingAnchor, constant: 12.0)
                .trailing(to: cardContainer.trailingAnchor, constant: -12.0)
                .bottom(to: cardContainer.bottomAnchor, constant: -12.0)
        }
        
        return cardContainer
    }
}
