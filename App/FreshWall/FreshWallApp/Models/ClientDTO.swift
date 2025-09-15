@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - ClientDTO

/// A customer or client associated with the team.
struct ClientDTO: Codable, Identifiable, Hashable {
    /// Firestore-generated document identifier for the client.
    @DocumentID var id: String?
    /// Name of the client.
    var name: String
    /// Optional additional notes about the client.
    var notes: String?
    /// Billing defaults for this client.
    var defaults: ClientDefaults?
    /// Flag indicating whether the client is soft-deleted.
    var isDeleted: Bool
    /// Timestamp when the client was marked deleted (if applicable).
    var deletedAt: Timestamp?
    /// Timestamp when this client was created.
    var createdAt: Timestamp
    /// Timestamp of the most recent incident for this client (denormalized).
    var lastIncidentAt: Timestamp
}

// MARK: ClientDTO.BillingMethod

extension ClientDTO {
    /// Method used to bill clients.
    enum BillingMethod: String, CaseIterable, Codable, Hashable, Sendable {
        case time
        case squareFootage = "square_footage"

        var displayName: String {
            switch self {
            case .squareFootage: "Square Footage"
            case .time: "Time"
            }
        }

        var unitLabel: String {
            switch self {
            case .squareFootage: "sq ft"
            case .time: "hours"
            }
        }
    }
}

// MARK: ClientDTO.ClientDefaults

extension ClientDTO {
    /// Billing configuration defaults for a client.
    struct ClientDefaults: Codable, Hashable, Sendable {
        /// How this client should be billed.
        var billingMethod: BillingMethod
        /// Minimum quantity the client will be charged for.
        var minimumBillableQuantity: Double
        /// Amount charged per unit.
        var amountPerUnit: Double
        /// Time rounding configuration (only applies to time-based billing).
        var timeRounding: TimeRounding?

        init(
            billingMethod: BillingMethod,
            minimumBillableQuantity: Double,
            amountPerUnit: Double,
            timeRounding: TimeRounding? = nil
        ) {
            self.billingMethod = billingMethod
            self.minimumBillableQuantity = minimumBillableQuantity
            self.amountPerUnit = amountPerUnit
            self.timeRounding = timeRounding
        }
    }

    /// Time rounding configuration for time-based billing.
    struct TimeRounding: Codable, Hashable, Sendable {
        /// Increment to round up to (in hours). E.g., 0.5 = 30 minutes, 0.25 = 15 minutes.
        var roundingIncrement: Double

        init(roundingIncrement: Double = 0.25) {
            self.roundingIncrement = roundingIncrement
        }

        /// Applies the rounding logic to raw hours.
        func applyRounding(to rawHours: Double) -> Double {
            // Round up to next increment
            (rawHours / roundingIncrement).rounded(.up) * roundingIncrement
        }

        /// Default rounding configuration.
        static let `default` = TimeRounding(roundingIncrement: 0.25)

        /// Common presets for easy selection.
        static let presets: [TimeRounding] = [
            TimeRounding(roundingIncrement: 1.0 / 60.0), // Round to 1-min
            TimeRounding(roundingIncrement: 0.25), // Round to 15-min
            TimeRounding(roundingIncrement: 0.5), // Round to 30-min
            TimeRounding(roundingIncrement: 1.0), // Round to 1-hour
        ]

        var displayName: String {
            let incrementMinutes = Int(roundingIncrement * 60)
            return "Round to \(incrementMinutes) min"
        }
    }
}
