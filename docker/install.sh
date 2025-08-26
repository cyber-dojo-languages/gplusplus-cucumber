#!/bin/bash -Eeu

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

gem install bundler
bundle install

# Install gtest
git clone https://github.com/google/googletest.git
cd googletest
mkdir build
cd build
cmake ../
cmake --build . --parallel
sudo cmake --install .

git clone https://github.com/cucumber/cucumber-cpp.git
cd cucumber-cpp

# Create build directory
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


#readonly CUKE_VERSION=v0.7.0
#
#apt-get update && apt-get upgrade --yes
#apt-get install --yes ruby ruby-dev
#gem install bundler
#
## Install googletest headers and boost
#apt-get install --yes cmake git libboost-all-dev libgtest-dev
#
## build cucumber-cpp
#git clone https://github.com/cucumber/cucumber-cpp.git
#cd cucumber-cpp
#git checkout tags/$CUKE_VERSION
#
#bundle install
#mkdir build && (cd build && cmake -DCUKE_DISABLE_QT=on -DCUKE_ENABLE_EXAMPLES=on ..)
#cmake --build build --target install
#mv build/gmock/src/gtest-build/libg* /usr/lib
#
## cleanup
#rm -rf cucumber-cpp
#apt-get remove --yes cmake
