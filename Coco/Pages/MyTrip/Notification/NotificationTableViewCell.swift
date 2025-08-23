//
//  NotificationTableViewCell.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 22/08/25.
//

import UIKit

final class NotificationTableViewCell: UITableViewCell {
    static let identifier = "NotificationTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with notification: NotificationItem) {
        avatarImageView.image = UIImage(systemName: notification.avatarImageName) ?? UIImage()
        senderNameLabel.text = notification.senderName
        messageLabel.text = notification.message
        tripNameLabel.text = notification.tripName
        unreadIndicator.isHidden = !notification.isUnread
    }
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.tintColor = Token.grayscale70
        imageView.backgroundColor = Token.grayscale20
        return imageView
    }()
    
    private lazy var unreadIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = Token.mainColorPrimary
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var senderNameLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .body, weight: .semibold)
        label.textColor = Token.additionalColorsBlack
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .regular)
        label.textColor = Token.grayscale70
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var tripNameLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        label.textColor = Token.mainColorPrimary
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var calendarIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar") ?? UIImage()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Token.mainColorPrimary
        return imageView
    }()
}

private extension NotificationTableViewCell {
    func setupView() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        let messageStackView = UIStackView(arrangedSubviews: [senderNameLabel, messageLabel])
        messageStackView.axis = .horizontal
        messageStackView.spacing = 4
        messageStackView.alignment = .center
        
        let tripStackView = UIStackView(arrangedSubviews: [calendarIcon, tripNameLabel])
        tripStackView.axis = .horizontal
        tripStackView.spacing = 4
        tripStackView.alignment = .center
        
        let contentStackView = UIStackView(arrangedSubviews: [messageStackView, tripStackView])
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        contentStackView.alignment = .leading
        
        contentView.addSubviews([
            avatarImageView,
            contentStackView,
            unreadIndicator
        ])
        
        avatarImageView.layout {
            $0.leading(to: contentView.leadingAnchor, constant: 16)
                .centerY(to: contentView.centerYAnchor)
                .size(40)
        }
        
        contentStackView.layout {
            $0.leading(to: avatarImageView.trailingAnchor, constant: 12)
                .centerY(to: contentView.centerYAnchor)
                .trailing(to: unreadIndicator.leadingAnchor, constant: -12)
        }
        
        unreadIndicator.layout {
            $0.trailing(to: contentView.trailingAnchor, constant: -16)
                .centerY(to: contentView.centerYAnchor)
                .size(8)
        }
        
        calendarIcon.layout {
            $0.size(12)
        }
        
        // Set content compression resistance
        senderNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tripNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}
