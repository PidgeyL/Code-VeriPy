cd /usr/src/app
# Define colors
NC="\033[0m"
RED='\033[0;31m'
GREEN='\033[0;32m'

# Installing dependencies
pip install --quiet --root-user-action=ignore --upgrade pip
pip install --quiet --root-user-action=ignore flake8 flake8-annotations flake8-docstrings

# Install project, if able
pip install --quiet --root-user-action=ignore . >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "$RED[!]$NC Could not install '${PYTEST_PROJECT_FOLDER}'. Is it a valid python module?"
    echo "Exiting..."
    exit 1
fi

# Flake8 tests
output=$(flake8)
if [ $? -ne 0 ]; then
    echo "$RED[!]$NC flake8 reported issues:"
    echo "${output}"
else
    echo "$GREEN[v]$NC flake8 successful"
fi
