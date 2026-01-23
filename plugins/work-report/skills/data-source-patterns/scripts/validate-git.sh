#!/bin/bash
# Validate Git repository for work-report data collection

set -e

path="${1:-.}"

echo "Validating Git repository: $path"
echo "================================"

# Check if directory exists
if [ ! -d "$path" ]; then
    echo "✗ Directory does not exist: $path"
    exit 1
fi

# Check if it's a git repository
if [ ! -d "$path/.git" ]; then
    echo "✗ Not a Git repository (no .git directory)"
    exit 1
fi

echo "✓ Valid Git repository"

# Change to the repository
cd "$path"

# Get repository info
echo ""
echo "Repository Info:"
echo "----------------"
echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'No remote')"
echo "Branch: $(git branch --show-current)"
echo "Author: $(git config user.email)"

# Recent commits
echo ""
echo "Recent Commits (last 5):"
echo "------------------------"
git log --oneline -5

# Check for commits today
echo ""
echo "Today's Commits:"
echo "----------------"
today_commits=$(git log --since="midnight" --format="%h %s" --author="$(git config user.email)" 2>/dev/null | wc -l)
if [ "$today_commits" -eq 0 ]; then
    echo "No commits today"
else
    git log --since="midnight" --format="%h %s" --author="$(git config user.email)"
fi

echo ""
echo "✓ Validation complete"
