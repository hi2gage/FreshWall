import Foundation
import TPPDF
import UIKit
import os

// MARK: - PDFService

/// Service for generating PDF reports and invoices from incident and client data.
enum PDFService {
    private static let logger = Logger.freshWall(category: "PDFService")
    /// Generates a monthly client invoice PDF.
    static func generateClientInvoice(
        client: Client,
        incidents: [Incident],
        reportPeriod: String,
        companyInfo: CompanyInfo = .freshWall
    ) -> Data {
        let billableIncidents = incidents
        let document = PDFDocument(format: .usLetter)

        // Configure document
        document.info.title = "\(client.name) Invoice - \(reportPeriod)"
        document.info.author = companyInfo.name

        do {
            return try buildInvoicePDF(
                document: document,
                client: client,
                incidents: billableIncidents,
                reportPeriod: reportPeriod,
                companyInfo: companyInfo
            )
        } catch {
            logger.error("Error generating invoice PDF: \(error.localizedDescription)")
            return Data()
        }
    }

    /// Generates a detailed incident tracking report PDF.
    static func generateIncidentReport(
        client: Client,
        incidents: [Incident],
        reportPeriod: String,
        companyInfo: CompanyInfo = .freshWall
    ) -> Data {
        let document = PDFDocument(format: .usLetter)

        // Configure document
        document.info.title = "\(client.name) Incident Report - \(reportPeriod)"
        document.info.author = companyInfo.name

        do {
            return try buildIncidentReportPDF(
                document: document,
                client: client,
                incidents: incidents,
                reportPeriod: reportPeriod,
                companyInfo: companyInfo
            )
        } catch {
            logger.error("Error generating incident report PDF: \(error.localizedDescription)")
            return Data()
        }
    }

    // MARK: - Invoice PDF Builder

    private static func buildInvoicePDF(
        document: PDFDocument,
        client: Client,
        incidents: [Incident],
        reportPeriod _: String,
        companyInfo: CompanyInfo
    ) throws -> Data {
        // Company Header
        document.add(.contentLeft, textObject: PDFSimpleText(
            text: companyInfo.name,
            spacing: 2.0
        ))

        // Set smaller font for company details
        document.set(font: UIFont.systemFont(ofSize: 10))

        for address in companyInfo.address {
            document.add(.contentLeft, text: address)
        }
        document.add(.contentLeft, text: companyInfo.website)
        document.add(.contentLeft, text: companyInfo.phone)

        // Reset to default font
        document.set(font: UIFont.systemFont(ofSize: 12))

        // Invoice Title
        document.add(.contentRight, textObject: PDFSimpleText(
            text: "Invoice",
            spacing: 2.0
        ))

        document.add(space: 20)

        // Bill To Section
        document.add(.contentLeft, textObject: PDFSimpleText(
            text: "Bill To",
            spacing: 2.0
        ))
        document.add(.contentLeft, text: client.name)

        // Invoice Details
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        document.add(.contentRight, text: "Date: \(dateFormatter.string(from: Date()))")
        document.add(.contentRight, text: "Invoice #: \(generateInvoiceNumber())")
        document.add(.contentRight, text: "Terms: Net 30")

        document.add(space: 20)

        // Create line items table
        let tableData = createInvoiceTableData(incidents: incidents)
        let table = PDFTable(rows: tableData.count, columns: 4)

        // Configure table styling
        for rowIndex in 0 ..< tableData.count {
            for colIndex in 0 ..< 4 {
                let cell = table[rowIndex, colIndex]
                cell.content = try PDFTableContent(content: tableData[rowIndex][colIndex])

                if rowIndex == 0 {
                    // Header row
                    cell.style = PDFTableCellStyle(
                        colors: (fill: UIColor.lightGray, text: UIColor.black),
                        borders: PDFTableCellBorders(
                            left: PDFLineStyle(type: .full, color: .black, width: 1),
                            top: PDFLineStyle(type: .full, color: .black, width: 1),
                            right: PDFLineStyle(type: .full, color: .black, width: 1),
                            bottom: PDFLineStyle(type: .full, color: .black, width: 1)
                        ),
                        font: UIFont.boldSystemFont(ofSize: 10)
                    )
                } else {
                    // Content rows
                    cell.style = PDFTableCellStyle(
                        colors: (fill: UIColor.white, text: UIColor.black),
                        borders: PDFTableCellBorders(
                            left: PDFLineStyle(type: .full, color: .black, width: 0.5),
                            top: PDFLineStyle(type: .full, color: .black, width: 0.5),
                            right: PDFLineStyle(type: .full, color: .black, width: 0.5),
                            bottom: PDFLineStyle(type: .full, color: .black, width: 0.5)
                        ),
                        font: UIFont.systemFont(ofSize: 9)
                    )
                }
            }
        }

        try document.add(table: table)

        // Total
        let total = incidents.reduce(0) { $0 + $1.totalCost }
        document.add(space: 20)
        document.add(.contentRight, textObject: PDFSimpleText(
            text: "Total: \(formatCurrency(total))",
            spacing: 2.0
        ))

        // Footer
        document.add(space: 30)
        document.add(.contentLeft, text: "It has been our pleasure working with you!")
        document.add(.contentLeft, textObject: PDFSimpleText(
            text: "Please remit payment to:",
            spacing: 2.0
        ))
        document.add(.contentLeft, text: companyInfo.name)
        for address in companyInfo.address {
            document.add(.contentLeft, text: address)
        }
        document.add(space: 10)
        document.add(.contentLeft, textObject: PDFSimpleText(
            text: "Thank you for your business!",
            spacing: 2.0
        ))

        // Generate PDF
        let generator = PDFGenerator(document: document)
        return try generator.generateData()
    }

    // MARK: - Incident Report PDF Builder

    private static func buildIncidentReportPDF(
        document: PDFDocument,
        client: Client,
        incidents: [Incident],
        reportPeriod: String,
        companyInfo _: CompanyInfo
    ) throws -> Data {
        // Report Header
        document.add(.contentCenter, textObject: PDFSimpleText(
            text: "Graffiti Reporting",
            spacing: 2.0
        ))
        document.add(.contentRight, textObject: PDFSimpleText(
            text: reportPeriod,
            spacing: 2.0
        ))

        document.add(space: 20)

        document.add(.contentLeft, text: "Client: \(client.name)")
        document.add(.contentLeft, text: "Report Period: \(reportPeriod)")

        document.add(space: 20)

        // Create incident tracking table
        let tableData = createIncidentTrackingTableData(incidents: incidents)
        let table = PDFTable(rows: tableData.count, columns: tableData.first?.count ?? 0)

        // Configure table styling
        for rowIndex in 0 ..< tableData.count {
            for colIndex in 0 ..< (tableData.first?.count ?? 0) {
                let cell = table[rowIndex, colIndex]
                cell.content = try PDFTableContent(content: tableData[rowIndex][colIndex])

                if rowIndex == 0 {
                    // Header row
                    cell.style = PDFTableCellStyle(
                        colors: (fill: UIColor.lightGray, text: UIColor.black),
                        borders: PDFTableCellBorders(
                            left: PDFLineStyle(type: .full, color: .black, width: 1),
                            top: PDFLineStyle(type: .full, color: .black, width: 1),
                            right: PDFLineStyle(type: .full, color: .black, width: 1),
                            bottom: PDFLineStyle(type: .full, color: .black, width: 1)
                        ),
                        font: UIFont.boldSystemFont(ofSize: 8)
                    )
                } else {
                    // Content rows
                    cell.style = PDFTableCellStyle(
                        colors: (fill: UIColor.white, text: UIColor.black),
                        borders: PDFTableCellBorders(
                            left: PDFLineStyle(type: .full, color: .black, width: 0.5),
                            top: PDFLineStyle(type: .full, color: .black, width: 0.5),
                            right: PDFLineStyle(type: .full, color: .black, width: 0.5),
                            bottom: PDFLineStyle(type: .full, color: .black, width: 0.5)
                        ),
                        font: UIFont.systemFont(ofSize: 7)
                    )
                }
            }
        }

        try document.add(table: table)

        // Generate PDF
        let generator = PDFGenerator(document: document)
        return try generator.generateData()
    }

    // MARK: - Helper Methods

    private static func createInvoiceTableData(incidents: [Incident]) -> [[String]] {
        var data: [[String]] = []

        // Header row
        data.append(["Quantity", "Description", "Rate", "Amount"])

        // Data rows
        for incident in incidents {
            let quantity = formatQuantity(incident.billableHours)
            let description = formatIncidentDescription(incident)
            let rate = formatCurrency(incident.rate ?? 0)
            let amount = formatCurrency(incident.totalCost)

            data.append([quantity, description, rate, amount])
        }

        return data
    }

    private static func createIncidentTrackingTableData(incidents: [Incident]) -> [[String]] {
        var data: [[String]] = []

        // Header row
        data.append(["#", "ID", "Date", "Location", "Surface", "Type", "Arrived", "Left", "Method", "Notes"])

        // Data rows
        for (index, incident) in incidents.enumerated() {
            let instanceNumber = "\(index + 1)"
            let instanceID = generateInstanceID(incident: incident, number: index + 1)
            let date = formatDate(incident.createdAt.dateValue())
            let location = extractLocation(from: incident.description)
            let surface = extractSurface(from: incident.description)
            let type = extractGraffitiType(from: incident.description)
            let arrived = formatTime(incident.startTime.dateValue())
            let left = formatTime(incident.endTime.dateValue())
            let method = extractRemovalMethod(from: incident)
            let notes = incident.materialsUsed ?? ""

            data.append([instanceNumber, instanceID, date, location, surface, type, arrived, left, method, notes])
        }

        return data
    }

    private static func generateInvoiceNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }

    private static func generateInstanceID(incident: Incident, number: Int) -> String {
        let year = Calendar.current.component(.year, from: incident.createdAt.dateValue()) % 100
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: incident.createdAt.dateValue()) ?? 1
        return String(format: "%02d%03d%02d-I", year, dayOfYear, number)
    }

    private static func formatQuantity(_ hours: Double) -> String {
        if hours == floor(hours) {
            String(Int(hours))
        } else {
            String(format: "%.1f", hours)
        }
    }

    private static func formatIncidentDescription(_ incident: Incident) -> String {
        let location = extractLocation(from: incident.description)
        let type = extractGraffitiType(from: incident.description)
        let surface = extractSurface(from: incident.description)

        return "Graffiti Removal at \(location), \(type) on \(surface)"
    }

    private static func formatCurrency(_ amount: Double) -> String {
        String(format: "$%.2f", amount)
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter.string(from: date)
    }

    private static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    // MARK: - Description Parsing Helpers

    private static func extractLocation(from description: String) -> String {
        let components = description.components(separatedBy: " - ")
        return components.first?.trimmingCharacters(in: .whitespaces) ?? "Location"
    }

    private static func extractGraffitiType(from description: String) -> String {
        let lowercased = description.lowercased()

        if lowercased.contains("spray paint") {
            return "Spray paint"
        } else if lowercased.contains("slap tag") {
            return "Slap tag(s)"
        } else if lowercased.contains("chalk") {
            return "Chalk pen"
        } else if lowercased.contains("poster") {
            return "Poster(s)"
        } else {
            return "Graffiti"
        }
    }

    private static func extractSurface(from description: String) -> String {
        let lowercased = description.lowercased()

        if lowercased.contains("utility box") {
            return "Utility box(es)"
        } else if lowercased.contains("street sign") {
            return "Street sign(s)"
        } else if lowercased.contains("telephone pole") {
            return "Telephone pole(s)"
        } else if lowercased.contains("dumpster") {
            return "Dumpster(s)"
        } else if lowercased.contains("fire hydrant") {
            return "Fire hydrant(s)"
        } else {
            return "Various"
        }
    }

    private static func extractRemovalMethod(from incident: Incident) -> String {
        let materialsUsed = incident.materialsUsed?.lowercased() ?? ""

        if materialsUsed.contains("razor") {
            return "Razorblade"
        } else if materialsUsed.contains("ssr") || materialsUsed.contains("ipa") {
            return "SSR/IPA"
        } else if materialsUsed.contains("bb") || materialsUsed.contains("pw") {
            return "BB/PW"
        } else {
            return "Standard"
        }
    }
}

// MARK: - CompanyInfo

/// Company information for PDF headers.
struct CompanyInfo {
    let name: String
    let address: [String]
    let website: String
    let phone: String

    static let freshWall = CompanyInfo(
        name: "FreshWall Services",
        address: ["123 Business Ave", "Your City, State 12345"],
        website: "www.freshwallservices.com",
        phone: "1-800-FRESH-WALL"
    )
}

// MARK: - PDF Export Extensions

extension Client {
    /// Generates a formatted client reference for PDFs.
    var pdfDisplayName: String {
        name
    }
}

extension Incident {
    /// Calculates billable hours for this incident.
    var billableHours: Double {
        let duration = endTime.dateValue().timeIntervalSince(startTime.dateValue())
        return max(0.5, duration / 3600.0) // Minimum 0.5 hours, rounded
    }

    /// Calculates total cost for this incident.
    var totalCost: Double {
        guard let rate else { return 0 }

        return billableHours * rate
    }

    /// Formatted location string for PDF display.
    var locationDescription: String {
        // You might want to extract location from description or add location field
        description
    }
}
