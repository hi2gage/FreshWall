//
//  ClientsRepository.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/28/25.
//

import Foundation

protocol ClientsRepository {
    /// Fetches active clients for the current team.
    func fetchClients(sortedBy sortOption: ClientSortOption) async throws -> [ClientDTO]
    /// Adds a new client using an input value object.
    func addClient(_ input: AddClientInput) async throws
}

struct DefaultClientsRepository: ClientsRepository {
    let client: ClientServiceProtocol

    func fetchClients(sortedBy sortOption: ClientSortOption) async throws -> [ClientDTO] {
        try await client.fetchClients(sortedBy: sortOption)
    }

    func addClient(_ input: AddClientInput) async throws {
        try await client.addClient(input)
    }
}
