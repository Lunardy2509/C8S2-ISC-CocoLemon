//
//  NotificationDetailViewController.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 25/08/25.
//


import UIKit

final class NotificationDetailViewController: UIViewController {
    private let notification: NotificationItem
    private let thisView: NotificationDetailView = NotificationDetailView()
    
    init(notification: NotificationItem) {
        self.notification = notification
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        configureView()
    }
    
    override func loadView() {
        view = thisView
    }
}

// MARK: - Private Methods
private extension NotificationDetailViewController {
    func setupView() {
        thisView.delegate = self
        thisView.addButtonsToParent(self)
    }
    
//    func setupNavigationBar() {
//        title = "Notification Detail"
//        navigationController?.navigationBar.prefersLargeTitles = false
//        
//        // Optional: Add close button if presented modally
//        if presentingViewController != nil {
//            navigationItem.leftBarButtonItem = UIBarButtonItem(
//                barButtonSystemItem: .cancel,
//                navigationItem.UIColor.black,
//                target: self,
//                action: #selector(dismissViewController)
//            )
//        }
//    }
//    
    func setupNavigationBar() {
        title = "Notification Detail"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black  // <- ini ubah warna back button default

        // Optional: Add close button if presented modally
        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(dismissViewController)
            )
            closeButton.tintColor = .black   // <- ini ubah warna tombol cancel jadi hitam
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    func configureView() {
        thisView.configure(with: notification)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
    func handleAcceptAction() {
        // Show loading state
        showLoadingAlert()
        
//        // Simulate API call
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            self?.dismissLoadingAlert()
//            self?.showSuccessAlert(title: "Accepted!", message: "You have successfully joined the trip.") {
//                self?.navigationController?.popViewController(animated: true)
//            }
//        }
    }
    
    func handleDeclineAction() {
        let alert = UIAlertController(
            title: "Decline Invitation",
            message: "Are you sure you want to decline this trip invitation?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Decline", style: .destructive) { [weak self] _ in
            self?.performDeclineAction()
        })
        
        present(alert, animated: true)
    }
    
    func performDeclineAction() {
        // Show loading state
        showLoadingAlert()
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.dismissLoadingAlert()
            self?.showSuccessAlert(title: "Declined", message: "You have declined the trip invitation.") {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func showLoadingAlert() {
        let alert = UIAlertController(title: nil, message: "Processing...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        present(alert, animated: true)
    }
    
    func dismissLoadingAlert() {
        dismiss(animated: true)
    }
    
    func showSuccessAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
}

// MARK: - NotificationDetailViewDelegate
extension NotificationDetailViewController: NotificationDetailViewDelegate {
    func notificationDetailViewDidTapAccept() {
        handleAcceptAction()
    }
    
    func notificationDetailViewDidTapDecline() {
        handleDeclineAction()
    }
}
