#!/bin/bash

#
# Copyright (c) 2020, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.
#

## Usage
# bash update-version.sh <type>
#     where <type> is either `major`, `minor`, `patch`

set -e

# Grab argument for release type
RELEASE_TYPE=$1

# Get current version and calculate next versions
CURRENT_TAG=$(git tag | grep -xE 'v[0-9\.]+' | sort --version-sort | tail -n 1 | tr -d 'v')
CURRENT_MAJOR=$(echo "$CURRENT_TAG" | awk '{split($0, a, "."); print a[1]}')
CURRENT_MINOR=$(echo "$CURRENT_TAG" | awk '{split($0, a, "."); print a[2]}')
CURRENT_PATCH=$(echo "$CURRENT_TAG" | awk '{split($0, a, "."); print a[3]}')
CURRENT_SHORT_TAG=${CURRENT_MAJOR}.${CURRENT_MINOR}
NEXT_MAJOR=$((CURRENT_MAJOR + 1))
NEXT_MINOR=$((CURRENT_MINOR + 1))
NEXT_PATCH=$((CURRENT_PATCH + 1))
NEXT_FULL_TAG=""
NEXT_SHORT_TAG=""

# Determine release type
if [ "$RELEASE_TYPE" == "major" ]; then
  NEXT_FULL_TAG="${NEXT_MAJOR}.0.0"
  NEXT_SHORT_TAG="${NEXT_MAJOR}.0"
elif [ "$RELEASE_TYPE" == "minor" ]; then
  NEXT_FULL_TAG="${CURRENT_MAJOR}.${NEXT_MINOR}.0"
  NEXT_SHORT_TAG="${CURRENT_MAJOR}.${NEXT_MINOR}"
elif [ "$RELEASE_TYPE" == "patch" ]; then
  NEXT_FULL_TAG="${CURRENT_MAJOR}.${CURRENT_MINOR}.${NEXT_PATCH}"
  NEXT_SHORT_TAG="${CURRENT_MAJOR}.${CURRENT_MINOR}"
else
  echo "Incorrect release type; use 'major', 'minor', or 'patch' as an argument"
  exit 1
fi

echo "Preparing '$RELEASE_TYPE' release [$CURRENT_TAG -> $NEXT_FULL_TAG]"

python3 ci/release/update_configuration.py --configuration_file './setup.cfg' --fields "{\"metadata\":{\"version\":\"${NEXT_FULL_TAG}\"}}"
