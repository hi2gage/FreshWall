//
//  FreshWallApp.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//

import FirebaseCore
@preconcurrency import FirebaseFirestore
import GoogleSignIn
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

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - FreshWallApp

@main
struct FreshWallApp: App {
    @Environment(\.colorScheme) var colorScheme

    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(colorScheme == .dark ? .freshWallOrange : .freshWallBlue)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Process pending address resolution tasks when app becomes active
                    Task {
                        await ServiceContainer.shared.addressResolutionService.processPendingTasks()
                    }
                }
        }
    }
}
