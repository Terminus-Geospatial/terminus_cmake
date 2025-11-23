############################# INTELLECTUAL PROPERTY RIGHTS #############################
##                                                                                    ##
##                           Copyright (c) 2024 Terminus LLC                          ##
##                                All Rights Reserved.                                ##
##                                                                                    ##
##          Use of this source code is governed by LICENSE in the repo root.          ##
##                                                                                    ##
############################# INTELLECTUAL PROPERTY RIGHTS #############################
#
#    File:    CMakeLists.txt
#    Author:  Marvin Smith
#    Date:    7/5/2023
#
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

# Set the Project-Name
project( terminus_cmake
         VERSION ${CONAN_PKG_VERSION}
         HOMEPAGE_URL ${CONAN_PKG_URL}
         DESCRIPTION ${CONAN_PKG_DESCRIPTION}
         LANGUAGES CXX
)

#  Set C++ Standard
set( CMAKE_CXX_STANDARD 23 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )

include( "cmake/terminus_cmake.cmake" )

if( TERMINUS_CMAKE_ENABLE_TESTS )
    message( "Enabling Unit-Tests" )
    enable_testing()
    add_subdirectory( test/unit )
else()
    message( "Skipping Unit-Tests" )
endif()

install( DIRECTORY cmake/ DESTINATION cmake )
