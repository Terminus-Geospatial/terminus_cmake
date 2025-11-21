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
#    File:    terminus_cmake_util.cmake
#    Author:  Marvin Smith
#    Date:    7/6/2023
#
#    Purpose:  Utilities for handing CMake calls more elegantly
#
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

include_guard()

message( STATUS "Loading Terminus CMake - Utilities" )

#  terminus_util_get_all_targets
#
#  Collects all targets created up to the point the function was invoked. Any
#  target created in the same directory as, or a subdirectory of, `PROJECT_SOURCE_DIR`
#  will be included in the value of `_OUTPUT_VAR_`.
#
function( terminus_util_get_all_targets _OUTPUT_VAR )
    set(_TARGETS)
    terminus_util_get_all_targets_impl( _TARGETS ${PROJECT_SOURCE_DIR} )
    set( ${_OUTPUT_VAR} ${_TARGETS} PARENT_SCOPE )
endfunction()

# terminus_util_get_all_targets_impl
#
#  Recursive helper function for above function
#
macro( terminus_util_get_all_targets_impl _TARGETS _CURRENT_DIR )
    get_property( _SUBDIRECTORIES DIRECTORY ${_CURRENT_DIR} PROPERTY SUBDIRECTORIES )
    foreach( _SUBDIR ${_SUBDIRECTORIES} )
        terminus_util_get_all_targets_impl( ${_TARGETS} ${_SUBDIR} )
    endforeach()

    get_property( _CURRENT_TARGETS ${_CURRENT_DIR} PROPERTY BUILDSYSTEM_TARGETS )
    list( APPEND ${_TARGETS} ${_CURRENT_TARGETS} )
endmacro()


function(terminus_dump_cmake_variables)
    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName ${_variableNames})
        if (ARGV0)
            unset(MATCHED)
            string(REGEX MATCH ${ARGV0} MATCHED ${_variableName})
            if (NOT MATCHED)
                continue()
            endif()
        endif()
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
endfunction()