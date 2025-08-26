//
//  ClientsRepository.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/28/25.
//

import Foundation

// MARK: - ClientsRepository

protocol ClientsRepository {
    /// Fetches active clients for the current team.
    func fetchClients() async throws -> [Client]
    /// Adds a new client using an input value object.
    /// - Returns: The ID of the newly created client.
    func addClient(_ input: AddClientInput) async throws -> String
}

// MARK: - DefaultClientsRepository

struct DefaultClientsRepository: ClientsRepository {
    let client: ClientServiceProtocol

    func fetchClients() async throws -> [Client] {
        try await client.fetchClients()
    }

    func addClient(_ input: AddClientInput) async throws -> String {
        try await client.addClient(input)
    }
}
