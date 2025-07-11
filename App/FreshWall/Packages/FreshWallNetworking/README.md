# FreshWallNetworking

A Swift package that provides a clean, testable networking layer for the FreshWall iOS app. This package abstracts Firebase SDK dependencies and provides a protocol-based interface for all network operations.

## Features

- **Protocol-based design**: Clean interfaces for all networking operations
- **Firebase abstraction**: Hides Firebase implementation details from the app layer
- **Mock implementation**: Built-in mock client for testing and SwiftUI previews
- **Type-safe DTOs**: Strongly typed data transfer objects
- **Comprehensive error handling**: Detailed error types with user-friendly messages
- **Async/await**: Modern Swift concurrency throughout

## Installation

Add this package to your Xcode project:

1. In Xcode, select File → Add Package Dependencies
2. Click the "+" button
3. Select "Add Local..."
4. Navigate to `App/FreshWall/Packages/FreshWallNetworking`
5. Click "Add Package"

## Usage

### Basic Setup

```swift
import FreshWallNetworking

// Create a network client
let networkClient = try await NetworkClientFactory.createClient(useMock: false)

// Or for testing/previews
let mockClient = NetworkClientFactory.createMockClient()
```

### Authentication

```swift
// Sign up
let user = try await networkClient.signUp(email: "user@example.com", password: "password123")

// Sign in
let user = try await networkClient.signIn(email: "user@example.com", password: "password123")

// Sign out
try await networkClient.signOut()

// Get current user
if let currentUser = await networkClient.getCurrentUser() {
    print("Logged in as: \(currentUser.email ?? "Unknown")")
}
```

### Team Operations

```swift
// Create a team
let teamId = try await networkClient.createTeam(
    name: "My Team",
    userId: currentUser.id,
    userName: "John Doe"
)

// Get team details
let team = try await networkClient.getTeam(teamId: teamId)

// Get teams for a user
let teams = try await networkClient.getTeamsForUser(userId: currentUser.id)
```

### Client Management

```swift
// Create a client
let clientCreate = ClientCreate(name: "ABC Corp", notes: "Important client")
let clientId = try await networkClient.createClient(teamId: teamId, client: clientCreate)

// Update a client
let updates = ClientUpdate(name: "ABC Corporation")
try await networkClient.updateClient(clientId: clientId, teamId: teamId, updates: updates)

// Get all clients for a team
let clients = try await networkClient.getClientsForTeam(teamId: teamId)

// Delete a client (soft delete)
try await networkClient.deleteClient(clientId: clientId, teamId: teamId)
```

### Incident Tracking

```swift
// Create an incident
let incidentCreate = IncidentCreate(
    projectTitle: "Downtown Cleanup",
    clientId: clientId,
    workerIds: [userId1, userId2],
    description: "Graffiti removal on main street",
    area: 150.5,
    startTime: Date(),
    endTime: Date().addingTimeInterval(3600),
    beforePhotos: [],
    afterPhotos: [],
    billable: true,
    rate: 75.0,
    status: "open"
)

let incidentId = try await networkClient.createIncident(teamId: teamId, incident: incidentCreate)

// Get incidents for a client
let incidents = try await networkClient.getIncidentsForClient(clientId: clientId, teamId: teamId)

// Update incident status
let updates = IncidentUpdate(status: "completed")
try await networkClient.updateIncident(incidentId: incidentId, teamId: teamId, updates: updates)
```

### Error Handling

```swift
do {
    let team = try await networkClient.getTeam(teamId: "invalid-id")
} catch let error as NetworkError {
    switch error {
    case .notAuthenticated:
        print("Please log in first")
    case .documentNotFound:
        print("Team not found")
    case .permissionDenied:
        print("You don't have access to this team")
    case .networkFailure(let underlyingError):
        print("Network error: \(underlyingError)")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## Testing

The package includes a comprehensive mock implementation for testing:

```swift
let mockClient = MockNetworkClient()

// Configure test behavior
mockClient.shouldFailAuth = true
mockClient.networkDelay = 0.5

// Seed with custom test data
mockClient.reset()

// Test your code
await #expect(throws: NetworkError.notAuthenticated) {
    _ = try await mockClient.signIn(email: "test@example.com", password: "wrong")
}
```

## Architecture

### Core Components

- **NetworkClient**: Main protocol defining all network operations
- **NetworkConfiguration**: Configuration for network client (production/development)
- **NetworkError**: Comprehensive error types for all failure scenarios

### DTOs (Data Transfer Objects)

- **Team**: Team information
- **User**: User profile within a team
- **Client**: Customer/client information
- **Incident**: Graffiti incident tracking
- **IncidentPhoto**: Photo metadata with location information

### Repository Interfaces

The package also defines repository protocols for more granular access:

- **AuthRepository**: Authentication operations
- **TeamRepository**: Team management
- **UserRepository**: User management
- **ClientRepository**: Client operations
- **IncidentRepository**: Incident tracking
- **StorageRepository**: File storage
- **InviteRepository**: Team invitation codes

## Migration Guide

To migrate from direct Firebase usage to this networking package:

1. Replace Firebase imports with `import FreshWallNetworking`
2. Replace service initializations with network client creation
3. Update method calls to use the new async/await APIs
4. Replace Firebase-specific types (DocumentReference, Timestamp) with package DTOs
5. Update error handling to use NetworkError cases

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## License

This package is part of the FreshWall project and follows the same license terms.