#!/bin/bash

# Function to remove ANSI escape codes
function remove_ansi_codes() {
  echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# Function to extract essential output from Terraform plan
function extract_essential_output() {
  cat "$1" | sed -n '/Terraform used the selected providers/,/Terraform plan return code:/p'
}

# Function to escape special characters in a string
function escape_special_characters() {
  echo "$1" | sed 's/`/\\`/g; s/#/\\#/g'
}

# Function to comment on the PR using GitHub CLI
function comment_on_pr() {
  local body="$1"
  echo -e "$body" | gh pr comment "$pr_url" --body-file -
}

# Error handling for missing output file
if [[ ! -f "$output_file" ]]; then
  echo "Output file not found!"
  exit 1
fi

# Capture the Terraform plan output into a variable
plan_output=$(cat "$output_file")

# Extract the essential part of the output and remove ANSI codes
essential_output=$(extract_essential_output "$output_file")
clean_essential_output=$(remove_ansi_codes "$essential_output")

# Comment on PR
if [[ -z $clean_essential_output ]]; then
  comment_on_pr "Terraform essential output is empty. Please check the plan output."
else
  comment_body=$(printf "## Terraform Plan Essential Output\n\`\`\`\n%s\n\`\`\`\n" "$clean_essential_output")
  comment_on_pr "$comment_body"
fi
