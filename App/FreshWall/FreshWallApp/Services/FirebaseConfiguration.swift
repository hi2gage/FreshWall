@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
@preconcurrency import FirebaseStorage
import Foundation

/// Handles emulator setup for Firebase services.
enum FirebaseConfiguration {
    /// IP address of the host running Firebase emulators when testing on device.
    static let deviceHostIP = "192.168.0.99"

    /// Configure all Firebase services to connect to local emulators.
    static func configureEmulators() {
        #if DEBUG
            let host = emulatorHost

            var settings = Firestore.firestore().settings
            settings.host = "\(host):8080"
            settings.isSSLEnabled = false
            settings.isPersistenceEnabled = false
            Firestore.firestore().settings = settings

            Functions.functions().useEmulator(withHost: host, port: 5001)
            Auth.auth().useEmulator(withHost: host, port: 9099)
            Storage.storage().useEmulator(withHost: host, port: 9199)
        #endif
    }

    /// Returns the host for Firebase emulators depending on the run destination.
    private static var emulatorHost: String {
        #if targetEnvironment(simulator)
            return "localhost"
        #else
            return deviceHostIP
        #endif
    }
}
