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
- Do not use `PreviewProvider` for SwiftUi previews. Use `#Preview`. 
  - Also add the `FreshWallPreview {}` view builder around all SwiftUI previews
- All ViewModels @Observable and @MainActor

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