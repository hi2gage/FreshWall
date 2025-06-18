@preconcurrency import FirebaseFirestore
import Foundation

/// Input model for updating an existing client via `ClientService`.
struct UpdateClientInput: Sendable {
    /// Updated name for the client.
    let name: String
    /// Optional updated notes for the client.
    let notes: String?
}
