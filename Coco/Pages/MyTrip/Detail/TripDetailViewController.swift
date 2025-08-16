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
        labelVC.didMove(toParent: self)
    }
    
    func shareTripDetail() {
        let image = thisView.asImage()
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
}

