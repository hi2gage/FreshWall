import FirebaseFirestore
import SwiftUI

struct MainAppView: View {
    @State private var routerPath = RouterPath()

    /// Authenticated user session with team context.
    private let sessionStore: AuthenticatedSessionStore

    private let clientService: ClientServiceProtocol

    private let incidentModelService: IncidentModelServiceProtocol
    private let incidentPhotoService: IncidentPhotoServiceProtocol
    private let clientModelService: ClientModelServiceProtocol
    private let userModelService: UserModelServiceProtocol

    private let incidentService: IncidentServiceProtocol
    private let memberService: MemberServiceProtocol

    init(sessionStore: AuthenticatedSessionStore) {
        self.sessionStore = sessionStore

        let firestore = Firestore.firestore()

        incidentModelService = IncidentModelService(firestore: firestore)
        incidentPhotoService = IncidentPhotoService()
        clientModelService = ClientModelService(firestore: firestore)
        userModelService = UserModelService(firestore: firestore)

        clientService = ClientService(
            modelService: clientModelService,
            session: sessionStore.session
        )

        incidentService = IncidentService(
            modelService: incidentModelService,
            photoService: incidentPhotoService,
            clientModelService: clientModelService,
            userModelService: userModelService,
            metadataService: PhotoMetadataService(),
            session: sessionStore.session
        )

        memberService = MemberService(firestore: firestore, session: sessionStore.session)
    }

    var body: some View {
        NavigationStack(path: $routerPath.path) {
            MainListView(sessionStore: sessionStore)
                .withAppRouter(
                    clientService: clientService,
                    incidentService: incidentService,
                    memberService: memberService,
                    currentUserId: sessionStore.session.userId
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
