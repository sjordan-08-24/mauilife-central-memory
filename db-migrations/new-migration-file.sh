#!/bin/bash

# Creates a migration script file with the required naming convention.
# Example V2025.02.21.1245__my_migration_script.yml

# The first portion, prior to the double underscore is in a format that:
# - Flyway accepts
# - Creates a clean order of applying
# - Is easily understood

# It must be unique to all migrations. UTC date and time is used to help this.

# V - Required by Flyway to denote a 'Versioned Migration'
# 2025 - The current year
# 02 - The current month
# 21 - The current day
# 1245 - The current time
# __ - The double underscore is required by Flyway to separate the version from the description

# The second portion, after the double underscore is a description. It must be alpha/numerics and can include spaces.

# Usage: ./create_migration.sh "my migration script"

set -e  # Exit on error

DIRECTORY="./migrations"  # Change this if needed

# Validate input arguments
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <DESCRIPTION>"
  exit 1
fi

DATE=$(date -u +"%Y.%m.%d")
TIME=$(date -u +"%H%M%S")

DESCRIPTION="$1"

# Validate description format (allow only letters, numbers, spaces, underscores and periods - no double underscores)
if [[ ! "$DESCRIPTION" =~ ^[a-zA-Z0-9\ \._]+$ ]]; then
  echo "Error: Description must be letters, numbers, spaces, underscores and periods - no double underscores"
  exit 1
fi

# Convert everything to lowercase
DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')  # Replace spaces with underscores

# Construct filename
FILENAME="V${DATE}.${TIME}__${DESCRIPTION}.sql"
FILEPATH="${DIRECTORY}/${FILENAME}"

# Ensure directory exists
mkdir -p "$DIRECTORY"

# Create the file
touch "$FILEPATH"

echo "Move your script to the appropriate folder" >&2
echo "within ./migrations as necessary." >&2

echo "Created migration file:" >&2

echo $FILEPATH