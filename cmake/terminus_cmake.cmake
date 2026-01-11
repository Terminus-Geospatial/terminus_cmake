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
#    File:    terminus_cmake.cmake
#    Author:  Marvin Smith
#    Date:    7/5/2023
#
#    Purpose:  Tie in all utility scripts
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

include_guard()

message( STATUS "Loading Terminus CMake - All" )

include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_project.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_apps.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_colors.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_coverage.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_test.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_util.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_libs.cmake" )
include( "${CMAKE_CURRENT_LIST_DIR}/terminus_cmake_protobuf.cmake" )
