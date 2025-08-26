import Foundation

public struct NetworkConfiguration: Sendable {
    public let useEmulator: Bool
    public let emulatorHost: String
    public let authEmulatorPort: Int
    public let firestoreEmulatorPort: Int
    public let functionsEmulatorPort: Int
    public let storageEmulatorPort: Int

    public init(
        useEmulator: Bool = false,
        emulatorHost: String = "127.0.0.1",
        authEmulatorPort: Int = 9099,
        firestoreEmulatorPort: Int = 8080,
        functionsEmulatorPort: Int = 5001,
        storageEmulatorPort: Int = 9199
    ) {
        self.useEmulator = useEmulator
        self.emulatorHost = emulatorHost
        self.authEmulatorPort = authEmulatorPort
        self.firestoreEmulatorPort = firestoreEmulatorPort
        self.functionsEmulatorPort = functionsEmulatorPort
        self.storageEmulatorPort = storageEmulatorPort
    }

    public static let production = NetworkConfiguration(useEmulator: false)

    public static let development = NetworkConfiguration(
        useEmulator: true,
        emulatorHost: "127.0.0.1"
    )
}
