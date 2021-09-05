#  scripts/fix-snapshot-host-app.sh
#
#  By default the snapshot test host does not copy any bundle products because of the current usage of Swift Package Manager and SharedPackagesKit
#  This script is run as a postCompileScript phase to ensure the module bundles are copied in and can be located by the Swift Package Manager generated bundle finder code.
# 

rsync -avP --include="*.bundle" --exclude="*" "${BUILT_PRODUCTS_DIR}/" "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"