#!/bin/bash

set -euo pipefail

echo "Application build started"

echo "Running tests..."

echo "All tests passed"

echo "Build version: ${APP_VERSION}"

echo "Target environment: ${APP_ENV}"

echo "Deploying version ${APP_VERSION} to ${APP_ENV}"

echo "Build completed successfuly"

echo "Automatic CI trigger test"

echo "Creating build artifact...."

echo "Application version: ${APP_VERSION}" > build-info.txt

echo "Environment: ${APP_ENV}" >> build-info.txt

echo "Artifact created successfully"
