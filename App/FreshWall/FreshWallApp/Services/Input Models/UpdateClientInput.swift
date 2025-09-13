@preconcurrency import FirebaseFirestore
import Foundation

/// Input model for updating an existing client via `ClientService`.
struct UpdateClientInput: Sendable {
    /// Updated name for the client.
    let name: String
    /// Optional updated notes for the client.
    let notes: String?
    /// Optional updated billing defaults for the client.
    let defaults: ClientDefaults?
}
