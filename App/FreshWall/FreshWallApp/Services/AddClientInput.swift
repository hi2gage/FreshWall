import Foundation
@preconcurrency import FirebaseFirestore

/// Input model for creating a new client via `ClientService`.
struct AddClientInput: Sendable {
    /// Name of the new client.
    let name: String
    /// Optional notes for the new client.
    let notes: String?

    let lastIncidentAt: Timestamp
}
