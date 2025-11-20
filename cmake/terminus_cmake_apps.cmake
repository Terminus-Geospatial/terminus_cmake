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
#    File:    terminus_cmake_apps.cmake
#    Author:  Marvin Smith
#    Date:    7/6/2023
#
#    Purpose:  CMake scripts for applications
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

message( STATUS "Loading Terminus CMake - Apps" )

#  terminus_app_configure
#
#   Set target props for applications
function( terminus_app_configure TARGET )

    set_target_properties( ${TARGET} PROPERTIES
        INSTALL_RPATH "\$ORIGIN/../lib"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    )

    if( TERMINUS_CXX_FLAGS )
        target_compile_options( ${TARGET} PUBLIC ${TERMINUS_CXX_FLAGS} )
    endif()

    install( TARGETS ${TARGET} DESTINATION "bin" )

endfunction( terminus_app_configure )