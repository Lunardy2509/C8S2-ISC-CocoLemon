//
//  NotificationModel.swift
//  Coco
//
//  Created by Ahmad Al Wabil on 25/08/25.
//
import Foundation
import UIKit

struct NotificationItem {
    let id: String
    let senderName: String
    let message: String
    let tripName: String
    let avatarIcon: Icon
    let isUnread: Bool
}
