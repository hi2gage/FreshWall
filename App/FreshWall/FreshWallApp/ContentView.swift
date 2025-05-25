//
//  ContentView.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//

@preconcurrency import FirebaseFirestore
import SwiftUI

struct ContentView: View {
    /// Shared Firestore instance
    let firestore: Firestore

    @State private var authService: AuthService
    
    @State private var userService: UserService
    @State private var clientService: ClientService
    @State private var incidentService: IncidentService
    @State private var memberService: MemberService

    @State private var routerPath = RouterPath()

    init() {
        authService = AuthService()

        let firestore = Firestore.firestore()
        self.firestore = firestore

        let userService = UserService()
        self.userService = userService

        clientService = ClientService(
            firestore: firestore,
            userService: userService
        )
        incidentService = IncidentService(
            firestore: firestore,
            userService: userService
        )
        memberService = MemberService(
            firestore: firestore,
            userService: userService
        )
    }

    var body: some View {
        NavigationStack(path: $routerPath.path) {
            if authService.isAuthenticated {
                MainListView(authService: authService, userService: userService)
                    .withAppRouter(
                        userService: userService,
                        clientService: clientService,
                        incidentService: incidentService,
                        memberService: memberService
                    )
            } else {
                LoginView(authService: authService)
                    .withAppRouter(
                        userService: userService,
                        clientService: clientService,
                        incidentService: incidentService,
                        memberService: memberService
                    )
            }
        }
        .environment(routerPath)
    }
}

#Preview {
    FreshWallPreview {
        ContentView()
    }
}
