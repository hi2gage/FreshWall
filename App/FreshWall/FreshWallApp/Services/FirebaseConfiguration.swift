@preconcurrency import FirebaseAuth
import FirebaseCore
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
@preconcurrency import FirebaseStorage
import Foundation

/// Handles emulator setup for Firebase services.
enum FirebaseConfiguration {
    /// IP address of the host running Firebase emulators when testing on device.
    static let deviceHostIP = "192.168.0.99"

    /// Configure all Firebase services to connect to local emulators.
    private static func configureEmulators() {
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

    static func configureFirebase() {
        guard
            let plistName = Bundle.main.object(forInfoDictionaryKey: "FIREBASE_GOOGLE_SERVICE_PLIST") as? String,
            let filePath = Bundle.main.path(forResource: plistName, ofType: nil),
            let options = FirebaseOptions(contentsOfFile: filePath) else {
            let error = String(describing: Bundle.main.object(forInfoDictionaryKey: "FIREBASE_GOOGLE_SERVICE_PLIST"))
            fatalError("❌ Missing or invalid Firebase plist: \(error) ")
        }

        FirebaseApp.configure(options: options)
        print("✅ Firebase configured using: \(plistName)")

        FirebaseConfiguration.configureEmulators() // <-- Call your existing emulator setup here
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
