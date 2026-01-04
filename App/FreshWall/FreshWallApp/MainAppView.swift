@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
import os
import SwiftUI

struct MainAppView: View {
    private let logger = Logger.freshWall(category: "MainAppView")
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
            session: sessionStore.session
        )

        memberService = MemberService(firestore: firestore, session: sessionStore.session)
    }

    var body: some View {
        VStack(spacing: 0) {
            BackgroundUploadIndicatorView()

            NavigationStack(path: $routerPath.path) {
                MainListView(sessionStore: sessionStore)
                    .withAppRouter(
                        clientService: clientService,
                        incidentService: incidentService,
                        memberService: memberService,
                        userSession: sessionStore.session,
                        currentUserId: sessionStore.session.userId,
                        sessionStore: sessionStore
                    )
            }
            .environment(routerPath)
        }
        .onShake {
            routerPath.push(.debugSettings)
        }
        .taskOnce {
            _ = try? await incidentService.fetchIncidents()
            logger.info("✅ Incidents prefetched on first appear")
        }
//        .environment(BackgroundUploadService.shared)
    }
}

#Preview {
    FreshWallPreview {
        MainAppView(
            sessionStore: AuthenticatedSessionStore(
                sessionStore: SessionStore(),
                session: UserSession(
                    userId: "user123",
                    displayName: "Preview User",
                    teamId: "team123",
                    role: .admin
                ),
                loginManager: LoginManager(
                    sessionStore: SessionStore(),
                    authService: AuthService(),
                    userService: UserService(),
                    sessionService: SessionService()
                )
            )
        )
    }
}
