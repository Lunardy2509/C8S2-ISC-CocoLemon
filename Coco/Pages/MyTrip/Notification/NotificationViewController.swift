//
//  NotificationViewController.swift
//  Coco
//
//  Created by Assistant on 22/08/25.
//

import UIKit

final class NotificationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        return tableView
    }()
    
    // Mock data for notifications
    private let notifications: [NotificationItem] = [
        NotificationItem(
            id: "1",
            senderName: "Adhis Aurellia",
            message: "invited you to join collaboration trip",
            tripName: "CoCoLemon goes to Bali",
            avatarImageName: "person.circle.fill",
            isUnread: true
        ),
        NotificationItem(
            id: "2", 
            senderName: "Ferdinand Lunardy",
            message: "invited you to join collaboration trip",
            tripName: "CoCoLemon goes to Bali",
            avatarImageName: "person.circle.fill",
            isUnread: true
        )
    ]
}

private extension NotificationViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupNavigationBar() {
        title = "Notification"
        
        // Use native back button with custom text
        let backButton = UIBarButtonItem()
        backButton.title = "My Trip"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
}

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        let notification = notifications[indexPath.row]
        cell.configure(with: notification)
        return cell
    }
}

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle notification tap if needed
    }
}

// MARK: - Models
struct NotificationItem {
    let id: String
    let senderName: String
    let message: String
    let tripName: String
    let avatarImageName: String
    let isUnread: Bool
}
