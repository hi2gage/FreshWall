import FirebaseFirestore
import SwiftUI

struct MainAppView: View {
    @State private var routerPath = RouterPath()

    /// Authenticated user session with team context.
    let session: UserSession
    let sessionStore: SessionStore

    private var userService: UserService
    private var clientService: ClientServiceProtocol
    private var incidentService: IncidentServiceProtocol
    private var memberService: MemberServiceProtocol

    init(session: UserSession, sessionStore: SessionStore) {
        let firestore = Firestore.firestore()

        self.session = session
        self.sessionStore = sessionStore
        userService = UserService()
        clientService = ClientService(firestore: firestore, session: session)
        incidentService = IncidentService(firestore: firestore, session: session)
        memberService = MemberService(firestore: firestore, session: session)
    }

    var body: some View {
        NavigationStack(path: $routerPath.path) {
            MainListView(
                sessionStore: sessionStore
            )
            .withAppRouter(
                userService: userService,
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
            session: UserSession(userId: "user123", teamId: "team123"),
            sessionStore: SessionStore()
        )
    }
}
