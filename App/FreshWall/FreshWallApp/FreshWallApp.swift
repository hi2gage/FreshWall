//
//  FreshWallApp.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//

import FirebaseCore
@preconcurrency import FirebaseFirestore
import SwiftUI

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseConfiguration.configureFirebase()
        return true
    }
}

// MARK: - FreshWallApp

@main
struct FreshWallApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Process pending address resolution tasks when app becomes active
                    Task {
                        await ServiceContainer.shared.addressResolutionService.processPendingTasks()
                    }
                }
        }
    }
}
