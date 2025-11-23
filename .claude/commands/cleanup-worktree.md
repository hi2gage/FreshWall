# Cleanup Worktree

Remove a git worktree when you're done working on a feature.

## When to Use

Use this command when:
- Feature branch has been merged and you're done with the worktree
- You want to clean up old/abandoned worktrees
- You need to free up disk space
- Removing all worktrees to start fresh

## Steps

1. **Check active worktrees** - List all current worktrees:
   ```bash
   ./Scripts/worktree.sh list
   ```

2. **Show worktree status** - Display which worktrees exist and their git status

3. **Prompt for action** - Ask user what they want to do:
   - Remove a specific worktree (ask for branch name)
   - Remove all worktrees (cleanup everything)
   - Cancel

4. **For specific worktree removal**:
   - Confirm the branch name
   - Check if there are uncommitted changes (warn user)
   - Run: `./Scripts/worktree.sh remove <branch-name>`

5. **For cleanup all**:
   - Warn about uncommitted changes in any worktree
   - Confirm with user
   - Run: `./Scripts/worktree.sh cleanup`

6. **Inform user** - Let them know what was removed

## What Gets Removed

When removing a worktree:
- The `.worktrees/<branch-name>/` directory is deleted
- The local git branch is deleted
- The remote branch is NOT deleted (you can still find it on GitHub)
- Any uncommitted changes in that worktree are LOST

## Safety Checks

Before removing, check for:
- Uncommitted changes (git status)
- Unpushed commits (git log origin/branch..HEAD)
- Currently active processes in that directory

## Important Notes

- This does NOT delete the remote branch on GitHub
- This does NOT close or delete the PR
- Uncommitted changes will be lost (warn user!)
- You cannot remove the main worktree (the root project directory)
- You should be in the main worktree when running this command

## Example Usage

```
User: /cleanup-worktree
Claude: Here are your current worktrees:
        - feature-login-improvements (clean)
        - feature-new-dashboard (2 uncommitted changes)
        - bugfix-auth-timeout (merged, clean)

        What would you like to do?
        1. Remove a specific worktree
        2. Remove all worktrees
        3. Cancel

User: 1
Claude: Which worktree would you like to remove?
User: bugfix-auth-timeout
Claude: ✓ Removed worktree: feature-bugfix-auth-timeout
        ✓ Deleted local branch: bugfix-auth-timeout
```

## Interactive Manager

For a visual dashboard and interactive management, you can also use:
```bash
./Scripts/worktree-manager.sh
```

This provides:
- Visual dashboard with status indicators
- Git status for each worktree
- Interactive menu for all operations
- Batch cleanup options
