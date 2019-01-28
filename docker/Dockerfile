FROM cyberdojofoundation/gplusplus
LABEL maintainer=estermann.michel@gmail.com

ARG CUKE_VERSION=v0.5

RUN apt-get update \
  && apt-get install -y \
    cmake \
    git \
    libboost-all-dev \
    libgtest-dev \
    ruby \
    ruby-dev

# build cucumber-cpp
RUN git clone https://github.com/cucumber/cucumber-cpp.git
WORKDIR "cucumber-cpp"
RUN git checkout tags/$CUKE_VERSION

RUN gem install bundler && bundle install
RUN mkdir build && (cd build && cmake -DCUKE_DISABLE_QT=on -DCUKE_ENABLE_EXAMPLES=on ..)
RUN cmake --build build --target install
RUN mv build/gmock/src/gtest-build/libg* /usr/lib

COPY red_amber_green.rb /usr/local/bin
WORKDIR /

# cleanup
RUN rm -rf cucumber-cpp
RUN apt-get remove -y cmake
