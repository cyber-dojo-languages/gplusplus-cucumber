FROM cyberdojofoundation/gplusplus
LABEL maintainer=estermann.michel@gmail.com

ARG CUKE_VERSION=v0.5

RUN \
apt-get update && \
apt-get install --yes \
    cmake \
    git \
    libboost-all-dev \
    libgtest-dev \
    ruby \
    ruby-dev && \
\
`# build cucumber-cpp` \
git clone https://github.com/cucumber/cucumber-cpp.git && \
cd cucumber-cpp && \
git checkout tags/$CUKE_VERSION && \
\
gem install bundler && \
bundle install && \
mkdir build && (cd build && cmake -DCUKE_DISABLE_QT=on -DCUKE_ENABLE_EXAMPLES=on ..) && \
cmake --build build --target install && \
mv build/gmock/src/gtest-build/libg* /usr/lib && \
\
`# cleanup` \
rm -rf /cucumber-cpp && \
apt-get remove --yes cmake

COPY red_amber_green.rb /usr/local/bin
