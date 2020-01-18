#!/bin/bash -Eeu

readonly CUKE_VERSION=v0.5

apt-get update
apt-get install --yes \
    cmake \
    git \
    libgtest-dev \
    ruby \
    ruby-dev

# build cucumber-cpp
git clone https://github.com/cucumber/cucumber-cpp.git
cd cucumber-cpp
git checkout tags/$CUKE_VERSION

gem install bundler
bundle install
mkdir build && (cd build && cmake -DCUKE_DISABLE_QT=on -DCUKE_ENABLE_EXAMPLES=on ..)
cmake --build build --target install
mv build/gmock/src/gtest-build/libg* /usr/lib

# cleanup
rm -rf /cucumber-cpp
apt-get remove --yes cmake
