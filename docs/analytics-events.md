# FreshWall user tasks to consider for analytics

This document catalogs user-facing tasks visible in the current SwiftUI codebase so you can decide where to attach analytics events.

## Authentication and onboarding
- Log in with email/password, including error states for missing accounts.  
  Source: `AuthFlowView` login action. 【F:App/FreshWall/FreshWallApp/Auth/Views/AuthFlowView.swift†L24-L71】
- Attempt Google Sign-In and branch into Google onboarding when the account is not linked to a team.  
  Source: `AuthFlowView` Google button. 【F:App/FreshWall/FreshWallApp/Auth/Views/AuthFlowView.swift†L84-L115】
- Create a new account and team.  
  Source: `SignupWithNewTeamView`. 【F:App/FreshWall/FreshWallApp/Auth/Views/SignupWithNewTeamView.swift†L1-L60】
- Create an account and join an existing team with a code.  
  Source: `SignupWithExistingTeamView`. 【F:App/FreshWall/FreshWallApp/Auth/Views/SignupWithExistingTeamView.swift†L1-L58】
- Complete Google onboarding by creating a team or joining with a team code.  
  Source: `GoogleOnboardingView`. 【F:App/FreshWall/FreshWallApp/Auth/Views/GoogleOnboardingView.swift†L5-L103】
- Open login-level settings and debug tools.  
  Source: `AuthFlowView` toolbar route to `LoginSettingsView`. 【F:App/FreshWall/FreshWallApp/Auth/Views/AuthFlowView.swift†L136-L150】

## Dashboard and navigation
- Visit the Dashboard and launch core modules: Incidents, Clients, Team Members, Management reports (coming soon).  
  Source: `MainListView` buttons. 【F:App/FreshWall/FreshWallApp/MainListView.swift†L20-L68】
- Use the floating action button to start a new incident.  
  Source: `MainListView` add control. 【F:App/FreshWall/FreshWallApp/MainListView.swift†L72-L94】
- Open Settings from the Dashboard toolbar.  
  Source: `MainListView` gear button. 【F:App/FreshWall/FreshWallApp/MainListView.swift†L96-L106】

## Incident workflows
- Load, refresh, and browse incident lists with grouping, sorting, date filters, and client filters; clear filters.  
  Source: `IncidentsListView` menus and refresh. 【F:App/FreshWall/FreshWallApp/Incidents/IncidentsListView.swift†L17-L147】
- Start incident creation with photos (before/after), time tracking, client selection or creation, surface type, area, location capture, billing configuration (defaults vs manual), materials, and enhanced notes; save submission.  
  Source: `AddIncidentView`. 【F:App/FreshWall/FreshWallApp/Incidents/AddIncidentView.swift†L20-L137】
- View incident details with photos, timeline, billing display, surface type, location details, materials, and notes.  
  Source: `IncidentDetailView` sections. 【F:App/FreshWall/FreshWallApp/Incidents/IncidentDetailView.swift†L35-L127】
- Update incident metadata from detail: add photos, change linked client (or create a new one), capture location, refresh data, edit incident, or delete incident.  
  Source: `IncidentDetailView` toolbars and change handlers. 【F:App/FreshWall/FreshWallApp/Incidents/IncidentDetailView.swift†L130-L208】

## Client management
- Browse and refresh clients, sort by name or recent incident activity, and create a new client.  
  Source: `ClientsListView`. 【F:App/FreshWall/FreshWallApp/Clients/ClientsListView.swift†L10-L59】
- Add a client with optional notes and billing defaults; validate and save.  
  Source: `AddClientView`. 【F:App/FreshWall/FreshWallApp/Clients/AddClientView.swift†L1-L63】
- Inspect client details, including associated incidents, and navigate to incidents.  
  Source: `ClientDetailView` content. 【F:App/FreshWall/FreshWallApp/Clients/ClientDetailView.swift†L107-L156】
- Export client reports (invoice or detailed incident PDF), edit client information, refresh details, or delete the client.  
  Source: `ClientDetailView` toolbars and dialogs. 【F:App/FreshWall/FreshWallApp/Clients/ClientDetailView.swift†L38-L215】

## Team member management
- Browse, group, sort, and refresh team members; start an invite flow.  
  Source: `MembersListView`. 【F:App/FreshWall/FreshWallApp/Members/MembersListView.swift†L6-L110】
- Generate and share invitation codes with configurable role and max uses; regenerate codes or adjust options.  
  Source: `InviteMemberView`. 【F:App/FreshWall/FreshWallApp/Members/InviteMemberView.swift†L3-L220】
- Review member profiles, view permission breakdowns, open a change-role prompt, and observe removed-member status.  
  Source: `MemberDetailView`. 【F:App/FreshWall/FreshWallApp/Members/MemberDetailView.swift†L1-L114】

## Settings, profile, and diagnostics
- Edit profile display name, view app version/build, see team ID, open debug settings, or log out.  
  Source: `SettingsView`. 【F:App/FreshWall/FreshWallApp/Views/SettingsView.swift†L23-L127】
- Update display name and save or cancel changes.  
  Source: `EditProfileView`. 【F:App/FreshWall/FreshWallApp/Views/EditProfileView.swift†L1-L74】
- Switch environments, clear caches, enable Firebase logging, show user info, or navigate to persistence debugging.  
  Source: `DebugMenuView` actions. 【F:App/FreshWall/FreshWallApp/Views/DebugMenuView.swift†L21-L158】
- Access login-level settings (version/build, environment) and support entry point.  
  Source: `LoginSettingsView`. 【F:App/FreshWall/FreshWallApp/Views/LoginSettingsView.swift†L1-L74】

## Location, media, and utilities
- Capture or pick incident locations through map-based flows or enhanced capture.  
  Source: router destinations for `MapLocationPickerView` and `EnhancedLocationCaptureView`. 【F:App/FreshWall/FreshWallApp/Navigation/RouterPath.swift†L29-L43】【F:App/FreshWall/FreshWallApp/Navigation/RouterPath.swift†L268-L277】
- View photos full-screen via the photo viewer destination.  
  Source: router destination for `.photoViewer`. 【F:App/FreshWall/FreshWallApp/Navigation/RouterPath.swift†L254-L255】
