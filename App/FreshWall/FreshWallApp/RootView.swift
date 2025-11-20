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
        ZStack {
            if isLoading {
                LoadingScreen()
                    .transition(.opacity)
                    .zIndex(1)
            } else if let session = sessionStore.session {
                MainAppView(
                    sessionStore: AuthenticatedSessionStore(
                        sessionStore: sessionStore,
                        session: session,
                        loginManager: loginManager
                    )
                )
                .transition(.opacity)
            } else {
                AuthFlowView(
                    loginManager: loginManager
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .task {
            // Ensure loading screen shows for minimum 1 second
            async let sessionRestore: Void = loginManager.restoreSessionIfAvailable()
            async let minimumDelay: Void = Task.sleep(nanoseconds: 1_000_000_000)

            _ = try? await (sessionRestore, minimumDelay)
            isLoading = false
        }
    }
}
