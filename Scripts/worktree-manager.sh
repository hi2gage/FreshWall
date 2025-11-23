#!/bin/bash

# Interactive Git Worktree Manager for FreshWall
# Provides a dashboard view and interactive management of all worktrees

set -e

WORKTREE_DIR=".worktrees"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

function print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║          Git Worktree Manager - FreshWall                 ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

function get_worktree_status() {
    local worktree_path=$1
    local status=""

    cd "$worktree_path" 2>/dev/null || return

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        status="${status}${YELLOW}●${NC} "  # Modified
    fi

    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        status="${status}${RED}+${NC} "  # Untracked
    fi

    # Check for staged changes
    if ! git diff-index --cached --quiet HEAD -- 2>/dev/null; then
        status="${status}${GREEN}✓${NC} "  # Staged
    fi

    # Check if ahead/behind remote
    local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -n "$upstream" ]; then
        local ahead=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
        local behind=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")

        if [ "$ahead" -gt 0 ]; then
            status="${status}${CYAN}↓${ahead}${NC} "
        fi
        if [ "$behind" -gt 0 ]; then
            status="${status}${MAGENTA}↑${behind}${NC} "
        fi
    fi

    if [ -z "$status" ]; then
        status="${GREEN}✓ Clean${NC}"
    fi

    echo -e "$status"
}

function get_last_commit_info() {
    local worktree_path=$1
    cd "$worktree_path" 2>/dev/null || return

    local last_commit=$(git log -1 --pretty=format:"%h - %s" 2>/dev/null || echo "No commits")
    local commit_time=$(git log -1 --pretty=format:"%ar" 2>/dev/null || echo "")

    if [ -n "$commit_time" ]; then
        echo "$last_commit (${commit_time})"
    else
        echo "$last_commit"
    fi
}

function display_dashboard() {
    print_header

    # Get main worktree info
    local main_branch=$(cd "$PROJECT_ROOT" && git branch --show-current)
    echo -e "${BOLD}Main Worktree:${NC}"
    echo -e "  ${BLUE}Branch:${NC} $main_branch"
    echo -e "  ${BLUE}Path:${NC} $PROJECT_ROOT"
    local main_status=$(get_worktree_status "$PROJECT_ROOT")
    echo -e "  ${BLUE}Status:${NC} $main_status"
    echo ""

    # List all feature worktrees
    if [ ! -d "$PROJECT_ROOT/$WORKTREE_DIR" ]; then
        echo -e "${YELLOW}No feature worktrees found${NC}"
        echo ""
        return
    fi

    local worktree_count=0
    local worktrees=()

    # Collect worktree info
    for worktree in "$PROJECT_ROOT/$WORKTREE_DIR"/*; do
        if [ -d "$worktree" ]; then
            worktrees+=("$worktree")
            ((worktree_count++))
        fi
    done

    if [ $worktree_count -eq 0 ]; then
        echo -e "${YELLOW}No feature worktrees found${NC}"
        echo ""
        return
    fi

    echo -e "${BOLD}Feature Worktrees (${worktree_count}):${NC}"
    echo ""

    local index=1
    for worktree in "${worktrees[@]}"; do
        local dir_name=$(basename "$worktree")
        local branch_name=$(cd "$worktree" && git branch --show-current 2>/dev/null || echo "unknown")
        local status=$(get_worktree_status "$worktree")
        local last_commit=$(get_last_commit_info "$worktree")

        echo -e "${BOLD}${index}.${NC} ${CYAN}${branch_name}${NC}"
        echo -e "   ${BLUE}Path:${NC} $worktree"
        echo -e "   ${BLUE}Status:${NC} $status"
        echo -e "   ${BLUE}Last:${NC} ${last_commit}"
        echo ""

        ((index++))
    done

    # Legend
    echo -e "${BOLD}Legend:${NC}"
    echo -e "  ${YELLOW}●${NC} Modified   ${RED}+${NC} Untracked   ${GREEN}✓${NC} Staged"
    echo -e "  ${CYAN}↓${NC} Behind     ${MAGENTA}↑${NC} Ahead"
    echo ""
}

function interactive_menu() {
    while true; do
        display_dashboard

        echo -e "${BOLD}Actions:${NC}"
        echo "  1) Open worktree in iTerm"
        echo "  2) Open worktree in Xcode"
        echo "  3) Show git status for a worktree"
        echo "  4) Remove a worktree"
        echo "  5) Refresh dashboard"
        echo "  6) Create new worktree"
        echo "  7) Cleanup all worktrees"
        echo "  q) Quit"
        echo ""

        read -p "Select action: " action

        case $action in
            1)
                open_in_iterm
                ;;
            2)
                open_in_xcode
                ;;
            3)
                show_git_status
                ;;
            4)
                remove_worktree_interactive
                ;;
            5)
                clear
                continue
                ;;
            6)
                create_new_worktree
                ;;
            7)
                cleanup_all_worktrees
                ;;
            q|Q)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                clear
                ;;
        esac
    done
}

function select_worktree() {
    local worktrees=()

    for worktree in "$PROJECT_ROOT/$WORKTREE_DIR"/*; do
        if [ -d "$worktree" ]; then
            worktrees+=("$worktree")
        fi
    done

    if [ ${#worktrees[@]} -eq 0 ]; then
        echo -e "${RED}No worktrees available${NC}"
        sleep 2
        clear
        return 1
    fi

    echo ""
    echo -e "${BOLD}Select a worktree:${NC}"
    local index=1
    for worktree in "${worktrees[@]}"; do
        local branch_name=$(cd "$worktree" && git branch --show-current 2>/dev/null || echo "unknown")
        echo "  ${index}) ${branch_name}"
        ((index++))
    done
    echo ""

    read -p "Enter number: " selection

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#worktrees[@]} ]; then
        echo -e "${RED}Invalid selection${NC}"
        sleep 2
        clear
        return 1
    fi

    selected_worktree="${worktrees[$((selection-1))]}"
    return 0
}

function open_in_iterm() {
    if ! select_worktree; then
        return
    fi

    local branch_name=$(cd "$selected_worktree" && git branch --show-current)

    echo -e "${BLUE}Opening $branch_name in iTerm...${NC}"

    osascript <<EOF
tell application "iTerm2"
    create window with default profile
    tell current session of current window
        write text "cd \"$selected_worktree\""
        write text "git status"
    end tell
    activate
end tell
EOF

    sleep 1
    clear
}

function open_in_xcode() {
    if ! select_worktree; then
        return
    fi

    local xcode_project="$selected_worktree/App/FreshWall/FreshWall.xcodeproj"

    if [ ! -d "$xcode_project" ]; then
        echo -e "${RED}Xcode project not found${NC}"
        sleep 2
        clear
        return
    fi

    local branch_name=$(cd "$selected_worktree" && git branch --show-current)
    echo -e "${BLUE}Opening $branch_name in Xcode...${NC}"

    open "$xcode_project"
    sleep 1
    clear
}

function show_git_status() {
    if ! select_worktree; then
        return
    fi

    local branch_name=$(cd "$selected_worktree" && git branch --show-current)

    echo ""
    echo -e "${BOLD}${CYAN}Git Status for: $branch_name${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo ""

    cd "$selected_worktree"
    git status

    echo ""
    read -p "Press enter to continue..."
    clear
}

function remove_worktree_interactive() {
    if ! select_worktree; then
        return
    fi

    local branch_name=$(cd "$selected_worktree" && git branch --show-current)

    echo ""
    echo -e "${YELLOW}WARNING: This will remove the worktree for: $branch_name${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled${NC}"
        sleep 1
        clear
        return
    fi

    echo -e "${BLUE}Removing worktree...${NC}"
    git worktree remove "$selected_worktree"

    echo ""
    read -p "Delete branch '$branch_name' too? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$PROJECT_ROOT"
        git branch -d "$branch_name" 2>/dev/null || git branch -D "$branch_name"
        echo -e "${GREEN}Branch deleted${NC}"
    fi

    echo -e "${GREEN}✓ Worktree removed${NC}"
    sleep 2
    clear
}

function create_new_worktree() {
    echo ""
    read -p "Enter branch name (e.g., feature/new-feature): " branch_name

    if [ -z "$branch_name" ]; then
        echo -e "${RED}Branch name required${NC}"
        sleep 2
        clear
        return
    fi

    echo ""
    read -p "Enter Claude Code prompt (optional): " prompt

    clear
    echo -e "${BLUE}Creating worktree...${NC}"

    cd "$PROJECT_ROOT"
    if [ -n "$prompt" ]; then
        ./Scripts/worktree.sh create "$branch_name" "$prompt"
    else
        ./Scripts/worktree.sh create "$branch_name"
    fi

    echo ""
    read -p "Press enter to continue..."
    clear
}

function cleanup_all_worktrees() {
    echo ""
    echo -e "${RED}${BOLD}WARNING: This will remove ALL feature worktrees!${NC}"
    read -p "Are you absolutely sure? (yes/N): " confirm

    if [ "$confirm" != "yes" ]; then
        echo -e "${BLUE}Cancelled${NC}"
        sleep 1
        clear
        return
    fi

    echo -e "${BLUE}Cleaning up all worktrees...${NC}"

    cd "$PROJECT_ROOT"
    ./Scripts/worktree.sh cleanup

    echo ""
    read -p "Press enter to continue..."
    clear
}

# Main entry point
if [ "${1:-}" == "--dashboard" ] || [ "${1:-}" == "-d" ]; then
    display_dashboard
else
    clear
    interactive_menu
fi
