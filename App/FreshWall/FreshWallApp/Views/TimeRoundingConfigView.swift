import SwiftUI

// MARK: - PresetOptions

struct PresetOptions {
    let displayName: String
    let roundingHours: Double

    static let all: [PresetOptions] = [
        PresetOptions(displayName: "Round to 1 min", roundingHours: 1.0 / 60.0),
        PresetOptions(displayName: "Round to 15 min", roundingHours: 0.25),
        PresetOptions(displayName: "Round to 30 min", roundingHours: 0.5),
        PresetOptions(displayName: "Round to 1 hour", roundingHours: 1.0),
    ]
}

// MARK: - RoundingExample

struct RoundingExample: View {
    let rounding: ClientDTO.TimeRounding
    let minimumBillableQuantity: Double
    let amountPerUnit: Double

    @State private var showExamples = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Button header (always visible, never moves)

            Button {
                showExamples.toggle()
            } label: {
                HStack {
                    Text("Billing Examples")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: showExamples ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.2), value: showExamples)
                }
            }
            .buttonStyle(.plain)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Collapsible content (expands below button)
            if showExamples {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rate: $\(amountPerUnit, specifier: "%.2f")/hour • Minimum: \(minimumBillableQuantity, specifier: "%.1f") hours")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    let examples = [0.08333333, 0.16666667, 0.25, 0.5, 1.2, 1.75, 2.3, 3.1, 4.67]

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(examples, id: \.self) { rawHours in
                            let roundedHours = rounding.applyRounding(to: rawHours)
                            let billableHours = max(roundedHours, minimumBillableQuantity)
                            let totalCost = billableHours * amountPerUnit

                            HStack {
                                Text("\(rawHours, specifier: "%.2f")h")
                                    .frame(width: 45, alignment: .leading)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("→")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("\(roundedHours, specifier: "%.2f")h")
                                    .frame(width: 35, alignment: .leading)
                                    .font(.caption)
                                    .fontWeight(.medium)

                                if billableHours != roundedHours {
                                    Text("(min: \(billableHours, specifier: "%.2f")h)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .frame(width: 70, alignment: .leading)
                                } else {
                                    Spacer()
                                        .frame(width: 70)
                                }

                                Spacer()

                                Text("$\(totalCost, specifier: "%.2f")")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - TimeRoundingConfigView

struct TimeRoundingConfigView: View {
    @Binding var clientDefaults: ClientDTO.ClientDefaults

    @State private var selectedPresetIndex: Int = 0
    @State private var isCustom = false
    @State private var customRoundingMinutes: Int = 30

    private let presets = ClientDTO.TimeRounding.presets

    // User-friendly preset options with precise internal values
    private let presetOptions = PresetOptions.all

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time Rounding Configuration")
                .font(.headline)

            Text("Configure how time is rounded for billing calculations.")
                .font(.caption)
                .foregroundColor(.secondary)

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
                        clientDefaults.timeRounding = ClientDTO.TimeRounding(
                            roundingIncrement: Double(customRoundingMinutes) / 60.0
                        )
                    }
                }
            }

            // Preset Selection
            VStack(alignment: .leading, spacing: 8) {
                Picker("Rounding \nMethod", selection: $selectedPresetIndex) {
                    ForEach(presetOptions.indices, id: \.self) { index in
                        Text(presetOptions[index].displayName).tag(index)
                    }
                    Text("Custom").tag(-1)
                }
                .pickerStyle(.menu)
                .onChange(of: selectedPresetIndex) { _, newValue in
                    if newValue == -1 {
                        isCustom = true
                        clientDefaults.timeRounding = ClientDTO.TimeRounding(
                            roundingIncrement: Double(customRoundingMinutes) / 60.0
                        )
                    } else {
                        isCustom = false
                        let preset = presetOptions[newValue]
                        clientDefaults.timeRounding = ClientDTO.TimeRounding(
                            roundingIncrement: preset.roundingHours
                        )
                    }
                }
            }

            // Billing Examples
            if let rounding = clientDefaults.timeRounding {
                RoundingExample(
                    rounding: rounding,
                    minimumBillableQuantity: clientDefaults.minimumBillableQuantity,
                    amountPerUnit: clientDefaults.amountPerUnit
                )
            }
        }
        .onAppear {
            setupInitialSelection()
        }
    }

    private func setupInitialSelection() {
        if let currentRounding = clientDefaults.timeRounding {
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
            // Default to 15 min rounding (index 0)
            selectedPresetIndex = 0
            let preset = presetOptions[0]
            clientDefaults.timeRounding = ClientDTO.TimeRounding(
                roundingIncrement: preset.roundingHours
            )
        }
    }
}

#Preview {
    @Previewable @State var sampleDefaults = ClientDTO.ClientDefaults(
        billingMethod: .time,
        minimumBillableQuantity: 0.5,
        amountPerUnit: 80,
        timeRounding: ClientDTO.TimeRounding.default
    )

    return FreshWallPreview {
        Form {
            Section("Time Rounding") {
                TimeRoundingConfigView(
                    clientDefaults: $sampleDefaults
                )
            }
        }
    }
}
