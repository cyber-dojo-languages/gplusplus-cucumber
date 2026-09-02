#!/bin/bash
# Invoked as [bash build_pch.sh], and that ignores the shebang line, so the
# shell options have to be set here to have any effect.
set -Eeu -o pipefail

# Precompiles the headers a step-definition file spends its time parsing. That
# one file is nearly the whole cost of a [test] press here: it pulls in both
# GoogleTest and cucumber-cpp, while the code under test pulls in neither.
#
# cucumber-cpp's autodetect.hpp cannot be precompiled on its own. It looks for a
# test framework and stops with #error when it finds none, so what is
# precompiled is a header naming both, in the order a step-definition file uses
# them.
#
# The flags below must match the start-point makefile's CXXFLAGS. gcc does not
# fail when they disagree; it ignores the .gch and every run is merely as slow
# as it was before, which is the kind of regression nobody notices. The check at
# the end is what turns that silence into a failed build.

readonly WRAPPER=/usr/local/include/cucumber_cpp_gtest_pch.hpp
readonly FLAGS='-std=c++2a -Wall -Wextra -O0'

printf '#include <gtest/gtest.h>\n#include <cucumber-cpp/autodetect.hpp>\n' > "${WRAPPER}"

g++ -x c++-header ${FLAGS} "${WRAPPER}" -o "${WRAPPER}.gch"
ls --format=long "${WRAPPER}.gch"

# Compile a throwaway source the way a step-definition file is compiled, and ask
# gcc to name the headers it reads. A .gch it actually used is listed with a
# leading [!].
readonly PROBE=/tmp/pch_probe.cpp
printf '#include <gtest/gtest.h>\n#include <cucumber-cpp/autodetect.hpp>\n' > "${PROBE}"

# Held in a variable rather than piped into grep. Under pipefail, [grep -q]
# closing the pipe on its first match leaves gcc killed by SIGPIPE, and the
# whole pipeline then reports a failure that never happened.
readonly HEADERS_READ=$(g++ -Winvalid-pch -include "${WRAPPER}" ${FLAGS} -H -c "${PROBE}" -o /tmp/pch_probe.o 2>&1)

if grep -q '^! .*cucumber_cpp_gtest_pch\.hpp\.gch' <<< "${HEADERS_READ}"; then
  echo 'PRECOMPILED HEADER CONFIRMED in use'
else
  >&2 echo 'The precompiled header was built but gcc did not use it.'
  >&2 echo 'Most likely the flags here and in the start-point makefile have drifted apart.'
  exit 42
fi

rm -f "${PROBE}" /tmp/pch_probe.o
