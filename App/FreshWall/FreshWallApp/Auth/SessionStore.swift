//
//  SessionStore.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//
import Observation

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
