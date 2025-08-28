//
//  NotificationDetailCoordinator.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 25/08/25.
//


import Foundation
import UIKit

// MARK: - Optional: If you want to follow MVVM pattern with Coordinator
final class NotificationDetailCoordinator: BaseCoordinator {
    struct Input {
        let navigationController: UINavigationController
        let flow: Flow
        
        enum Flow {
            case detail(notification: NotificationItem)
        }
    }
    
    init(input: Input) {
        self.input = input
        super.init(navigationController: input.navigationController)
    }
    
    override func start() {
        super.start()
        
        switch input.flow {
        case .detail(let notification):
            let notificationDetailViewController = NotificationDetailViewController(notification: notification)
            start(viewController: notificationDetailViewController)
        }
    }
    
    private let input: Input
}

