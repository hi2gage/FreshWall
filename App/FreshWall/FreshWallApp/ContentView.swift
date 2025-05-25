import SwiftUI

/// Root view that toggles between Auth and Main app flows.
struct ContentView: View {
    @State private var sessionStore: SessionStore = .init()

    private let authService = AuthService()
    private let userService = UserService()
    private let sessionService = SessionService()

    var body: some View {
        Group {
            if let session = sessionStore.session {
                MainAppView(
                    session: session,
                    sessionStore: sessionStore
                )
            } else {
                AuthFlowView(
                    loginManager: LoginManager(
                        sessionStore: sessionStore,
                        authService: authService,
                        userService: userService,
                        sessionService: sessionService
                    )
                )
            }
        }
    }
}

#Preview {
    FreshWallPreview {
        ContentView()
    }
}
