import SwiftData
import SwiftUI

@MainActor
@Observable
final class LoginRouterPath {
    /// The navigation path for pushed destinations.
    var path: [RouterDestination] = []

    /// Pushes a new destination onto the navigation path.
    func push(_ item: RouterDestination) {
        path.append(item)
    }

    /// Pops the last destination from the navigation path.
    func pop() {
        _ = path.popLast()
    }
}

extension LoginRouterPath {
    /// Destinations for navigation within the app.
    enum RouterDestination: Hashable {
        /// Sign up screen for new users.
        case signup
        case signupWithTeam
    }
}

// swiftlint:disable cyclomatic_complexity
extension View {
    /// Sets up routing destinations for various views, injecting necessary services.
    func withAppLoginRouter(
        loginManager: LoginManager
    ) -> some View {
        navigationDestination(for: LoginRouterPath.RouterDestination.self) { destination in
            switch destination {
            case .signup:
                SignupWithNewTeamView(loginManager: loginManager)
            case .signupWithTeam:
                SignupWithExistingTeamView(loginManager: loginManager)
            }
        }
    }
}

// swiftlint:enable cyclomatic_complexity
