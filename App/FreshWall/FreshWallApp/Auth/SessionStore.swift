//
//  SessionStore.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//
import Observation

// MARK: - SessionStore

@Observable
@MainActor
class SessionStore {
    var session: UserSession?

    func startSession(_ session: UserSession) {
        self.session = session
    }

    func logout() {
        session = nil
    }
}

// MARK: - AuthenticatedSessionStore

@MainActor
struct AuthenticatedSessionStore {
    let sessionStore: SessionStore
    let session: UserSession

    func logout() {
        sessionStore.logout()
    }
}
