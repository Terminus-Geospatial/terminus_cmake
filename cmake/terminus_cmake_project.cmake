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
#    File:    terminus_cmake_project.cmake
#    Author:  Marvin Smith
#    Date:    7/5/2023
#
#    Purpose:  Create CMake settings automatically
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

include_guard()

message( STATUS "Loading Terminus CMake - Project Init" )

#  Terminus C++ Warning Flags
#
#  Provide escalating compiler-warning presets that always treat warnings as errors.
set( TERMINUS_CXX_FLAGS_LOW
    -Wall
    -Wextra
    -Werror
)

set( TERMINUS_CXX_FLAGS_MEDIUM
    ${TERMINUS_CXX_FLAGS_LOW}
    -Wconversion
    -Wpedantic
)

set( TERMINUS_CXX_FLAGS_HIGH
    ${TERMINUS_CXX_FLAGS_MEDIUM}
    -Wdouble-promotion
    -Wshadow
    -Wundef
)

#  Legacy aggregate for consumers expecting a single warning list
set( TERMINUS_CXX_WARNING_FLAGS ${TERMINUS_CXX_FLAGS_LOW} )

if( NOT DEFINED TERMINUS_CXX_FLAGS )
    set( TERMINUS_CXX_FLAGS ${TERMINUS_CXX_FLAGS_HIGH} )
endif()

