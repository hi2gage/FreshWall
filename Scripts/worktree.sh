#!/bin/bash

# Git Worktree Management Script for FreshWall
# Helps manage multiple feature branches simultaneously using git worktrees

set -e

WORKTREE_DIR=".worktrees"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_usage() {
    echo "Git Worktree Management for FreshWall"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <branch-name> [prompt]  Create a new worktree for a feature branch"
    echo "                                  Optional: provide a prompt for Claude Code"
    echo "  list                            List all active worktrees"
    echo "  remove <branch-name>            Remove a worktree"
    echo "  cleanup                         Remove all worktrees and clean up git references"
    echo "  open <branch-name>              Open worktree in Xcode"
    echo ""
    echo "Examples:"
    echo "  $0 create feature/new-dashboard"
    echo "  $0 create feature/new-dashboard 'Implement user dashboard with charts'"
    echo "  $0 list"
    echo "  $0 remove feature/new-dashboard"
    echo "  $0 open feature/new-dashboard"
    echo ""
}

function ensure_worktree_dir() {
    if [ ! -d "$PROJECT_ROOT/$WORKTREE_DIR" ]; then
        echo -e "${BLUE}Creating worktree directory: $WORKTREE_DIR${NC}"
        mkdir -p "$PROJECT_ROOT/$WORKTREE_DIR"
    fi
}

function launch_iterm_with_claude() {
    local worktree_path=$1
    local prompt=$2

    # AppleScript to create new iTerm2 window with two tabs
    osascript <<EOF
tell application "iTerm2"
    -- Create a new window
    create window with default profile

    tell current session of current window
        -- First tab: navigate to worktree directory
        write text "cd \"$worktree_path\""
        write text "echo 'Working in worktree: $worktree_path'"
        write text "git branch --show-current"
    end tell

    -- Create second tab for Claude Code
    tell current window
        create tab with default profile
    end tell

    tell current session of current window
        -- Second tab: run Claude Code with the prompt
        write text "cd \"$worktree_path\""
        if "$prompt" is not "" then
            write text "claude --dangerously-skip-permissions \"$prompt\""
        else
            write text "# Ready for Claude Code"
            write text "# Run: claude --dangerously-skip-permissions \"<your prompt>\""
        end if
    end tell

    -- Switch back to first tab
    tell current window
        select first session
    end tell

    activate
end tell
EOF
}

function create_worktree() {
    local branch_name=$1
    local claude_prompt="${@:2}"  # All remaining arguments as the prompt

    if [ -z "$branch_name" ]; then
        echo -e "${RED}Error: Branch name is required${NC}"
        print_usage
        exit 1
    fi

    # Sanitize branch name for directory (replace / with -)
    local dir_name=$(echo "$branch_name" | sed 's/\//-/g')
    local worktree_path="$PROJECT_ROOT/$WORKTREE_DIR/$dir_name"

    ensure_worktree_dir

    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        echo -e "${RED}Error: Worktree already exists at $worktree_path${NC}"
        exit 1
    fi

    echo -e "${BLUE}Creating worktree for branch: $branch_name${NC}"

    # Check if branch exists remotely
    if git show-ref --verify --quiet refs/remotes/origin/$branch_name; then
        echo -e "${YELLOW}Branch exists remotely, checking out...${NC}"
        git worktree add "$worktree_path" "$branch_name"
    else
        echo -e "${YELLOW}Creating new branch from main...${NC}"
        git worktree add -b "$branch_name" "$worktree_path" main
    fi

    echo -e "${GREEN}✓ Worktree created at: $worktree_path${NC}"
    echo ""

    # Launch iTerm2 with the worktree
    echo -e "${BLUE}Launching iTerm2 with worktree...${NC}"
    launch_iterm_with_claude "$worktree_path" "$claude_prompt"

    echo ""
    echo -e "${GREEN}✓ iTerm2 window opened${NC}"
    echo -e "${BLUE}Tab 1:${NC} Worktree directory"
    if [ -n "$claude_prompt" ]; then
        echo -e "${BLUE}Tab 2:${NC} Claude Code running with prompt: \"$claude_prompt\""
    else
        echo -e "${BLUE}Tab 2:${NC} Ready for Claude Code"
    fi
}

function list_worktrees() {
    echo -e "${BLUE}Active worktrees:${NC}"
    echo ""
    git worktree list
    echo ""

    if [ -d "$PROJECT_ROOT/$WORKTREE_DIR" ]; then
        local count=$(find "$PROJECT_ROOT/$WORKTREE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}Total feature worktrees: $count${NC}"
    fi
}

function remove_worktree() {
    local branch_name=$1

    if [ -z "$branch_name" ]; then
        echo -e "${RED}Error: Branch name is required${NC}"
        print_usage
        exit 1
    fi

    local dir_name=$(echo "$branch_name" | sed 's/\//-/g')
    local worktree_path="$PROJECT_ROOT/$WORKTREE_DIR/$dir_name"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}Error: Worktree not found at $worktree_path${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Removing worktree: $branch_name${NC}"
    git worktree remove "$worktree_path"
    echo -e "${GREEN}✓ Worktree removed${NC}"

    # Ask if user wants to delete the branch
    echo ""
    read -p "Do you want to delete the branch '$branch_name'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -d "$branch_name" 2>/dev/null || git branch -D "$branch_name"
        echo -e "${GREEN}✓ Branch deleted locally${NC}"
    fi
}

function cleanup_all() {
    echo -e "${YELLOW}Warning: This will remove ALL worktrees in $WORKTREE_DIR${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi

    if [ -d "$PROJECT_ROOT/$WORKTREE_DIR" ]; then
        for worktree in "$PROJECT_ROOT/$WORKTREE_DIR"/*; do
            if [ -d "$worktree" ]; then
                echo -e "${BLUE}Removing: $(basename $worktree)${NC}"
                git worktree remove "$worktree" --force
            fi
        done
    fi

    # Prune any stale worktree references
    git worktree prune

    echo -e "${GREEN}✓ All worktrees cleaned up${NC}"
}

function open_worktree() {
    local branch_name=$1

    if [ -z "$branch_name" ]; then
        echo -e "${RED}Error: Branch name is required${NC}"
        print_usage
        exit 1
    fi

    local dir_name=$(echo "$branch_name" | sed 's/\//-/g')
    local worktree_path="$PROJECT_ROOT/$WORKTREE_DIR/$dir_name"

    if [ ! -d "$worktree_path" ]; then
        echo -e "${RED}Error: Worktree not found at $worktree_path${NC}"
        exit 1
    fi

    local xcode_project="$worktree_path/App/FreshWall/FreshWall.xcodeproj"

    if [ ! -d "$xcode_project" ]; then
        echo -e "${RED}Error: Xcode project not found at $xcode_project${NC}"
        exit 1
    fi

    echo -e "${BLUE}Opening Xcode project...${NC}"
    open "$xcode_project"
}

# Main command router
case "${1:-}" in
    create)
        shift  # Remove 'create' from arguments
        create_worktree "$@"  # Pass all remaining arguments
        ;;
    list)
        list_worktrees
        ;;
    remove)
        remove_worktree "$2"
        ;;
    cleanup)
        cleanup_all
        ;;
    open)
        open_worktree "$2"
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
