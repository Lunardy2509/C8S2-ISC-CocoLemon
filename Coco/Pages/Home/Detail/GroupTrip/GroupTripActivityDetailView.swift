//
//  GroupTripActivityDetailView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation
import UIKit
import SwiftUI

final class GroupTripActivityDetailView: UIView {
    weak var delegate: GroupTripActivityDetailViewDelegate?
    
    var tripMembers: [TripMember] = [
        TripMember(name: "Adhis", email: "adhis@example.com", profileImageURL: nil, isWaiting: false)
    ]
    
    internal var selectedPackageIds: Set<Int> = []
    private var selectedPackageId: Int?
    
    // Change these from force-unwrapped to optional
    private var activityImageView: UIImageView?
    private var priceRangeLabel: UILabel?
    
    // Store the data temporarily until the views are created
    private var pendingActivityData: ActivityDetailDataModel?
    
    // Move the stored property inside the main class
    private var currentSearchBarViewModel: HomeSearchBarViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ data: ActivityDetailDataModel) {
        print("GroupTripActivityDetailView.configureView called with: \(data.title)")
        // Store the data for later use when views are created
        pendingActivityData = data
        
        // If views are already created, configure them now
        if let titleLabel = self.titleLabel as UILabel?,
           let locationLabel = self.locationLabel as UILabel? {
            titleLabel.text = data.title
            locationLabel.text = data.location
            
            // Load the first image if available and imageView exists
            if let firstImage = data.imageUrlsString.first,
                let url = URL(string: firstImage),
               let imageView = activityImageView {
                imageView.loadImage(from: url)
            }
            
            // Set price range from packages if priceLabel exists
            if !data.availablePackages.content.isEmpty, let priceLabel = priceRangeLabel {
                let prices = data.availablePackages.content.map { $0.price }
                let minPrice = prices.min() ?? ""
                let maxPrice = prices.max() ?? ""
                
                if minPrice == maxPrice {
                    priceLabel.text = "\(minPrice)/Person"
                } else {
                    priceLabel.text = "\(minPrice) - \(maxPrice)/Person"
                }
            }
        } else {
            // If title view doesn't exist yet, we need to update the trip destination section
            // This happens when we have search results and need to show the activity card
            updateTripDestinationWithActivity(data)
        }
        
        // Add sections to content stack view only if not already added
        if contentStackView.arrangedSubviews.isEmpty {
            contentStackView.addArrangedSubview(tripDestinationSection)
            contentStackView.addArrangedSubview(scheduleSection)
            contentStackView.addArrangedSubview(tripMembersSection)
        }
        
        if !data.availablePackages.content.isEmpty {
            if !contentStackView.arrangedSubviews.contains(packageSection) {
                contentStackView.addArrangedSubview(packageSection)
            }
            
            // Clear existing package views
            packageContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if data.availablePackages.content.count == data.hiddenPackages.count {
                packageButton.isHidden = true
                data.availablePackages.content.forEach { packageData in
                    packageContainer.addArrangedSubview(createPackageView(data: packageData))
                }
            } else {
                data.hiddenPackages.forEach { packageData in
                    packageContainer.addArrangedSubview(createPackageView(data: packageData))
                }
            }
            
            packageLabel.text = data.availablePackages.title
        }
        
        packageLabel.isHidden = data.availablePackages.content.isEmpty
    }
    
    func addImageSliderView(with view: UIView) {
        imageSliderView.subviews.forEach { $0.removeFromSuperview() }
        imageSliderView.addSubviewAndLayout(view)
    }
    
    func toggleImageSliderView(isShown: Bool) {
        imageSliderView.isHidden = !isShown
    }
    
    func addCreateTripButton(button: UIView) {
        createTripButtonContainer.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layout {
            $0.top(to: createTripButtonContainer.topAnchor, constant: 16)
                .leading(to: createTripButtonContainer.leadingAnchor, constant: 24)
                .trailing(to: createTripButtonContainer.trailingAnchor, constant: -24)
                .bottom(to: createTripButtonContainer.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        }
    }
    
    func addScheduleInputView(with view: UIView) {
        scheduleInputContainer.subviews.forEach { $0.removeFromSuperview() }
        scheduleInputContainer.addSubviewAndLayout(view)
    }
    
    // MARK: - Lazy Properties
    private lazy var imageSliderView: UIView = UIView()
    private lazy var titleView: UIView = createTitleView()
    internal lazy var titleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title2, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    
    internal lazy var locationLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    
    internal lazy var packageSection: UIView = createPackageSection()
    internal lazy var packageLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    internal lazy var packageButton: UIButton = createPackageTextButton()
    
    internal lazy var packageContainer: UIStackView = createStackView(spacing: 18.0)
    private lazy var contentStackView: UIStackView = createStackView(spacing: 29.0)
    
    private lazy var isPackageButtonStateHidden: Bool = true
    
    private lazy var createTripButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = .init(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var scheduleSection: UIView = createScheduleSection()
    private lazy var scheduleInputContainer: UIView = UIView()
    
    private lazy var tripMembersSection: UIView = createTripMembersSection()
    private lazy var tripMembersContainer: UIView = createTripMembersContainer()
    
    private lazy var tripDestinationSection: UIView = createTripDestinationSection()
}

extension GroupTripActivityDetailView {
    func setupView() {
        let scrollView: UIScrollView = UIScrollView()
        let contentView: UIView = UIView()
        
        let buttonContainer = createTripButtonContainer
        
        addSubview(scrollView)
        addSubview(buttonContainer)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor)
        ])
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        scrollView.addSubviewAndLayout(contentView)
        contentView.layout {
            $0.widthAnchor(to: scrollView.widthAnchor)
        }
        
        contentView.addSubview(contentStackView)
        
        contentStackView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(vertical: 20.0, horizontal: 15.0)
        contentStackView.layer.cornerRadius = 24.0
        contentStackView.backgroundColor = Token.additionalColorsWhite
        
        scrollView.backgroundColor = UIColor.from("#F5F5F5")
        backgroundColor = .white
    }
}

// MARK: - Internal Helper Methods (accessible by extensions)
internal extension GroupTripActivityDetailView {
    func createStackView(
        spacing: CGFloat,
        axis: NSLayoutConstraint.Axis = .vertical
    ) -> UIStackView {
        let stackView: UIStackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = axis
        
        return stackView
    }
    
    func createSectionView(title: String, view: UIView) -> UIView {
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

// MARK: - Private UI Creation Methods
private extension GroupTripActivityDetailView {
    func createTripDestinationSection() -> UIView {
        return createSectionView(title: "Trip Destination", view: titleView)
    }
    
    func createTitleView() -> UIView {
        // Create a card-style container similar to package cards
        let cardContainer = UIView()
        cardContainer.backgroundColor = Token.additionalColorsWhite
        cardContainer.layer.cornerRadius = 16.0
        cardContainer.layer.borderWidth = 1.0
        cardContainer.layer.borderColor = Token.additionalColorsLine.cgColor
        
        // Create horizontal stack view for image and content
        let contentStackView = createStackView(spacing: 12.0, axis: .horizontal)
        
        // Create image view (similar to package image)
        let activityImageView = UIImageView()
        activityImageView.contentMode = .scaleAspectFill
        activityImageView.layout {
            $0.size(92.0)
        }
        activityImageView.layer.cornerRadius = 14.0
        activityImageView.clipsToBounds = true
        activityImageView.backgroundColor = Token.grayscale30
        
        // Create vertical stack for text content
        let textStackView = createStackView(spacing: 8.0)
        
        // Activity title label - increased font size
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .title3, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        
        // Location container with pin icon
        let locationContainer = UIView()
        let pinIcon = UIImageView(image: CocoIcon.icPinPointBlue.image)
        pinIcon.layout {
            $0.size(16.0)
        }
        
        let locationLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption2, weight: .medium),
            textColor: Token.grayscale70,
            numberOfLines: 1
        )
        
        locationContainer.addSubviews([pinIcon, locationLabel])
        
        pinIcon.layout {
            $0.leading(to: locationContainer.leadingAnchor)
                .centerY(to: locationContainer.centerYAnchor)
        }
        
        locationLabel.layout {
            $0.leading(to: pinIcon.trailingAnchor, constant: 4.0)
                .trailing(to: locationContainer.trailingAnchor)
                .centerY(to: locationContainer.centerYAnchor)
                .top(to: locationContainer.topAnchor)
                .bottom(to: locationContainer.bottomAnchor)
        }
        
        // Price range label - increased font size
        let priceLabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption2, weight: .semibold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        
        // Add labels to text stack
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(locationContainer)
        textStackView.addArrangedSubview(priceLabel)
        
        let removeButton = UIButton(type: .system)
        let xmarkImage = UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        )
        removeButton.setImage(xmarkImage, for: .normal)
        removeButton.tintColor = Token.additionalColorsWhite
        removeButton.backgroundColor = Token.grayscale40
        removeButton.layer.cornerRadius = 10.0
        removeButton.layout {
            $0.size(20.0)
        }
        removeButton.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
        
        // Add image and text stack to content stack
        contentStackView.addArrangedSubview(activityImageView)
        contentStackView.addArrangedSubview(textStackView)
        
        // Add content stack and remove button to card
        cardContainer.addSubviews([contentStackView, removeButton])
        
        // Layout content stack with padding
        contentStackView.layout {
            $0.top(to: cardContainer.topAnchor, constant: 12.0)
                .leading(to: cardContainer.leadingAnchor, constant: 12.0)
                .bottom(to: cardContainer.bottomAnchor, constant: -12.0)
                .trailing(to: removeButton.leadingAnchor, constant: -8.0)
        }
        
        // Position remove button exactly on the borderline (top-right corner)
        removeButton.layout {
            $0.top(to: cardContainer.topAnchor, constant: -6.0) // Move it up by half its height
                .trailing(to: cardContainer.trailingAnchor, constant: 6.0) // Move it right by half its width
        }
        
        // Store references for data binding (now as optionals)
        self.titleLabel = titleLabel
        self.locationLabel = locationLabel
        self.activityImageView = activityImageView
        self.priceRangeLabel = priceLabel
        
        // Configure with pending data if available
        if let data = pendingActivityData {
            titleLabel.text = data.title
            locationLabel.text = data.location
            
            // Load the first image if available
            if let firstImage = data.imageUrlsString.first, let url = URL(string: firstImage) {
                activityImageView.loadImage(from: url)
            }
            
            // Set price range from packages
            if !data.availablePackages.content.isEmpty {
                let numericPrices = data.availablePackages.content.compactMap { packageData in
                    let cleanPrice = packageData.price.replacingOccurrences(of: "Rp", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")
                    return Double(cleanPrice)
                }
                
                if let minPrice = numericPrices.min(), let maxPrice = numericPrices.max() {
                    // Format back to currency string
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.groupingSeparator = "."
                    
                    let minPriceString = "Rp\(formatter.string(from: NSNumber(value: minPrice)) ?? "")"
                    let maxPriceString = "Rp\(formatter.string(from: NSNumber(value: maxPrice)) ?? "")"
                    
                    if minPrice == maxPrice {
                        priceLabel.text = "\(minPriceString)/Person"
                    } else {
                        priceLabel.text = "\(minPriceString) - \(maxPriceString)/Person"
                    }
                }
            }
        }
        
        return cardContainer
    }
    
    func createPackageTextButton() -> UIButton {
        let textButton: UIButton = UIButton.textButton(title: "Show All")
        textButton.addTarget(self, action: #selector(didTapTextButton), for: .touchUpInside)
        
        return textButton
    }
    
    @objc func didTapTextButton() {
        isPackageButtonStateHidden.toggle()
        packageButton.setTitle(isPackageButtonStateHidden ? "Show All" : "Show Less", for: .normal)
        delegate?.notifyPackagesButtonDidTap(shouldShowAll: !isPackageButtonStateHidden)
    }
    
    func createScheduleSection() -> UIView {
        return createSectionView(title: "Trip Details", view: scheduleInputContainer)
    }
    
    func createTripMembersSection() -> UIView {
        return createSectionView(title: "Trip Members", view: tripMembersContainer)
    }
    
    func createTripMembersContainer() -> UIView {
        let containerView = UIView()
        
        // Create a collection view for better handling of multiple members
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 70, height: 90)
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.minimumLineSpacing = 16
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TripMemberCell.self, forCellWithReuseIdentifier: "TripMemberCell")
        collectionView.register(AddFriendCell.self, forCellWithReuseIdentifier: "AddFriendCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
        
        containerView.addSubview(collectionView)
        collectionView.layout {
            $0.edges(to: containerView)
                .height(90)
        }
        
        return containerView
    }
}

// Change this method from private to internal so the view controller can access it
extension GroupTripActivityDetailView {
    // Move addTripMember from private extension to public extension
    func addTripMember(name: String, email: String) {
        let newMember = TripMember(name: name, email: email, profileImageURL: nil, isWaiting: true)
        tripMembers.append(newMember)
        
        if let collectionView = tripMembersContainer.subviews.first as? UICollectionView {
            collectionView.reloadData()
        }
    }
    
    // Move these @objc methods inside the class extension
    @objc private func didTapRemoveButton() {
        delegate?.notifyRemoveActivityButtonDidTap()
    }
    
    @objc private func didTapSearchContainer() {
        delegate?.notifySearchActivityTapped()
    }
    
    func showSearchBar() {
        let searchBarContainer = UIView()
        
        // Create search icon
        let searchIconView = UIImageView(image: CocoIcon.icSearchLoop.image)
        searchIconView.tintColor = Token.grayscale60
        searchIconView.contentMode = .scaleAspectFit
        
        // Create placeholder label
        let placeholderLabel = UILabel(
            font: .jakartaSans(forTextStyle: .body, weight: .regular),
            textColor: Token.grayscale60,
            numberOfLines: 1
        )
        placeholderLabel.text = "Search..."
        
        // Add subviews
        searchBarContainer.addSubviews([searchIconView, placeholderLabel])
        
        // Layout
        searchIconView.layout {
            $0.leading(to: searchBarContainer.leadingAnchor, constant: 16.0)
                .centerY(to: searchBarContainer.centerYAnchor)
                .size(20.0)
        }
        
        placeholderLabel.layout {
            $0.leading(to: searchIconView.trailingAnchor, constant: 12.0)
                .centerY(to: searchBarContainer.centerYAnchor)
                .trailing(to: searchBarContainer.trailingAnchor, constant: -16.0)
        }
        
        // Style the container
        searchBarContainer.backgroundColor = Token.grayscale20
        searchBarContainer.layer.cornerRadius = 12.0
        searchBarContainer.layer.borderWidth = 1.0
        searchBarContainer.layer.borderColor = Token.grayscale30.cgColor
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearchContainer))
        searchBarContainer.addGestureRecognizer(tapGesture)
        searchBarContainer.isUserInteractionEnabled = true
        
        // Set height constraint
        searchBarContainer.layout {
            $0.height(56.0)
        }
        
        updateTripDestinationSection(with: searchBarContainer)
    }
    
    func updateTripDestinationWithActivity(_ data: ActivityDetailDataModel) {
        print("Updating trip destination with activity: \(data.title)")
        
        // Create a new title view with the activity data
        let newTitleView = createTitleView()
        
        // The createTitleView method already stores the references to titleLabel, locationLabel, etc.
        // and configures them with pendingActivityData if available, so we're good here
        
        // Replace the current content in the trip destination section
        updateTripDestinationSection(with: newTitleView)
    }
    
    private func updateTripDestinationSection(with newView: UIView) {
        print("Updating trip destination section with new view")
        // Find the trip destination section and update it
        if let sectionView = contentStackView.arrangedSubviews.first {
            print("Found section view, replacing content")
            // The content view to replace is the last subview in the section
            if let existingContentView = sectionView.subviews.last {
                print("Removing existing content view")
                existingContentView.removeFromSuperview()
            }
            
            // Add the new view (activity card or search bar)
            sectionView.addSubview(newView)
            print("Added new view to section")
            
            // Re-apply constraints relative to the title label
            if let titleLabel = sectionView.subviews.first {
                newView.layout {
                    $0.top(to: titleLabel.bottomAnchor, constant: 8.0)
                        .leading(to: sectionView.leadingAnchor)
                        .trailing(to: sectionView.trailingAnchor)
                        .bottom(to: sectionView.bottomAnchor)
                }
                print("Applied constraints to new view")
            }
        } else {
            print("Could not find section view in contentStackView")
        }
    }
}

// Add HomeSearchBarViewModelDelegate conformance
extension GroupTripActivityDetailView: HomeSearchBarViewModelDelegate {
    func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
        delegate?.notifySearchBarTapped(with: viewModel.currentTypedText)
    }
}
