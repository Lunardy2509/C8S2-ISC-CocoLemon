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
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc private func shareButtonTapped() {
        viewModel.onShareButtonTapped()
    }
    
    private let viewModel: TripDetailViewModelProtocol
    private let thisView: TripDetailView = TripDetailView()
}

extension TripDetailViewController: TripDetailViewModelAction {
    func configureView(dataModel: BookingDetailDataModel) {
        thisView.configureView(dataModel)
        
        let labelVC: CocoStatusLabelHostingController = CocoStatusLabelHostingController(
            title: dataModel.status.text,
            style: dataModel.status.style
        )
        thisView.configureStatusLabelView(with: labelVC.view)
        addChild(labelVC)
        labelVC.didMove(toParent: self)
    }
    
    func shareTripDetail(data: ShareTripDataModel?) {
        let imageToShare: UIImage
        
        if let data = data {
            let shareView = ShareTripView()
            shareView.configureView(data)
            
            // To correctly render a view with Auto Layout off-screen,
            // we must give it a width constraint and let it determine its height.
            shareView.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = shareView.widthAnchor.constraint(equalToConstant: 414)
            widthConstraint.isActive = true
            
            // The size is calculated based on the constraints.
            let size = shareView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            shareView.bounds = CGRect(origin: .zero, size: size)
            
            // We need to force another layout pass for the `asImage`
            // to work correctly with the new bounds.
            shareView.setNeedsLayout()
            shareView.layoutIfNeeded()

            imageToShare = shareView.asImage()
            
            // Deactivate constraint to avoid potential issues if the view were reused.
            widthConstraint.isActive = false
        } else {
            imageToShare = thisView.asImage()
        }
        
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
}

