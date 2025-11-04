#!/bin/bash
set -euo pipefail

# Set default options
BUILD_TYPE="Release"
BUILD_DIR="build"
INSTALL_DIR="$(pwd)/install"
REGRESSION_TESTS="OFF"
BUILD_SHARED_LIBS="ON"

SYSTEMC_CI_DEFAULT_TARGET="systemc"
SYSTEMC_CI_REGRESSION_TARGET="check-tests"
SYSTEMC_CI_TARGET=${SYSTEMC_CI_DEFAULT_TARGET}

for arg in "$@"; do
    if [[ "$arg" == "--run-regression" ]]; then
        REGRESSION_TESTS="ON"
        SYSTEMC_CI_TARGET=${SYSTEMC_CI_REGRESSION_TARGET}
    fi
done

# Generate the project
cmake -B ${BUILD_DIR} \
      -D ENABLE_REGRESSION=${REGRESSION_TESTS} \
      -D BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS} \
      -D CMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -D CMAKE_INSTALL_PREFIX="${INSTALL_DIR}"

# Build the project
cmake --build ${BUILD_DIR} --config ${BUILD_TYPE} --parallel --target ${SYSTEMC_CI_TARGET}

# Skip installation for regressions runs
if [ "${REGRESSION_TESTS}" == "OFF" ]; then
    cmake --install ${BUILD_DIR}
fi

exit 0
