//
//  GroupTripActivityDetailView+Package.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 25/08/25.
//

import Foundation
import UIKit

extension GroupTripActivityDetailView {
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
       
        if !selectedPackageIds.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.refreshPackageViews()
            }
        }
    }
    
    func setSelectedPackages(ids: Set<Int>) {
        selectedPackageIds = ids
        refreshPackageViews()
    }
    
    func getSelectedPackageIds() -> Set<Int> {
        return selectedPackageIds
    }
}

// MARK: - Package Creation and Styling
internal extension GroupTripActivityDetailView {
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
        
        // Create checkbox instead of radio button
        let checkboxButton = UIButton(type: .custom)
        checkboxButton.layout {
            $0.size(24.0)
        }
        
        // Set initial state based on multiple selection
        let isSelected = selectedPackageIds.contains(data.id)
        updateCheckboxButton(checkboxButton, isSelected: isSelected)
        
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
        
        let contentContainer = UIView()
        contentContainer.addSubviews([contentStackView, checkboxButton])
        
        // Layout content stack view (name, capacity, price)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(capacityLabel)
        contentStackView.addArrangedSubview(priceLabel)
        
        contentStackView.layout {
            $0.leading(to: contentContainer.leadingAnchor)
                .top(to: contentContainer.topAnchor)
                .bottom(to: contentContainer.bottomAnchor)
                .trailing(to: checkboxButton.leadingAnchor, constant: -12.0)
        }
   
        checkboxButton.layout {
            $0.trailing(to: contentContainer.trailingAnchor)
                .centerY(to: capacityLabel.centerYAnchor)
        }
        
        checkboxButton.setContentHuggingPriority(.required, for: .horizontal)
        checkboxButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(contentContainer)
        
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
    
    func updateCheckboxButton(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            button.tintColor = Token.mainColorPrimary
        } else {
            button.setImage(UIImage(systemName: "circle"), for: .normal)
            button.tintColor = Token.grayscale40
        }
    }
    
    func updateContainerStyling(_ container: UIStackView, isSelected: Bool) {
        if isSelected {
            container.layer.borderWidth = 2.0
            container.layer.borderColor = Token.mainColorPrimary.cgColor
            container.backgroundColor = Token.additionalColorsWhite
        } else {
            container.layer.borderWidth = 1.0
            container.layer.borderColor = Token.additionalColorsLine.cgColor
            container.backgroundColor = Token.additionalColorsWhite
        }
    }
    
    @objc func packageViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let containerView = gesture.view as? UIStackView else { return }
        let packageId = containerView.tag
    
        // Toggle selection instead of single selection
        if selectedPackageIds.contains(packageId) {
            selectedPackageIds.remove(packageId)
        } else {
            selectedPackageIds.insert(packageId)
        }
        
        // Refresh all package views to update their appearance
        refreshPackageViews()
        
        // Notify delegate with the package ID and current selection state
        delegate?.notifyPackagesDetailDidTap(with: packageId)
    }
    
    func refreshPackageViews() {
        // Refresh all package container views
        for subview in packageContainer.arrangedSubviews {
            guard let containerStack = subview as? UIStackView else { continue }
            
            let packageId = containerStack.tag
            let isSelected = selectedPackageIds.contains(packageId)
            
            // Update container styling
            updateContainerStyling(containerStack, isSelected: isSelected)
            
            // Find and update checkbox button
            if let contentContainer = containerStack.arrangedSubviews.last as? UIView,
               let checkboxButton = contentContainer.subviews.compactMap({ $0 as? UIButton }).first {
                updateCheckboxButton(checkboxButton, isSelected: isSelected)
            }
        }
    }
}