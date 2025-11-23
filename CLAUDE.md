# AGENTS.md – Project Guide for OpenAI Codex and Other AI Agents

This file provides structure, conventions, and architectural context for AI agents (like OpenAI Codex) working within the FreshWall project.

## 📦 Project Overview

FreshWall is a **mono repo** containing two major components:

- `App/`: A SwiftUI-based iOS app for graffiti incident tracking, team collaboration, and client reporting.
- `Firebase/`: The backend layer, including Firestore rules, Cloud Functions, and authentication powered by Firebase Emulator Suite.

AI agents should understand and respect the separation between frontend (Swift code) and backend (TypeScript functions + Firebase configuration).

---

## 🧭 Repository Structure

.
├── App/                    # SwiftUI iOS application
│   └── FreshWall/          # Xcode project, app code, UI, view models, and model definitions
│       ├── FreshWallApp/   # Main app target
│       ├── FreshWallTests/ # Unit and UI tests
│       └── FreshWall.xcodeproj     # Xcode project
│
├── Firebase/               # Firebase backend (Cloud Functions, Firestore rules)
│   ├── functions/          # Cloud Functions (TypeScript, Node.js v18+)
│   │   ├── src/            # Function implementations
│   │   └── lib/            # Built JS output
│   ├── firestore.rules     # Firestore security rules
│   ├── firestore.indexes.json # Optional indexes
│   └── firebase.json       # Emulator and project config
│
├── AGENTS.md             
├── README.md

---

## 🧱 Architectural Principles

- Each **team** owns its own scoped data in Firestore:  
  `/teams/{teamId}/clients/...`, `/teams/{teamId}/users/...`, etc.
- All write operations are handled via **Cloud Functions** for consistency and permission validation.
- The iOS app interacts with Firestore and Functions via Firebase SDK.
- Firestore Emulator and Functions Emulator are used during development and testing.

---

## 🧑‍💻 Coding Conventions

### iOS App (`App/`)

- Language: Swift 5.9+ with Swift Concurrency
- UI: SwiftUI (MVVM architecture)
- Naming:
  - Files and types use `PascalCase`
  - Variables and functions use `camelCase`
- Model Types must conform to `Codable` and reflect Firestore schema
- Use `@DocumentID var id: String?` where needed for Firestore ID binding
- Do not use `import FirebaseFirestoreSwift`, it's no longer used. So use `import FirebaseFirestore`
- Whenever you reference Firestore types such as `Firestore.firestore` you must add `@preconcurrency import FirebaseFirestore`
- Whenever you reference `FirebaseAuth` you must add `@preconcurrency import FirebaseAuth`
- Whenever you reference `Functions` you must add `@preconcurrency import FirebaseFunctions`
- Do not use `PreviewProvider` for SwiftUi previews. Use `#Preview`.
  - Also add the `FreshWallPreview {}` view builder around all SwiftUI previews
- All ViewModels @Observable and @MainActor

#### Navigation Requirements
**CRITICAL: Navigation must use RouterPath - NEVER use sheets or showingX = true for navigation**
- All navigation MUST use `NavigationLink(value: RouterDestination.xxx)` pattern
- There are two router types:
  - `LoginRouterPath` - For unauthenticated screens (login, signup, etc.)
  - `RouterPath` - For authenticated app screens
- DO NOT use `.sheet()` or `@State private var showingX = false` for navigation to new screens
- All new screens must be added to the appropriate RouterDestination enum
- Navigation should be consistent and follow the established router pattern
- Alerts are fine for confirmations, errors, and simple user interactions

> AI agents must prefer functional, composable code. Avoid global state and `DispatchQueue` unless interacting with legacy APIs.

### Firebase Functions (`Firebase/functions`)

- Language: TypeScript
- Module Format: ESM (ECMAScript Modules)
- Target Node.js 18 (even if locally installed Node is 22)
- Cloud Functions are structured using `onCall()` from `firebase-functions/v2`
- Use `admin.initializeApp()` and Firestore Admin SDK

### Firestore Rules

- Restrict reads/writes to authenticated users within their own team
- Role-based access control (lead vs. member)
- Helpers like `isInTeam(teamId)` and `isLead(teamId)` are defined for readability

---

## ✍️ Swift Naming Rules for OpenAI Codex

- Models: `Team`, `User`, `Incident`, `Client`
- Enums: `UserRole`, `IncidentStatus`
- Environment: Use `@EnvironmentObject` for shared services like `AuthService`
- View structure:
  - `LoginView`, `SignupView`, `IncidentListView`, etc.
  - Avoid overly deep view nesting (keep components small)

---

## 🧪 Testing & Validation

### iOS Tests

- Use Swift Testing for unit tests
- Test files must match the name of the class being tested (`XyzViewModelTests.swift`)
- PreviewProvider usage is encouraged for SwiftUI views

### Firebase Tests

- Functions can be tested with `firebase-functions-test`
- Emulator-only development is enforced (production writes are restricted)

---

## 🚀 Dev Commands

### Firebase (inside `Firebase/`):

```bash
# Install dependencies
npm install

# Build cloud functions
npm run build
```

### Release Management:

```bash
# Create a new release version
./Scripts/release.sh
```

The release script will:
- Prompt for version type (patch/minor/major/custom)
- Update `IDENTITY_VERSION` and `IDENTITY_BUILD` in `App/FreshWall/Configurations/Base.xcconfig`
- Commit changes with standardized message format
- Create and push git tag (e.g., `v1.1.4`)
- Push to remote repository

**When to use**: After completing feature development, bug fixes, or any changes ready for production deployment. AI agents should suggest using this script when work is complete and ready for release.

---

## 🔀 Git Workflow & Branch Strategy

### Branch Structure
- **`main`** - Primary development branch. All PRs target this branch.
- **`feature/*`** - Feature branches should PR to `main`

**IMPORTANT: Never commit directly to `main`. Always create a feature branch (e.g., `feature/add-xyz`) before making changes, even for small fixes. All changes must go through the PR process.**

### Workflow
1. Create feature branch from `main`
2. Make changes and commit
3. Open PR to `main` (default branch)
4. After PR is merged to `main`, changes automatically deploy to **staging environment**
5. When ready for production, create and push a platform-specific tag

### CI/CD Automation
- **Merges to `main`**: Auto-deploy to staging environment (Firebase Functions, Web app, etc.)
- **Tag pushes**: Deploy to production based on tag prefix:
  - `firebase/*` tags → Deploy Firebase Functions/Firestore to production
  - `web/*` tags → Deploy Web app to production
  - `ios/*` tags → Trigger iOS production release

### Production Releases
To release to production, create and push a tag:

```bash
# Firebase production release
git tag firebase/v1.0.0
git push origin firebase/v1.0.0

# Web production release
git tag web/v1.0.0
git push origin web/v1.0.0

# iOS production release
git tag ios/v1.0.0
git push origin ios/v1.0.0
```

**Important**: AI agents should always create PRs targeting `main`. Production releases are controlled via tags.

### Working with Git Worktrees

FreshWall supports git worktrees to work on multiple features simultaneously without switching branches. This is especially useful when you need to:
- Work on multiple features in parallel
- Test different branches without stashing changes
- Keep your main worktree clean and pristine

#### Worktree Management Scripts

**Interactive Manager (`Scripts/worktree-manager.sh`)** - Visual dashboard and interactive management:

```bash
# Launch interactive manager (recommended)
./Scripts/worktree-manager.sh

# Or show dashboard only
./Scripts/worktree-manager.sh --dashboard
```

The interactive manager provides:
- Visual dashboard showing all worktrees with status indicators
- Git status for each worktree (modified, staged, ahead/behind remote)
- Interactive menu to open, remove, or manage worktrees
- Quick access to create new worktrees
- Batch cleanup operations

**Command-line Tool (`Scripts/worktree.sh`)** - Direct commands for scripts/automation:

```bash
# Create a new worktree (opens iTerm2 with 2 tabs)
./Scripts/worktree.sh create feature/new-dashboard

# Create with Claude Code prompt (auto-runs in tab 2)
./Scripts/worktree.sh create feature/new-dashboard "Implement the dashboard UI"

# List all active worktrees
./Scripts/worktree.sh list

# Open a worktree in Xcode
./Scripts/worktree.sh open feature/new-dashboard

# Remove a worktree when done
./Scripts/worktree.sh remove feature/new-dashboard

# Clean up all worktrees
./Scripts/worktree.sh cleanup
```

#### Worktree Structure

Worktrees are created in `.worktrees/` directory:
```
FreshWall/
├── .worktrees/
│   ├── feature-new-dashboard/    # Full project copy on feature/new-dashboard
│   ├── feature-api-refactor/     # Full project copy on feature/api-refactor
│   └── bugfix-login-issue/       # Full project copy on bugfix/login-issue
├── App/                           # Main worktree (typically on main branch)
├── Firebase/
└── Scripts/
```

#### Best Practices

1. **Main worktree stays clean**: Keep your primary FreshWall directory on `main` branch without local changes
2. **One worktree per feature**: Create a worktree for each feature branch you're actively working on
3. **Clean up when done**: Remove worktrees after PRs are merged to avoid clutter
4. **Xcode conflicts**: Each worktree has its own derived data, avoiding Xcode workspace conflicts
5. **Firebase emulator**: You can run Firebase emulators from different worktrees simultaneously (use different ports)

#### AI Agent Usage

When AI agents need to work on a new feature:
1. Check current branch with `git branch --show-current`
2. If on `main`, create a new worktree: `./Scripts/worktree.sh create feature/xyz`
3. Work in the worktree directory: `cd .worktrees/feature-xyz`
4. When done, return to main worktree and remove: `./Scripts/worktree.sh remove feature/xyz`

---

🔐 Firebase Auth + Firestore Rules Summary
	•	Users must authenticate before accessing any data
	•	Only team leads may create or delete users and clients
	•	Members may create incidents but cannot escalate privileges

⸻

✅ Pull Request Requirements

When contributing or when AI agents generate a PR:
	1.	Follow code structure and naming conventions above
	2.	Add tests for all new Swift views or functions
	3.	Ensure Firestore rules are updated when data access changes
	4.	Add docs or comments for any new Function or Auth flow
	5.	Use npm run lint and npm run build in Firebase/ before merging

⸻

📘 Example Agent Queries Codex Should Understand
	•	“Create a SwiftUI view to list all incidents for the current team”
	•	“Write a Cloud Function to delete a client if the user is a team lead”
	•	“Generate Firestore rules to prevent members from editing users”
	•	“Add a Firebase Callable Function that lets a user create a new team and join it”