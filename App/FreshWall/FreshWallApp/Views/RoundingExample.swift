//
//  RoundingExample.swift
//  FreshWall
//
//  Created by Gage Halverson on 9/14/25.
//
import SwiftUI

struct RoundingExample: View {
    let rounding: ClientDTO.TimeRounding
    let minimumBillableQuantity: Double
    let amountPerUnit: Double

    let examples = [0.08333333, 0.16666667, 0.25, 0.5, 1.2, 1.75, 2.3, 3.1, 4.67]

    @State private var showExamples = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Billing Examples")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            // Collapsible content (expands below button)
            VStack(alignment: .leading, spacing: 12) {
                Text("Rate: $\(amountPerUnit, specifier: "%.2f")/hour • Minimum: \(minimumBillableQuantity, specifier: "%.1f") hours")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Section {
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
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}
