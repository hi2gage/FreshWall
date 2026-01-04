import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation
import os

// MARK: - PreviewIncidentService

@MainActor
final class PreviewIncidentService: IncidentServiceProtocol {
    private let logger = Logger.freshWall(category: "PreviewIncidentService")
    func fetchIncidents() async throws -> [Incident] {
        [Incident].preview
    }

    func fetchIncident(id: String) async throws -> Incident? {
        // Return nil for previews - could be enhanced with mock data if needed
        logger.info("🎭 PreviewIncidentService.fetchIncident called with id: \(id)")
        return nil
    }

    func addIncident(_: Incident) async throws {
        // No-op implementation for previews
    }

    func addIncident(
        _: AddIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws -> String {
        "preview-incident-id"
    }

    func updateIncident(
        _: String,
        with _: UpdateIncidentInput,
        newBeforePhotos _: [PickedPhoto],
        newAfterPhotos _: [PickedPhoto],
        photosToDelete _: [String]
    ) async throws {
        // No-op implementation for previews
    }

    func deleteIncident(_: String) async throws {
        // No-op implementation for previews
    }
}

// MARK: - Preview Data

extension [Incident] {
    static let preview: [Incident] = [
        Incident(
            id: "0XlDYGDiUmCWeNQFOf9P",
            clientRef: nil,
            description: "Graffiti removal on Pear Street",
            area: 15.5,
            location: GeoPoint(latitude: 45.690936666666666, longitude: -111.02662783333334),
            createdAt: Timestamp(date: Date().addingTimeInterval(-86400)),
            startTime: Timestamp(date: Date().addingTimeInterval(-172_800)),
            endTime: Timestamp(date: Date().addingTimeInterval(-86400)),
            beforePhotos: [
                IncidentPhoto(
                    id: "BA689F41-074C-452E-9789-0E9F9993C90E/L0/001",
                    url: "https://firebasestorage.googleapis.com/sample-before-1.jpg",
                    thumbnailUrl: "https://firebasestorage.googleapis.com/sample-before-1-thumb.jpg",
                    captureDate: Date().addingTimeInterval(-172_800),
                    location: CLLocationCoordinate2D(latitude: 45.690936666666666, longitude: -111.02662783333334)
                ),
            ],
            afterPhotos: [
                IncidentPhoto(
                    id: "2A2EC8BA-5960-467D-8FB0-60CD60CDB28D/L0/001",
                    url: "https://firebasestorage.googleapis.com/sample-after-1.jpg",
                    thumbnailUrl: "https://firebasestorage.googleapis.com/sample-after-1-thumb.jpg",
                    captureDate: Date().addingTimeInterval(-86400),
                    location: CLLocationCoordinate2D(latitude: 45.69233666666667, longitude: -111.0270695)
                ),
            ],
            createdBy: Firestore.firestore().document("users/sample-user-1"),
            lastModifiedBy: Firestore.firestore().document("users/sample-user-1"),
            lastModifiedAt: Timestamp(date: Date().addingTimeInterval(-3600)),
            rate: 85.00,
            materialsUsed: "Paint remover, pressure washer",
            status: .completed
        ),

        Incident(
            id: "0fB24ddlbttjbwFlP3Tc",
            clientRef: nil,
            description: "Graffiti cleanup on Gold Avenue",
            area: 8.2,
            location: GeoPoint(latitude: 45.692903333333334, longitude: -111.02793883333334),
            createdAt: Timestamp(date: Date().addingTimeInterval(-172_800)),
            startTime: Timestamp(date: Date().addingTimeInterval(-259_200)),
            endTime: Timestamp(date: Date().addingTimeInterval(-172_800)),
            beforePhotos: [
                IncidentPhoto(
                    id: "53AEE53D-A8B0-4936-8863-02A067455A99/L0/001",
                    url: "https://firebasestorage.googleapis.com/sample-before-2.jpg",
                    thumbnailUrl: "https://firebasestorage.googleapis.com/sample-before-2-thumb.jpg",
                    captureDate: Date().addingTimeInterval(-259_200),
                    location: CLLocationCoordinate2D(latitude: 45.692903333333334, longitude: -111.02793883333334)
                ),
            ],
            afterPhotos: [
                IncidentPhoto(
                    id: "66BB7AC8-2FFF-4030-A2B2-7909E962CA02/L0/001",
                    url: "https://firebasestorage.googleapis.com/sample-after-2.jpg",
                    thumbnailUrl: "https://firebasestorage.googleapis.com/sample-after-2-thumb.jpg",
                    captureDate: Date().addingTimeInterval(-172_800),
                    location: CLLocationCoordinate2D(latitude: 45.69229166666667, longitude: -111.02704716666666)
                ),
            ],
            createdBy: Firestore.firestore().document("users/sample-user-2"),
            lastModifiedBy: Firestore.firestore().document("users/sample-user-2"),
            lastModifiedAt: Timestamp(date: Date().addingTimeInterval(-7200)),
            rate: 75.00,
            materialsUsed: "Chemical remover, scrub brushes",
            status: .inProgress
        ),

        Incident(
            id: "KipVQRqENjakkWF68eTL",
            clientRef: nil,
            description: "Helena downtown cleanup",
            area: 12.0,
            location: GeoPoint(latitude: 46.58953, longitude: -112.03978616666667),
            createdAt: Timestamp(date: Date().addingTimeInterval(-259_200)),
            startTime: Timestamp(date: Date().addingTimeInterval(-345_600)),
            endTime: Timestamp(date: Date().addingTimeInterval(-259_200)),
            beforePhotos: [
                IncidentPhoto(
                    id: "EB37ECAB-1C78-44DF-9D51-925DE7A47C79/L0/001",
                    url: "https://firebasestorage.googleapis.com/sample-before-3.jpg",
                    thumbnailUrl: "https://firebasestorage.googleapis.com/sample-before-3-thumb.jpg",
                    captureDate: Date().addingTimeInterval(-345_600),
                    location: CLLocationCoordinate2D(latitude: 46.58953, longitude: -112.03978616666667)
                ),
            ],
            afterPhotos: [
                IncidentPhoto(
                    id: "D92E134D-4C2E-49F4-AFD5-28DEE4A7D647/L0/001",
                    url: "https://firebasestorage.googleapis.com/sample-after-3.jpg",
                    thumbnailUrl: "https://firebasestorage.googleapis.com/sample-after-3-thumb.jpg",
                    captureDate: Date().addingTimeInterval(-259_200),
                    location: CLLocationCoordinate2D(latitude: 46.58953, longitude: -112.03978616666667)
                ),
            ],
            createdBy: Firestore.firestore().document("users/sample-user-3"),
            lastModifiedBy: Firestore.firestore().document("users/sample-user-3"),
            lastModifiedAt: Timestamp(date: Date().addingTimeInterval(-14400)),
            rate: 95.00,
            materialsUsed: "Steam cleaner, biodegradable solvents",
            status: .open
        ),
    ]
}
