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
    func addClient(_ input: AddClientInput) async throws
}

// MARK: - DefaultClientsRepository

struct DefaultClientsRepository: ClientsRepository {
    let client: ClientServiceProtocol

    func fetchClients() async throws -> [Client] {
        try await client.fetchClients()
    }

    func addClient(_ input: AddClientInput) async throws {
        try await client.addClient(input)
    }
}
