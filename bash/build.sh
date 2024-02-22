#!/bin/bash

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <branch_B> [build_directory]"
    exit 1
fi

# Name of branch B from the first script argument
BRANCH_B="$1"

# Use the second argument as the build directory if provided, otherwise default to "build"
BUILD_DIR="${2:-build}"

# Determine the current branch as branch A
BRANCH_A=$(git rev-parse --abbrev-ref HEAD)

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Fetch the latest changes for the current and target branches (optional, but recommended)
git fetch origin $BRANCH_A
git fetch origin $BRANCH_B

# Get the list of modified and added files from branch B compared to the current branch
FILES=$(git diff --name-status $BRANCH_A..$BRANCH_B | awk '$1 != "D" { print $2 }')

# Copy changed files to the build directory
for FILE in $FILES; do
    # Create directory structure in the build directory
    mkdir -p "$BUILD_DIR/$(dirname "$FILE")"

    # Copy the file content from branch B to the corresponding path in the build directory
    git show $BRANCH_B:"$FILE" > "$BUILD_DIR/$FILE"
done

echo "Files from branch $BRANCH_B have been copied to the $BUILD_DIR directory."
