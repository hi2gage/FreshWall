# Create Pull Request

Create a pull request for your current work with automatic branch safety checks.

## When to Use

Use this command when:
- You've completed a feature or bug fix and want to create a PR
- You want to push your changes and create a PR in one step
- You need to ensure you're not accidentally committing to main

## Safety Features

This command includes automatic safety checks:
- **Main branch protection**: If you're on `main`, automatically creates a new feature branch
- **Uncommitted changes check**: Ensures all changes are committed before creating PR
- **Automatic push**: Pushes your branch to remote before creating PR

**IMPORTANT**: This project ONLY uses `main` branch. DO NOT reference, check for, or use `staging` branch in any way.

## Steps

1. **Check current branch** - Verify which branch you're on:
   ```bash
   git branch --show-current
   ```

2. **Main branch safety check** - If on `main` (ONLY check for `main`, NOT staging or any other branch):
   - Prompt user for a new branch name (e.g., "feature/fix-login" or just "fix-login")
   - If user provides just a name without prefix, prepend "feature/"
   - Create and checkout new branch: `git checkout -b <branch-name>`
   - Inform user that branch was created

3. **Check for uncommitted changes**:
   ```bash
   git status --porcelain
   ```
   - If there are uncommitted changes, ask user if they want to commit them first
   - If yes, run the standard git commit flow (with proper commit message format)
   - If no, abort and inform user to commit or stash changes first

4. **Gather PR context** - Run these commands in parallel to understand the changes:
   ```bash
   git status
   git diff --cached
   git diff main...HEAD
   git log main...HEAD
   ```

5. **Check remote tracking** - Verify if branch is tracking remote:
   ```bash
   git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
   ```
   - If not tracking or behind, push with `-u` flag

6. **Push to remote**:
   ```bash
   git push -u origin <current-branch>
   ```

7. **Draft PR title and body**:
   - Analyze all commits in the branch (from `git log main...HEAD`)
   - Review the full diff from main
   - Create a comprehensive PR description with:
     - **Title**: Clear, concise summary of changes
     - **Summary**: 1-3 bullet points of key changes
     - **Test plan**: Checklist of testing steps
     - Include Claude Code attribution footer

8. **Create PR** using `gh`:
   ```bash
   gh pr create --title "the pr title" --body "$(cat <<'EOF'
   ## Summary
   <1-3 bullet points>

   ## Test plan
   [Bulleted markdown checklist of TODOs for testing the pull request...]

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )"
   ```

9. **Return PR URL** - Display the PR URL so user can view it

## Branch Name Guidelines

Good branch names:
- `feature/login-improvements`
- `bugfix/auth-timeout`
- `refactor/api-client`
- `docs/update-readme`

The command will automatically:
- Convert spaces to hyphens
- Convert to lowercase
- Prepend "feature/" if no prefix is provided

## PR Format

The PR will follow the FreshWall standard format:

```markdown
## Summary
- Key change 1
- Key change 2
- Key change 3

## Test plan
- [ ] Test scenario 1
- [ ] Test scenario 2
- [ ] Verify no regressions

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Important Notes

- **Never commit directly to main**: This command enforces the branch protection policy
- **All PRs target main**: The default and ONLY base branch is `main`
- **NEVER use staging**: This project does not use a staging branch. All comparisons, diffs, and PR bases use `main` only
- **Auto-deployment**: PRs merged to `main` may trigger automatic deployments
- **Production releases**: Use platform-specific tags (`firebase/*`, `web/*`, `ios/*`) for production
- **DO NOT push to remote** unless explicitly in this command flow
- **DO NOT use TodoWrite** - This is a focused PR creation command
- **Comprehensive analysis**: Review ALL commits and changes, not just the latest
- **Base branch is always main**: When running `git diff` or `git log`, always use `main` as the base, never staging

## Example Usage Flow

### Scenario 1: On feature branch with changes
```
User: /create-pr
Claude: You're on branch feature/login-improvements
        Checking for uncommitted changes...
        ✓ All changes committed
        ✓ Pushed to origin
        Creating PR...
        ✓ PR created: https://github.com/user/repo/pull/123
```

### Scenario 2: Accidentally on main
```
User: /create-pr
Claude: ⚠️  You're currently on main branch!
        Let me create a new feature branch for you.
        What would you like to name the branch?
User: fix-auth-bug
Claude: ✓ Created and switched to branch: feature/fix-auth-bug
        Now creating PR...
        ✓ PR created: https://github.com/user/repo/pull/124
```

### Scenario 3: Uncommitted changes
```
User: /create-pr
Claude: You have uncommitted changes:
        - App/FreshWall/Views/LoginView.swift (modified)
        - App/FreshWall/Models/User.swift (modified)

        Would you like to commit these changes first?
User: yes
Claude: [Runs git commit flow]
        ✓ Changes committed
        ✓ Pushed to origin
        ✓ PR created: https://github.com/user/repo/pull/125
```

## Integration with Worktrees

This command works seamlessly with git worktrees:
- Can be run from any worktree directory
- Automatically detects the current worktree's branch
- Pushes from the worktree's branch
- Creates PR for the worktree's feature branch

## What This Command Does NOT Do

- Does NOT merge the PR
- Does NOT delete branches after PR creation
- Does NOT trigger production deployments (use tags for that)
- Does NOT use the TodoWrite tool
- Does NOT read/explore additional code beyond git commands
