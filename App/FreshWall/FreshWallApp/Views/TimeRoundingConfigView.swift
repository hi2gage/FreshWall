import SwiftUI

struct TimeRoundingConfigView: View {
    @Binding var timeRounding: ClientDTO.TimeRounding?
    let clientDefaults: ClientDTO.ClientDefaults?

    @State private var selectedPresetIndex: Int = 0
    @State private var isCustom = false
    @State private var customBufferMinutes: Int = 15
    @State private var customRoundingMinutes: Int = 30

    private let presets = ClientDTO.TimeRounding.presets

    // User-friendly preset options with precise internal values
    private let presetOptions: [(displayName: String, bufferHours: Double, roundingHours: Double)] = [
        ("No buffer, round to 15 min", 0.0, 0.25),
        ("No buffer, round to 30 min", 0.0, 0.5),
        ("15 min buffer, round to 30 min", 0.2499, 0.5), // Shows as 15 min, uses 0.2499
        ("Excel formula equivalent", 0.2499, 0.5),
        ("30 min buffer, round to 1 hour", 0.4999, 1.0), // Shows as 30 min, uses 0.4999
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time Rounding Configuration")
                .font(.headline)

            Text("Configure how time is rounded for billing calculations.")
                .font(.caption)
                .foregroundColor(.secondary)

            // Preset Selection
            VStack(alignment: .leading, spacing: 8) {
                Picker("Rounding Method", selection: $selectedPresetIndex) {
                    ForEach(presetOptions.indices, id: \.self) { index in
                        Text(presetOptions[index].displayName).tag(index)
                    }
                    Text("Custom").tag(-1)
                }
                .pickerStyle(.menu)
                .onChange(of: selectedPresetIndex) { _, newValue in
                    if newValue == -1 {
                        isCustom = true
                        updateTimeRounding()
                    } else {
                        isCustom = false
                        let preset = presetOptions[newValue]
                        timeRounding = ClientDTO.TimeRounding(
                            bufferHours: preset.bufferHours,
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
                        Text("Buffer Time (minutes)")
                            .font(.caption)
                        HStack {
                            Slider(
                                value: Binding(
                                    get: { Double(customBufferMinutes) },
                                    set: { customBufferMinutes = Int($0) }
                                ),
                                in: 0 ... 30,
                                step: 1
                            )
                            Text("\(customBufferMinutes) min")
                                .frame(width: 50, alignment: .trailing)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Round To (minutes)")
                            .font(.caption)
                        HStack {
                            Slider(
                                value: Binding(
                                    get: { Double(customRoundingMinutes) },
                                    set: { customRoundingMinutes = Int($0) }
                                ),
                                in: 15 ... 60,
                                step: 15
                            )
                            Text("\(customRoundingMinutes) min")
                                .frame(width: 50, alignment: .trailing)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onChange(of: customBufferMinutes) { _, _ in updateTimeRounding() }
                .onChange(of: customRoundingMinutes) { _, _ in updateTimeRounding() }
            }

            // Billing Examples
            if let rounding = timeRounding, let defaults = clientDefaults {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Billing Examples")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Rate: $\(defaults.amountPerUnit, specifier: "%.2f")/hour • Minimum: \(defaults.minimumBillableQuantity, specifier: "%.1f") hours")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    let examples = [1.2, 1.75, 2.3, 3.1, 4.67]

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(examples, id: \.self) { rawHours in
                            let roundedHours = rounding.applyRounding(to: rawHours)
                            let billableHours = max(roundedHours, defaults.minimumBillableQuantity)
                            let totalCost = billableHours * defaults.amountPerUnit

                            HStack {
                                Text("\(rawHours, specifier: "%.2f")h")
                                    .frame(width: 45, alignment: .leading)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("→")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("\(roundedHours, specifier: "%.1f")h")
                                    .frame(width: 35, alignment: .leading)
                                    .font(.caption)
                                    .fontWeight(.medium)

                                if billableHours != roundedHours {
                                    Text("(min: \(billableHours, specifier: "%.1f")h)")
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
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .onAppear {
            setupInitialSelection()
        }
    }

    private func setupInitialSelection() {
        if let currentRounding = timeRounding {
            // Check if it matches any preset
            if let presetIndex = presetOptions.firstIndex(where: { preset in
                abs(preset.bufferHours - currentRounding.bufferHours) < 0.001 &&
                    abs(preset.roundingHours - currentRounding.roundingIncrement) < 0.001
            }) {
                selectedPresetIndex = presetIndex
                isCustom = false
            } else {
                // It's a custom configuration
                selectedPresetIndex = -1
                isCustom = true
                // Convert to user-friendly minutes for display
                customBufferMinutes = Int(round(currentRounding.bufferHours * 60))
                customRoundingMinutes = Int(round(currentRounding.roundingIncrement * 60))
            }
        } else {
            // Default to the Excel formula equivalent (index 3)
            selectedPresetIndex = 3
            let preset = presetOptions[3]
            timeRounding = ClientDTO.TimeRounding(
                bufferHours: preset.bufferHours,
                roundingIncrement: preset.roundingHours
            )
        }
    }

    private func updateTimeRounding() {
        if isCustom {
            // Use precise 0.2499 if user selects 15 minutes, otherwise use exact conversion
            let bufferHours = if customBufferMinutes == 15 {
                0.2499
            } else if customBufferMinutes == 30 {
                0.4999
            } else {
                Double(customBufferMinutes) / 60.0
            }

            timeRounding = ClientDTO.TimeRounding(
                bufferHours: bufferHours,
                roundingIncrement: Double(customRoundingMinutes) / 60.0
            )
        }
    }
}

#Preview {
    @State var timeRounding: ClientDTO.TimeRounding? = ClientDTO.TimeRounding.default

    let sampleDefaults = ClientDTO.ClientDefaults(
        billingMethod: .time,
        minimumBillableQuantity: 2.0,
        amountPerUnit: 85.0,
        timeRounding: timeRounding
    )

    return FreshWallPreview {
        Form {
            Section("Time Rounding") {
                TimeRoundingConfigView(
                    timeRounding: $timeRounding,
                    clientDefaults: sampleDefaults
                )
            }
        }
    }
}
