import FirebaseFirestore
import SwiftUI

struct MainAppView: View {
    @State private var routerPath = RouterPath()

    /// Authenticated user session with team context.
    private let sessionStore: AuthenticatedSessionStore

    private let clientService: ClientServiceProtocol
    private let incidentService: IncidentServiceProtocol
    private let memberService: MemberServiceProtocol

    init(sessionStore: AuthenticatedSessionStore) {
        self.sessionStore = sessionStore

        let firestore = Firestore.firestore()
        clientService = ClientService(firestore: firestore, session: sessionStore.session)
        incidentService = IncidentService(firestore: firestore, session: sessionStore.session)
        memberService = MemberService(firestore: firestore, session: sessionStore.session)
    }

    var body: some View {
        NavigationStack(path: $routerPath.path) {
            MainListView(sessionStore: sessionStore)
                .withAppRouter(
                    clientService: clientService,
                    incidentService: incidentService,
                    memberService: memberService
                )
        }
        .environment(routerPath)
    }
}

#Preview {
    FreshWallPreview {
        MainAppView(
            sessionStore: AuthenticatedSessionStore(
                sessionStore: SessionStore(),
                session: UserSession(
                    userId: "user123",
                    displayName: "",
                    teamId: "team123"
                )
            )
        )
    }
}
