import SwiftUI
import FirebaseFirestore

struct MainAppView: View {
    /// Authenticated user session with team context.
    let session: UserSession

    let sessionStore: SessionStore

    @State private var userService: UserService
    @State private var clientService: ClientServiceProtocol
    @State private var incidentService: IncidentServiceProtocol
    @State private var memberService: MemberServiceProtocol
    @State private var routerPath = RouterPath()

    init(session: UserSession, sessionStore: SessionStore) {
        self.session = session
        self.sessionStore = sessionStore
        let firestore = Firestore.firestore()
        let userSvc = UserService()
        userSvc.teamId = session.teamId
        _userService = State(wrappedValue: userSvc)
        _clientService = State(wrappedValue: ClientService(firestore: firestore, userService: userSvc))
        _incidentService = State(wrappedValue: IncidentService(firestore: firestore, userService: userSvc))
        _memberService = State(wrappedValue: MemberService(firestore: firestore, userService: userSvc))
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
