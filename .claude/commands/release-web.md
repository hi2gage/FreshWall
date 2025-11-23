# Release Web

Create a new Web app release with proper versioning and tagging.

## Quick Start

For most releases, just use the release script:
```bash
./Scripts/release-platform.sh
# Select "Web" → choose version type → done!
```

## Manual Steps (if needed)

1. **Verify we're on main branch** - Start from main
2. **Get current Web version** - Find latest `web/v*` tag
3. **Calculate next version** - Ask user for patch/minor/major/custom
4. **Update version file** - Update `Web/package.json`:
   - `"version"` = new version (e.g., "0.6.0")
5. **Commit and push to main** - `Bump Web version to v{VERSION}`
6. **Wait for staging deploy** - Changes auto-deploy to staging environment
7. **Test on staging** - Verify at staging.freshwall.app
8. **Create git tag** - Format: `web/v{VERSION}` with release notes
9. **Push tag** - `git push origin web/v{VERSION}` (triggers production deploy)
10. **Create GitHub release** - Using `gh release create`

## Version Calculation

Given current version `0.5.0`:
- **Patch**: `0.5.1` (bug fixes)
- **Minor**: `0.6.0` (new features)
- **Major**: `1.0.0` (production ready / breaking changes)
- **Custom**: User specifies

## Example Tag Message

```
Web Release v0.6.0

- Dashboard color updates with brand system
- New feedback form component
- Improved responsive design
```

## What This Triggers

Creating a `web/v*` tag will trigger:
- Web app deployment to Vercel/production
- Firebase deployment (if Firebase/ changed)
- Telegram notification

## Important Notes

- Web uses semantic versioning: MAJOR.MINOR.PATCH
- Version changes must go through PR to main first
- Merging to main auto-deploys to staging for testing
- Tag is created on main after testing on staging
- Tag format must be: `web/v0.6.0` (not `v0.6.0`)

## Workflow Summary

```
1. Update Web/package.json version
2. Commit and push to main
3. Wait for staging deploy (automatic)
4. Test on staging.freshwall.app
5. Create tag: git tag web/v0.6.0
6. Push tag: git push origin web/v0.6.0
7. Production deployment triggers automatically
```

## Using the Release Script

The `./Scripts/release-platform.sh` script handles everything for you:
- Gets current version from git tags
- Calculates next version
- Creates and pushes the tag
- Creates GitHub release

This is the recommended approach!
