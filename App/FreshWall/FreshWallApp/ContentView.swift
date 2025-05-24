//
//  ContentView.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var routerPath = RouterPath()

    var body: some View {
        NavigationStack(path: $routerPath.path) {
            Group {
                if authService.isAuthenticated {
                    VStack(spacing: 16) {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                        Text("Hello, world!")
                        Button("Fetch") {
                            guard let user = authService.userSession else {
                                print("no user")
                                return
                            }
                            authService.fetchUserRecord(user: user)
                        }
                        Button("LogOut") {
                            authService.signOut()
                        }
                    }
                    .padding()
                } else {
                    LoginView()
                }
            }
            .withAppRouter()
        }
        .environment(routerPath)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
