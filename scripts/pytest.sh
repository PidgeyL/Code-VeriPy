cd /usr/src/app
VERSION=$(printf "%-4s" "$PYTHON_VERSION")

# Define colors
NC="\033[0m"
RED='\033[0;31m'
GREEN='\033[0;32m'

# Installing dependencies
pip install --quiet --root-user-action=ignore --upgrade pip
pip install --quiet --root-user-action=ignore pytest flake8

# Install project, if able
pip install --quiet --root-user-action=ignore . >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "$RED[!]$NC Could not install '${PYTEST_PROJECT_FOLDER}'. Is it a valid python module?"
    echo "Exiting..."
    exit 1
fi


# Pytest tests
output=$(pytest -q)
if [ $? -ne 0 ]; then
    echo "$RED[!]$NC $VERSION pytest failed!"
    echo "${output}"
    exit 1
else
    echo "$GREEN[v]$NC $VERSION pytest successful"
fi
