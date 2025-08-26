//
//  GroupFormDismissEnvironment.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import SwiftUI

struct GroupFormDismissKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var groupFormDismiss: (() -> Void)? {
        get { self[GroupFormDismissKey.self] }
        set { self[GroupFormDismissKey.self] = newValue }
    }
}

extension Notification.Name {
    static let groupFormShouldDismiss = Notification.Name("groupFormShouldDismiss")
    static let newTripCreated = Notification.Name("newTripCreated")
    static let newLocalTripCreated = Notification.Name("newLocalTripCreated")
}
