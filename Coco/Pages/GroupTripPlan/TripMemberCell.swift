//
//  TripMemberCell.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 26/08/25.
//

import UIKit

final class TripMemberCell: UICollectionViewCell {
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.backgroundColor = Token.grayscale30
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .caption2, weight: .medium)
        label.textColor = Token.additionalColorsBlack
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with member: TripMember) {
        nameLabel.text = member.name
        
        // Configure profile image
        if let image = member.image {
            profileImageView.image = image.image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = Token.grayscale50
        }
        
        // Configure waiting status
        if member.isWaiting {
            statusIndicator.isHidden = false
            statusIndicator.backgroundColor = Token.additionalColorsBlack
        } else {
            statusIndicator.isHidden = true
        }
    }
    
    private func setupView() {
        contentView.addSubviews([profileImageView, nameLabel, statusIndicator])
        
        profileImageView.layout {
            $0.top(to: contentView.topAnchor)
                .centerX(to: contentView.centerXAnchor)
                .size(60)
        }
        
        nameLabel.layout {
            $0.top(to: profileImageView.bottomAnchor, constant: 8)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        statusIndicator.layout {
            $0.top(to: profileImageView.topAnchor, constant: -3)
                .trailing(to: profileImageView.trailingAnchor, constant: 3)
                .size(12)
        }
    }
}
