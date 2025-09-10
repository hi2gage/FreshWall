@preconcurrency import FirebaseAuth
import FirebaseCore
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
@preconcurrency import FirebaseStorage
import Foundation
import TinyStorage

// MARK: - FirebaseStorageKeys

enum FirebaseStorageKeys: String, TinyStorageKey {
    case environment = "firebase_environment"
    case customIP = "firebase_custom_ip"
}

extension TinyStorage {
    static let environment: TinyStorage = {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return .init(insideDirectory: documentsURL, name: "firebase-environment-prefs")
    }()
}

/// Firebase environment configuration options
enum FirebaseEnvironment: String, CaseIterable, Codable {
    case production = "Production"
    case localhost = "Localhost"
    case customIP = "Custom IP"

    var description: String {
        rawValue
    }
}

/// Handles Firebase environment setup and switching.
enum FirebaseConfiguration {
    /// Default IP address for Firebase emulators when testing on device.
    private static let defaultDeviceHostIP = "192.168.1.234"

    /// Current custom IP address for Firebase emulators.
    static var customIP: String {
        get {
            TinyStorage.environment.retrieve(
                type: String.self,
                forKey: FirebaseStorageKeys.customIP
            ) ?? defaultDeviceHostIP
        }
        set {
            TinyStorage.environment.store(
                newValue,
                forKey: FirebaseStorageKeys.customIP
            )
        }
    }

    /// Current environment - defaults to production in release, localhost in debug
    static var currentEnvironment: FirebaseEnvironment {
        get {
            TinyStorage.environment.retrieve(
                type: FirebaseEnvironment.self,
                forKey: FirebaseStorageKeys.environment
            ) ?? defaultEnvironment
        }
        set {
            TinyStorage.environment.store(
                newValue,
                forKey: FirebaseStorageKeys.environment
            )
        }
    }

    /// Default environment based on build configuration
    private static var defaultEnvironment: FirebaseEnvironment {
        #if DEBUG
            return .localhost
        #else
            return .production
        #endif
    }

    /// Configure Firebase services based on current environment
    private static func configureEnvironment() {
        switch currentEnvironment {
        case .production:
            // Use production Firebase - no emulator configuration needed
            print("🚀 Using Production Firebase")

        case .localhost, .customIP:
            let host = emulatorHost
            var settings = Firestore.firestore().settings
            settings.host = "\(host):8080"
            settings.isSSLEnabled = false
            settings.isPersistenceEnabled = false
            Firestore.firestore().settings = settings

            Functions.functions().useEmulator(withHost: host, port: 5001)
            Auth.auth().useEmulator(withHost: host, port: 9099)
            Storage.storage().useEmulator(withHost: host, port: 9199)

            print("🔧 Using Firebase Emulator at \(host)")
        }
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

        FirebaseConfiguration.configureEnvironment()
    }

    /// Returns the host for Firebase emulators based on environment and run destination.
    private static var emulatorHost: String {
        switch currentEnvironment {
        case .production:
            return "" // Not used in production
        case .localhost:
            return "localhost"
        case .customIP:
            #if targetEnvironment(simulator)
                return "localhost" // Fallback to localhost on simulator
            #else
                return customIP
            #endif
        }
    }

    /// Switch to a different Firebase environment
    static func switchEnvironment(to environment: FirebaseEnvironment) {
        currentEnvironment = environment
        print("⚠️ Environment switched to \(environment.rawValue). App restart required for changes to take effect.")
    }
}
