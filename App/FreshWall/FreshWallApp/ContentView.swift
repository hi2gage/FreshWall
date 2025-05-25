//
//  ContentView.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var authService = AuthService()
    @State private var userService = UserService()
    @State private var routerPath = RouterPath()

    var body: some View {
        NavigationStack(path: $routerPath.path) {
            if authService.isAuthenticated {
                VStack(spacing: 16) {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                    Button("LogOut") {
                        authService.signOut()
                    }
                }
                .withAppRouter(userService: userService)
                .padding()
            } else {
                LoginView(authService: authService)
                    .withAppRouter(userService: userService)
            }
        }
        .environment(routerPath)
    }
}

#Preview {
    ContentView()
}
