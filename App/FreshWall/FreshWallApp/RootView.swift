//
//  RootView.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/25/25.
//
import SwiftUI

struct RootView: View {
    @State private var isLoading = true

    @State private var sessionStore: SessionStore
    let loginManager: LoginManager

    init(
        sessionStore: SessionStore,
        loginManager: LoginManager
    ) {
        _sessionStore = State(wrappedValue: sessionStore)
        self.loginManager = loginManager
    }

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen()
            } else if let session = sessionStore.session {
                MainAppView(
                    sessionStore: AuthenticatedSessionStore(
                        sessionStore: sessionStore,
                        session: session,
                        loginManager: loginManager
                    )
                )
            } else {
                AuthFlowView(
                    loginManager: loginManager
                )
            }
        }
        .task {
            // Ensure loading screen shows for minimum 2 seconds
            async let sessionRestore: Void = loginManager.restoreSessionIfAvailable()
            async let minimumDelay: Void = Task.sleep(nanoseconds: 2_000_000_000)

            _ = await (sessionRestore, minimumDelay)
            isLoading = false
        }
    }
}
