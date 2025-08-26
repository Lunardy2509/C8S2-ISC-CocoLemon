

//
//  NotificationViewController.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 22/08/25.
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
            senderName: "Reminder",
            message: "Invited You to join colaboration trip",
            tripName: "CoCoLemon goes to Bali",
            avatarIcon: Contributor.remindFriend,
            isUnread: false
        ),
        NotificationItem(
            id: "2",
            senderName: "Ferdinand Lunardy",
            message: "Invited You to join colaboration trip",
            tripName: "CoCoLemon goes to Bali",
            avatarIcon: Contributor.ferdinand,
            isUnread: true
        ),
        NotificationItem(
            id: "3",
            senderName: "Griselda Shavilla",
            message: "Griselda Shavilla has joined colaboration trip",
            tripName: "CoCoLemon goes to Bali",
            avatarIcon: Contributor.griselda,
            isUnread: true
        ),
        NotificationItem(
            id: "4",
            senderName: "Ferdinand Lunardy",
            message: "Ferdinand Lunardy has joined colaboration trip",
            tripName: "CoCoLemon goes to Bali",
            avatarIcon: Contributor.ferdinand,
            isUnread: true
        ),
        NotificationItem(
            id: "5",
            senderName: "Cynthia Shabrina",
            message: "Cynthia Shabrina  has joined colaboration trip",
            tripName: "CoCoLemon goes to Bali",
            avatarIcon: Contributor.cynthia,
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
        let backButton = UIBarButtonItem()
        backButton.title = "My Trip"
        backButton.tintColor = .black
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
        
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 64
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let notification = notifications[indexPath.row]
            navigateToNotificationDetail(notification: notification)
        }
}

private extension NotificationViewController {
    func navigateToNotificationDetail(notification: NotificationItem) {
        let notificationDetailViewController = NotificationDetailViewController(notification: notification)
        navigationController?.pushViewController(notificationDetailViewController, animated: true)
    }
}



