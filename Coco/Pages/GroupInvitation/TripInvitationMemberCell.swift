//
//  TripInvitationMemberCell.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 28/08/25.
//

import Foundation
import UIKit
import Combine
import SwiftUI
final class TripInvitationMemberCell: UICollectionViewCell {
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.backgroundColor = .systemGray4
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
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
    
    func configure(with member: TripsMember) {
        nameLabel.text = member.name
        
        // Configure profile image
        if let imageURL = member.profileImageURL, let url = URL(string: imageURL) {
            // Load image from URL (you would use image loading library here)
            profileImageView.backgroundColor = .systemGray4
        } else {
            // Add placeholder
            let placeholderLabel = UILabel()
            placeholderLabel.text = "👤"
            placeholderLabel.font = .systemFont(ofSize: 24)
            placeholderLabel.textAlignment = .center
            placeholderLabel.textColor = .white
            profileImageView.addSubview(placeholderLabel)
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                placeholderLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
                placeholderLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
            ])
        }
        
        // Configure waiting status
        if member.isWaiting {
            statusIndicator.isHidden = false
            statusIndicator.backgroundColor = .black
        } else {
            statusIndicator.isHidden = true
        }
    }
    
    private func setupView() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusIndicator)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            statusIndicator.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -3),
            statusIndicator.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 3),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
}
