////
////  GroupInvitationTripViewDelegate.swift
////  Coco
////
////  Created by Ahmad Al Wabil on 28/08/25.
////


import SwiftUI

struct GroupInvitationTripView: View {
    let tripData: TripInvitationModel
    
    var onBookNow: (() -> Void)?
    var onMemberTap: ((TripsMember) -> Void)?
    var onPackageTap: ((TripPackage) -> Void)?
    @State private var selectedPackageId: Set <String> = []

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: Activity Section
                    activitySection
                    
                    // MARK: Trip Detail Section
                    tripDetailSection
                    
                    // MARK: Trip Members
                    tripMembersSection
                    
                    // MARK: Available Packages
                    availablePackagesSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 100) // biar ga ketutupan tombol
            }
            
            // MARK: Book Now Button
            VStack {
                Button(action: { onBookNow?() }) {
                    Text("Book Now")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(25)
                        .padding(.horizontal, 25)
                }
            }
            .background(Color(.systemBackground).shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2))
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Sections
private extension GroupInvitationTripView {
    var activitySection: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 92, height: 92)
                .cornerRadius(14)
                // ✅ ganti pakai AsyncImage jika ada URL
            
            VStack(alignment: .leading, spacing: 6) {
                Text(tripData.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                        .foregroundColor(.blue)
                    Text(tripData.location)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text(tripData.priceRange)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5)))
    }
    
    var tripDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trip Detail")
                .font(.system(size: 16, weight: .bold))
            
            detailRow(icon: "checkmark.circle.fill", label: "Status", value: tripData.status.rawValue)
            detailRow(icon: "person.fill", label: "Person", value: "\(tripData.person)")
            detailRow(icon: "calendar", label: "Date Visit", value: formattedDate(tripData.visitDate))
            detailRow(icon: "calendar", label: "Due Date Form", value: formattedDate(tripData.dueDate))
        }
    }
    
    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
    }
    
    var tripMembersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trip Members")
                .font(.system(size: 16, weight: .bold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(tripData.members, id: \.id) { member in
                        VStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                            Text(member.name)
                                .font(.system(size: 14, weight: .medium))
                                .lineLimit(1)
                        }
                        .onTapGesture { onMemberTap?(member) }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 90)
        }
    }
   
    var availablePackagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
               Text("Available Packages")
                   .font(.system(size: 16, weight: .bold))
               
               VStack(spacing: 12) {
                   ForEach(tripData.availablePackages, id: \.id) { package in
                       packageCard(package, isSelected: selectedPackageId.contains(package.id)) {
                           if selectedPackageId.contains(package.id) {
                               selectedPackageId.remove(package.id) // unselect
                           } else {
                               selectedPackageId.insert(package.id) // select
                           }
                           onPackageTap?(package)
                       }
                   }
               }
           }
    }
    
//    var availablePackagesSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Available Packages")
//                .font(.system(size: 16, weight: .bold))
//            
//            VStack(spacing: 12) {
//                ForEach(tripData.availablePackages, id: \.id) { package in
//                    packageCard(package)
//                        .onTapGesture { onPackageTap?(package) }
//                }
//            }
//        }
//    }
    func packageCard(_ package: TripPackage, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 92, height: 92)
                    .cornerRadius(14)

                VStack(alignment: .leading, spacing: 8) {
                    Text(package.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(package.price)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(package.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()

                // ✅ Bulat checkbox
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color(.systemGray5), lineWidth: 2)
            )
            .animation(.easeInOut, value: isSelected) // animasi smooth
        }
        .buttonStyle(.plain) // supaya nggak ada efek default tombol
    }
    
//    func packageCard(_ package: TripPackage) -> some View {
//        HStack(spacing: 12) {
//            Rectangle()
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: 92, height: 92)
//                .cornerRadius(14)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text(package.name)
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(.primary)
//                Text(package.price)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.primary)
//                Text(package.description)
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(.secondary)
//            }
//            Spacer()
//        }
//        .padding(12)
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5)))
//    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy"
        return formatter.string(from: date)
    }
}


//import UIKit
//import Foundation
//import ObjectiveC
//
//final class GroupInvitationTripView: UIView {
//    weak var delegate: GroupInvitationTripViewDelegate?
//    
//    // MARK: - UI Components
//    private lazy var contentStackView: UIStackView = createStackView(spacing: 24.0)
//    
//    // Activity Section
//    private lazy var activitySection: UIView = createActivitySection()
//    private lazy var activityImageView: UIImageView = UIImageView()
//    private lazy var activityTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 18, weight: .bold)
//        label.textColor = .label
//        label.numberOfLines = 2
//        return label
//    }()
//    private lazy var activityLocationLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .secondaryLabel
//        label.numberOfLines = 1
//        return label
//    }()
//    private lazy var activityPriceLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14, weight: .semibold)
//        label.textColor = .label
//        label.numberOfLines = 1
//        return label
//    }()
//    
//    // Trip Details Section
//    private lazy var tripDetailSection: UIView = createTripDetailSection()
//    private lazy var statusLabel: StatusLabel = StatusLabel()
//    private lazy var personCountLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        label.numberOfLines = 1
//        return label
//    }()
//    private lazy var dateVisitLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        label.numberOfLines = 1
//        return label
//    }()
//    private lazy var dueDateFormLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        label.numberOfLines = 1
//        return label
//    }()
//    
//    // Trip Members Section
//    private lazy var tripMembersSection: UIView = createTripMembersSection()
//    private lazy var tripMembersContainer: UIView = UIView()
//    
//    // Available Packages Section
//    private lazy var availablePackagesSection: UIView = createAvailablePackagesSection()
//    private lazy var packagesContainer: UIStackView = createStackView(spacing: 12.0)
//    
//    // Book Now Button Container
//    private lazy var bookNowButtonContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.1
//        view.layer.shadowOffset = .init(width: 0, height: -2)
//        view.layer.shadowRadius = 4
//        return view
//    }()
//    
//    private lazy var bookNowButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = .systemBlue
//        button.setTitle("Book Now", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
//        button.layer.cornerRadius = 25
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//            print("🟡 GroupInvitationTripView init called")
//            backgroundColor = .systemBackground
//            setupView()
//            print("🟡 setupView completed")
//
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // 2. Tambahkan debug method di GroupInvitationTripView
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        print("GroupInvitationTripView frame: \(frame)")
//        print("GroupInvitationTripView bounds: \(bounds)")
//    }
//
//    // 3. Override setupView dengan debug info
//    private func setupView() {
//        print("🔵 setupView started")
//        backgroundColor = .systemBackground
//        print("Setting up GroupInvitationTripView")
//        
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.backgroundColor = .systemRed // DEBUG COLOR
//        print("🔵 ScrollView created")
//        
//        let contentView = UIView()
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.backgroundColor = .systemBlue // DEBUG COLOR
//        
//        addSubview(scrollView)
//        addSubview(bookNowButtonContainer)
//        scrollView.addSubview(contentView)
//        print("🔵 Added scrollView and bookNowButtonContainer")
//        print("Added subviews to GroupInvitationTripView")
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
//                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
//                scrollView.bottomAnchor.constraint(equalTo: bookNowButtonContainer.topAnchor),
//                
//            
//            bookNowButtonContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
//            bookNowButtonContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
//            bookNowButtonContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
//            
//            // ContentView menempel pada ContentLayoutGuide scrollView
//               contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
//               contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
//               contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
//               contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor), // <-- Ini benar, karena contentView akan mendorong guide ini
//               
//               // Lebar ContentView harus sama dengan FrameLayoutGuide scrollView
//               contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
//        ])
//        
//        print("Set up scroll view constraints")
//        
//        contentView.addSubview(contentStackView)
//        contentStackView.translatesAutoresizingMaskIntoConstraints = false
//        contentStackView.backgroundColor = .systemGreen // DEBUG COLOR
//        
//        NSLayoutConstraint.activate([
//            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
//        ])
//        
//        print("Set up content stack view constraints")
//        
//        // Add sections to stack view
//        contentStackView.addArrangedSubview(activitySection)
//        contentStackView.addArrangedSubview(tripDetailSection)
//        contentStackView.addArrangedSubview(tripMembersSection)
//        contentStackView.addArrangedSubview(availablePackagesSection)
//        
//        print("Added sections to stack view")
//        
//        // Setup book now button
//        bookNowButtonContainer.addSubview(bookNowButton)
//        NSLayoutConstraint.activate([
//            bookNowButton.topAnchor.constraint(equalTo: bookNowButtonContainer.topAnchor, constant: 16),
//            bookNowButton.leadingAnchor.constraint(equalTo: bookNowButtonContainer.leadingAnchor, constant: 24),
//            bookNowButton.trailingAnchor.constraint(equalTo: bookNowButtonContainer.trailingAnchor, constant: -24),
//            bookNowButton.bottomAnchor.constraint(equalTo: bookNowButtonContainer.safeAreaLayoutGuide.bottomAnchor, constant: -8),
//            bookNowButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//        
//        bookNowButton.addTarget(self, action: #selector(bookNowTapped), for: .touchUpInside)
//        
//        print("Setup complete")
//        print("🔵 setupView completed")
//    }
//    
//    @objc private func bookNowTapped() {
//        delegate?.didTapBookNow()
//    }
//    
//    func configure(with tripData: TripInvitationModel) {
//        // Force UI setup jika belum
//        layoutIfNeeded()
//        
//        print("Configuring with: \(tripData.title)")
//        
//        // Configure activity section
//        activityTitleLabel.text = tripData.title
//        activityLocationLabel.text = "\(tripData.location)" // Hapus emoji dulu untuk testing
//        activityPriceLabel.text = tripData.priceRange
//        
//        print("Activity labels set - title: \(activityTitleLabel.text ?? "nil")")
//        
//        // Load image if URL exists
//        if let imageURL = tripData.imageURL {
//            // Here you would typically use an image loading library like SDWebImage
//        } else {
//            activityImageView.backgroundColor = .systemGray5
//        }
//        
//        // Configure trip details
//        statusLabel.updateTitle(tripData.status.rawValue)
//        statusLabel.updateStyle(tripData.status.style)
//        personCountLabel.text = "\(tripData.person)"
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "E, dd MMM yyyy"
//        dateVisitLabel.text = formatter.string(from: tripData.visitDate)
//        dueDateFormLabel.text = formatter.string(from: tripData.dueDate)
//        
//        print("Detail labels set - person: \(personCountLabel.text ?? "nil")")
//        
//        // Configure trip members
//        setupTripMembers(tripData.members)
//        
//        // Configure packages
//        setupAvailablePackages(tripData.availablePackages)
//        
//        print("Configuration complete")
//    }
//}
//
//// MARK: - Setup Methods
//private extension GroupInvitationTripView {
//    func createStackView(spacing: CGFloat, axis: NSLayoutConstraint.Axis = .vertical) -> UIStackView {
//        let stackView = UIStackView()
//        stackView.axis = axis
//        stackView.spacing = spacing
//        return stackView
//    }
//    
//    struct AssociatedKeys {
//        static var packageKey = "TripPackageAssociatedKey"
//    }
//
//    
//    func createSectionView(title: String, view: UIView) -> UIView {
//        let containerView = UIView()
//        
//        let titleLabel = UILabel()
//        titleLabel.text = title
//        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
//        titleLabel.textColor = .label
//        titleLabel.numberOfLines = 1
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(view)
//        
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            
//            view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//        
//        return containerView
//    }
//    
//    func createActivitySection() -> UIView {
//        let cardContainer = UIView()
//        cardContainer.backgroundColor = .systemBackground
//        cardContainer.layer.cornerRadius = 16.0
//        cardContainer.layer.borderWidth = 1.0
//        cardContainer.layer.borderColor = UIColor.systemGray5.cgColor
//        
//        let contentStackView = createStackView(spacing: 12.0, axis: .horizontal)
//        
//        activityImageView.contentMode = .scaleAspectFill
//        activityImageView.clipsToBounds = true
//        activityImageView.layer.cornerRadius = 14.0
//        activityImageView.backgroundColor = .systemGray5
//        activityImageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            activityImageView.widthAnchor.constraint(equalToConstant: 92),
//            activityImageView.heightAnchor.constraint(equalToConstant: 92)
//        ])
//        
//        let textStackView = createStackView(spacing: 6.0)
//        
//        let locationContainer = UIView()
//        let pinIcon = UIImageView(image: UIImage(systemName: "location.fill"))
//        pinIcon.tintColor = .systemBlue
//        pinIcon.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            pinIcon.widthAnchor.constraint(equalToConstant: 16),
//            pinIcon.heightAnchor.constraint(equalToConstant: 16)
//        ])
//        
//        locationContainer.addSubview(pinIcon)
//        locationContainer.addSubview(activityLocationLabel)
//        
//        activityLocationLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            pinIcon.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor),
//            pinIcon.centerYAnchor.constraint(equalTo: locationContainer.centerYAnchor),
//            
//            activityLocationLabel.leadingAnchor.constraint(equalTo: pinIcon.trailingAnchor, constant: 4),
//            activityLocationLabel.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor),
//            activityLocationLabel.centerYAnchor.constraint(equalTo: locationContainer.centerYAnchor),
//            activityLocationLabel.topAnchor.constraint(equalTo: locationContainer.topAnchor),
//            activityLocationLabel.bottomAnchor.constraint(equalTo: locationContainer.bottomAnchor)
//        ])
//        
//        textStackView.addArrangedSubview(activityTitleLabel)
//        textStackView.addArrangedSubview(locationContainer)
//        textStackView.addArrangedSubview(activityPriceLabel)
//        
//        contentStackView.addArrangedSubview(activityImageView)
//        contentStackView.addArrangedSubview(textStackView)
//        
//        cardContainer.addSubview(contentStackView)
//        contentStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            contentStackView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 12),
//            contentStackView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 12),
//            contentStackView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -12),
//            contentStackView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -12)
//        ])
//        
//        return cardContainer
//    }
//    
//    func createTripDetailSection() -> UIView {
//        let containerView = UIView()
//        
//        let titleLabel = UILabel()
//        titleLabel.text = "Trip detail"
//        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
//        titleLabel.textColor = .label
//        titleLabel.numberOfLines = 1
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        let detailsStackView = createStackView(spacing: 16.0)
//        
//        // Status row
//        let statusRow = createDetailRow(
//            icon: UIImage(systemName: "checkmark.circle.fill"),
//            label: "Status",
//            valueView: statusLabel
//        )
//        
//        // Person row
//        let personRow = createDetailRow(
//            icon: UIImage(systemName: "person.fill"),
//            label: "Person",
//            valueView: personCountLabel
//        )
//        
//        // Date Visit row
//        let dateVisitRow = createDetailRow(
//            icon: UIImage(systemName: "calendar"),
//            label: "Date Visit",
//            valueView: dateVisitLabel
//        )
//        
//        // Due Date Form row
//        let dueDateFormRow = createDetailRow(
//            icon: UIImage(systemName: "calendar"),
//            label: "Due Date Form",
//            valueView: dueDateFormLabel
//        )
//        
//        detailsStackView.addArrangedSubview(statusRow)
//        detailsStackView.addArrangedSubview(personRow)
//        detailsStackView.addArrangedSubview(dateVisitRow)
//        detailsStackView.addArrangedSubview(dueDateFormRow)
//        
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(detailsStackView)
//        
//        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            
//            detailsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            detailsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            detailsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            detailsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//        
//        return containerView
//    }
//    
//    func createDetailRow(icon: UIImage?, label: String, valueView: UIView) -> UIView {
//        let rowView = UIView()
//        
//        let iconView = UIImageView(image: icon)
//        iconView.contentMode = .scaleAspectFit
//        iconView.tintColor = .secondaryLabel
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            iconView.widthAnchor.constraint(equalToConstant: 20),
//            iconView.heightAnchor.constraint(equalToConstant: 20)
//        ])
//        
//        let labelView = UILabel()
//        labelView.text = label
//        labelView.font = .systemFont(ofSize: 16, weight: .medium)
//        labelView.textColor = .secondaryLabel
//        labelView.numberOfLines = 1
//        labelView.translatesAutoresizingMaskIntoConstraints = false
//        
//        rowView.addSubview(iconView)
//        rowView.addSubview(labelView)
//        rowView.addSubview(valueView)
//        
//        valueView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            iconView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
//            iconView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
//            
//            labelView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
//            labelView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
//            
//            valueView.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
//            valueView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
//            valueView.topAnchor.constraint(equalTo: rowView.topAnchor),
//            valueView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
//        ])
//        
//        return rowView
//    }
//
//
//    func createTripMembersSection() -> UIView {
//        return createSectionView(title: "Trip Members", view: tripMembersContainer)
//    }
//    
//    func createAvailablePackagesSection() -> UIView {
//        return createSectionView(title: "Available Packages", view: packagesContainer)
//    }
//    func setupTripMembers(_ members: [TripsMember]) {
//        print("Setting up \(members.count) members")
//        
//        tripMembersContainer.subviews.forEach { $0.removeFromSuperview() }
//        
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.itemSize = CGSize(width: 70, height: 90)
//        flowLayout.minimumInteritemSpacing = 16
//        flowLayout.minimumLineSpacing = 16
//        flowLayout.scrollDirection = .horizontal
//        
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.register(TripInvitationMemberCell.self, forCellWithReuseIdentifier: "TripInvitationMemberCell")
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Create a simple data source for the collection view
//        let dataSource = TripMembersDataSource(members: members)
//        dataSource.delegate = self.delegate // Tambahkan ini
//        
//        collectionView.dataSource = dataSource
//        collectionView.delegate = dataSource
//        
//        tripMembersContainer.addSubview(collectionView)
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: tripMembersContainer.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: tripMembersContainer.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: tripMembersContainer.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: tripMembersContainer.bottomAnchor),
//            collectionView.heightAnchor.constraint(equalToConstant: 90)
//        ])
//        
//        // Store the data source to prevent deallocation
//        objc_setAssociatedObject(collectionView, "dataSource", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        
//        print("Collection view setup complete")
//    }
//    
//    func setupAvailablePackages(_ packages: [TripPackage]) {
//        packagesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        
//        for package in packages {
//            let packageView = createPackageView(data: package)
//            packagesContainer.addArrangedSubview(packageView)
//        }
//    }
//    
//    func createPackageView(data: TripPackage) -> UIView {
//        let containerStackView = createStackView(spacing: 12.0, axis: .horizontal)
//        let contentStackView = createStackView(spacing: 8.0)
//
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 14.0
//        imageView.backgroundColor = .systemGray5
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            imageView.widthAnchor.constraint(equalToConstant: 92),
//            imageView.heightAnchor.constraint(equalToConstant: 92)
//        ])
//
//        let nameLabel = UILabel()
//        nameLabel.text = data.name
//        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
//        nameLabel.textColor = .label
//        nameLabel.numberOfLines = 2
//
//        let priceLabel = UILabel()
//        priceLabel.text = data.price
//        priceLabel.font = .systemFont(ofSize: 14, weight: .semibold)
//        priceLabel.textColor = .label
//        priceLabel.numberOfLines = 1
//
//        let minMaxLabel = UILabel()
//        minMaxLabel.text = data.description
//        minMaxLabel.font = .systemFont(ofSize: 12, weight: .medium)
//        minMaxLabel.textColor = .secondaryLabel
//        minMaxLabel.numberOfLines = 1
//
//        contentStackView.addArrangedSubview(nameLabel)
//        contentStackView.addArrangedSubview(priceLabel)
//        contentStackView.addArrangedSubview(minMaxLabel)
//
//        containerStackView.addArrangedSubview(imageView)
//        containerStackView.addArrangedSubview(contentStackView)
//
//        let cardContainer = UIView()
//        cardContainer.backgroundColor = .systemBackground
//        cardContainer.layer.cornerRadius = 16.0
//        cardContainer.layer.borderWidth = 1.0
//        cardContainer.layer.borderColor = UIColor.systemGray5.cgColor
//
//        cardContainer.addSubview(containerStackView)
//        containerStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            containerStackView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 12),
//            containerStackView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 12),
//            containerStackView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -12),
//            containerStackView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -12)
//        ])
//
//        // 🔗 Associate the package
//        objc_setAssociatedObject(cardContainer, &AssociatedKeys.packageKey, data, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//
//        // ✅ Add tap gesture
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(packageTapped(_:)))
//        cardContainer.addGestureRecognizer(tapGesture)
//        cardContainer.isUserInteractionEnabled = true
//
//        return cardContainer
//    }
//
//    
//    @objc private func packageTapped(_ gesture: UITapGestureRecognizer) {
//        guard let view = gesture.view,
//              let package = objc_getAssociatedObject(view, &AssociatedKeys.packageKey) as? TripPackage else {
//            return
//        }
//
//        print("Package tapped: \(package.name)")
//        delegate?.didSelectPackage(package)
//    }
//}
//
//
//
//// MARK: - TripMembersDataSource
//private class TripMembersDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
//    private let members: [TripsMember]
//    weak var delegate: GroupInvitationTripViewDelegate?
//    
//    init(members: [TripsMember]) {
//        self.members = members
//        super.init()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return members.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripInvitationMemberCell", for: indexPath) as? TripInvitationMemberCell else {
//            return UICollectionViewCell()
//        }
//        
//        let member = members[indexPath.item]
//        cell.configure(with: member)
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let member = members[indexPath.item]
//        delegate?.didTapMember(member)
//    }
//}
//
//
