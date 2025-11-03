# Team Code vs Invite Code - Important Distinction

## The Issue

When you try to join the team with code `6F4E5E`, you get "Invite code not found."

## Why This Happens

FreshWall has **TWO different types of codes**:

### 1. Team Code (`team.teamCode`)
- **Location**: Stored directly on the team document at `/teams/{teamId}`
- **Example**: `6F4E5E` (for Urban Beautification team)
- **Created**: When `createTeamCreateUser` is called (team creation)
- **Purpose**: Originally intended as a team identifier, but **NOT used for joining**
- **Status**: Appears to be legacy/unused

### 2. Invite Codes (`/teams/{teamId}/inviteCodes/{code}`)
- **Location**: Stored as documents in the `inviteCodes` subcollection
- **Examples**: `028EB1`, `228C29`, `66AE0F` (for Urban Beautification team)
- **Created**: When `generateInviteCode` is called by admins/managers
- **Purpose**: **Actually used for joining teams** via `joinTeamCreateUser`
- **Status**: Active and working

## The Code Flow

```typescript
// 1. When a team is created:
createTeamCreateUser() {
  const teamCode = randomBytes(3).toString("hex").toUpperCase();  // e.g., "6F4E5E"
  teamRef.set({ name, teamCode, ... });  // Stored on team doc
  // ⚠️ No inviteCode document is created with this code!
}

// 2. When admins generate invite codes:
generateInviteCode() {
  const code = randomBytes(3).toString("hex").toUpperCase();  // e.g., "028EB1"
  teamRef.collection("inviteCodes").doc(code).set({ ... });  // Creates inviteCode doc
}

// 3. When users try to join:
joinTeamCreateUser(teamCode) {
  // ❌ Does NOT look at team.teamCode
  // ✅ Only looks in inviteCodes collection:
  const inviteDocs = await collectionGroup("inviteCodes").get();
  const inviteDoc = inviteDocs.docs.find(doc => doc.id === teamCode);

  if (!inviteDoc) {
    throw new Error("Invite code not found.");  // This is what you're seeing!
  }
}
```

## The Solution

**Don't use `team.teamCode` (6F4E5E) to join the team.**

Instead, use one of the **actual invite codes** that were copied to staging:
- `028EB1` (field_worker role)
- `228C29` (field_worker role)
- `66AE0F` (field_worker role)
- ...and 5 more

You can see all the invite codes by running:
```bash
node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49 --dry-run
```

## Migration Status

✅ **The migration was successful!**

The script correctly copied all 8 invite codes from production to staging. The issue was just confusion between the two different types of codes.

```
Migration Summary:
  Team ID:           4bn04KFSRcPvGbHXOV49
  Team Name:         Urban Beautification
  Users copied:      3
  Clients copied:    1
  Invite codes:      8  ← These are the codes you should use!
  Incidents copied:  10
  Photos copied:     27
```

## Recommended Fix (Long-term)

There's a design inconsistency here that should be addressed:

**Option A**: Remove `team.teamCode` entirely
- It's not used and causes confusion
- Keep only the `inviteCodes` collection

**Option B**: Create a default invite code on team creation
- When `createTeamCreateUser` runs, also create an invite code document with the same code
- This would make the team code usable for joining

**Option C**: Update `joinTeamCreateUser` to check both
- First check `team.teamCode`
- Then check `inviteCodes` collection
- This maintains backward compatibility

---

**Next Steps for Testing:**

1. Try joining the staging team using code `028EB1` (or any of the other copied invite codes)
2. This should work! ✅

---

**Last Updated:** November 3, 2025
