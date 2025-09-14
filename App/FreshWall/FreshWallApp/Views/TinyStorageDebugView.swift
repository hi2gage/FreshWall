import SwiftUI
import TinyStorage

// MARK: - TinyStorageDebugViewModel

@MainActor
@Observable
class TinyStorageDebugViewModel {
    var storageData: [String: [StorageEntry]] = [:]
    var isLoading = false

    struct StorageEntry {
        let key: String
        let value: String
        let type: String
    }

    init() {
        loadAllStorageData()
    }

    func loadAllStorageData() {
        isLoading = true
        storageData.removeAll()

        // Load Firebase Environment Storage
        loadFirebaseEnvironmentStorage()

        // Load Filter Preferences Storage
        loadFilterPreferencesStorage()

        isLoading = false
    }

    private func loadFirebaseEnvironmentStorage() {
        var entries: [StorageEntry] = []

        // Firebase storage uses the same TinyStorage instance as FirebaseConfiguration
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let firebaseStorage = TinyStorage(insideDirectory: documentsURL, name: "firebase-environment-prefs")

        // Try to load each known key
        let firebaseKeys: [any TinyStorageKey] = [
            FirebaseStorageKeys.mode,
            FirebaseStorageKeys.firebaseEnvironment,
            FirebaseStorageKeys.emulatorEnvironment,
            FirebaseStorageKeys.customIP,
        ]

        for key in firebaseKeys {
            if let mode = firebaseStorage.retrieve(type: EnvironmentMode.self, forKey: FirebaseStorageKeys.mode),
               key.rawValue == FirebaseStorageKeys.mode.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: mode.rawValue,
                    type: "EnvironmentMode"
                ))
            } else if let env = firebaseStorage.retrieve(type: FirebaseEnvironment.self, forKey: FirebaseStorageKeys.firebaseEnvironment),
                      key.rawValue == FirebaseStorageKeys.firebaseEnvironment.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: env.rawValue,
                    type: "FirebaseEnvironment"
                ))
            } else if let emulatorEnv = firebaseStorage.retrieve(type: EmulatorEnvironment.self, forKey: FirebaseStorageKeys.emulatorEnvironment),
                      key.rawValue == FirebaseStorageKeys.emulatorEnvironment.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: emulatorEnv.rawValue,
                    type: "EmulatorEnvironment"
                ))
            } else if let ip = firebaseStorage.retrieve(type: String.self, forKey: FirebaseStorageKeys.customIP),
                      key.rawValue == FirebaseStorageKeys.customIP.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: ip,
                    type: "String"
                ))
            }
        }

        if !entries.isEmpty {
            storageData["Firebase Environment"] = entries
        }
    }

    private func loadFilterPreferencesStorage() {
        var entries: [StorageEntry] = []

        // Filter storage
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filterStorage = TinyStorage(insideDirectory: documentsURL, name: "filter-preferences")

        // Try to load each known filter key
        let filterKeys: [any TinyStorageKey] = [
            FilterStorageKeys.incidentsDateRange,
            FilterStorageKeys.incidentsClient,
            FilterStorageKeys.incidentsGroupOption,
            FilterStorageKeys.incidentsSort,
        ]

        for key in filterKeys {
            if let dateRange = filterStorage.retrieve(type: DateRangeOption.self, forKey: FilterStorageKeys.incidentsDateRange),
               key.rawValue == FilterStorageKeys.incidentsDateRange.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: dateRange.rawValue,
                    type: "DateRangeOption"
                ))
            } else if let client = filterStorage.retrieve(type: String.self, forKey: FilterStorageKeys.incidentsClient),
                      key.rawValue == FilterStorageKeys.incidentsClient.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: client,
                    type: "String"
                ))
            } else if let groupOption = filterStorage.retrieve(type: IncidentGroupOption.self, forKey: FilterStorageKeys.incidentsGroupOption),
                      key.rawValue == FilterStorageKeys.incidentsGroupOption.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: groupOption.rawValue,
                    type: "IncidentGroupOption"
                ))
            } else if let sort = filterStorage.retrieve(type: SortState<IncidentSortField>.self, forKey: FilterStorageKeys.incidentsSort),
                      key.rawValue == FilterStorageKeys.incidentsSort.rawValue {
                entries.append(StorageEntry(
                    key: key.rawValue,
                    value: "field: \(sort.field.label), ascending: \(sort.isAscending)",
                    type: "SortState<IncidentSortField>"
                ))
            }
        }

        if !entries.isEmpty {
            storageData["Filter Preferences"] = entries
        }
    }

    func clearAllStorage() {
        // Clear firebase storage
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let firebaseStorage = TinyStorage(insideDirectory: documentsURL, name: "firebase-environment-prefs")
        let filterStorage = TinyStorage(insideDirectory: documentsURL, name: "filter-preferences")

        // Clear known keys
        for key in [
            FirebaseStorageKeys.mode,
            FirebaseStorageKeys.firebaseEnvironment,
            FirebaseStorageKeys.emulatorEnvironment,
            FirebaseStorageKeys.customIP,
        ] {
            firebaseStorage.remove(key: key)
        }

        for key in [
            FilterStorageKeys.incidentsDateRange,
            FilterStorageKeys.incidentsClient,
            FilterStorageKeys.incidentsGroupOption,
            FilterStorageKeys.incidentsSort,
        ] {
            filterStorage.remove(key: key)
        }

        // Reload data
        loadAllStorageData()
    }

    func clearFilterStorage() {
        FilterManager.clearAllIncidentsPreferences()
        loadAllStorageData()
    }
}

// MARK: - TinyStorageDebugView

struct TinyStorageDebugView: View {
    @State private var viewModel = TinyStorageDebugViewModel()
    @State private var showingClearAlert = false
    @State private var showingClearFiltersAlert = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading persistence data...")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                } else if viewModel.storageData.isEmpty {
                    Text("No persistence data found")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding(.vertical)
                } else {
                    ForEach(viewModel.storageData.keys.sorted(), id: \.self) { storageType in
                        if let entries = viewModel.storageData[storageType] {
                            Section(header: Text(storageType)) {
                                ForEach(entries, id: \.key) { entry in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(entry.key)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Text(entry.type)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(4)
                                        }

                                        Text(entry.value)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 8)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                }

                // Action buttons
                Section(header: Text("Actions")) {
                    Button("Refresh Data") {
                        viewModel.loadAllStorageData()
                    }
                    .foregroundColor(.blue)

                    Button("Clear Filter Storage") {
                        showingClearFiltersAlert = true
                    }
                    .foregroundColor(.orange)

                    Button("Clear All Storage") {
                        showingClearAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Persistence Debug")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Clear All Storage", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllStorage()
                }
            } message: {
                Text("This will clear all persistence data including Firebase environment settings. You may need to reconfigure settings.")
            }
            .alert("Clear Filter Storage", isPresented: $showingClearFiltersAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear Filters", role: .destructive) {
                    viewModel.clearFilterStorage()
                }
            } message: {
                Text("This will clear all saved filter preferences and reset them to defaults.")
            }
        }
    }
}

#Preview {
    FreshWallPreview {
        TinyStorageDebugView()
    }
}
