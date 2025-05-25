import SwiftUI

/// Root view that toggles between Auth and Main app flows.
struct ContentView: View {
    private var sessionStore: SessionStore = .init()

    private let authService = AuthService()
    private let userService = UserService()
    private let sessionService = SessionService()

    var body: some View {
        RootView(
            sessionStore: sessionStore,
            loginManager: LoginManager(
                sessionStore: sessionStore,
                authService: authService,
                userService: userService,
                sessionService: sessionService
            )
        )
    }
}

#Preview {
    FreshWallPreview {
        ContentView()
    }
}
