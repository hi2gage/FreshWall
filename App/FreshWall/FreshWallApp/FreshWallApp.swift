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
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

// MARK: - AppRootView

/// Root view wrapper that applies app-wide modifiers with access to environment
struct AppRootView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
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
