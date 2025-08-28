//
//  GroupInvitationTripViewController.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 28/08/25.
//


import UIKit
import SwiftUI

final class GroupInvitationTripViewController: UIViewController {
    private var viewModel: GroupInvitationTripViewModelProtocol
    private var hostingController: UIHostingController<GroupInvitationTripView>?

    init(viewModel: GroupInvitationTripViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSwiftUIView()
        bindViewModel()
    }

    private func setupSwiftUIView() {
        let tripView = GroupInvitationTripView(
            tripData: viewModel.tripData,
            onBookNow: { [weak self] in
                self?.viewModel.onBookNow?()
            },
            onMemberTap: { [weak self] member in
                self?.viewModel.onMemberTap?(member)
            },
            onPackageTap: { [weak self] package in
                self?.viewModel.onPackageSelect?(package)
            }
        )

        let hosting = UIHostingController(rootView: tripView)
        addChild(hosting)
        view.addSubview(hosting.view)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hosting.didMove(toParent: self)
        self.hostingController = hosting
    }

    private func setupNavigationBar() {
        title = "Group Invitation Trip"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    private func bindViewModel() {
        viewModel.onBookNow = { [weak self] in
            self?.handleBookNow()
        }
        viewModel.onMemberTap = { [weak self] member in
            self?.handleMemberTap(member)
        }
//        viewModel.onPackageSelect = {
//        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Handlers
    private func handleBookNow() {
        let alert = UIAlertController(
            title: "Book Now",
            message: "Proceed to booking for \(viewModel.tripData.title)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Proceed", style: .default) { [weak self] _ in
            self?.navigateToBooking()
        })
        present(alert, animated: true)
    }

    private func handleMemberTap(_ member: TripsMember) {
        let alert = UIAlertController(
            title: "Member Info",
            message: "View profile of \(member.name)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "View Profile", style: .default) { [weak self] _ in
            self?.navigateToMemberProfile(member)
        })
        present(alert, animated: true)
    }

//    private func handlePackageSelection(_ package: TripPackage) {
//        let alert = UIAlertController(
//            title: "Package Selected",
//            message: "You selected \(package.name) - \(package.price)",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }

    private func navigateToBooking() {
        print("Navigate to booking for trip: \(viewModel.tripData.title)")
    }

    private func navigateToMemberProfile(_ member: TripsMember) {
        print("Navigate to profile for member: \(member.name)")
    }
}


//import Foundation
//import UIKit
//
//// MARK: - ViewController
//final class GroupInvitationTripViewController: UIViewController {
//    private var viewModel: GroupInvitationTripViewModelProtocol
//    private lazy var mainView: GroupInvitationTripView = {
//        let view = GroupInvitationTripView()
//        view.delegate = self // Set delegate saat inisialisasi
//        return view
//    }()
//    
//    init(viewModel: GroupInvitationTripViewModelProtocol) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//        setupNavigationBar()
//        bindViewModel()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // Configure view setelah view hierarchy sepenuhnya siap
//        configureView()
//    }
//
//    private func configureView() {
//        print("Configuring view with: \(viewModel.tripData.title)")
//        
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.mainView.configure(with: self.viewModel.tripData)
//        }
//    }
//    
//    private func setupView() {
//        view.backgroundColor = .systemBackground
//        
//        print("Setting up main view...")
//        print("View controller view frame: \(view.frame)")
//        
//        _ = mainView.frame
//        
//        // Tambah debug background color
////        mainView.backgroundColor = .systemBlue
//        
//        print("MainView initialized, background set to yellow")
//        
//        // Add mainView sebagai subview
//        view.addSubview(mainView)
//        mainView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let constraints = [
//            mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ]
//        
//        NSLayoutConstraint.activate(constraints)
//        
//        print("Main view constraints activated")
//        print("Main view frame: \(mainView.frame)")
//        
//        // Force layout
//        view.layoutIfNeeded()
//        
//        print("After layout - Main view frame: \(mainView.frame)")
//        
//        // TAMBAH INI - force setup internal views
//        mainView.setNeedsLayout()
//        mainView.layoutIfNeeded()
//        
//        print("MainView internal layout forced")
//    }
//    
//    private func setupNavigationBar() {
//        title = "Group Invitation Trip"
//        navigationController?.navigationBar.prefersLargeTitles = false
//        navigationController?.navigationBar.tintColor = .black
//        
//        // Add back button if needed
//        let backButton = UIBarButtonItem(
//            image: UIImage(systemName: "chevron.left"),
//            style: .plain,
//            target: self,
//            action: #selector(backButtonTapped)
//        )
//        backButton.tintColor = .black
//        navigationItem.leftBarButtonItem = backButton
//    }
//    
//    private func bindViewModel() {
//        viewModel.onBookNow = { [weak self] in
//            self?.handleBookNow()
//        }
//        
//        viewModel.onMemberTap = { [weak self] member in
//            self?.handleMemberTap(member)
//        }
//        
//        viewModel.onPackageSelect = { [weak self] package in
//            self?.handlePackageSelection(package)
//        }
//    }
//    
//    @objc private func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    private func handleBookNow() {
//        let alert = UIAlertController(
//            title: "Book Now",
//            message: "Proceed to booking for \(viewModel.tripData.title)?",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Proceed", style: .default) { [weak self] _ in
//            self?.navigateToBooking()
//        })
//        
//        present(alert, animated: true)
//    }
//    
//    private func handleMemberTap(_ member: TripsMember) {
//        let alert = UIAlertController(
//            title: "Member Info",
//            message: "View profile of \(member.name)?",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "View Profile", style: .default) { [weak self] _ in
//            self?.navigateToMemberProfile(member)
//        })
//        
//        present(alert, animated: true)
//    }
//    
//    private func handlePackageSelection(_ package: TripPackage) {
//        let alert = UIAlertController(
//            title: "Package Selected",
//            message: "You selected \(package.name) - \(package.price)",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    private func navigateToBooking() {
//        print("Navigate to booking for trip: \(viewModel.tripData.title)")
//    }
//    
//    private func navigateToMemberProfile(_ member: TripsMember) {
//        print("Navigate to profile for member: \(member.name)")
//    }
//}
//
//extension GroupInvitationTripViewController: GroupInvitationTripViewDelegate {
//    func didTapBookNow() {
//        viewModel.onBookNow?()
//    }
//    
//    func didTapMember(_ member: TripsMember) {
//        viewModel.onMemberTap?(member)
//    }
//    
//    func didSelectPackage(_ package: TripPackage) {
//        viewModel.onPackageSelect?(package)
//    }
//}
