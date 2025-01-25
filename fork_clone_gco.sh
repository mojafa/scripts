#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# USAGE:
#   1) Make the script executable:
#        chmod +x fork_and_clone.sh
#
#   2) Create a text file (e.g. repos.txt) with one GitHub link per line.
#      Example lines:
#         https://github.com/owner/repo
#         https://github.com/owner/repo/blob/commit/dir/file
#
#   3) Run:
#        ./fork_and_clone.sh repos.txt

# Check if a file was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file_with_links>"
  exit 1
fi

INPUT_FILE="$1"

# Associative array to track processed repos (requires Bash 4+)
declare -A processed_repos

# Loop over each line in the file
while IFS= read -r link; do
  # Skip empty lines
  [[ -z "$link" ]] && continue

  # A regex to capture: github.com/OWNER/REPO
  regex='github\.com/([^/]+)/([^/]+)'
  if [[ $link =~ $regex ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"

    # Sometimes the repo might contain .git or extra
    repo="${repo%.git}"

    # Skip if this repository was already processed
    if [[ -n "${processed_repos["$owner/$repo"]}" ]]; then
      echo "Skipping already processed repository: $owner/$repo"
      continue
    fi

    echo "Forking $owner/$repo ..."

    # Check if the directory already exists
    if [ -d "$repo" ]; then
      echo "Directory '$repo' already exists, skipping fork and clone."
    else
      # Use GH CLI to fork and clone
      gh repo fork "$owner/$repo" --clone --remote
      sleep 6  # Wait for 2 seconds before the next request
    fi

    # The fork is cloned into a folder named "$repo" (by default).
    # If there's a collision, GH CLI might create "$repo-1", "$repo-2", etc.
    # We'll assume no name collisions for simplicity.
    if [ -d "$repo" ]; then
      echo "Switching to new branch 'update-readme-codeanywhere' in '$repo'..."

      cd "$repo"

      # Check if the branch already exists
      if git show-ref --verify --quiet "refs/heads/update-readme-codeanywhere"; then
        echo "Branch 'update-readme-codeanywhere' already exists, checking it out..."
        git checkout update-readme-codeanywhere
      else
        echo "Creating new branch 'update-readme-codeanywhere'..."
        git checkout -b update-readme-codeanywhere
      fi

      cd ..
    else
      echo "Warning: Directory '$repo' not found. Skipping branch checkout."
    fi

    echo ""
    echo "====================================================="
    echo "Forked and cloned: $owner/$repo"
    echo "====================================================="
    echo ""

    # Mark this repository as processed
    processed_repos["$owner/$repo"]=1
  else
    echo "Skipping line (not a recognized GitHub link): $link"
  fi
done < "$INPUT_FILE"
