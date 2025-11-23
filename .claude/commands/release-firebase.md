# Release Firebase

Create a Firebase backend-only release (no client app changes).

## When to Use

Use this command **only** when deploying Firebase changes without iOS or Web releases:
- Security rule updates
- Cloud Functions bug fixes
- Firestore index changes
- Extension configuration updates
- Database migrations

**Note**: If Firebase changes are part of iOS or Web releases, use `/release-ios` or `/release-web` instead.

## Steps

1. **Verify we're on main branch** - Start from main
2. **Get current Firebase version** - Find latest `firebase/v*` tag
3. **Calculate next version** - Ask user for patch/minor/major/custom
4. **Create release branch** - `release/firebase-v{VERSION}` from main
5. **Update version file** - Update `Firebase/functions/package.json`:
   - `"version"` = new version (e.g., "1.0.1")
6. **Commit changes** - `Bump Firebase version to v{VERSION}`
7. **Push branch and create PR** - PR to main
8. **After PR merged to main** - Changes auto-deploy to staging environment
9. **When ready for production** - Create git tag: `firebase/v{VERSION}` with release notes on main
10. **Push tag** - `git push origin firebase/v{VERSION}` (triggers production deploy)
11. **Create GitHub release** - Using `gh release create`

## Version Calculation

Given current version `1.0.0`:
- **Patch**: `1.0.1` (bug fixes, security patches)
- **Minor**: `1.1.0` (new functions, non-breaking changes)
- **Major**: `2.0.0` (breaking API changes)
- **Custom**: User specifies

## Example Tag Message

```
Firebase Release v1.0.1

- Security fix for Firestore rules
- Improved error handling in Cloud Functions
- Updated Firestore indexes
```

## What This Triggers

Creating a `firebase/v*` tag will trigger:
- Cloud Functions deployment
- Firestore rules deployment
- Storage rules deployment
- Extensions deployment
- Telegram notification

## Important Notes

- Firebase uses semantic versioning: MAJOR.MINOR.PATCH
- Use this **only for backend-only** changes
- If changing client apps too, use `/release-ios` or `/release-web`
- Version changes must go through PR to main first
- Merging to main auto-deploys to staging for testing
- Tag is created on main after testing on staging
- Tag format must be: `firebase/v1.0.1` (not `v1.0.1`)

## Workflow Summary

```
1. main → create release/firebase-v1.0.1 branch
2. Update Firebase/functions/package.json → commit → push
3. Create PR: release/firebase-v1.0.1 → main
4. Merge PR to main → auto-deploys to staging
5. Test on staging environment
6. Create tag firebase/v1.0.1 on main
7. Push tag → triggers production deployment
```
