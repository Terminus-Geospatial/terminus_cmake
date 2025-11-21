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
#    File:    terminus_cmake_coverage.cmake
#    Author:  Marvin Smith
#    Date:    7/5/2023
#

# cmake-cov
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

include_guard()

message(STATUS "Loading Terminus CMake - Coverage")

include("${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_util.cmake")

# terminus_coverage_enable
#
# Sets global compiler flags needed for code coverage reporting. This function should be called
# before any targets are created and configured to ensure that all targets are compiled with the
# appropriate coverage flags enabled.
#
function( terminus_coverage_enable )
    message( STATUS "Enabling code coverage reporting" )

    # Make sure we aren't configuring with any optimizations
    get_property(_GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" OR _GENERATOR_IS_MULTI_CONFIG))
        message(WARNING "Code coverage results with a non-Debug build may be misleading")
    endif()

    # Set global compiler flags to enable coverage reporting
    set(_COVERAGE_COMPILER_FLAGS "--coverage -fprofile-abs-path")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${_COVERAGE_COMPILER_FLAGS}" PARENT_SCOPE)

endfunction( terminus_coverage_enable )

# terminus_coverage_create_target
#
# Verifies that `gcov` is installed on the system and then proceeds to create the `coverage` target
# that, when invoked, will run all tests with `ctest` and generate code coverage reports for all
# compiled targets in the project.
#
# When the `coverage` target is run, `gcov` will collect coverage reports and place them in the
# `${PROJECT_SOURCE_DIR}/coverage` directory. Only coverage for files contained within the project
# will be included in the report.
#
# It is best to call this function at the end of configuring all the source targets.
#
# Multi-valued Options
# --------------------
# - IGNORE_TARGETS
#   A list of target names to not include in the calculation of code coverage. This is particularly
#   useful when you want to leave out certain component-level functionality that can't be unit
#   tested effectively.
#
function( terminus_coverage_create_target )
    # Parse arguments
    cmake_parse_arguments(
        _TERMINUS_COV
        ""
        ""
        "IGNORE_TARGETS"
        ${ARGN}
    )

    # Locate gcov
    find_program(_GCOV_PATH gcov)
    if(NOT _GCOV_PATH)
        message(FATAL_ERROR "Code coverage tool 'gcov' not found! Aborting...")
    endif()

    # Collect the object files to analyze
    set(_OBJECT_FILES)
    terminus_util_get_all_targets(_ALL_TARGETS)
    foreach(_T ${_ALL_TARGETS})
        get_target_property(_TYPE ${_T} TYPE)
        if (NOT ${_TYPE} STREQUAL "INTERFACE_LIBRARY" AND NOT ${_T} IN_LIST _TERMINUS_COV_IGNORE_TARGETS)
            list(APPEND _OBJECT_FILES $<TARGET_OBJECTS:${_T}>)
        endif()
    endforeach()

    # Setup the gcov command to run
    set(_GCOV_CMD ${_GCOV_PATH} --preserve-paths -r -s ${PROJECT_SOURCE_DIR} ${_OBJECT_FILES})

    message(STATUS "Configuring command to generate coverage reports")

    # Prepare the report directory
    set(_COVERAGE_REPORT_DIR "${PROJECT_SOURCE_DIR}/coverage")
    set(_COVERAGE_PREPARE_TARGET coverage_prepare)
    add_custom_target(${_COVERAGE_PREPARE_TARGET}
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${_COVERAGE_REPORT_DIR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${_COVERAGE_REPORT_DIR}"
        COMMENT "Preparing coverage report directory"
    )

    # Run the tests to get code coverage statistics
    cmake_host_system_information(RESULT _PROCESSOR_COUNT QUERY NUMBER_OF_PHYSICAL_CORES)
    set(_COVERAGE_TEST_TARGET coverage_execute_tests)
    add_custom_target(${_COVERAGE_TEST_TARGET}
        COMMAND ctest -j ${_PROCESSOR_COUNT}
        DEPENDS ${_COVERAGE_PREPARE_TARGET}
        WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
        COMMENT "Gathering coverage information"
    )

    # Run the code coverage tool
    set(_COVERAGE_TARGET coverage)
    add_custom_target(${_COVERAGE_TARGET}
        COMMAND ${_GCOV_CMD}
        DEPENDS ${_COVERAGE_PREPARE_TARGET} ${_COVERAGE_TEST_TARGET}
        WORKING_DIRECTORY "${_COVERAGE_REPORT_DIR}"
        VERBATIM
        COMMAND_EXPAND_LISTS
        COMMENT "Generating coverage report"
    )

    # Show info where to find the report
    add_custom_command(TARGET ${_COVERAGE_TARGET} POST_BUILD
        COMMAND ;
        COMMENT "Code coverage report saved in ${_COVERAGE_REPORT_DIR}"
    )
endfunction( terminus_coverage_create_target )
