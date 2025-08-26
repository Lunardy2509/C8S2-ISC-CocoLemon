//
//  EmptyStateView.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 25/08/25.
//

import UIKit

final class EmptyStateView: UIView {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let captionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = Token.grayscale60
        lbl.font = .jakartaSans(forTextStyle: .body, weight: .regular)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var cocoButtonHostingController: CocoButtonHostingController?
    
    private var buttonAction: (() -> Void)?
    
    init(
        image: UIImage?,
        caption: String,
        buttonTitle: String,
        buttonStyle: CocoButtonStyle = .large,
        buttonType: CocoButtonType = .primary,
        action: @escaping () -> Void
    ) {
        super.init(frame: .zero)
        self.buttonAction = action
        
        setupCocoButton(
            title: buttonTitle,
            style: buttonStyle,
            type: buttonType,
            action: action
        )
        
        setupView()
        configureContent(image: image, caption: caption)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCocoButton(
        title: String,
        style: CocoButtonStyle,
        type: CocoButtonType,
        action: @escaping () -> Void
    ) {
        cocoButtonHostingController = CocoButtonHostingController(
            action: action,
            text: title,
            style: style,
            type: type,
            isStretch: false // Set to false for natural button width
        )
    }
    
    private func setupView() {
        guard let cocoButtonHostingController = cocoButtonHostingController else { return }
        
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            captionLabel,
            cocoButtonHostingController.view
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // Stack view constraints
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            // Image view constraints
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            
            // Caption label constraints for better text wrapping
            captionLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
    
    private func configureContent(image: UIImage?, caption: String) {
        imageView.image = image
        captionLabel.text = caption
    }
    
    // MARK: - Public Methods for Dynamic Updates
    
    func updateContent(
        image: UIImage? = nil,
        caption: String? = nil,
        buttonTitle: String? = nil
    ) {
        if let image = image {
            imageView.image = image
        }
        
        if let caption = caption {
            captionLabel.text = caption
        }
        
        // Note: ButtonTitle update would require recreating the hosting controller
        // For simplicity, this is not implemented here but can be added if needed
    }
    
    func updateButtonStyle(
        style: CocoButtonStyle,
        type: CocoButtonType
    ) {
        guard let currentTitle = getCurrentButtonTitle() else { return }
        
        // Remove old button
        cocoButtonHostingController?.view.removeFromSuperview()
        
        // Create new button with updated style
        setupCocoButton(
            title: currentTitle,
            style: style,
            type: type,
            action: buttonAction ?? {}
        )
        
        // Re-setup the view
        setupView()
    }
    
    private func getCurrentButtonTitle() -> String? {
        // This would need to be tracked if dynamic updates are needed
        // For now, return nil or implement a title tracking mechanism
        return nil
    }
}

// MARK: - Convenience Initializers

extension EmptyStateView {
    
    // Convenience initializer with common button styles
    convenience init(
        image: UIImage?,
        caption: String,
        primaryButtonTitle: String,
        action: @escaping () -> Void
    ) {
        self.init(
            image: image,
            caption: caption,
            buttonTitle: primaryButtonTitle,
            buttonStyle: .large,
            buttonType: .primary,
            action: action
        )
    }
    
    convenience init(
        image: UIImage?,
        caption: String,
        secondaryButtonTitle: String,
        action: @escaping () -> Void
    ) {
        self.init(
            image: image,
            caption: caption,
            buttonTitle: secondaryButtonTitle,
            buttonStyle: .large,
            buttonType: .secondary,
            action: action
        )
    }
    
    convenience init(
        image: UIImage?,
        caption: String,
        outlineButtonTitle: String,
        action: @escaping () -> Void
    ) {
        self.init(
            image: image,
            caption: caption,
            buttonTitle: outlineButtonTitle,
            buttonStyle: .small,
            buttonType: .primary,
            action: action
        )
    }
}
