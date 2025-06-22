//
//  SessionService.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/24/25.
//

@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

struct SessionService {
    var firestore: Firestore {
        Firestore.firestore()
    }

    init() {
        #if DEBUG
            let settings = FirestoreSettings()
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            settings.isPersistenceEnabled = false
            Firestore.firestore().settings = settings

            Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        #endif
    }

    func fetchUserRecord(for user: FirebaseAuth.User) async throws -> UserSession {
        let teamsSnapshot = try await firestore.collection("teams").getDocuments()

        for teamDoc in teamsSnapshot.documents {
            let userRef = teamDoc.reference.collection("users").document(user.uid)
            let userDoc = try await userRef.getDocument()

            if userDoc.exists {
                let userModel = try userDoc.data(as: UserDTO.self)
                return UserSession(
                    userId: user.uid,
                    displayName: userModel.displayName,
                    teamId: teamDoc.documentID
                )
            }
        }

        throw NSError(
            domain: "SessionService",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "User not found in any team"]
        )
    }
}
