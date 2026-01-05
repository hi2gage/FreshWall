@preconcurrency import FirebaseAuth
import FirebaseCore
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
@preconcurrency import FirebaseStorage
import Foundation
import TinyStorage
import os

// MARK: - FirebaseStorageKeys

enum FirebaseStorageKeys: String, TinyStorageKey {
    case mode = "environment_mode"
    case firebaseEnvironment = "firebase_environment"
    case emulatorEnvironment = "emulator_environment"
    case customIP = "firebase_custom_ip"
}

extension TinyStorage {
    static let environment: TinyStorage = {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return .init(insideDirectory: documentsURL, name: "firebase-environment-prefs")
    }()
}

/// Firebase backend environment options
enum FirebaseEnvironment: String, CaseIterable, Codable {
    case dev = "Dev"
    case beta = "Beta"
    case prod = "Prod"

    var description: String {
        rawValue
    }
}

/// Emulator environment options
enum EmulatorEnvironment: String, CaseIterable, Codable {
    case localhost = "Localhost"
    case customIP = "Custom IP"

    var description: String {
        rawValue
    }
}

/// Current environment mode
enum EnvironmentMode: String, CaseIterable, Codable {
    case firebase
    case emulator
}

/// Handles Firebase environment setup and switching.
enum FirebaseConfiguration {
    private static let logger = Logger.freshWall(category: "FirebaseConfiguration")
    /// Default IP address for Firebase emulators when testing on device.
    private static let defaultDeviceHostIP = "192.168.0.99"

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

    /// Current environment mode
    static var currentMode: EnvironmentMode {
        get {
            TinyStorage.environment.retrieve(
                type: EnvironmentMode.self,
                forKey: FirebaseStorageKeys.mode
            ) ?? defaultMode
        }
        set {
            TinyStorage.environment.store(
                newValue,
                forKey: FirebaseStorageKeys.mode
            )
        }
    }

    /// Current Firebase environment (only used when mode is .firebase)
    static var currentFirebaseEnvironment: FirebaseEnvironment {
        get {
            TinyStorage.environment.retrieve(
                type: FirebaseEnvironment.self,
                forKey: FirebaseStorageKeys.firebaseEnvironment
            ) ?? .prod
        }
        set {
            TinyStorage.environment.store(
                newValue,
                forKey: FirebaseStorageKeys.firebaseEnvironment
            )
        }
    }

    /// Current emulator environment (only used when mode is .emulator)
    static var currentEmulatorEnvironment: EmulatorEnvironment {
        get {
            TinyStorage.environment.retrieve(
                type: EmulatorEnvironment.self,
                forKey: FirebaseStorageKeys.emulatorEnvironment
            ) ?? .localhost
        }
        set {
            TinyStorage.environment.store(
                newValue,
                forKey: FirebaseStorageKeys.emulatorEnvironment
            )
        }
    }

    /// Default environment mode based on build configuration
    private static var defaultMode: EnvironmentMode {
        #if DEBUG
            return .emulator
        #else
            return .firebase
        #endif
    }

    /// Configure Firebase services based on current environment
    private static func configureEnvironment() {
        switch currentMode {
        case .firebase:
            // Use Firebase backend - no emulator configuration needed
            logger.info("🚀 Using Firebase \(currentFirebaseEnvironment.description)")

            // Clear network caches on simulator to avoid stale QUIC connections
            #if targetEnvironment(simulator)
                clearSimulatorNetworkCache()
            #endif

        case .emulator:
            let host = "192.168.0.99"
            var settings = Firestore.firestore().settings
            settings.host = "\(host):8080"
            settings.isSSLEnabled = false
            settings.isPersistenceEnabled = false
            Firestore.firestore().settings = settings

            Functions.functions().useEmulator(withHost: host, port: 5001)
            Auth.auth().useEmulator(withHost: host, port: 9099)
            Storage.storage().useEmulator(withHost: host, port: 9199)

            logger.info("🔧 Using Firebase Emulator at \(host) (\(currentEmulatorEnvironment.description))")
        }
    }

    /// Clear network caches on simulator to prevent stale QUIC connections
    #if targetEnvironment(simulator)
        private static func clearSimulatorNetworkCache() {
            // Clear URLSession caches to remove stale HTTP/3 connections
            URLCache.shared.removeAllCachedResponses()

            // Invalidate the default URLSession to force new connections
            URLSession.shared.invalidateAndCancel()

            logger.info("🧹 Simulator: Cleared network cache to avoid stale QUIC connections")
        }
    #endif

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

        let resolvedLocation = validPath.contains("GoogleConfigs") ? "GoogleConfigs" : "main bundle"
        let analyticsAppID = options.googleAppID
        let measurementID = options.trackingID ?? "Unknown"

        FirebaseApp.configure(options: options)
        logger.info("✅ Firebase configured using: \(plistName) from GoogleConfigs")

        FirebaseConfiguration.configureEnvironment()
    }

    /// Returns the host for Firebase emulators based on environment and run destination.
    private static var emulatorHost: String {
        switch currentMode {
        case .firebase:
            "" // Not used for Firebase backend
        case .emulator:
            switch currentEmulatorEnvironment {
            case .localhost:
                "localhost"
            case .customIP:
                customIP
            }
        }
    }

    /// Switch to Firebase mode with specific environment
    static func switchToFirebase(environment: FirebaseEnvironment) {
        currentMode = .firebase
        currentFirebaseEnvironment = environment
        logger.info("⚠️ Environment switched to Firebase \(environment.rawValue). App restart required for changes to take effect.")
    }

    /// Switch to emulator mode with specific environment
    static func switchToEmulator(environment: EmulatorEnvironment) {
        currentMode = .emulator
        currentEmulatorEnvironment = environment
        logger.info("⚠️ Environment switched to \(environment.rawValue). App restart required for changes to take effect.")
    }
}
