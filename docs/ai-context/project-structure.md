# FreshWall Project Structure

This document provides the complete technology stack and file tree structure for the FreshWall project. **AI agents MUST read this file to understand the project organization before making any changes.**

## Technology Stack

### iOS App Technologies
- **Swift 5.9+** with **Swift Concurrency** - Modern async/await patterns
- **SwiftUI** - Declarative UI framework with MVVM architecture
- **Firebase iOS SDK** - Backend integration and real-time data sync
- **Swift Testing** - Unit testing framework
- **Xcode Cloud** - CI/CD pipeline

### Backend Technologies (Firebase)
- **TypeScript** with **Node.js 18+** - Cloud Functions runtime
- **Firebase Cloud Functions v2** - Serverless backend using `onCall()`
- **Firestore** - NoSQL document database
- **Firebase Auth** - Authentication and user management
- **Firebase Storage** - Image storage for incident photos
- **ESM** - ECMAScript Modules for Cloud Functions

### Development & Quality Tools
- **Firebase Emulator Suite** - Local development and testing
- **npm** - Package management for Cloud Functions
- **Swift Package Manager** - iOS dependency management
- **Git** - Version control with feature branch workflow

### Architectural Patterns
- **Team-scoped data model** - Each team owns its data namespace
- **Cloud Functions for writes** - All data mutations go through functions
- **Role-based access control** - Lead vs member permissions
- **Real-time sync** - Firestore listeners for live updates

## Complete Project Structure

```
FreshWall/
├── README.md                           # Project overview and setup
├── CLAUDE.md                           # Master AI context file (AGENTS.md)
├── AGENTS.md                           # AI agent guide and conventions
├── .gitignore                          # Git ignore patterns
├── .claude/                            # Claude-specific configuration
├── App/                                # SwiftUI iOS application
│   └── FreshWall/                      # Xcode project root
│       ├── FreshWall.xcodeproj/        # Xcode project file
│       │   ├── project.pbxproj         # Project configuration
│       │   └── xcshareddata/           # Shared schemes and settings
│       ├── Configurations/             # Build configurations
│       │   ├── Base.xcconfig           # Base configuration
│       │   ├── Dev.xcconfig            # Development environment
│       │   ├── Beta.xcconfig           # Beta testing environment
│       │   └── Prod.xcconfig           # Production environment
│       ├── FreshWallApp/               # Main app target
│       │   ├── Assets.xcassets/        # App icons and images
│       │   ├── FreshWallApp.swift      # App entry point
│       │   ├── FreshWallPreview.swift  # Preview environment wrapper
│       │   ├── ContentView.swift       # Root content view
│       │   ├── MainAppView.swift       # Main app navigation
│       │   ├── RootView.swift          # Root view with auth check
│       │   ├── Auth/                   # Authentication module
│       │   │   ├── AuthService.swift   # Firebase Auth wrapper
│       │   │   ├── LoginManager.swift  # Login business logic
│       │   │   ├── SessionService.swift # Session management
│       │   │   ├── SessionStore.swift  # Session state
│       │   │   └── Views/              # Auth UI components
│       │   │       ├── AuthFlowView.swift
│       │   │       ├── SignupWithNewTeamView.swift
│       │   │       └── SignupWithExistingTeamView.swift
│       │   ├── Clients/                # Client management module
│       │   │   ├── ClientsListView.swift
│       │   │   ├── ClientsListViewModel.swift
│       │   │   ├── AddClientView.swift
│       │   │   ├── AddClientViewModel.swift
│       │   │   ├── EditClientView.swift
│       │   │   ├── EditClientViewModel.swift
│       │   │   ├── ClientDetailView.swift
│       │   │   ├── ClientListCell.swift
│       │   │   ├── ClientSortField.swift
│       │   │   ├── Models/
│       │   │   │   └── ClientCellModel.swift
│       │   │   └── Repositories/
│       │   │       └── ClientsRepository.swift
│       │   ├── Incidents/              # Incident tracking module
│       │   │   ├── IncidentsListView.swift
│       │   │   ├── IncidentsListViewModel.swift
│       │   │   ├── AddIncidentView.swift
│       │   │   ├── AddIncidentViewModel.swift
│       │   │   ├── EditIncidentView.swift
│       │   │   ├── EditIncidentViewModel.swift
│       │   │   ├── IncidentDetailView.swift
│       │   │   ├── IncidentListCell.swift
│       │   │   ├── IncidentSortField.swift
│       │   │   └── IncidentGroupOption.swift
│       │   ├── Members/                # Team member management
│       │   │   ├── MembersListView.swift
│       │   │   ├── MembersListViewModel.swift
│       │   │   ├── InviteMemberView.swift
│       │   │   ├── InviteMemberViewModel.swift
│       │   │   ├── MemberDetailView.swift
│       │   │   ├── MemberListCell.swift
│       │   │   ├── MemberSortField.swift
│       │   │   └── MemberGroupOption.swift
│       │   ├── Models/                 # Data models (Codable)
│       │   │   ├── Client.swift
│       │   │   ├── ClientDTO.swift
│       │   │   ├── Incident.swift
│       │   │   ├── IncidentDTO.swift
│       │   │   ├── IncidentPhoto.swift
│       │   │   ├── IncidentPhotoDTO.swift
│       │   │   ├── Member.swift
│       │   │   ├── TeamDTO.swift
│       │   │   ├── UserDTO.swift
│       │   │   ├── UserSession.swift
│       │   │   └── PickedPhoto+IncidentDTO.swift
│       │   ├── Services/               # Business logic and Firebase integration
│       │   │   ├── FirebaseConfiguration.swift
│       │   │   ├── ClientService.swift
│       │   │   ├── ClientModelService.swift
│       │   │   ├── IncidentService.swift
│       │   │   ├── IncidentModelService.swift
│       │   │   ├── IncidentPhotoService.swift
│       │   │   ├── UserService.swift
│       │   │   ├── UserModelService.swift
│       │   │   ├── MemberService.swift
│       │   │   ├── InviteCodeService.swift
│       │   │   ├── StorageService.swift
│       │   │   ├── PhotoMetadataService.swift
│       │   │   └── Input Models/       # Function input types
│       │   │       ├── AddClientInput.swift
│       │   │       ├── AddIncidentInput.swift
│       │   │       ├── AddMemberInput.swift
│       │   │       ├── UpdateClientInput.swift
│       │   │       └── UpdateIncidentInput.swift
│       │   ├── GenericViews/           # Reusable UI components
│       │   │   ├── GenericListView.swift
│       │   │   ├── GenericGroupableListView.swift
│       │   │   ├── AsyncSheet.swift
│       │   │   ├── PhotoPicker.swift
│       │   │   ├── CameraPicker.swift
│       │   │   ├── PhotoSourcePicker.swift
│       │   │   ├── PhotoCarousel.swift
│       │   │   ├── PhotoViewer.swift
│       │   │   ├── PhotoViewerContext.swift
│       │   │   ├── ListCellStyle.swift
│       │   │   ├── Label+extension.swift
│       │   │   ├── ZoomableModifer.swift
│       │   │   └── Sort/              # Sorting components
│       │   │       ├── SortButton.swift
│       │   │       ├── SortFieldRepresentable.swift
│       │   │       └── SortState.swift
│       │   ├── Navigation/             # Navigation helpers
│       │   │   ├── RouterPath.swift
│       │   │   └── LoginRouterPath.swift
│       │   └── Domain/                 # Domain-specific components
│       │       ├── IncidentRow.swift
│       │       └── MemberRow.swift
│       ├── FreshWallTests/             # Unit tests
│       │   ├── FreshWallTests.swift
│       │   ├── ClientsListViewModelTests.swift
│       │   ├── EditClientViewModelTests.swift
│       │   ├── IncidentsListViewModelTests.swift
│       │   ├── EditIncidentViewModelTests.swift
│       │   ├── MembersListViewModelTests.swift
│       │   ├── InviteMemberViewModelTests.swift
│       │   ├── PhotoMetadataServiceTests.swift
│       │   ├── PhotoPickerTests.swift
│       │   ├── CameraPickerTests.swift
│       │   ├── PhotoViewerTests.swift
│       │   ├── PhotoViewerContextTests.swift
│       │   ├── GenericGroupableListViewTests.swift
│       │   ├── ClientServiceCompositionTests.swift
│       │   └── IncidentServiceCompositionTests.swift
│       ├── FreshWallUITests/           # UI tests
│       ├── TestPlan.xctestplan        # Test configuration
│       └── ci_scripts/                 # Xcode Cloud scripts
│           └── ci_post_clone.sh
├── Firebase/                           # Firebase backend
│   ├── firebase.json                   # Firebase configuration
│   ├── firestore.rules                 # Security rules
│   ├── firestore.indexes.json          # Database indexes
│   ├── storage.rules                   # Storage security rules
│   ├── functions/                      # Cloud Functions
│   │   ├── package.json                # Node dependencies
│   │   ├── package-lock.json           # Dependency lock file
│   │   ├── tsconfig.json               # TypeScript config
│   │   ├── tsconfig.dev.json           # Dev TypeScript config
│   │   ├── src/                        # Function source code
│   │   │   ├── index.ts                # Function exports
│   │   │   └── signup/                 # Signup functions
│   │   │       ├── createTeamCreateUser.ts
│   │   │       ├── joinTeamCreateUser.ts
│   │   │       └── generateInviteCode.ts
│   │   ├── lib/                        # Built JavaScript
│   │   └── emulator-data/              # Local emulator data
│   └── scripts/                        # Deployment scripts
│       └── deploy-prep.sh
├── Business/                           # Business documentation
│   ├── executive-summary.md
│   └── roadmap.md
├── docs/                               # Project documentation
│   ├── CLAUDE.md                       # Master AI context
│   ├── README.md                       # Documentation overview
│   ├── ai-context/                     # AI-specific docs
│   │   ├── project-structure.md        # This file
│   │   ├── docs-overview.md
│   │   ├── system-integration.md
│   │   ├── deployment-infrastructure.md
│   │   └── handoff.md
│   ├── specs/                          # Feature specifications
│   └── open-issues/                    # Known issues
├── commands/                           # AI command templates
│   ├── README.md
│   ├── code-review.md
│   ├── create-docs.md
│   ├── full-context.md
│   ├── handoff.md
│   ├── refactor.md
│   └── update-docs.md
└── bin/                                # Binary/script files
```

## Key Architectural Notes

### Data Flow
1. **iOS App** → Makes authenticated calls to Cloud Functions
2. **Cloud Functions** → Validate permissions and write to Firestore
3. **Firestore** → Triggers real-time updates back to iOS app
4. **Storage** → Handles incident photo uploads with metadata

### Security Model
- All data is team-scoped: `/teams/{teamId}/...`
- Role-based permissions: `lead` can manage team, `member` has limited access
- Cloud Functions enforce all write permissions
- Firestore rules restrict read access to team members only

### Development Workflow
1. Run Firebase emulators locally for backend development
2. Use Xcode with dev configuration for iOS development
3. Test with emulator data before deploying to production
4. CI/CD through Xcode Cloud for iOS, Firebase CLI for backend