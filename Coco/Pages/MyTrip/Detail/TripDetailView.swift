//
//  TripDetailView.swift
//  Coco
//
//  Created by Jackie Leonardy on 16/07/25.
//

import Foundation
import UIKit
import SwiftUI 

struct BookingDetailDataModel {
    let imageString: String
    let activityName: String
    let packageName: String
    let location: String
    let bookingDateText: String
    let dueDateForm: String 
    let status: StatusLabel
    let paxNumber: Int
    let price: Double
    let address: String
    let bookedPackages: [BookedPackageInfo]? 
    
    struct StatusLabel {
        let text: String
        let style: CocoStatusLabelStyle
    }
    
    struct BookedPackageInfo {
        let name: String
        let price: String
        let imageUrl: String
        let minParticipants: Int  
        let maxParticipants: Int  
        let voters: [TripMember]
        let totalVotes: Int
    }
    
    // Original initializer for API BookingDetails (without group trip features)
    init(bookingDetail: BookingDetails) {
        var bookingStatus: String = bookingDetail.status
        var statusStyle: CocoStatusLabelStyle = .pending
        
        // If status is already "Pending", keep it as is (for newly created plans)
        if bookingDetail.status.lowercased() == "pending" {
            bookingStatus = "Pending"
            statusStyle = .pending
        } else {
            // For other statuses, apply date-based logic
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            
            if let targetDate: Date = formatter.date(from: bookingDetail.activityDate) {
                let today: Date = Date()
                
                if targetDate < today {
                    bookingStatus = "Completed"
                    statusStyle = .success
                } else if targetDate > today {
                    bookingStatus = "Upcoming"
                    statusStyle = .success // Fix: use .success instead of .refund for upcoming
                }
            }
        }
        
        status = StatusLabel(text: bookingStatus, style: statusStyle)
        imageString = bookingDetail.destination.imageUrl ?? ""
        activityName = bookingDetail.activityTitle
        packageName = bookingDetail.packageName
        location = bookingDetail.destination.name
        paxNumber = bookingDetail.participants
        price = bookingDetail.totalPrice
        address = bookingDetail.address
        
        // For regular bookings, these fields don't exist
        dueDateForm = "Not specified"
        bookedPackages = nil
        
        // Format the date to display in a user-friendly format like "Tues, 15 March 2025"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: bookingDetail.activityDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "E, d MMMM yyyy"
            outputFormatter.locale = Locale(identifier: "en_US")
            bookingDateText = outputFormatter.string(from: date)
        } else {
            bookingDateText = bookingDetail.activityDate
        }
    }
    
    // New initializer for LocalBookingDetails (group trips)
    init(localBookingDetail: LocalBookingDetails) {
        self.imageString = localBookingDetail.destination.imageUrl ?? ""
        self.activityName = localBookingDetail.activityTitle
        self.packageName = localBookingDetail.packageName
        self.location = localBookingDetail.destination.name
        self.paxNumber = localBookingDetail.participants
        self.price = localBookingDetail.totalPrice
        self.address = localBookingDetail.address
        self.dueDateForm = localBookingDetail.dueDateForm ?? "Not specified"
        
        // Convert selected packages to BookedPackageInfo
        if let selectedPackages = localBookingDetail.selectedPackages {
            self.bookedPackages = selectedPackages.map { package in
                BookedPackageInfo(
                    name: package.name,
                    price: package.price,
                    imageUrl: package.imageUrlString,
                    minParticipants: package.minParticipants,
                    maxParticipants: package.maxParticipants,
                    voters: package.voters,
                    totalVotes: package.totalVotes
                )
            }
        } else {
            self.bookedPackages = nil
        }
        
        // Status handling - use available CocoStatusLabelStyle values
        switch localBookingDetail.status.lowercased() {
        case "upcoming":
            self.status = StatusLabel(text: "Upcoming", style: .success) // Fix: use .success
        case "completed":
            self.status = StatusLabel(text: "Completed", style: .success) // Fix: use .success
        default:
            self.status = StatusLabel(text: "Pending", style: .pending)
        }
        
        // Date formatting
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        
        if let date = inputFormatter.date(from: localBookingDetail.activityDate) {
            self.bookingDateText = outputFormatter.string(from: date)
        } else {
            self.bookingDateText = localBookingDetail.activityDate
        }
    }
}

final class TripDetailView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ data: BookingDetailDataModel) {
        activityImage.loadImage(from: URL(string: data.imageString))
        activityTitle.text = data.activityName
        activityLocationTitle.text = data.location
        activityDescription.text = data.packageName
        
        bookingDateLabel.text = data.bookingDateText
        dueDateFormLabel.text = data.dueDateForm 
        paxNumberLabel.text = "\(data.paxNumber)"
        
        if let bookedPackages = data.bookedPackages, !bookedPackages.isEmpty {
            setupBookedPackages(bookedPackages)
            bookedPackagesSection.isHidden = false
        } else {
            bookedPackagesSection.isHidden = true
        }
        
        priceDetailTitle.text = "Pay during trip"
        priceDetailPrice.text = data.price.toRupiah()
        
        addressLabel.text = data.address
    }
    
    func configureStatusLabelView(with view: UIView) {
        statusLabel.addSubview(view)
        view.layout {
            $0.leading(to: statusLabel.leadingAnchor)
                .top(to: statusLabel.topAnchor)
                .trailing(to: statusLabel.trailingAnchor, relation: .lessThanOrEqual)
                .bottom(to: statusLabel.bottomAnchor)
        }
    }
    
    private lazy var dueDateFormSection: UIView = createSectionTitle(title: "Due Date Form", view: dueDateFormLabel)
    private lazy var dueDateFormLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 0
    )
    
    private lazy var bookedPackagesSection: UIView = createBookedPackagesSection()
    private lazy var bookedPackagesContainer: UIStackView = createStackView(spacing: 12.0) // Fix: add spacing parameter
    
    private func createBookedPackagesSection() -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel(
            font: .jakartaSans(forTextStyle: .title3, weight: .bold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        titleLabel.text = "Booked Packages"
        
        containerView.addSubviews([titleLabel, bookedPackagesContainer])
        
        titleLabel.layout {
            $0.top(to: containerView.topAnchor)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
        }
        
        bookedPackagesContainer.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 16.0)
                .leading(to: containerView.leadingAnchor)
                .trailing(to: containerView.trailingAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        return containerView
    }
    
    private func setupBookedPackages(_ packages: [BookingDetailDataModel.BookedPackageInfo]) {
        bookedPackagesContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for package in packages {
            let packageView = createBookedPackageView(package: package)
            bookedPackagesContainer.addArrangedSubview(packageView)
        }
    }
    
    private func createBookedPackageView(package: BookingDetailDataModel.BookedPackageInfo) -> UIView {
        let hostingController = UIHostingController(
            rootView: BookedPackageCardView(package: package)
        )
        
        hostingController.view.backgroundColor = UIColor.clear // Fix: specify UIColor.clear
        return hostingController.view
    }
    
    private lazy var activityDetailView: UIView = createActivityDetailView()
    private lazy var activityImage: UIImageView = createImageView()
    private lazy var activityTitle: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .title2, weight: .semibold),
        textColor: Token.grayscale90,
        numberOfLines: 0
    )
    private lazy var activityDescription: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 0
    )
    private lazy var activityLocationTitle: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .footnote, weight: .medium),
        textColor: Token.grayscale90,
        numberOfLines: 2
    )
    
    private lazy var contentStackView: UIStackView = createStackView()
    
    private lazy var bookingDateSection: UIView = createSectionTitle(title: "Date Visit", view: bookingDateLabel) 
    private lazy var bookingDateLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 0
    )
    
    private lazy var statusSection: UIView = createSectionTitle(title: "Status", view: statusLabel)
    private lazy var statusLabel: UIView = UIView()
    
    private lazy var paxNumberSection: UIView = createSectionTitle(title: "Person", view: paxNumberLabel)
    private lazy var paxNumberLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 0
    )
    
    private lazy var priceDetailTitle: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .callout, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    private lazy var priceDetailPrice: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .semibold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 2
    )
    
    private lazy var addressSection: UIView = createSectionTitle(title: "Meeting Point", view: addressLabel)
    private lazy var addressLabel: UILabel = UILabel(
        font: .jakartaSans(forTextStyle: .body, weight: .bold),
        textColor: Token.additionalColorsBlack,
        numberOfLines: 0
    )
    
    private lazy var priceDetailSection: UIView = createLeftRightAlignment(lhs: priceDetailTitle, rhs: priceDetailPrice)
}

private extension TripDetailView {
    func setupView() {
        addSubview(contentStackView)

        contentStackView.layout {
            $0.top(to: self.safeAreaLayoutGuide.topAnchor, constant: 24.0)
                .leading(to: self.leadingAnchor, constant: 24.0)
                .trailing(to: self.trailingAnchor, constant: -24.0)
                .bottom(to: self.bottomAnchor, relation: .lessThanOrEqual, constant: -24.0)
        }
        
        let dateStatusSection: UIView = UIView()
        dateStatusSection.addSubviews([
            bookingDateSection,
            statusSection
        ])
        
        bookingDateSection.layout {
            $0.leading(to: dateStatusSection.leadingAnchor)
                .centerY(to: dateStatusSection.centerYAnchor)
        }
        
        statusSection.layout {
            $0.leading(to: bookingDateSection.trailingAnchor)
                .leading(to: dateStatusSection.centerXAnchor)
                .trailing(to: dateStatusSection.trailingAnchor)
                .top(to: dateStatusSection.topAnchor)
                .bottom(to: dateStatusSection.bottomAnchor)
        }
        
        contentStackView.addArrangedSubview(activityDetailView)
        contentStackView.addArrangedSubview(dateStatusSection)
        
        // Add Due Date Form section after dateStatusSection
        contentStackView.addArrangedSubview(dueDateFormSection)
        
        contentStackView.addArrangedSubview(paxNumberSection)
        
        // Add Booked Packages section before price details
        contentStackView.addArrangedSubview(bookedPackagesSection)
        
        contentStackView.addArrangedSubview(createLineDivider())
        contentStackView.addArrangedSubview(priceDetailSection)
        contentStackView.addArrangedSubview(createLineDivider())
        contentStackView.addArrangedSubview(addressSection)
        
        backgroundColor = Token.additionalColorsWhite
    }
    
    func createStackView(spacing: CGFloat = 24.0) -> UIStackView { // Fix: add default spacing parameter
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = spacing
          
        return stackView
    }
    
    func createActivityDetailView() -> UIView {
        let imageView: UIImageView = UIImageView(image: CocoIcon.icPinPointBlack.image)
        imageView.layout {
            $0.size(20.0)
        }
        
        let imageTextContent: UIView = UIView()
        imageTextContent.addSubviews([
            imageView,
            activityLocationTitle
        ])
        
        imageView.layout {
            $0.leading(to: imageTextContent.leadingAnchor)
                .top(to: imageTextContent.topAnchor)
                .bottom(to: imageTextContent.bottomAnchor)
                .centerY(to: imageTextContent.centerYAnchor)
        }
        
        activityLocationTitle.layout {
            $0.leading(to: imageView.trailingAnchor, constant: 4.0)
                .trailing(to: imageTextContent.trailingAnchor)
                .centerY(to: imageTextContent.centerYAnchor)
        }
        
        let containerView: UIView = UIView()
        containerView.addSubviews([
            activityImage,
            activityTitle,
            activityDescription,
            imageTextContent
        ])
        
        activityImage.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor, relation: .lessThanOrEqual)
        }
        
        activityTitle.layout {
            $0.leading(to: activityImage.trailingAnchor, constant: 10.0)
                .top(to: containerView.topAnchor)
                .trailing(to: containerView.trailingAnchor)
        }
        
        activityDescription.layout {
            $0.leading(to: activityTitle.leadingAnchor)
                .top(to: activityTitle.bottomAnchor, constant: 8.0)
                .trailing(to: containerView.trailingAnchor)
        }
        
        imageTextContent.layout {
            $0.leading(to: activityTitle.leadingAnchor)
                .top(to: activityDescription.bottomAnchor, constant: 8.0)
                .trailing(to: containerView.trailingAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        return containerView
    }
    
    func createImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layout {
            $0.size(92.0)
        }
        imageView.layer.cornerRadius = 14.0
        imageView.clipsToBounds = true
        return imageView
    }
    
    func createSectionTitle(title: String, view: UIView) -> UIView {
        let titleView: UILabel = UILabel(
            font: .jakartaSans(forTextStyle: .callout, weight: .regular),
            textColor: Token.grayscale60,
            numberOfLines: 0
        )
        titleView.text = title
        
        let contentView: UIView = UIView()
        contentView.addSubviews(
            [
                titleView,
                view
            ]
        )
        
        titleView.layout {
            $0.leading(to: contentView.leadingAnchor)
                .top(to: contentView.topAnchor)
                .trailing(to: contentView.trailingAnchor)
        }
        
        view.layout {
            $0.leading(to: contentView.leadingAnchor)
                .top(to: titleView.bottomAnchor, constant: 4.0)
                .trailing(to: contentView.trailingAnchor)
                .bottom(to: contentView.bottomAnchor)
        }
        
        return contentView
    }
    
    func createLineDivider() -> UIView {
        let contentView: UIView = UIView()
        let divider: UIView = UIView()
        divider.backgroundColor = Token.additionalColorsLine
        divider.layout {
            $0.height(1.0)
        }
        
        contentView.addSubviewAndLayout(divider, insets: .init(vertical: 0, horizontal: 8.0))
        
        return contentView
    }
    
    func createLeftRightAlignment(
        lhs: UIView,
        rhs: UIView
    ) -> UIView {
        let containerView: UIView = UIView()
        containerView.addSubviews([
            lhs,
            rhs
        ])
        lhs.layout {
            $0.leading(to: containerView.leadingAnchor)
                .top(to: containerView.topAnchor)
                .bottom(to: containerView.bottomAnchor)
        }
        
        rhs.layout {
            $0.leading(to: lhs.trailingAnchor, relation: .greaterThanOrEqual, constant: 4.0)
                .trailing(to: containerView.trailingAnchor)
                .centerY(to: containerView.centerYAnchor)
        }
        
        return containerView
    }
}
