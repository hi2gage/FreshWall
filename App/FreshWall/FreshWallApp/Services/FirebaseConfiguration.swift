@preconcurrency import FirebaseAuth
import FirebaseCore
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
@preconcurrency import FirebaseStorage
import Foundation

/// Handles emulator setup for Firebase services.
enum FirebaseConfiguration {
    /// IP address of the host running Firebase emulators when testing on device.
    static let deviceHostIP = "192.168.1.234"

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
            let plistName = Bundle.main.object(forInfoDictionaryKey: "FIREBASE_GOOGLE_SERVICE_PLIST") as? String else {
            let error = String(describing: Bundle.main.object(forInfoDictionaryKey: "FIREBASE_GOOGLE_SERVICE_PLIST"))
            fatalError("❌ Missing or invalid Firebase plist key: \(error)")
        }

        // Look for the plist file in the GoogleConfigs subdirectory
        var filePath: String?

        // First try: exact name in GoogleConfigs directory
        filePath = Bundle.main.path(forResource: plistName, ofType: nil, inDirectory: "GoogleConfigs")
        if filePath == nil {
            // Second try: with .plist extension in GoogleConfigs
            filePath = Bundle.main.path(forResource: plistName, ofType: "plist", inDirectory: "GoogleConfigs")
        }
        if filePath == nil {
            // Third try: remove .plist if it's in the name and try again in GoogleConfigs
            let nameWithoutExt = plistName.replacingOccurrences(of: ".plist", with: "")
            filePath = Bundle.main.path(forResource: nameWithoutExt, ofType: "plist", inDirectory: "GoogleConfigs")
        }

        // Fallback: try in main bundle (for backward compatibility)
        if filePath == nil {
            filePath = Bundle.main.path(forResource: plistName, ofType: nil)
        }
        if filePath == nil {
            filePath = Bundle.main.path(forResource: plistName, ofType: "plist")
        }
        if filePath == nil {
            let nameWithoutExt = plistName.replacingOccurrences(of: ".plist", with: "")
            filePath = Bundle.main.path(forResource: nameWithoutExt, ofType: "plist")
        }

        guard let validPath = filePath,
              let options = FirebaseOptions(contentsOfFile: validPath) else {
            fatalError("❌ Missing or invalid Firebase plist: \(plistName)")
        }

        FirebaseApp.configure(options: options)
        print("✅ Firebase configured using: \(plistName) from GoogleConfigs")

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
