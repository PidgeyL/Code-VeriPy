#!/bin/bash

#####
# Check if a path was provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/module/to/test"
    exit 1
fi

#####
# Check if docker exec rights are avaialble
docker ps > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    echo "Cannot execute docker commands as $USER. Retrying with sudo..."
    sudo "$0" "$@"
    exit 0
fi

#####
# Colors
NC="\033[0m"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

#####
# Variables
PYTEST_PROJECT_FOLDER="$1"
CODE="${PYTEST_PROJECT_FOLDER}"

source ./CONFIG

#####
# Flake 8 test code
if [ "$TEST_FLAKE8" = true ]; then
    echo  "#################### Flake 8 test ####################"
    echo -ne "${YELLOW}[ ]${NC} ${VERSION} flake8 running...\r"
    docker run -w /usr/src/tools -v "${CODE}:/usr/src/app" \
               -v ./scripts/flake.sh:/usr/src/tools/flake.sh \
               -e PYTHON_VERSION=3.12 \
               -e PYTEST_PROJECT_FOLDER="${PYTEST_PROJECT_FOLDER}" \
                python:3."${TEST_PY3_UPPER}" sh -c "chmod +x flake.sh && ./flake.sh "
fi

#####
# pytest code
if [ "$TEST_PYTEST" = true ]; then
    echo "####################    Pytest    ####################"
    for ((i=TEST_PY3_UPPER; i>=TEST_PY3_LOWER; i--)); do
        VERSION=$(printf "%-4s" "3.${i}")
        echo -ne "${YELLOW}[ ]${NC} ${VERSION} pytest running...\r"
        docker run -w /usr/src/tools -v "${CODE}:/usr/src/app" \
                   -v ./scripts/pytest.sh:/usr/src/tools/pytest.sh \
                   -e PYTHON_VERSION="3.${i}" \
                   -e PYTEST_PROJECT_FOLDER="${PYTEST_PROJECT_FOLDER}" \
                    python:3."$i" sh -c "chmod +x pytest.sh && ./pytest.sh "
        if [ $? -ne 0 ]; then
            exit 1
        fi
    done
fi
