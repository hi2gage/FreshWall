import SwiftUI

// MARK: - BillingDefaultsConfigView.FocusedField

extension BillingDefaultsConfigView {
    enum FocusedField: Hashable {
        case minimumQuantity
        case amountPerUnit
    }
}

// MARK: - BillingDefaultsConfigView

struct BillingDefaultsConfigView: View {
    typealias BillingMethod = ClientDTO.BillingMethod

    @Binding var billingMethod: BillingMethod
    @Binding var minimumBillableQuantity: String
    @Binding var amountPerUnit: String
    @Binding var timeRounding: ClientDTO.TimeRounding?

    @FocusState private var focusedField: BillingDefaultsConfigView.FocusedField?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Billing Method Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Billing Method")
                    .font(.headline)
                Picker("Billing Method", selection: $billingMethod) {
                    ForEach(BillingMethod.allCases, id: \.self) { method in
                        Text(method.displayName).tag(method)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Minimum Billable Quantity
            VStack(alignment: .leading, spacing: 8) {
                Text("Minimum Billable Quantity")
                    .font(.headline)
                HStack {
                    TextField("0", text: $minimumBillableQuantity)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .minimumQuantity)
                    Text(billingMethod.unitLabel)
                        .foregroundColor(.secondary)
                }
            }

            // Amount Per Unit
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount Per Unit")
                    .font(.headline)
                HStack {
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("0.00", text: $amountPerUnit)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .amountPerUnit)
                    Text("per \(billingMethod.unitLabel)")
                        .foregroundColor(.secondary)
                }
            }

            // Time Rounding Configuration (only for time-based billing)
            if billingMethod == .time {
                let currentDefaults = ClientDTO.ClientDefaults(
                    billingMethod: billingMethod,
                    minimumBillableQuantity: Double(minimumBillableQuantity) ?? 0,
                    amountPerUnit: Double(amountPerUnit) ?? 0,
                    timeRounding: timeRounding
                )
                TimeRoundingConfigView(
                    timeRounding: $timeRounding,
                    clientDefaults: currentDefaults
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if focusedField != nil {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var billingMethod: ClientDTO.BillingMethod = .time
    @State var minimumQuantity = "2.0"
    @State var amountPerUnit = "85.0"
    @State var timeRounding: ClientDTO.TimeRounding? = ClientDTO.TimeRounding.default

    return FreshWallPreview {
        Form {
            Section("Billing Defaults") {
                BillingDefaultsConfigView(
                    billingMethod: $billingMethod,
                    minimumBillableQuantity: $minimumQuantity,
                    amountPerUnit: $amountPerUnit,
                    timeRounding: $timeRounding
                )
            }
        }
    }
}
