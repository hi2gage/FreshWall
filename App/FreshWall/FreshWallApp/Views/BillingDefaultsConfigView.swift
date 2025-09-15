import SwiftUI

// MARK: - PresetOptions

struct PresetOptions {
    let displayName: String // Full name for picker menu
    let shortName: String // Short name for selected state
    let roundingHours: Double

    static let all: [PresetOptions] = [
        PresetOptions(displayName: "Round to 1 min", shortName: "1 minute", roundingHours: 1.0 / 60.0),
        PresetOptions(displayName: "Round to 15 min", shortName: "15 minutes", roundingHours: 0.25),
        PresetOptions(displayName: "Round to 30 min", shortName: "30 minutes", roundingHours: 0.5),
        PresetOptions(displayName: "Round to 1 hour", shortName: "1 hour", roundingHours: 1.0),
    ]
}

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

    // Time rounding configuration state
    @State private var selectedPresetIndex: Int = 2
    @State private var isCustom = false
    @State private var customRoundingMinutes: Int = 30

    private let presetOptions = PresetOptions.all

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
                VStack(alignment: .leading, spacing: 16) {
                    Text("Time Rounding Configuration")
                        .font(.headline)

                    Text("Configure how time is rounded for billing calculations.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Preset Selection
                    HStack(spacing: 8) {
                        Text("Round to:")
                            .foregroundColor(.primary)

                        Menu {
                            ForEach(presetOptions.indices, id: \.self) { index in
                                Button(presetOptions[index].displayName) {
                                    selectedPresetIndex = index
                                }
                            }
                            Button("Custom") {
                                selectedPresetIndex = -1
                            }
                        } label: {
                            HStack {
                                Text(selectedPresetIndex == -1 ? "Custom" : presetOptions[selectedPresetIndex].shortName)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .onChange(of: selectedPresetIndex) { _, newValue in
                            if newValue == -1 {
                                isCustom = true
                                timeRounding = ClientDTO.TimeRounding(
                                    roundingIncrement: Double(customRoundingMinutes) / 60.0
                                )
                            } else {
                                isCustom = false
                                let preset = presetOptions[newValue]
                                timeRounding = ClientDTO.TimeRounding(
                                    roundingIncrement: preset.roundingHours
                                )
                            }
                        }
                    }

                    // Custom Configuration
                    if isCustom {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Custom Configuration")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Round To (minutes)")
                                    .font(.caption)
                                HStack {
                                    Slider(
                                        value: Binding(
                                            get: { Double(customRoundingMinutes) },
                                            set: { customRoundingMinutes = Int($0) }
                                        ),
                                        in: 1 ... 60,
                                        step: 1
                                    )
                                    Text("\(customRoundingMinutes) min")
                                        .frame(width: 50, alignment: .trailing)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onChange(of: customRoundingMinutes) { _, _ in
                            if isCustom {
                                timeRounding = ClientDTO.TimeRounding(
                                    roundingIncrement: Double(customRoundingMinutes) / 60.0
                                )
                            }
                        }
                    }

                    // Billing Examples
                    if let rounding = timeRounding {
                        RoundingExample(
                            rounding: rounding,
                            minimumBillableQuantity: Double(minimumBillableQuantity) ?? 0,
                            amountPerUnit: Double(amountPerUnit) ?? 0
                        )
                    }
                }
                .onAppear {
                    setupInitialTimeRoundingSelection()
                }
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

    private func setupInitialTimeRoundingSelection() {
        if let currentRounding = timeRounding {
            // Check if it matches any preset
            if let presetIndex = presetOptions.firstIndex(where: { preset in
                abs(preset.roundingHours - currentRounding.roundingIncrement) < 0.001
            }) {
                selectedPresetIndex = presetIndex
                isCustom = false
            } else {
                // It's a custom configuration
                selectedPresetIndex = -1
                isCustom = true
                // Convert to user-friendly minutes for display
                customRoundingMinutes = Int(round(currentRounding.roundingIncrement * 60))
            }
        } else {
            let index = 2
            // Default to 15 min rounding (index 2)
            selectedPresetIndex = index
            let preset = presetOptions[index]
            timeRounding = ClientDTO.TimeRounding(
                roundingIncrement: preset.roundingHours
            )
        }
    }
}

#Preview {
    @Previewable @State var billingMethod: ClientDTO.BillingMethod = .time
    @Previewable @State var minimumQuantity = "0.5"
    @Previewable @State var amountPerUnit = "80.0"
    @Previewable @State var timeRounding: ClientDTO.TimeRounding? = ClientDTO.TimeRounding.default

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
