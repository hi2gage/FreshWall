# FreshWall

FreshWall is a mono repo containing the iOS application and its Firebase backend. The app helps teams track graffiti incidents, manage clients, and collaborate in the field. All backend logic and rules are handled with Firebase services running in the emulator during development.

## Repository Layout

- **App/** – SwiftUI iOS app
- **Firebase/** – Cloud Functions, Firestore rules, and emulator configuration

## iOS App

The iOS project lives under `App/FreshWall`. It follows the MVVM pattern and relies on Swift Concurrency. When adding SwiftUI previews, use `#Preview` wrapped in the `FreshWallPreview {}` helper so previews run with the proper environment injected.

### Build

Open the Xcode project and build the `FreshWallApp` target:

```bash
cd App/FreshWall
open FreshWall.xcodeproj  # or build from the command line
# xcodebuild -scheme FreshWallApp -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Tests

Run unit tests with `xcodebuild` or from within Xcode:

```bash
xcodebuild -scheme FreshWallApp -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Firebase Backend

The backend lives in `Firebase/` and uses Cloud Functions with TypeScript, Firestore rules, and the Emulator Suite.

### Functions

Key callable functions are implemented in `functions/src`:

- `createTeamCreateUser` – create a new team and user in one call.
- `joinTeamCreateUser` – join an existing team with a code.
- `updateClientLastIncident` – Firestore trigger updating a client when an incident is created.

### Build & Lint

Install dependencies and run the provided scripts before running emulators or deploying:

```bash
cd Firebase/functions
npm install
npm run lint
npm run build
```

### Emulators

Start the local emulators (Firestore, Auth, Storage and Functions) from the `Firebase/` directory:

```bash
firebase emulators:start
```

### Deploy

Deploy functions to Firebase (after linting and building):

```bash
firebase deploy --only functions
```

## Running Combined Tests

`npm run test` inside `Firebase/functions` runs lint and build to ensure TypeScript code compiles cleanly.

All Swift tests reside in `App/FreshWall/FreshWallTests` and can be run via Xcode or `xcodebuild`.

