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

message( STATUS "Loading Terminus CMake - Project Init" )

#  Terminus C++ Warning Flags
#
#  General C++ Warning Flags
if( NOT DEFINED TERMINUS_CXX_WARN_LEVEL )
    set( TERMINUS_CXX_WARN_LEVEL "MEDIUM" CACHE STRING "Terminus C++ warning level (LOW/MEDIUM/HIGH)" )
endif()
set_property( CACHE TERMINUS_CXX_WARN_LEVEL PROPERTY STRINGS LOW MEDIUM HIGH )

if( MSVC )
    set( TERMINUS_CXX_WARNING_FLAGS_LOW    /W3 )
    set( TERMINUS_CXX_WARNING_FLAGS_MEDIUM /W4 )
    set( TERMINUS_CXX_WARNING_FLAGS_HIGH   /W4 /permissive- )
else()
    set( TERMINUS_CXX_WARNING_FLAGS_LOW
        -Wall
        -Wextra
    )

    set( TERMINUS_CXX_WARNING_FLAGS_MEDIUM
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wformat=2
        -Wnull-dereference
        -Wimplicit-fallthrough
    )

    set( TERMINUS_CXX_WARNING_FLAGS_HIGH
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wformat=2
        -Wnull-dereference
        -Wimplicit-fallthrough
        -Wconversion
        -Wsign-conversion
        -Wold-style-cast
        -Woverloaded-virtual
    )
endif()

if( NOT DEFINED TERMINUS_CXX_WARNING_FLAGS )
    if( TERMINUS_CXX_WARN_LEVEL STREQUAL "LOW" )
        set( TERMINUS_CXX_WARNING_FLAGS ${TERMINUS_CXX_WARNING_FLAGS_LOW} )
    elseif( TERMINUS_CXX_WARN_LEVEL STREQUAL "HIGH" )
        set( TERMINUS_CXX_WARNING_FLAGS ${TERMINUS_CXX_WARNING_FLAGS_HIGH} )
    else()
        set( TERMINUS_CXX_WARNING_FLAGS ${TERMINUS_CXX_WARNING_FLAGS_MEDIUM} )
    endif()
endif()

if( NOT DEFINED TERMINUS_CXX_FLAGS )
    set( TERMINUS_CXX_FLAGS ${TERMINUS_CXX_WARNING_FLAGS} )
endif()

