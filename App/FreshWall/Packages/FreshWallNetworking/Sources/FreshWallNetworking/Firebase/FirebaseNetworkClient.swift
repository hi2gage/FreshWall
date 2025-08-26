@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
@preconcurrency import FirebaseStorage
import Foundation

public final class FirebaseNetworkClient: NetworkClient {
    private var auth: Auth?
    private var firestore: Firestore?
    private var functions: Functions?
    private var storage: Storage?

    public init() {}

    public func configure(with configuration: NetworkConfiguration) async throws {
        // Configure Firebase services
        auth = Auth.auth()
        firestore = Firestore.firestore()
        functions = Functions.functions()
        storage = Storage.storage()

        // Configure emulator if needed
        if configuration.useEmulator {
            auth?.useEmulator(withHost: configuration.emulatorHost, port: configuration.authEmulatorPort)

            let settings = firestore!.settings
            settings.host = "\(configuration.emulatorHost):\(configuration.firestoreEmulatorPort)"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
            firestore?.settings = settings

            functions?.useEmulator(withHost: configuration.emulatorHost, port: configuration.functionsEmulatorPort)
            storage?.useEmulator(withHost: configuration.emulatorHost, port: configuration.storageEmulatorPort)
        }
    }

    // MARK: - Authentication

    public func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        guard let auth = auth else { throw NetworkError.notAuthenticated }

        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return AuthenticatedUser(id: result.user.uid, email: result.user.email)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func signUp(email: String, password: String) async throws -> AuthenticatedUser {
        guard let auth = auth else { throw NetworkError.notAuthenticated }

        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return AuthenticatedUser(id: result.user.uid, email: result.user.email)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func signOut() async throws {
        guard let auth = auth else { throw NetworkError.notAuthenticated }

        do {
            try auth.signOut()
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getCurrentUser() async -> AuthenticatedUser? {
        guard let user = auth?.currentUser else { return nil }

        return AuthenticatedUser(id: user.uid, email: user.email)
    }

    // MARK: - Team Operations

    public func createTeam(name: String, userId _: String, userName: String) async throws -> String {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = [
                "teamName": name,
                "displayName": userName,
            ]

            let result = try await functions.httpsCallable("createTeamCreateUser").call(data)

            guard let responseData = result.data as? [String: Any],
                  let teamId = responseData["teamId"] as? String else {
                throw NetworkError.invalidData
            }

            return teamId
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getTeam(teamId: String) async throws -> Team {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let document = try await firestore.collection("teams").document(teamId).getDocument()

            guard document.exists,
                  let data = document.data() else {
                throw NetworkError.documentNotFound
            }

            return try mapTeamFromFirestore(document: document, data: data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getTeamsForUser(userId: String) async throws -> [Team] {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            // Query all teams where the user exists
            let teamsSnapshot = try await firestore.collection("teams").getDocuments()
            var teams: [Team] = []

            for teamDoc in teamsSnapshot.documents {
                // Check if user exists in this team
                let userDoc = try await firestore
                    .collection("teams")
                    .document(teamDoc.documentID)
                    .collection("users")
                    .document(userId)
                    .getDocument()

                if userDoc.exists {
                    let team = try mapTeamFromFirestore(document: teamDoc, data: teamDoc.data())
                    teams.append(team)
                }
            }

            return teams
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - User Operations

    public func createUser(userId: String, email: String, name: String, teamId: String, role: UserRole) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data: [String: Any] = [
                "teamId": teamId,
                "userId": userId,
                "email": email,
                "displayName": name,
                "role": role.rawValue,
            ]

            _ = try await functions.httpsCallable("createUser").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getUser(userId: String, teamId: String) async throws -> User {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let document = try await firestore
                .collection("teams")
                .document(teamId)
                .collection("users")
                .document(userId)
                .getDocument()

            guard document.exists,
                  let data = document.data() else {
                throw NetworkError.documentNotFound
            }

            return try mapUserFromFirestore(document: document, data: data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getUsersForTeam(teamId: String) async throws -> [User] {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let snapshot = try await firestore
                .collection("teams")
                .document(teamId)
                .collection("users")
                .order(by: "displayName")
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try mapUserFromFirestore(document: doc, data: doc.data())
            }
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func updateUser(userId: String, teamId: String, updates: UserUpdate) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            var data: [String: Any] = [
                "teamId": teamId,
                "userId": userId,
            ]

            if let displayName = updates.displayName {
                data["displayName"] = displayName
            }

            if let role = updates.role {
                data["role"] = role.rawValue
            }

            _ = try await functions.httpsCallable("updateUser").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func deleteUser(userId: String, teamId: String) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = [
                "teamId": teamId,
                "userId": userId,
            ]

            _ = try await functions.httpsCallable("deleteUser").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Client Operations

    public func createClient(teamId: String, client: ClientCreate) async throws -> String {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            var data: [String: Any] = [
                "teamId": teamId,
                "name": client.name,
            ]

            if let notes = client.notes {
                data["notes"] = notes
            }

            let result = try await functions.httpsCallable("createClient").call(data)

            guard let responseData = result.data as? [String: Any],
                  let clientId = responseData["id"] as? String else {
                throw NetworkError.invalidData
            }

            return clientId
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getClient(clientId: String, teamId: String) async throws -> Client {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let document = try await firestore
                .collection("teams")
                .document(teamId)
                .collection("clients")
                .document(clientId)
                .getDocument()

            guard document.exists,
                  let data = document.data() else {
                throw NetworkError.documentNotFound
            }

            return try mapClientFromFirestore(document: document, data: data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getClientsForTeam(teamId: String) async throws -> [Client] {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let snapshot = try await firestore
                .collection("teams")
                .document(teamId)
                .collection("clients")
                .whereField("isDeleted", isEqualTo: false)
                .order(by: "name")
                .getDocuments()

            return try snapshot.documents.compactMap { doc in
                try mapClientFromFirestore(document: doc, data: doc.data())
            }
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func updateClient(clientId: String, teamId: String, updates: ClientUpdate) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            var data: [String: Any] = [
                "teamId": teamId,
                "clientId": clientId,
            ]

            if let name = updates.name {
                data["name"] = name
            }

            if let notes = updates.notes {
                data["notes"] = notes
            }

            _ = try await functions.httpsCallable("updateClient").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func deleteClient(clientId: String, teamId: String) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = [
                "teamId": teamId,
                "clientId": clientId,
            ]

            _ = try await functions.httpsCallable("deleteClient").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Incident Operations

    public func createIncident(teamId: String, incident: IncidentCreate) async throws -> String {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = mapIncidentCreateToFirestore(teamId: teamId, incident: incident)
            let result = try await functions.httpsCallable("createIncident").call(data)

            guard let responseData = result.data as? [String: Any],
                  let incidentId = responseData["id"] as? String else {
                throw NetworkError.invalidData
            }

            return incidentId
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getIncident(incidentId: String, teamId: String) async throws -> Incident {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let document = try await firestore
                .collection("teams")
                .document(teamId)
                .collection("incidents")
                .document(incidentId)
                .getDocument()

            guard document.exists,
                  let data = document.data() else {
                throw NetworkError.documentNotFound
            }

            return try await mapIncidentFromFirestore(document: document, data: data, teamId: teamId)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getIncidentsForClient(clientId: String, teamId: String) async throws -> [Incident] {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let clientRef = firestore
                .collection("teams")
                .document(teamId)
                .collection("clients")
                .document(clientId)

            let snapshot = try await firestore
                .collection("teams")
                .document(teamId)
                .collection("incidents")
                .whereField("clientRef", isEqualTo: clientRef)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            return try await mapIncidentsFromSnapshot(snapshot: snapshot, teamId: teamId)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func getIncidentsForTeam(teamId: String) async throws -> [Incident] {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }

        do {
            let snapshot = try await firestore
                .collection("teams")
                .document(teamId)
                .collection("incidents")
                .order(by: "createdAt", descending: true)
                .getDocuments()

            return try await mapIncidentsFromSnapshot(snapshot: snapshot, teamId: teamId)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func updateIncident(incidentId: String, teamId: String, updates: IncidentUpdate) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = mapIncidentUpdateToFirestore(incidentId: incidentId, teamId: teamId, updates: updates)
            _ = try await functions.httpsCallable("updateIncident").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func deleteIncident(incidentId: String, teamId: String) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = [
                "teamId": teamId,
                "incidentId": incidentId,
            ]

            _ = try await functions.httpsCallable("deleteIncident").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Storage Operations

    public func uploadImage(data: Data, path: String) async throws -> URL {
        guard let storage = storage else { throw NetworkError.notAuthenticated }

        do {
            let storageRef = storage.reference().child(path)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            _ = try await storageRef.putDataAsync(data, metadata: metadata)
            let url = try await storageRef.downloadURL()

            return url
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func deleteImage(at url: URL) async throws {
        guard let storage = storage else { throw NetworkError.notAuthenticated }

        do {
            let storageRef = storage.reference(forURL: url.absoluteString)
            try await storageRef.delete()
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Invite Operations

    public func createInviteCode(teamId: String, createdBy _: String) async throws -> String {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = [
                "teamId": teamId,
            ]

            let result = try await functions.httpsCallable("createInviteCode").call(data)

            guard let responseData = result.data as? [String: Any],
                  let code = responseData["code"] as? String else {
                throw NetworkError.invalidData
            }

            return code
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func validateInviteCode(_ code: String) async throws -> InviteCodeInfo {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = ["code": code]
            let result = try await functions.httpsCallable("validateInviteCode").call(data)

            guard let responseData = result.data as? [String: Any],
                  let teamId = responseData["teamId"] as? String,
                  let teamName = responseData["teamName"] as? String else {
                throw NetworkError.invalidData
            }

            return InviteCodeInfo(teamId: teamId, teamName: teamName)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    public func joinTeamWithCode(_ code: String, userId _: String, userName: String, userEmail _: String) async throws {
        guard let functions = functions else { throw NetworkError.notAuthenticated }

        do {
            let data = [
                "code": code,
                "displayName": userName,
            ]

            _ = try await functions.httpsCallable("joinTeamCreateUser").call(data)
        } catch {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Helper Methods

    private func mapFirebaseError(_ error: Error) -> NetworkError {
        if let nsError = error as NSError? {
            switch nsError.code {
            case AuthErrorCode.userNotFound.rawValue,
                 AuthErrorCode.wrongPassword.rawValue:
                return .notAuthenticated
            case AuthErrorCode.networkError.rawValue:
                return .networkFailure(error)
            case FunctionsErrorCode.permissionDenied.rawValue:
                return .permissionDenied
            default:
                if let errorMessage = nsError.userInfo["message"] as? String {
                    return .serverError(errorMessage)
                }
            }
        }
        return .unknown(error)
    }

    private func mapTeamFromFirestore(document: DocumentSnapshot, data: [String: Any]) throws -> Team {
        guard let name = data["name"] as? String,
              let teamCode = data["teamCode"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            throw NetworkError.decodingError(NSError(domain: "FirebaseMapper", code: 0))
        }

        return Team(
            id: document.documentID,
            name: name,
            teamCode: teamCode,
            createdAt: createdAt
        )
    }

    private func mapUserFromFirestore(document: DocumentSnapshot, data: [String: Any]) throws -> User {
        guard let displayName = data["displayName"] as? String,
              let email = data["email"] as? String,
              let roleString = data["role"] as? String,
              let role = UserRole(rawValue: roleString),
              let isDeleted = data["isDeleted"] as? Bool else {
            throw NetworkError.decodingError(NSError(domain: "FirebaseMapper", code: 0))
        }

        let deletedAt = (data["deletedAt"] as? Timestamp)?.dateValue()

        return User(
            id: document.documentID,
            displayName: displayName,
            email: email,
            role: role,
            isDeleted: isDeleted,
            deletedAt: deletedAt
        )
    }

    private func mapClientFromFirestore(document: DocumentSnapshot, data: [String: Any]) throws -> Client {
        guard let name = data["name"] as? String,
              let isDeleted = data["isDeleted"] as? Bool,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue(),
              let lastIncidentAt = (data["lastIncidentAt"] as? Timestamp)?.dateValue() else {
            throw NetworkError.decodingError(NSError(domain: "FirebaseMapper", code: 0))
        }

        let notes = data["notes"] as? String
        let deletedAt = (data["deletedAt"] as? Timestamp)?.dateValue()

        return Client(
            id: document.documentID,
            name: name,
            notes: notes,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            createdAt: createdAt,
            lastIncidentAt: lastIncidentAt
        )
    }

    private func mapIncidentFromFirestore(document: DocumentSnapshot, data: [String: Any], teamId _: String) async throws -> Incident {
        guard let firestore = firestore else { throw NetworkError.notAuthenticated }
        guard let projectTitle = data["projectTitle"] as? String,
              let description = data["description"] as? String,
              let area = data["area"] as? Double,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue(),
              let startTime = (data["startTime"] as? Timestamp)?.dateValue(),
              let endTime = (data["endTime"] as? Timestamp)?.dateValue(),
              let createdByRef = data["createdBy"] as? DocumentReference,
              let billable = data["billable"] as? Bool,
              let status = data["status"] as? String else {
            throw NetworkError.decodingError(NSError(domain: "FirebaseMapper", code: 0))
        }

        // Extract IDs from references
        let clientId = (data["clientRef"] as? DocumentReference)?.documentID
        let createdById = createdByRef.documentID
        let lastModifiedById = (data["lastModifiedBy"] as? DocumentReference)?.documentID

        // Map worker references to IDs
        let workerRefs = data["workerRefs"] as? [DocumentReference] ?? []
        let workerIds = workerRefs.map { $0.documentID }

        // Map photos
        let beforePhotos = try mapPhotosFromArray(data["beforePhotos"] as? [[String: Any]] ?? [])
        let afterPhotos = try mapPhotosFromArray(data["afterPhotos"] as? [[String: Any]] ?? [])

        return Incident(
            id: document.documentID,
            projectTitle: projectTitle,
            clientId: clientId,
            workerIds: workerIds,
            description: description,
            area: area,
            createdAt: createdAt,
            startTime: startTime,
            endTime: endTime,
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos,
            createdById: createdById,
            lastModifiedById: lastModifiedById,
            lastModifiedAt: (data["lastModifiedAt"] as? Timestamp)?.dateValue(),
            billable: billable,
            rate: data["rate"] as? Double,
            status: status,
            materialsUsed: data["materialsUsed"] as? String
        )
    }

    private func mapIncidentsFromSnapshot(snapshot: QuerySnapshot, teamId: String) async throws -> [Incident] {
        var incidents: [Incident] = []

        for document in snapshot.documents {
            let incident = try await mapIncidentFromFirestore(
                document: document,
                data: document.data(),
                teamId: teamId
            )
            incidents.append(incident)
        }

        return incidents
    }

    private func mapPhotosFromArray(_ array: [[String: Any]]) throws -> [IncidentPhoto] {
        return try array.compactMap { photoData in
            guard let id = photoData["id"] as? String,
                  let url = photoData["url"] as? String else {
                throw NetworkError.decodingError(NSError(domain: "FirebaseMapper", code: 0))
            }

            let captureDate = (photoData["captureDate"] as? Timestamp)?.dateValue()

            var latitude: Double?
            var longitude: Double?

            if let location = photoData["location"] as? GeoPoint {
                latitude = location.latitude
                longitude = location.longitude
            }

            return IncidentPhoto(
                id: id,
                url: url,
                captureDate: captureDate,
                latitude: latitude,
                longitude: longitude
            )
        }
    }

    private func mapIncidentCreateToFirestore(teamId: String, incident: IncidentCreate) -> [String: Any] {
        guard let firestore = firestore else { return [:] }

        var data: [String: Any] = [
            "teamId": teamId,
            "projectTitle": incident.projectTitle,
            "description": incident.description,
            "area": incident.area,
            "startTime": incident.startTime,
            "endTime": incident.endTime,
            "billable": incident.billable,
            "status": incident.status,
        ]

        if let clientId = incident.clientId {
            data["clientId"] = clientId
        }

        if !incident.workerIds.isEmpty {
            data["workerIds"] = incident.workerIds
        }

        if let rate = incident.rate {
            data["rate"] = rate
        }

        if let materialsUsed = incident.materialsUsed {
            data["materialsUsed"] = materialsUsed
        }

        // Map photos
        if !incident.beforePhotos.isEmpty {
            data["beforePhotos"] = incident.beforePhotos.map { mapPhotoToFirestore($0) }
        }

        if !incident.afterPhotos.isEmpty {
            data["afterPhotos"] = incident.afterPhotos.map { mapPhotoToFirestore($0) }
        }

        return data
    }

    private func mapIncidentUpdateToFirestore(incidentId: String, teamId: String, updates: IncidentUpdate) -> [String: Any] {
        var data: [String: Any] = [
            "teamId": teamId,
            "incidentId": incidentId,
        ]

        if let projectTitle = updates.projectTitle {
            data["projectTitle"] = projectTitle
        }

        if let clientId = updates.clientId {
            data["clientId"] = clientId
        }

        if let workerIds = updates.workerIds {
            data["workerIds"] = workerIds
        }

        if let description = updates.description {
            data["description"] = description
        }

        if let area = updates.area {
            data["area"] = area
        }

        if let startTime = updates.startTime {
            data["startTime"] = startTime
        }

        if let endTime = updates.endTime {
            data["endTime"] = endTime
        }

        if let billable = updates.billable {
            data["billable"] = billable
        }

        if let rate = updates.rate {
            data["rate"] = rate
        }

        if let status = updates.status {
            data["status"] = status
        }

        if let materialsUsed = updates.materialsUsed {
            data["materialsUsed"] = materialsUsed
        }

        if let beforePhotos = updates.beforePhotos {
            data["beforePhotos"] = beforePhotos.map { mapPhotoToFirestore($0) }
        }

        if let afterPhotos = updates.afterPhotos {
            data["afterPhotos"] = afterPhotos.map { mapPhotoToFirestore($0) }
        }

        return data
    }

    private func mapPhotoToFirestore(_ photo: IncidentPhoto) -> [String: Any] {
        var data: [String: Any] = [
            "id": photo.id,
            "url": photo.url,
        ]

        if let captureDate = photo.captureDate {
            data["captureDate"] = captureDate
        }

        if let latitude = photo.latitude, let longitude = photo.longitude {
            data["location"] = GeoPoint(latitude: latitude, longitude: longitude)
        }

        return data
    }
}
