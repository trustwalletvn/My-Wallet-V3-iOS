#  scripts/remove-nested-frameworks.sh
#
#  xcodebuild will copy Swift Package Manager dynamic frameworks into the TodayExtension.appex bundle, which results in the build not being
#  able to be submitted to TestFlight. This script removes all nested bundles as they are unsupported.
#
#  See: https://forums.swift.org/t/swift-packages-in-multiple-targets-results-in-this-will-result-in-duplication-of-library-code-errors/34892
# 

rm -rf "${CODESIGNING_FOLDER_PATH}/PlugIns/TodayExtension.appex/Frameworks"