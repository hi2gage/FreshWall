@preconcurrency import FirebaseFirestore
import SwiftUI

// MARK: - BillingDisplayModel

/// Consolidated billing display logic that supports both incident billing and client defaults
struct BillingDisplayModel {
    let methodName: String
    let unitLabel: String
    let quantity: Double
    let rate: Double
    let totalAmount: Double
    let isFromIncident: Bool
    let timeRounding: ClientDTO.TimeRounding?
    let rawHours: Double?
    let isMinimumApplied: Bool

    /// Initialize for incident billing with client fallback
    init(incident: Incident, client: Client) {
        // Determine billing source and extract configuration
        if let incidentBilling = incident.billing {
            // Incident has its own billing configuration
            methodName = incidentBilling.billingMethod.displayName
            rate = incidentBilling.amountPerUnit
            isFromIncident = true
            timeRounding = nil // Incident billing doesn't have time rounding yet

            unitLabel = incidentBilling.billingMethod == .custom
                ? (incidentBilling.customUnitDescription ?? "units")
                : incidentBilling.billingMethod.unitLabel

            // Calculate quantity based on method
            let rawQuantity: Double
            var calculatedRawHours: Double? = nil

            switch incidentBilling.billingMethod {
            case .time:
                calculatedRawHours = incident.durationHours
                rawQuantity = incident.durationHours
            case .squareFootage, .custom:
                rawQuantity = incident.area
            }

            rawHours = calculatedRawHours
            quantity = max(rawQuantity, incidentBilling.minimumBillableQuantity)
            isMinimumApplied = quantity == incidentBilling.minimumBillableQuantity

        } else if let clientDefaults = client.defaults {
            // Fall back to client defaults
            methodName = clientDefaults.billingMethod.displayName
            unitLabel = clientDefaults.billingMethod.unitLabel
            rate = clientDefaults.amountPerUnit
            isFromIncident = false
            timeRounding = clientDefaults.timeRounding

            // Calculate quantity based on method
            let rawQuantity: Double
            var calculatedRawHours: Double? = nil

            switch clientDefaults.billingMethod {
            case .time:
                calculatedRawHours = incident.durationHours

                // Apply time rounding if available
                rawQuantity = if let timeRounding = clientDefaults.timeRounding {
                    timeRounding.applyRounding(to: incident.durationHours)
                } else {
                    incident.durationHours
                }
            case .squareFootage:
                rawQuantity = incident.area
            }

            rawHours = calculatedRawHours
            quantity = max(rawQuantity, clientDefaults.minimumBillableQuantity)
            isMinimumApplied = quantity == clientDefaults.minimumBillableQuantity

        } else {
            // No billing configuration available
            methodName = "None"
            unitLabel = "units"
            quantity = 0
            rate = 0
            isFromIncident = false
            timeRounding = nil
            rawHours = nil
            isMinimumApplied = false
        }

        totalAmount = quantity * rate
    }

    /// Initialize for client defaults only (no incident data)
    init(client: Client) {
        if let defaults = client.defaults {
            methodName = defaults.billingMethod.displayName
            unitLabel = defaults.billingMethod.unitLabel
            rate = defaults.amountPerUnit
            quantity = defaults.minimumBillableQuantity
            totalAmount = defaults.minimumBillableQuantity * defaults.amountPerUnit
            isFromIncident = false
            timeRounding = defaults.timeRounding
            rawHours = nil
            isMinimumApplied = false // For client defaults, we show the minimum as the standard
        } else {
            // No billing configuration available
            methodName = "None"
            unitLabel = "units"
            quantity = 0
            rate = 0
            totalAmount = 0
            isFromIncident = false
            timeRounding = nil
            rawHours = nil
            isMinimumApplied = false
        }
    }

    var hasConfiguration: Bool {
        methodName != "None"
    }
}

// MARK: - BillingDisplayView

/// Unified billing display view for both incident and client contexts
struct BillingDisplayView: View {
    let billing: BillingDisplayModel
    let context: BillingContext

    enum BillingContext {
        case incident
        case clientDefaults

        var sectionTitle: String {
            switch self {
            case .incident: "Billing"
            case .clientDefaults: "Billing Defaults"
            }
        }

        var totalAmountLabel: String {
            switch self {
            case .incident: "Total Amount"
            case .clientDefaults: "Minimum Bill Amount"
            }
        }

        var noConfigurationMessage: String {
            switch self {
            case .incident:
                "No billing configuration found for this incident. Set up billing information in the client details or when editing the incident."
            case .clientDefaults:
                "Set up billing defaults to automatically configure billing for new incidents with this client."
            }
        }

        var infoMessage: String {
            switch self {
            case .incident: "Minimum billing quantity applied"
            case .clientDefaults: "These defaults apply to new incidents for this client"
            }
        }
    }

    var body: some View {
        Section(context.sectionTitle) {
            if billing.hasConfiguration {
                VStack(alignment: .leading, spacing: 12) {
                    // Billing Method Header
                    BillingMethodHeader(billing: billing)

                    Divider()

                    // Quantity & Rate
                    BillingQuantityRateRow(billing: billing, context: context)

                    Divider()

                    // Total Amount
                    BillingTotalRow(billing: billing, context: context)

                    // Additional info
                    BillingInfoNote(billing: billing, context: context)
                }
                .padding(.vertical, 8)
            } else {
                BillingErrorState(context: context)
            }
        }
    }
}

// MARK: - BillingMethodHeader

private struct BillingMethodHeader: View {
    let billing: BillingDisplayModel

    var body: some View {
        HStack {
            Image(systemName: "creditcard.fill")
                .foregroundColor(.green)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text("Billing Method")
                    .font(.headline)
                Text(billing.methodName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Show time rounding configuration (only for client defaults)
                if let timeRounding = billing.timeRounding {
                    Text(timeRounding.displayName)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }

                // Show billing source
                if billing.isFromIncident {
                    Text("Manual Override")
                        .font(.caption2)
                        .foregroundColor(.red)
                } else {
                    Text("Client Defaults")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
        }
    }
}

// MARK: - BillingQuantityRateRow

private struct BillingQuantityRateRow: View {
    let billing: BillingDisplayModel
    let context: BillingDisplayView.BillingContext

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(context == .clientDefaults ? "Minimum Quantity" : "Quantity")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(billing.quantity, specifier: "%.1f") \(billing.unitLabel)")
                    .font(.headline)

                // Show rounding info for time-based billing
                if let rawHours = billing.rawHours, billing.timeRounding != nil {
                    if rawHours != billing.quantity {
                        Text("(\(rawHours, specifier: "%.2f") raw → rounded)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("Rate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("$\(billing.rate, specifier: "%.2f")/\(billing.unitLabel)")
                    .font(.headline)
            }
        }
    }
}

// MARK: - BillingTotalRow

private struct BillingTotalRow: View {
    let billing: BillingDisplayModel
    let context: BillingDisplayView.BillingContext

    var body: some View {
        HStack {
            Text(context.totalAmountLabel)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text("$\(billing.totalAmount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - BillingInfoNote

private struct BillingInfoNote: View {
    let billing: BillingDisplayModel
    let context: BillingDisplayView.BillingContext

    var body: some View {
        // Show different info based on context
        if context == .incident, billing.isMinimumApplied {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                Text("Minimum billing quantity applied")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else if context == .clientDefaults {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                Text(context.infoMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - BillingErrorState

private struct BillingErrorState: View {
    let context: BillingDisplayView.BillingContext

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("No billing configuration")
                    .font(.headline)
                    .foregroundColor(.orange)
            }

            Text(context.noConfigurationMessage)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
