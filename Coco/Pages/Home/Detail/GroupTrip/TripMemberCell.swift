//
//  TripMemberCell.swift
//  Coco
//
//  Created by Teuku Fazariz Basya on 24/08/25.
//

import UIKit

class TripMemberCell: UICollectionViewCell {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let waitingOverlay = UIView()
    private let waitingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Profile image
        profileImageView.backgroundColor = Token.grayscale30
        profileImageView.layer.cornerRadius = 25.0
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // Name label
        nameLabel.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        nameLabel.textColor = Token.additionalColorsBlack
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        
        // Waiting overlay
        waitingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        waitingOverlay.layer.cornerRadius = 25.0
        waitingOverlay.isHidden = true
        
        // Waiting label
        waitingLabel.text = "Waiting.."
        waitingLabel.font = .jakartaSans(forTextStyle: .caption2, weight: .medium)
        waitingLabel.textColor = .white
        waitingLabel.textAlignment = .center
        
        // Add subviews
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        profileImageView.addSubview(waitingOverlay)
        waitingOverlay.addSubview(waitingLabel)
        
        // Layout
        profileImageView.layout {
            $0.top(to: contentView.topAnchor)
                .centerX(to: contentView.centerXAnchor)
                .size(50.0)
        }
        
        nameLabel.layout {
            $0.top(to: profileImageView.bottomAnchor, constant: 8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        waitingOverlay.layout {
            $0.edges(to: profileImageView)
        }
        
        waitingLabel.layout {
            $0.centerX(to: waitingOverlay.centerXAnchor)
                .centerY(to: waitingOverlay.centerYAnchor)
        }
    }
    
    func configure(with member: TripMember) {
        nameLabel.text = member.name
        
        if let imageURL = member.profileImageURL {
            profileImageView.loadImage(from: URL(string: imageURL))
        } else {
            if member.name.lowercased() == "adhis" {
                profileImageView.image = UIImage(named: "adhis")
            } else {
                profileImageView.image = generateDummyProfile(for: member.name)
            }
        }
        
        waitingOverlay.isHidden = !member.isWaiting
    }
    
    private func generateDummyProfile(for name: String) -> UIImage? {
        // Generate different dummy images based on name
        let dummyImages = [
            "https://picsum.photos/seed/user1/100/100",
            "https://picsum.photos/seed/user2/100/100",
            "https://picsum.photos/seed/user3/100/100",
            "https://picsum.photos/seed/user4/100/100"
        ]
        
        let index = abs(name.hashValue) % dummyImages.count
        profileImageView.loadImage(from: URL(string: dummyImages[index]))
        return nil
    }
}

class AddFriendCell: UICollectionViewCell {
    private let addButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addButton.backgroundColor = Token.mainColorPrimary.withAlphaComponent(0.1)
        addButton.layer.cornerRadius = 25.0
        addButton.layer.borderWidth = 2.0
        addButton.layer.borderColor = Token.mainColorPrimary.cgColor
        
        let plusIcon = UIImage(systemName: "plus")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        )
        addButton.setImage(plusIcon, for: .normal)
        addButton.tintColor = Token.mainColorPrimary
        addButton.isUserInteractionEnabled = false
        
        titleLabel.text = "Add Friend"
        titleLabel.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        titleLabel.textColor = Token.mainColorPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        contentView.addSubview(addButton)
        contentView.addSubview(titleLabel)
        
        addButton.layout {
            $0.top(to: contentView.topAnchor)
                .centerX(to: contentView.centerXAnchor)
                .size(50.0)
        }
        
        titleLabel.layout {
            $0.top(to: addButton.bottomAnchor, constant: 8.0)
                .leading(to: contentView.leadingAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
    }
}
