# FreshWall Firebase Backend - Tier 2 Context

**Component**: Firebase Backend (Cloud Functions + Firestore)
**Role**: Serverless backend API and data persistence for FreshWall
**Architecture**: Cloud Functions v2 with TypeScript, Firestore NoSQL database

## 🏗️ Backend Architecture

### Core Principles

**Team-Scoped Data Model:**
- All data lives under `/teams/{teamId}/` collections
- Enforces data isolation between teams
- Enables multi-tenant scaling
- Simplified security rules and permissions

**Cloud Functions for Writes:**
- All mutations go through Cloud Functions
- Consistent validation and business logic
- Centralized permission checking
- Audit trail and logging

**Real-time Synchronization:**
- Firestore listeners for live updates
- Minimal state in functions (stateless)
- Client-side caching for performance
- Event-driven architecture

### Technology Stack

**Runtime Environment:**
- Node.js 18+ (Cloud Functions)
- TypeScript with strict type checking
- ESM (ECMAScript Modules)
- Firebase Admin SDK

**Database Design:**
```
Firestore Collections:
/teams/{teamId}/users/          # Team members
/teams/{teamId}/clients/        # Customer information
/teams/{teamId}/incidents/      # Job tracking
/teams/{teamId}/reports/        # Generated reports (future)
/teams/{teamId}/invites/        # Invitation codes
```

## 🔧 Cloud Functions Architecture

### Function Organization

**Authentication Functions** (`signup/`)
- `createTeamCreateUser` - New team registration
- `joinTeamCreateUser` - Join existing team
- `generateInviteCode` - Create team invitation

**Data Management Functions** (planned)
- Client CRUD operations
- Incident lifecycle management
- User role management
- Report generation

### Function Pattern
```typescript
// Standard Cloud Function pattern
export const functionName = onCall<InputType, OutputType>(
  {
    enforceAppCheck: true, // Security
    cors: true,           // Cross-origin requests
    region: 'us-central1' // Performance
  },
  async (request) => {
    // 1. Authentication check
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Must be logged in');
    }

    // 2. Input validation
    const { data } = request;
    // Validate input structure

    // 3. Permission checking
    // Verify user can perform this action

    // 4. Business logic
    // Core function implementation

    // 5. Return structured response
    return { success: true, data: result };
  }
);
```

## 🔐 Security Model

### Authentication Strategy
- Firebase Auth handles user identity
- JWT tokens validated automatically
- Custom claims for roles and team membership
- Session management handled client-side

### Authorization Patterns

**Role-Based Access Control:**
```typescript
enum UserRole {
  LEAD = 'lead',     // Full team management
  MEMBER = 'member'  // Limited functionality
}

// Permission checking utility
function requireRole(userId: string, teamId: string, role: UserRole) {
  // Implementation
}
```

**Team Isolation:**
- All functions validate team membership
- Users can only access their team's data
- Firestore rules enforce read permissions
- Storage rules limit file access by team

### Firestore Security Rules

**Key Patterns:**
```javascript
// Team membership validation
function isInTeam(teamId) {
  return request.auth != null && 
         request.auth.uid in resource.data.users;
}

// Role-based permissions
function isLead(teamId) {
  return isInTeam(teamId) && 
         get(/databases/$(database)/documents/teams/$(teamId)/users/$(request.auth.uid)).data.role == 'lead';
}

// Read access pattern
allow read: if isInTeam(teamId);

// Write access pattern (leads only)
allow write: if isLead(teamId);
```

## 📊 Data Model Design

### Team Structure
```typescript
interface Team {
  id: string;
  name: string;
  createdAt: Timestamp;
  createdBy: string;
  settings?: {
    // Future team-specific settings
  };
}
```

### User Management
```typescript
interface TeamUser {
  uid: string;          // Firebase Auth UID
  email: string;
  displayName: string;
  role: UserRole;
  joinedAt: Timestamp;
  invitedBy?: string;
  status: 'active' | 'invited' | 'disabled';
}
```

### Client Management
```typescript
interface Client {
  id: string;
  name: string;
  address?: string;
  contactInfo?: ContactInfo;
  notes?: string;
  createdAt: Timestamp;
  createdBy: string;
  status: 'active' | 'archived';
}
```

### Incident Tracking
```typescript
interface Incident {
  id: string;
  clientId: string;
  title: string;
  description?: string;
  location: GeoPoint;
  status: 'open' | 'in_progress' | 'completed' | 'cancelled';
  assignedTo?: string;
  beforePhotos: IncidentPhoto[];
  afterPhotos: IncidentPhoto[];
  createdAt: Timestamp;
  createdBy: string;
  completedAt?: Timestamp;
  completedBy?: string;
}
```

## 🗄️ Storage Management

### File Organization
```
Storage Buckets:
/teams/{teamId}/incidents/{incidentId}/
├── before/           # Before photos
│   ├── original/     # Full resolution
│   └── thumbnails/   # Compressed versions
└── after/            # After photos
    ├── original/
    └── thumbnails/
```

### Photo Processing
- Automatic compression on upload
- Thumbnail generation (future)
- Metadata extraction and storage
- Security rules based on team membership

## 🔄 Development Workflow

### Local Development
```bash
# Start emulator suite
cd Firebase
npm run build
firebase emulators:start

# Available endpoints:
# Firestore: http://localhost:8080
# Functions: http://localhost:5001
# Auth: http://localhost:9099
# Storage: http://localhost:9199
```

### Function Development
```bash
# TypeScript compilation
npm run build
npm run build:watch  # Watch mode

# Deploy functions
npm run deploy
firebase deploy --only functions

# Environment management
firebase use --add  # Add new project
firebase use dev    # Switch to dev project
```

### Testing Strategy
```bash
# Function testing
npm test

# Integration testing
npm run test:integration

# Emulator testing
firebase emulators:exec "npm test"
```

## 📈 Performance Considerations

### Function Optimization
- Cold start minimization
- Memory allocation tuning
- Concurrent execution limits
- Timeout configuration

### Database Performance
- Strategic indexing
- Compound queries optimization
- Pagination for large datasets
- Read optimization over writes

### Cost Management
- Function execution time optimization
- Firestore read/write minimization
- Storage cost optimization
- Network egress optimization

## 🚨 Error Handling & Monitoring

### Error Patterns
```typescript
// Standardized error handling
import { HttpsError } from 'firebase-functions/v2/https';

function throwStandardError(code: string, message: string, details?: any) {
  throw new HttpsError(code, message, details);
}

// Common error types:
// 'invalid-argument' - Bad input data
// 'permission-denied' - Authorization failure
// 'not-found' - Resource doesn't exist
// 'already-exists' - Duplicate resource
// 'internal' - Server error
```

### Logging Strategy
```typescript
import { logger } from 'firebase-functions/v2';

// Structured logging
logger.info('Operation completed', {
  operation: 'createIncident',
  teamId,
  userId,
  incidentId,
  duration: Date.now() - startTime
});

// Error logging
logger.error('Operation failed', error, {
  operation: 'createIncident',
  teamId,
  userId,
  input: sanitizeInput(data)
});
```

### Monitoring & Alerts
- Function performance metrics
- Error rate monitoring
- Database performance tracking
- Cost threshold alerts

## 🔄 Data Migration & Versioning

### Schema Evolution
- Backward-compatible changes
- Data migration functions
- Version-aware client handling
- Rollback strategies

### Deployment Strategy
- Staging environment testing
- Blue-green deployments
- Feature flags for gradual rollout
- Database backup before migrations

---

**Last Updated**: January 2025  
**Dependencies**: Firebase Admin SDK, TypeScript, Node.js 18+  
**Deployment**: Firebase CLI → Cloud Functions