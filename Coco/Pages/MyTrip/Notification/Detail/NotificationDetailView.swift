//
//  NotificationDetail.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 25/08/25.
//

import UIKit
import Foundation
import SwiftUI

protocol NotificationDetailViewDelegate: AnyObject {
    func notificationDetailViewDidTapAccept()
    func notificationDetailViewDidTapDecline()
}

final class NotificationDetailView: UIView {
    
    // MARK: - Properties
    weak var delegate: NotificationDetailViewDelegate?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.tintColor = Token.grayscale70
        imageView.backgroundColor = Token.grayscale20
        return imageView
    }()
    
    private let senderLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .body, weight: .semibold)
        label.textColor = Token.additionalColorsBlack
        label.numberOfLines = 1
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        label.textColor = Token.grayscale70
        label.numberOfLines = 1
        return label
    }()
    
    private let tripNameLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let calendarIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Token.mainColorPrimary
        return imageView
    }()
    
    private lazy var tripInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calendarIcon, tripNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var acceptButton: CocoButtonHostingController = {
        CocoButtonHostingController(
            action: { [weak self] in
                self?.acceptButtonTapped()
            },
            text: "Accept",
            style: .normal,
            type: .primary
        )
    }()
    
    private lazy var declineButton: CocoButtonHostingController = {
        CocoButtonHostingController(
            action: { [weak self] in
                self?.declineButtonTapped()
            },
            text: "Decline",
            style: .normal,
            type: .secondary
        )
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            acceptButton.view,
            declineButton.view
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            avatarImageView,
            senderLabel,
            messageLabel,
            tripInfoStackView,
            buttonStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with notification: NotificationItem) {
        avatarImageView.image = notification.avatarImage.image
        senderLabel.text = notification.senderName
        messageLabel.text = notification.message
        tripNameLabel.text = notification.tripName
    }
    
    func addButtonsToParent(_ parentViewController: UIViewController) {
        parentViewController.addChild(acceptButton)
        parentViewController.addChild(declineButton)
        acceptButton.didMove(toParent: parentViewController)
        declineButton.didMove(toParent: parentViewController)
    }
}

// MARK: - Private Methods
private extension NotificationDetailView {
    
    func setupView() {
        backgroundColor = .systemBackground
        setupScrollView()
        addSubviews()
        setupConstraints()
    }
    
    func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
    }
    
    func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(mainStackView)
    }
    
    func setupConstraints() {
        // Disable autoresizing masks
        [scrollView, containerView, mainStackView, tripInfoStackView, buttonStackView]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            // Main stack view constraints
            mainStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            mainStackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 32),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -32),
            mainStackView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 32),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -32),
            
            // Avatar constraints
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Trip info stack constraints
            tripInfoStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // Button stack constraints
            buttonStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            buttonStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Calendar icon constraints
            calendarIcon.widthAnchor.constraint(equalToConstant: 16),
            calendarIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    @objc func acceptButtonTapped() {
        delegate?.notificationDetailViewDidTapAccept()
    }
    
    @objc func declineButtonTapped() {
        delegate?.notificationDetailViewDidTapDecline()
    }
}
