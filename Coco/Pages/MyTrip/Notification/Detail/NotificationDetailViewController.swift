// Updated NotificationDetailViewController with Group Invitation Trip integration

import UIKit

final class NotificationDetailViewController: UIViewController {
    private let notification: NotificationItem
    private let thisView: NotificationDetailView = NotificationDetailView()
    private var groupInvitationCoordinator: GroupInvitationTripCoordinator?
    
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
        setupCoordinator()
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
    
    func setupNavigationBar() {
        title = "Notification Detail"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black

        if presentingViewController != nil {
            let closeButton = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(dismissViewController)
            )
            closeButton.tintColor = .black
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    func configureView() {
        thisView.configure(with: notification)
    }
    
    func setupCoordinator() {
        guard let navigationController = navigationController else { return }
        groupInvitationCoordinator = GroupInvitationTripCoordinator(navigationController: navigationController)
        groupInvitationCoordinator?.delegate = self
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
    func acceptAction() {
        
        print("Berhasil menerima")
        // Show loading state
//        showLoadingAlert()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                // Pastikan navigasi terjadi di main thread
                DispatchQueue.main.async {
                    self?.navigateToGroupInvitationTrip()
                }
            }
    }
    
    func navigateToGroupInvitationTrip() {
        // Create sample trip data based on notification
        let tripData = createTripDataFromNotification()
        
        // Use coordinator to navigate
        groupInvitationCoordinator?.start(with: tripData)
        print("Created trip data: \(tripData.title)")
        print("Members count: \(tripData.members.count)")
        print("Packages count: \(tripData.availablePackages.count)")
    }
    
    func createTripDataFromNotification() -> TripInvitationModel {
        // Create sample data - in real app, this would come from the notification or API
        let members = [
            TripsMember(
                id: "1",
                name: "Adhis",
                profileImageURL: nil,
                isCurrentUser: false,
                isWaiting: false
            ),
            TripsMember(
                id: "2",
                name: "Al",
                profileImageURL: nil,
                isCurrentUser: true,
                isWaiting: true
            )
        ]
        
        let packages = [
            TripPackage(
                id: "1",
                name: "Public Trip",
                price: "Rp.150.000",
                imageURL: nil,
                minPerson: 1,
                maxPerson: 20,
                description: "Min.1 - Max.20"
            ),
            
            TripPackage(
                id: "2",
                name: "Sunset Snorkel & BBQ",
                price: "Rp.150.000",
                imageURL: nil,
                minPerson: 4,
                maxPerson: 20,
                description: "Min.4 - Max.20"
            ),
            
        ]
        
        return TripInvitationModel(
            id: "trip_001",
            title: "Pink Beach Snorkeling Adventure",
            location: "Komodo National Park, NTT",
            imageURL: nil,
            priceRange: "Rp.1.300.000 - Rp.950.000/Person",
            status: .pending,
            person: 2,
            visitDate: Date(),
            dueDate: Date(),
            members: members,
            availablePackages: packages
        )
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
        showLoadingAlert()
        
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
    
    func notifyGroupContributorCreated(data: TripInvitationModel) {
        let viewModel = GroupInvitationTripViewModel(tripData: data)
        let groupContributorVC = GroupInvitationTripViewController(viewModel: viewModel)
        navigationController?.pushViewController(groupContributorVC, animated: true)
    }
}

// MARK: - NotificationDetailViewDelegate
extension NotificationDetailViewController: NotificationDetailViewDelegate {
    func notificationDetailViewDidTapAccept() {
        acceptAction()
    }
    
    func notificationDetailViewDidTapDecline() {
        handleDeclineAction()
    }
}

// MARK: - GroupInvitationTripCoordinatorDelegate
extension NotificationDetailViewController: GroupInvitationTripCoordinatorDelegate {
    func didFinishGroupInvitationTrip() {
        // Handle when user finishes with group invitation trip
        navigationController?.popViewController(animated: true)
    }
    
    func didRequestBooking(for trip: TripInvitationModel) {
        // Handle booking request - navigate to booking flow
        let alert = UIAlertController(
            title: "Booking",
            message: "Navigate to booking flow for \(trip.title)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // In real implementation, you would navigate to booking flow here
        // let bookingCoordinator = BookingCoordinator(navigationController: navigationController)
        // bookingCoordinator.start(with: trip)
    }
    
    func didRequestMemberProfile(for member: TripsMember) {
        // Handle member profile request
        let alert = UIAlertController(
            title: "Member Profile",
            message: "Navigate to profile for \(member.name)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // In real implementation, you would navigate to member profile here
        // let profileCoordinator = MemberProfileCoordinator(navigationController: navigationController)
        // profileCoordinator.start(with: member)
    }
}
