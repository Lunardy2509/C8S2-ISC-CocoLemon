//
//  GroupTripActivityDetailView.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 21/08/25.
//

import Foundation
import UIKit

protocol GroupTripActivityDetailViewDelegate: AnyObject {
    func notifyPackagesButtonDidTap(shouldShowAll: Bool)
    func notifyPackagesDetailDidTap(with packageId: Int)
    func notifyAddFriendButtonDidTap() // Add this new method
}

struct TripMember {
    let name: String
    let email: String
    let profileImageURL: String?
    let isWaiting: Bool
    
    init(name: String, email: String, profileImageURL: String? = nil, isWaiting: Bool = false) {
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.isWaiting = isWaiting
    }
}

final class GroupTripActivityDetailView: UIView {
    weak var delegate: GroupTripActivityDetailViewDelegate?
    
    private var tripMembers: [TripMember] = [
        TripMember(name: "Adhis", email: "adhis@example.com", profileImageURL: nil, isWaiting: false)
    ]
    
    private var selectedPackageId: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ data: ActivityDetailDataModel) {
        titleLabel.text = data.title
        locationLabel.text = data.location
        contentStackView.addArrangedSubview(scheduleSection)
        contentStackView.addArrangedSubview(tripMembersSection)
        
        if !data.availablePackages.content.isEmpty {
            contentStackView.addArrangedSubview(packageSection)
            
            if data.availablePackages.content.count == data.hiddenPackages.count {
                packageButton.isHidden = true
                data.availablePackages.content.forEach { data in
                    packageContainer.addArrangedSubview(createPackageView(data: data))
                }
            }
            else {
                data.hiddenPackages.forEach { data in
                    packageContainer.addArrangedSubview(createPackageView(data: data))
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
    
    func updatePackageData(_ data: [ActivityDetailDataModel.Package]) {
        packageContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, item) in data.enumerated() {
            let view: UIView = createPackageView(data: item)
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 8)
            packageContainer.addArrangedSubview(view)

            UIView.animate(
                withDuration: 0.3,
                delay: 0.05 * Double(index),
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut],
                animations: {
                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
       
        if selectedPackageId != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.refreshPackageViews()
            }
        }
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
    
    private lazy var imageSliderView: UIView = UIView()
    private lazy var titleView: UIView = createTitleView()
    private lazy var titleLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title2, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    
    private lazy var locationLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    
    private lazy var packageSection: UIView = createPackageSection()
    private lazy var packageLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var packageButton: UIButton = createPackageTextButton()
    
    private lazy var packageContainer: UIStackView = createStackView(spacing: 18.0)
    private lazy var contentStackView: UIStackView = createStackView(spacing: 29.0)
    private lazy var headerStackView: UIStackView = createStackView(spacing: 0)
    
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
        
        contentView.addSubviews([
            headerStackView,
            contentStackView
        ])
        
        headerStackView.backgroundColor = UIColor.from("#F5F5F5")
        headerStackView.addArrangedSubview(imageSliderView)
        headerStackView.addArrangedSubview(titleView)
        
        headerStackView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        contentStackView.layout {
            $0.top(to: headerStackView.bottomAnchor, constant: -8.0)
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
        
        imageSliderView.isHidden = true
    }
}

private extension GroupTripActivityDetailView {
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
    
    func createIconTextView(image: UIImage, text: String) -> UIView {
        let imageView: UIImageView = UIImageView(image: image)
        imageView.layout {
            $0.size(20.0)
        }
        
        let label: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
            textColor: Token.grayscale90,
            numberOfLines: 2
        )
        label.text = text
        
        let containerView: UIView = UIView()
        containerView.addSubviews([
            imageView,
            label
        ])
        
        imageView.layout {
            $0.leading(to: containerView.leadingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        label.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        return containerView
    }
    
    func createTitleView() -> UIView {
        let pinPointImage: UIImageView = UIImageView(image: CocoIcon.icPinPointBlue.image)
        pinPointImage.layout {
            $0.size(20.0)
        }
        
        let locationView: UIView = UIView()
        locationView.addSubviews([
            pinPointImage,
            locationLabel
        ])
        
        pinPointImage.layout {
            $0.leading(to: locationView.leadingAnchor)
                .bottom(to: locationView.bottomAnchor)
                .top(to: locationView.topAnchor)
        }
        
        locationLabel.layout {
            $0.leading(to: pinPointImage.trailingAnchor, constant: 4.0)
                .trailing(to: locationView.trailingAnchor)
                .centerY(to: locationView.centerYAnchor)
        }
        
        let contentView: UIView = UIView()
        contentView.addSubviews([
            titleLabel,
            locationView
        ])
        
        titleLabel.layout {
            $0.leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .top(to: contentView.topAnchor)
        }
        
        locationView.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        let contentWrapperView: UIView = UIView()
        contentWrapperView.addSubviewAndLayout(
            contentView,
            insets: .init(
                top: 16.0,
                left: 24.0,
                bottom: 16.0 + 8.0,
                right: 16.0
            )
        )
        
        return contentWrapperView
    }
    
    func createBenefitView(title: String) -> UIView {
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
    
    func createBenefitListView(titles: [String]) -> UIView {
        let stackView: UIStackView = createStackView(spacing: 12.0)
        
        titles.forEach { title in
            stackView.addArrangedSubview(createBenefitView(title: title))
        }
        
        return stackView
    }
    
    func createProviderDetail(imageUrl: String, name: String, description: String) -> UIView {
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
            descriptionLabel
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
    
    func createPackageView(data: ActivityDetailDataModel.Package) -> UIView {
        let containerStackView: UIStackView = createStackView(spacing: 12.0, axis: .horizontal)
        let contentStackView: UIStackView = createStackView(spacing: 8.0)
        
        let nameLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 0
        )
        nameLabel.text = data.name
        
        let capacityLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .caption1, weight: .medium),
            textColor: Token.grayscale70,
            numberOfLines: 1
        )
        capacityLabel.text = data.description
        
        let priceLabel: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .subheadline, weight: .semibold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.size(92.0)
        }
        imageView.layer.cornerRadius = 14.0
        imageView.loadImage(from: URL(string: data.imageUrlString))
        imageView.clipsToBounds = true
        
        // Create radio button
        let radioButton = UIButton(type: .custom)
        radioButton.layout {
            $0.size(24.0)
        }
        
        // Set initial state
        let isSelected = selectedPackageId == data.id
        updateRadioButton(radioButton, isSelected: isSelected)
        
        // Add tap gesture to the entire container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(packageViewTapped(_:)))
        containerStackView.addGestureRecognizer(tapGesture)
        containerStackView.isUserInteractionEnabled = true
        containerStackView.tag = data.id
        
        // Price formatting
        let attributedString = NSMutableAttributedString()
        
        let priceString = NSAttributedString(
            string: data.price,
            attributes: [
                .font : UIFont.jakartaSans(forTextStyle: .subheadline, weight: .semibold),
                .foregroundColor : Token.additionalColorsBlack
            ]
        )
        
        let perPersonString = NSAttributedString(
            string: "/Person",
            attributes: [
                .font : UIFont.jakartaSans(forTextStyle: .subheadline, weight: .medium),
                .foregroundColor : Token.grayscale60
            ]
        )
        
        attributedString.append(priceString)
        attributedString.append(perPersonString)
        priceLabel.attributedText = attributedString
        
        // Create content container with radio button positioned relative to capacity label
        let contentContainer = UIView()
        contentContainer.addSubviews([contentStackView, radioButton])
        
        // Layout content stack view (name, capacity, price)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(capacityLabel) // Capacity above price
        contentStackView.addArrangedSubview(priceLabel)   // Price below capacity
        
        contentStackView.layout {
            $0.leading(to: contentContainer.leadingAnchor)
                .top(to: contentContainer.topAnchor)
                .bottom(to: contentContainer.bottomAnchor)
                .trailing(to: radioButton.leadingAnchor, constant: -12.0) // Leave space for radio button
        }
        
        // Position radio button aligned with capacity label (middle element)
        radioButton.layout {
            $0.trailing(to: contentContainer.trailingAnchor)
                .centerY(to: capacityLabel.centerYAnchor) // Align with capacity label instead of content container
        }
        
        radioButton.setContentHuggingPriority(.required, for: .horizontal)
        radioButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // Add image and content to main container
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(contentContainer)
        
        // Set container styling based on selection
        updateContainerStyling(containerStackView, isSelected: isSelected)
        
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = .init(edges: 12.0)
        containerStackView.layer.cornerRadius = 16.0
        
        return containerStackView
    }
    
    func createPackageSection() -> UIView {
        let containerView: UIView = UIView()
        containerView.addSubviews([
            packageLabel,
            packageButton
        ])
        
        packageButton.setContentHuggingPriority(.required, for: .horizontal)
        packageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        packageLabel.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        packageButton.layout {
            $0.leading(to: packageLabel.trailingAnchor, constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        let contentView: UIView = UIView()
        contentView.addSubviews([
            containerView,
            packageContainer
        ])
        
        containerView.layout {
            $0.top(to: contentView.topAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        packageContainer.layout {
            $0.top(to: containerView.bottomAnchor, constant: 16.0)
                .bottom(to: contentView.bottomAnchor)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        return contentView
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
        
        containerView.addSubview(collectionView)
        collectionView.layout {
            $0.top(to: containerView.topAnchor)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
                .bottom(to: containerView.bottomAnchor)
                .height(90)
        }
        
        return containerView
    }
  
    public func addTripMember(name: String, email: String) {
        let newMember = TripMember(name: name, email: email, profileImageURL: nil, isWaiting: true)
        tripMembers.append(newMember)
        
        if let collectionView = tripMembersContainer.subviews.first as? UICollectionView {
            collectionView.reloadData()
        }
    }
    
    func setSelectedPackage(id: Int?) {
        selectedPackageId = id
        refreshPackageViews()
    }
}

extension GroupTripActivityDetailView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripMembers.count + 1 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < tripMembers.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripMemberCell", for: indexPath) as? TripMemberCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: tripMembers[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddFriendCell", for: indexPath) as? AddFriendCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= tripMembers.count {
            delegate?.notifyAddFriendButtonDidTap()
        }
    }
}

private extension GroupTripActivityDetailView {
    func updateRadioButton(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            // Selected state - filled circle with checkmark
            button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            button.tintColor = Token.mainColorPrimary
        } else {
            // Unselected state - empty circle
            button.setImage(UIImage(systemName: "circle"), for: .normal)
            button.tintColor = Token.grayscale40
        }
    }
    
    func updateContainerStyling(_ container: UIStackView, isSelected: Bool) {
        if isSelected {
            // Selected state - blue border and background
            container.layer.borderWidth = 2.0
            container.layer.borderColor = Token.mainColorPrimary.cgColor
            container.backgroundColor = Token.mainColorPrimary.withAlphaComponent(0.1)
        } else {
            // Unselected state - gray background
            container.layer.borderWidth = 0.0
            container.layer.borderColor = UIColor.clear.cgColor
            container.backgroundColor = Token.mainColorForth
        }
    }
    
    @objc func packageViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let containerView = gesture.view as? UIStackView else { return }
        let packageId = containerView.tag
        
        // Update selected package
        selectedPackageId = packageId
        
        // Refresh all package views to update their appearance
        refreshPackageViews()
        
        // Notify delegate
        delegate?.notifyPackagesDetailDidTap(with: packageId)
    }
    
    func refreshPackageViews() {
        // Refresh all package container views
        for subview in packageContainer.arrangedSubviews {
            guard let containerStack = subview as? UIStackView else { continue }
            
            let packageId = containerStack.tag
            let isSelected = selectedPackageId == packageId
            
            // Update container styling
            updateContainerStyling(containerStack, isSelected: isSelected)
            
            // Find and update radio button - adjusted for new structure
            if let contentContainer = containerStack.arrangedSubviews.last as? UIView,
               let radioButton = contentContainer.subviews.compactMap({ $0 as? UIButton }).first {
                updateRadioButton(radioButton, isSelected: isSelected)
            }
        }
    }
}
