//
//  TripDetailViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 16/07/25.
//

import Foundation
import UIKit

final class TripDetailViewController: UIViewController {
    
    init(viewModel: TripDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
        title = "Detail My Trip"
        setupNavigationBar() 
    }
    
    private func setupNavigationBar() {
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up") ?? UIImage(),
            style: .plain,
            target: self,
            action: #selector(shareButtonTapped)
        )
        shareButton.tintColor = Token.additionalColorsBlack
        
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc private func shareButtonTapped() {
        guard let tripData = getCurrentTripData() else { return }
        
        let screenshot = captureScreenshot()
        
        let shareText = """
        Check out my trip: \(tripData.activityName)
        
        📍 Location: \(tripData.location)
        📅 Date: \(tripData.bookingDateText)
        👥 People: \(tripData.paxNumber)
        💰 Price: \(tripData.price.toRupiah())
        
        Shared via CocoLemon
        """
        
        var shareItems: [Any] = [shareText]
        
        if let screenshot = screenshot {
            shareItems.append(screenshot)
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        
        if let popover = activityViewController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityViewController, animated: true)
    }
    
    private func captureScreenshot() -> UIImage? {
        return captureView(view)
    }
    
    private func captureView(_ targetView: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: targetView.bounds)
        
        let screenshot = renderer.image { context in
            targetView.drawHierarchy(in: targetView.bounds, afterScreenUpdates: true)
        }
        
        return screenshot
    }
    
    private func getCurrentTripData() -> BookingDetailDataModel? {
        return currentTripData
    }
    
    private let viewModel: TripDetailViewModelProtocol
    private let thisView: TripDetailView = TripDetailView()
    private var currentTripData: BookingDetailDataModel?
}

extension TripDetailViewController: TripDetailViewModelAction {
    func configureView(dataModel: BookingDetailDataModel) {
        currentTripData = dataModel 
        thisView.configureView(dataModel)
        
        let labelVC: CocoStatusLabelHostingController = CocoStatusLabelHostingController(
            title: dataModel.status.text,
            style: dataModel.status.style
        )
        thisView.configureStatusLabelView(with: labelVC.view)
        labelVC.didMove(toParent: self)
    }
}
