@preconcurrency import FirebaseFirestore
import Foundation

/// Input model for creating a new client via `ClientService`.
struct AddClientInput: Sendable {
    /// Name of the new client.
    let name: String
    /// Optional notes for the new client.
    let notes: String?
    /// Optional billing defaults for the client.
    let defaults: ClientDefaults?

    let lastIncidentAt: Timestamp
}
