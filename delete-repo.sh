#!/bin/bash

# Ensure the GitHub CLI is authenticated
if ! gh auth status &>/dev/null; then
  echo "Please authenticate with the GitHub CLI using 'gh auth login'."
  exit 1
fi

# Set the cutoff date (January 15th)
CUTOFF_DATE="2025-01-15T00:00:00Z"

# Fetch all repositories for the authenticated user
echo "Fetching repositories..."
repos=$(gh repo list --json name,createdAt,isFork --limit 1000)

# Dry-run flag
DRY_RUN=false

if [[ $1 == "--dry-run" ]]; then
  DRY_RUN=true
  echo "Dry-run mode: No repositories will be deleted."
fi

# Process repositories created since January 15th
echo "Processing repositories created after $CUTOFF_DATE..."
echo "$repos" | jq -c '.[] | select(.createdAt > "'$CUTOFF_DATE'")' | while read -r repo; do
  name=$(echo "$repo" | jq -r '.name')
  is_fork=$(echo "$repo" | jq -r '.isFork')

  echo "Repository: $name (Fork: $is_fork)"
  
  # Dry-run mode: Only list repositories
  if [[ "$DRY_RUN" == true ]]; then
    echo "Dry-run: Would delete $name."
    continue
  fi

  # Automatically delete repositories
  echo "Deleting $name..."
  gh repo delete "$name" --confirm
  if [[ $? -eq 0 ]]; then
    echo "$name deleted."
  else
    echo "Failed to delete $name."
  fi
done

echo "Done!"
