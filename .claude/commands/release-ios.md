# Release iOS

Create a new iOS app release with proper versioning and tagging.

## Steps

1. **Checkout main branch** - Run `git checkout main && git pull origin main` to ensure we're on the latest main
2. **Get current iOS version** - Find latest `ios/v*` tag
3. **Calculate next version** - Ask user for patch/minor/major/custom
4. **Create release branch** - `release/ios-v{VERSION}` from main
5. **Update version file** - Update `App/FreshWall/Configurations/Base.xcconfig`:
   - `IDENTITY_VERSION` = new version (e.g., 1.3.2)
   - `IDENTITY_BUILD` = increment by 1
6. **Commit changes** - `Bump iOS version to v{VERSION}`
7. **Push branch and create PR** - PR to main
8. **After PR merged to main** - Changes auto-deploy to staging environment
9. **When ready for production** - Create git tag: `ios/v{VERSION}` with release notes on main
10. **Push tag** - `git push origin ios/v{VERSION}` (triggers production deploy)
11. **Create GitHub release** - Using `gh release create`

## Version Calculation

Given current version `1.3.1`:
- **Patch**: `1.3.2` (bug fixes)
- **Minor**: `1.4.0` (new features)
- **Major**: `2.0.0` (breaking changes)
- **Custom**: User specifies (e.g., `1.5.0`)

## Example Tag Message

```
iOS Release v1.3.2

- Dashboard improvements with brand colors
- New feedback card
- Bug fixes for photo upload
```

## What This Triggers

Creating an `ios/v*` tag will trigger:
- iOS app build via Xcode Cloud
- TestFlight upload
- Firebase deployment (if Firebase/ changed)
- Telegram notification

## Important Notes

- iOS uses semantic versioning: MAJOR.MINOR.PATCH
- Build number auto-increments with each release
- Version changes must go through PR to main first
- Merging to main auto-deploys to staging for testing
- Tag is created on main after testing on staging
- Tag format must be: `ios/v1.2.3` (not `v1.2.3`)

## Workflow Summary

```
1. checkout main && git pull → create release/ios-v1.3.2 branch
2. Update version files → commit → push
3. Create PR: release/ios-v1.3.2 → main
4. Merge PR to main → auto-deploys to staging
5. Test on staging environment
6. Create tag ios/v1.3.2 on main
7. Push tag → triggers production deployment
```
