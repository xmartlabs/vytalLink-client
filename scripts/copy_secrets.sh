#!/bin/bash
# Script to copy sensitive files to their correct locations

# Required files
REQUIRED_FILES=(
  "env_secrets/google-services.json"
  "env_secrets/GoogleService-Info.dev.plist"
  "env_secrets/GoogleService-Info.prod.plist"
)

# Check if all required files exist
for FILE in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    echo "Error: Missing required file $FILE. Secrets must be placed in the 'env_secrets' folder at the root of the project. Please contact the repository admin to obtain it."
    exit 1
  fi
done

# ANDROID
cp env_secrets/google-services.json android/app/google-services.json

# IOS
cp env_secrets/GoogleService-Info.dev.plist ios/Runner/Dev/GoogleService-Info.plist
cp env_secrets/GoogleService-Info.prod.plist ios/Runner/GoogleService-Info.plist

echo "Secrets copied successfully."
