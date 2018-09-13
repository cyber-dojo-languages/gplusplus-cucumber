CXXFLAGS += -I.
CXXFLAGS += -std=c++17
CXXFLAGS += -Wall -Wextra -Werror
CXXFLAGS += -fprofile-arcs -ftest-coverage

GTEST_LIBS = -lgtest -pthread
BOOST_LIBS = -lboost_thread -lboost_system -lboost_regex -lboost_date_time -lboost_program_options -lboost_filesystem
CUCUMBER_LIB = -lcucumber-cpp

HPP_FILES = $(wildcard *.hpp)
COMPILED_HPP_FILES = $(patsubst %.hpp,%.compiled_hpp,$(HPP_FILES))
CPP_FILES = $(wildcard *.cpp)
CPP_STEP_FILES = $(wildcard features/step_definitions/*.cpp)

.PHONY: test.output
test.output: test makefile
	@./$< > /dev/null &

test: makefile $(CPP_FILES) $(CPP_STEP_FILES) $(COMPILED_HPP_FILES)
	@$(CXX) $(CXXFLAGS) -O $(CPP_FILES) $(CPP_STEP_FILES) $(GTEST_LIBS) $(BOOST_LIBS) $(CUCUMBER_LIB) -o $@

# This rule ensures header files build in their own right.
# The quality of header files is important because header files
# are #included from other files and thus have a large span
# of influence (unlike .cpp files which are not #included)

%.compiled_hpp: %.hpp
	@$(CXX) -x c++ $(CXXFLAGS) -c -o $@ $<
