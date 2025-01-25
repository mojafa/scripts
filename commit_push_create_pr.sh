#!/bin/bash

# Check if arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_file> <output_file>"
  exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$HOME/Downloads/my_pr_links/$2"

# Create the folder if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Clear or create the output file
> "$OUTPUT_FILE"

# Loop through each line in the input file
while IFS= read -r line; do
  echo "Processing $line ..."
  
  # Extract the repo name and URL
  repo_url=$(echo "$line" | sed 's|https://github.com/\([^/]*\)/\([^/]*\)/.*|\1/\2|')
  repo_name=$(echo "$repo_url" | cut -d'/' -f2)
  repo_dir=$(echo "$repo_url" | cut -d'/' -f1)
  
  # Clone the repository if it doesn't already exist
  if [ ! -d "$repo_name" ]; then
    git clone "https://github.com/$repo_url.git"
  fi

  # Navigate to the repository directory
  cd "$repo_name" || exit
  
  # Check for changes and commit
  git add .
  git commit -sm "added open with codeanywhere badge to README file"

  # Push to branch
  git push -u origin update-readme-codeanywhere

  # Create the PR
  pr_url=$(gh pr create --title "Add 'Open with Codeanywhere' badge to README.md" --body "With Codeanywhere, developers and contributors can instantly launch a cloud or local IDE with a pre-configured remote development environment. One can work in the cloud or locally, and it ensures all contributors have access to the same, ready-to-use dev env." )
   
  # Append the PR link to the output file
  if [ -n "$pr_url" ]; then
    echo "$pr_url" | tee -a "$OUTPUT_FILE" > /dev/null
    echo "PR created: $pr_url"
  else
    echo "Failed to create PR for $repo_name."
  fi
  echo "====================================================="
  cd ..  # Go back to the root directory
done < "$INPUT_FILE"

echo "All PR links saved to $OUTPUT_FILE."
