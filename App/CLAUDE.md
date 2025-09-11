# FreshWall iOS App - Tier 2 Context

**Component**: iOS Application (SwiftUI)
**Role**: Native mobile client for graffiti incident tracking and team collaboration
**Architecture**: MVVM with @Observable ViewModels and SwiftUI declarative UI

## 🏗️ iOS App Architecture

### Core Architectural Principles

**MVVM with Modern Swift Concurrency:**
- ViewModels are @Observable and @MainActor for UI thread safety
- Use async/await for all Firebase operations
- Views bind directly to @Observable properties
- No combine publishers or ObservableObject

**State Management Pattern:**
- Local state in ViewModels for UI-specific concerns
- Global state through shared services (AuthService, SessionService)
- Firebase real-time listeners for data synchronization
- @EnvironmentObject for dependency injection

### Module Organization

Each feature module follows this structure:
```
Feature/
├── Views/           # SwiftUI views
├── ViewModels/      # @Observable business logic
├── Models/          # Local data models
├── Services/        # Feature-specific services
└── Repositories/    # Data access layer
```

## 🎯 SwiftUI Conventions

### View Structure
```swift
// Standard view pattern
struct FeatureView: View {
    @State private var viewModel = FeatureViewModel()
    @Environment(AuthService.self) private var authService
    
    var body: some View {
        // UI implementation
    }
}

#Preview {
    FreshWallPreview {
        FeatureView()
    }
}
```

### ViewModel Pattern
```swift
@MainActor
@Observable
final class FeatureViewModel {
    // Published state properties
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?
    
    // Async operations
    func loadItems() async {
        // Implementation with proper error handling
    }
}
```

## 🔧 Firebase Integration

### Service Layer Architecture

**AuthService** (Global Singleton)
- Firebase Auth wrapper
- Session management
- Team context switching
- User role validation

**Feature Services** (Injected Dependencies)
- ClientService, IncidentService, UserService
- Cloud Function calls for mutations
- Firestore listeners for real-time data
- Local caching and offline support

### Data Flow Pattern
```
UI Action → ViewModel → Service → Cloud Function → Firestore → Real-time Listener → ViewModel → UI Update
```

## 📱 User Interface Patterns

### Navigation
- RouterPath-based programmatic navigation
- Hierarchical navigation with proper back button behavior
- Modal presentations for creation/editing flows
- Tab-based main navigation (when implemented)

### List Management
- GenericListView for consistent list styling
- GenericGroupableListView for categorized data
- Sorting with SortButton and SortState
- Pull-to-refresh and loading states

### Photo Management
- PhotoPicker for gallery selection
- CameraPicker for camera capture
- PhotoSourcePicker for choosing source
- PhotoCarousel and PhotoViewer for display
- Automatic compression and metadata extraction

### Form Handling
- SwiftUI Form with consistent styling
- Validation in ViewModels
- Error message display
- Loading states during submission

## 🔐 Security & Permissions

### Authentication Flow
1. Check existing session on app launch
2. Redirect to login if unauthenticated
3. Maintain Firebase Auth state
4. Handle token refresh automatically

### Role-Based UI
- Hide/show features based on user role
- Lead users see management features
- Members see limited functionality
- Validate permissions before actions

### Data Validation
- Client-side validation for UX
- Server-side validation in Cloud Functions
- Proper error handling and user feedback
- Input sanitization for security

## 📊 State Management Details

### Local State (View-specific)
- Form fields and validation states
- UI interaction states (selected items, etc.)
- Navigation state
- Modal presentation state

### Shared State (Service-level)
- User session and authentication
- Team membership and roles
- Real-time data from Firestore
- App-wide configuration

### Persistence
- UserDefaults for user preferences
- Keychain for sensitive data (handled by Firebase)
- Core Data not used - Firestore is source of truth

## 🧪 Testing Strategy

### Unit Tests
- ViewModel business logic testing
- Service layer testing with mocked dependencies
- Model validation and transformation testing
- Utility function testing

### UI Tests (Future)
- Critical user flows (auth, incident creation)
- Cross-device compatibility
- Accessibility testing
- Performance testing

### Test Structure
```swift
// Standard test pattern
@Test("Description of test case")
func testFeatureScenario() async {
    // Arrange
    let viewModel = FeatureViewModel()
    
    // Act
    await viewModel.performAction()
    
    // Assert
    #expect(viewModel.expectedState == expectedValue)
}
```

## 🚀 Performance Considerations

### Image Handling
- Compress photos before upload
- Progressive loading for image lists
- Thumbnail generation
- Cache management for downloaded images

### List Performance
- Lazy loading for large datasets
- Virtual scrolling where appropriate
- Efficient diffing for real-time updates
- Background processing for heavy operations

### Memory Management
- Weak references for delegates
- Proper cleanup of Firebase listeners
- Image cache eviction policies
- Background app state handling

## 🔧 Development Workflow

### Local Development
1. Start Firebase emulators
2. Open Xcode project
3. Select Dev scheme
4. Build and run on Simulator

### Testing Workflow
1. Run unit tests: Cmd+U
2. Test on device for Firebase functionality
3. Test offline scenarios
4. Validate with different team roles

### Build Configurations
- **Dev**: Points to local emulators
- **Beta**: Points to Firebase staging
- **Prod**: Points to production Firebase

## 🎨 UI Guidelines

### Design System
- Follow iOS Human Interface Guidelines
- Consistent spacing and typography
- System colors with semantic meanings
- Accessibility-first design

### Component Patterns
- Reusable components in GenericViews/
- Consistent styling with ListCellStyle
- Platform-appropriate interactions
- Dark mode support

### User Experience
- Intuitive navigation flows
- Clear feedback for actions
- Graceful error handling
- Offline capability where possible

## 🔄 Data Synchronization

### Real-time Updates
- Firestore listeners for live data
- Automatic UI updates via @Observable
- Conflict resolution (last-write-wins)
- Connection status handling

### Offline Support
- Cache recently viewed data
- Queue actions for when online
- Show cached data with indicators
- Sync when connection restored

---

**Last Updated**: January 2025  
**Dependencies**: Firebase iOS SDK, SwiftUI, Swift Concurrency  
**Deployment**: Xcode Cloud → TestFlight → App Store