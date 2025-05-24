//
//  ContentView.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        Group {
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
                .padding()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
            .environmentObject(AuthService())
    }
}
