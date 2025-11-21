#
############################# INTELLECTUAL PROPERTY RIGHTS #############################
##                                                                                    ##
##                           Copyright (c) 2024 Terminus LLC                          ##
##                                All Rights Reserved.                                ##
##                                                                                    ##
##          Use of this source code is governed by LICENSE in the repo root.          ##
##                                                                                    ##
############################# INTELLECTUAL PROPERTY RIGHTS #############################
#
#    File:    terminus_cmake_test.cmake
#    Author:  Marvin Smith
#    Date:    7/6/2023
#
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

include_guard()

message(STATUS "Loading Terminus CMake - Tests")

# terminus_test_prepare_unit
#
# Prepares for creation of unit test targets by finding all the required libraries and bringing
# additional utilities into scope.
#
macro(terminus_test_prepare_unit)
    find_package(GTest 1.10.0 CONFIG REQUIRED)
    include(GoogleTest)
endmacro()

# terminus_test_add_unit
#
# Adds a new unit test to the test suite. Tests are discovered via GTest. Each invocation of this
# function will create a new executable target that can be run using the `ctest` cmmand. It is
# assumed that the `enable_testing()` command has already been called in the root-level
# `CMakeLists.txt`
#
# Expected Positional Arguments
# -----------------------------
# - (1) SUFFIX
#       The unique suffix to add the end of the target name for this test. Tests are all prefixed
#       with `test_unit_${PROJECT_NAME}_`.
# - (2) FILE
#       The source file that contains the tests. This is the file that will be compiled into the
#       test executable. If it contains a custom `main()` function, then you must use the
#       `INCLUDES_MAIN` option.
#
# Options
# -------
# - INCLUDES_MAIN
#   If present, it is expected that the provided source file contains a user-defined `main()`
#   function, and so the GTest targets that include main will not be used.
#
# Single-valued Options
# - TARGET
#   The name of the primary target to link against. This should be a static or shared library that
#   contains the logic to test. If not provided, `PROJECT_NAME` will be used.
#
# Multi-valued Options
# --------------------
# - EXTRA_LIBS
#   Specifies a list of additional ibraries to link the test target against.
#
function(terminus_test_add_unit SUFFIX FILE)
    # Parse arguments
    cmake_parse_arguments(
        _TERMINUS_TEST
        "INCLUDES_MAIN"
        "TARGET"
        "EXTRA_LIBS"
        ${ARGN}
    )

    # Determine the libraries we should use
    if(_TERMINUS_TEST_INCLUDES_MAIN)
        set(_LIBS GTest::gtest GTest::gmock ${_TERMINUS_TEST_EXTRA_LIBS})
    else()
        set(_LIBS GTest::gtest_main GTest::gmock ${_TERMINUS_TEST_EXTRA_LIBS})
    endif()

    # Determine the target to link against
    if(NOT _TERMINUS_TEST_TARGET)
        set(_TERMINUS_TEST_TARGET ${PROJECT_NAME})
    endif()

    # Configure the test executable
    set(_TEST test_unit_${PROJECT_NAME}_${SUFFIX})
    add_executable(${_TEST} ${FILE})
    target_link_libraries(${_TEST} PRIVATE
        ${_LIBS}
        ${_TERMINUS_TEST_TARGET}
    )

    # Gather the tests
    gtest_discover_tests(${_TEST})
endfunction()