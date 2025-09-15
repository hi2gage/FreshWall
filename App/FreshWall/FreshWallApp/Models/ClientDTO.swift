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
        /// Buffer time added before rounding (in hours).
        var bufferHours: Double
        /// Increment to round to (in hours). E.g., 0.5 = 30 minutes, 0.25 = 15 minutes.
        var roundingIncrement: Double

        init(bufferHours: Double = 0.25, roundingIncrement: Double = 0.5) {
            self.bufferHours = bufferHours
            self.roundingIncrement = roundingIncrement
        }

        /// Applies the rounding logic to raw hours.
        func applyRounding(to rawHours: Double) -> Double {
            let bufferedHours = rawHours + bufferHours
            return (bufferedHours / roundingIncrement).rounded(.up) * roundingIncrement
        }

        /// Default rounding configuration matching your friend's Excel formula.
        static let `default` = TimeRounding(bufferHours: 0.2499, roundingIncrement: 0.5)

        /// Common presets for easy selection.
        static let presets: [TimeRounding] = [
            TimeRounding(bufferHours: 0.0, roundingIncrement: 0.25), // No buffer, 15-min increments
            TimeRounding(bufferHours: 0.0, roundingIncrement: 0.5), // No buffer, 30-min increments
            TimeRounding(bufferHours: 0.25, roundingIncrement: 0.5), // 15-min buffer, 30-min increments
            TimeRounding(bufferHours: 0.2499, roundingIncrement: 0.5), // Excel formula equivalent
            TimeRounding(bufferHours: 0.5, roundingIncrement: 1.0), // 30-min buffer, 1-hour increments
        ]

        var displayName: String {
            let bufferMinutes = Int(bufferHours * 60)
            let incrementMinutes = Int(roundingIncrement * 60)

            if bufferHours == 0 {
                return "Round to \(incrementMinutes) min"
            } else {
                return "+\(bufferMinutes) min, round to \(incrementMinutes) min"
            }
        }
    }
}
