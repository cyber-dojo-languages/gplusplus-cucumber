#!/bin/bash -Eeu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep --quiet '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep --quiet --fixed-strings "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

apt-get update && apt-get upgrade --yes

apt-get install --no-install-recommends \
          cmake \
          g++ \
          gcovr \
          git \
          libasio-dev \
          libboost-test-dev \
          libgl1-mesa-dev \
          libtclap-dev \
          ninja-build \
          nlohmann-json3-dev \
          qt6-base-dev \
          ruby \
          ruby-dev \
          --yes

# Install the newest cucumber-cpp release. It publishes tags but no GitHub
# releases, so the highest v<version> tag is resolved here at build time,
# and a rebuild picks up the next release by itself.
readonly CUCUMBER_TAG=$(git ls-remote --tags --refs https://github.com/cucumber/cucumber-cpp.git \
  | sed --quiet 's|.*refs/tags/\(v[0-9][0-9.]*\)$|\1|p' \
  | sort --version-sort \
  | tail -n 1)

# An empty tag means the tag listing could not be read or has changed shape,
# not that cucumber-cpp stopped releasing, so stop rather than install nothing.
if [ -z "${CUCUMBER_TAG}" ]; then
  echo 'Found no cucumber-cpp v<version> tag at github.com/cucumber/cucumber-cpp' >&2
  exit 1
fi

# Install the newest GoogleTest release, which the step definitions assert
# with. GitHub redirects releases/latest to the newest release's tag.
readonly GTEST_LATEST_URL=$(curl --silent --fail --output /dev/null --write-out '%{redirect_url}' \
  https://github.com/google/googletest/releases/latest)
readonly GTEST_TAG="${GTEST_LATEST_URL##*/}"

if [ -z "${GTEST_TAG}" ]; then
  echo 'Found no GoogleTest release tag at github.com/google/googletest' >&2
  exit 1
fi

git clone --branch "${CUCUMBER_TAG}" https://github.com/cucumber/cucumber-cpp.git
cd cucumber-cpp

gem install bundler
bundle install

git clone --branch "${GTEST_TAG}" https://github.com/google/googletest.git
cd googletest
mkdir build
cd build
cmake ../
cmake --build . --parallel
cmake --install .

# Create build directory
cd ../..
cmake -E make_directory build

# Generate Makefiles
cmake -E chdir build cmake \
    -DCUKE_ENABLE_BOOST_TEST=on \
    -DCUKE_ENABLE_GTEST=on \
    -DCUKE_ENABLE_QT_6=off \
    -DCUKE_TESTS_UNIT=on \
    -DCUKE_ENABLE_EXAMPLES=on \
    ..

# Build cucumber-cpp
cmake --build build

# Run unit tests
cmake --build build --target test

# Run install
cmake --install build

add_test_framework Cucumber "${CUCUMBER_TAG#v}"
add_test_framework GoogleTest "${GTEST_TAG#v}"
cat /versions.json
