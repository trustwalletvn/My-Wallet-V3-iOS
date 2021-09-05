#!/bin/sh
set -e

LIB_NAME="AnalyticsKit"

# Pipe project json to file.
echo "\n"
echo "Generating project '${LIB_NAME}' description."
swift package describe --type json >project-desc.json

echo "\n"
echo "Replace 'target_dependencies' -> 'dependencies."
sed -i '' 's/target_dependencies/dependencies/g' "project-desc.json"

echo "\n"
echo "Generating project '${LIB_NAME}' mocks."
mockingbird generate \
  --target "${LIB_NAME}" \
  --testbundle "${LIB_NAME}Tests" \
  --project project-desc.json \
  --disable-swiftlint

mv "MockingbirdMocks/${LIB_NAME}Mocks.generated.swift" "Tests/${LIB_NAME}Tests"
