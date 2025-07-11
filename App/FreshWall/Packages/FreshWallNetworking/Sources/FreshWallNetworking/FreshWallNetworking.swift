// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - Public Exports

// Core
public typealias NetworkError = FreshWallNetworking.NetworkError
public typealias NetworkConfiguration = FreshWallNetworking.NetworkConfiguration
public typealias NetworkClient = FreshWallNetworking.NetworkClient
public typealias AuthenticatedUser = FreshWallNetworking.AuthenticatedUser

// DTOs
public typealias Team = FreshWallNetworking.Team
public typealias User = FreshWallNetworking.User
public typealias UserUpdate = FreshWallNetworking.UserUpdate
public typealias UserRole = FreshWallNetworking.UserRole
public typealias Client = FreshWallNetworking.Client
public typealias ClientCreate = FreshWallNetworking.ClientCreate
public typealias ClientUpdate = FreshWallNetworking.ClientUpdate
public typealias Incident = FreshWallNetworking.Incident
public typealias IncidentCreate = FreshWallNetworking.IncidentCreate
public typealias IncidentUpdate = FreshWallNetworking.IncidentUpdate
public typealias IncidentPhoto = FreshWallNetworking.IncidentPhoto
public typealias InviteCodeInfo = FreshWallNetworking.InviteCodeInfo

// Repositories
public typealias TeamRepository = FreshWallNetworking.TeamRepository
public typealias UserRepository = FreshWallNetworking.UserRepository
public typealias ClientRepository = FreshWallNetworking.ClientRepository
public typealias IncidentRepository = FreshWallNetworking.IncidentRepository
public typealias AuthRepository = FreshWallNetworking.AuthRepository
public typealias StorageRepository = FreshWallNetworking.StorageRepository
public typealias InviteRepository = FreshWallNetworking.InviteRepository

// MARK: - NetworkClientFactory

public enum NetworkClientFactory {
    /// Creates a Firebase-based network client for production use
    public static func createFirebaseClient() -> NetworkClient {
        return FirebaseNetworkClient()
    }

    /// Creates a mock network client for testing and previews
    public static func createMockClient() -> MockNetworkClient {
        return MockNetworkClient()
    }

    /// Creates a configured network client based on the environment
    public static func createClient(useMock: Bool = false) async throws -> NetworkClient {
        let client: NetworkClient = useMock ? createMockClient() : createFirebaseClient()

        let configuration = useMock ? NetworkConfiguration.development : NetworkConfiguration.production
        try await client.configure(with: configuration)

        return client
    }
}
