# Release Web

Create a new Web app release with proper versioning and tagging.

## Steps

1. **Verify we're on main branch** - Start from main
2. **Get current Web version** - Find latest `web/v*` tag
3. **Calculate next version** - Ask user for patch/minor/major/custom
4. **Create release branch** - `release/web-v{VERSION}` from main
5. **Update version file** - Update `Web/package.json`:
   - `"version"` = new version (e.g., "0.6.0")
6. **Commit changes** - `Bump Web version to v{VERSION}`
7. **Push branch and create PR** - PR to main
8. **After PR merged to main** - Changes auto-deploy to staging environment
9. **When ready for production** - Create git tag: `web/v{VERSION}` with release notes on main
10. **Push tag** - `git push origin web/v{VERSION}` (triggers production deploy)
11. **Create GitHub release** - Using `gh release create`

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
1. main → create release/web-v0.6.0 branch
2. Update package.json → commit → push
3. Create PR: release/web-v0.6.0 → main
4. Merge PR to main → auto-deploys to staging
5. Test on staging environment
6. Create tag web/v0.6.0 on main
7. Push tag → triggers production deployment
```
