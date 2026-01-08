cmake_minimum_required(VERSION 3.18)
project(CovGoogleTest)

# starting from v. 1.17.0 GoogleTest requires at least C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(GOOGLETEST_SUBPATH "googletest/googletest.zip")

if(DEFINED GOOGLETEST_URL)
# use the specified URL
elseif(CPPTEST_HOME)
set(GOOGLETEST_URL "${CPPTEST_HOME}/${GOOGLETEST_SUBPATH}")
elseif(DEFINED ENV{CPPTEST_HOME})
set(GOOGLETEST_URL "$ENV{CPPTEST_HOME}/${GOOGLETEST_SUBPATH}")
elseif (EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../${GOOGLETEST_SUBPATH}")
set(GOOGLETEST_URL "${CMAKE_CURRENT_LIST_DIR}/../../${GOOGLETEST_SUBPATH}")
else()
message(FATAL_ERROR "Unable to locate GoogleTest package - please set CPPTEST_HOME (or GOOGLETEST_URL).")
endif()

include(FetchContent)
FetchContent_Declare(
  googletest
  URL "${GOOGLETEST_URL}"
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)
enable_testing()

if(CPPTEST_COVERAGE)
  include(cpptest-coverage.cmake)
endif()

add_executable(
  goo_test
  goo_test.cpp
  goo.cpp
)

target_link_libraries(
  goo_test
  gtest_main
)

include(GoogleTest)
gtest_discover_tests(goo_test XML_OUTPUT_DIR "${CMAKE_BINARY_DIR}/gtest-report")