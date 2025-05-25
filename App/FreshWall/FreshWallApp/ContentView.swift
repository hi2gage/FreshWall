import SwiftUI

/// Root view that toggles between Auth and Main app flows.
struct ContentView: View {
    @State private var sessionStore: SessionStore = SessionStore()

    var body: some View {
        Group {
            if let session = sessionStore.session {
                MainAppView(
                    session: session,
                    sessionStore: sessionStore
                )
            } else {
                AuthFlowView(
                    sessionStore: sessionStore
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

