# New Worktree

Create a new git worktree for parallel feature development.

## When to Use

Use this command when you want to work on a new feature or bugfix without switching branches in your main worktree:
- Starting work on a new feature while keeping main clean
- Working on multiple features simultaneously
- Testing different approaches in parallel
- Quick bug fixes without stashing current work

## What is a Worktree?

Git worktrees allow you to have multiple working directories from the same repository, each checked out to different branches. This lets you work on multiple features in parallel without the overhead of cloning the repository multiple times.

## Steps

1. **Prompt for branch name** - Ask user for the feature branch name (e.g., "feature/new-dashboard" or just "new-dashboard")
   - If user provides just a name without prefix, prepend "feature/"
   - Validate branch name format (no spaces, lowercase with hyphens)

2. **Prompt for task description** (optional) - Ask what they want to work on
   - This will be passed to Claude Code in the new worktree
   - Can be skipped if user just wants to create the worktree

3. **Create the worktree** - Run the worktree script:
   ```bash
   ./Scripts/worktree.sh create <branch-name> "<optional-task-description>"
   ```

4. **Inform user** - Let them know:
   - Worktree location: `.worktrees/<branch-name>/`
   - The script will automatically open iTerm2 with:
     - Tab 1: Worktree directory ready for work
     - Tab 2: Claude Code running with the task description (if provided)
   - They can also manually navigate: `cd .worktrees/<branch-name>`

## Branch Name Examples

Good branch names:
- `feature/login-improvements`
- `bugfix/auth-timeout`
- `refactor/api-client`
- `experiment/new-ui`

The script will automatically:
- Convert spaces to hyphens
- Convert to lowercase
- Create the branch from current main

## After Creating Worktree

The user can:
- Work in the new worktree independently
- Run Firebase emulators (use different ports to avoid conflicts)
- Build and test in Xcode (each worktree has its own derived data)
- Commit and push changes from the worktree
- Create a PR from the feature branch when ready

## Cleaning Up

When done with a worktree:
- Use `/cleanup-worktree` command (or `./Scripts/worktree.sh remove <branch-name>`)
- This removes the worktree directory and deletes the local branch
- Safe to do after PR is merged

## Important Notes

- Main worktree stays on `main` branch - keep it clean!
- Each worktree is a full project copy on a different branch
- Worktrees are stored in `.worktrees/` directory (gitignored)
- You can have multiple worktrees active simultaneously
- Each worktree can run its own Firebase emulator instance
- Xcode projects in different worktrees won't conflict

## Example Usage Flow

```
User: /new-worktree
Claude: What would you like to name the feature branch?
User: login-improvements
Claude: What would you like to work on? (optional, press enter to skip)
User: Add better error messages for failed login attempts
Claude: [Creates worktree and launches iTerm2]
        ✓ Worktree created at .worktrees/feature-login-improvements
        ✓ iTerm2 launched with Claude Code ready to help
```
