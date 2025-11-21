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
#    File:    terminus_cmake_libs.cmake
#    Author:  Marvin Smith
#    Date:    7/6/2023
#
cmake_minimum_required(VERSION 4.0.0)

include_guard()

message(STATUS "Loading Terminus CMake - Libs")

# terminus_lib_configure
#
# Sets target properties for a shared library that will be used by multiple other Terminus apps/libs
# using Terminus conventions. These conventions include:
#
# - Installing the built library to `${CMAKE_INSTALL_PREFIX}/lib`
# - Installing all headers in `${PROJECT_SOURCE_DIR}/include` to `${CMAKE_INSTALL_PREFIX}/include`
#
# The options/parameters below provide additional means of configuring what the final installation
# pacakge will look like.
#
# Expected Positional Parameters
# ------------------------------
# - (1) TARGET
#       The name of the CMake library target to configure.
#
# Options
# -------
# - NO_INSTALL
#       Skips configuring the install target to include this library. By default, the library will
#       be added to the install
#
# - HEADER_ONLY
#       Uses INTERFACE as the visibility for properties rather than PUBLIC, since header-only
#       libraries don't build any objects.
#
# Multi-valued Parameters
# -----------------------
# - FEATURE_HEADERS
#       Accepts a list of pairs. The first element in the pair is the name of a boolean variable
#       indicating whether a feature is enabled. The second element is the directory containing
#       header files to include in the installation package if the first element evaluates to true.
#       This directory should be relative and will resolve from the `include` directory in the
#       project source root. For example:
#
#           FEATURE_HEADERS TERMINUS_TIME_ENABLE_LEGACY terminus/time/legacy
#
#       This will install all files located under `${PROJECT_SOURCE_DIR}/include/terminus/time/legacy`
#       into `${CMAKE_INSTALL_PREFIX}/include/terminus/time/legacy` if the feature flag
#       `TERMINUS_TIME_ENABLE_LEGACY` is set to a truthy value. If the feature flag is set to a falsey
#       value, then the headers in the provided directory will not be included in the installation
#       package.
#
function( terminus_lib_configure TARGET )

    # Set options
    cmake_parse_arguments(
        _TERMINUS_LIB_CONFIGURE
        "NO_INSTALL;HEADER_ONLY"
        ""
        "FEATURE_HEADERS"
        ${ARGN}
    )

    # Determine visibility (interface/public)
    set(_VISIBILITY PUBLIC)
    if(_TERMINUS_LIB_CONFIGURE_HEADER_ONLY)
        set(_VISIBILITY INTERFACE)
    endif()

    # If we are header-only, we cannot configure certain properties. Make sure we are not
    # header-only before configuring them.
    if(NOT _TERMINUS_LIB_CONFIGURE_HEADER_ONLY)
        set_target_properties(${TARGET} PROPERTIES
            POSITION_INDEPENDENT_CODE ON
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
            ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        )
    endif()
    if( TERMINUS_CXX_FLAGS )
        if(NOT _VISIBILITY STREQUAL "INTERFACE")
            target_compile_options(${TARGET} PRIVATE ${TERMINUS_CXX_FLAGS})
        endif()
    endif()

    target_include_directories(${TARGET} ${_VISIBILITY}
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    )

    if(NOT _TERMINUS_LIB_CONFIGURE_NO_INSTALL)
        # NOTE: The EXPORT parameter must be on the same line as TARGETS or else CMake produces an error.
        install(
            TARGETS ${TARGET} EXPORT ${PROJECT_NAME}_exports
            LIBRARY DESTINATION "lib"
            ARCHIVE DESTINATION "lib"
        )
    endif()

    # Configure include directory install locations. This also determines which header
    # files to include/omit based on feature-flags.
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/include")
        message(FATAL_ERROR "No header files will be installed with this library (missing 'include' "
                            "directory in project source root)"
        )
    else()
        file(GLOB_RECURSE _HEADERS_TO_INSTALL RELATIVE "${PROJECT_SOURCE_DIR}/include"
            "${PROJECT_SOURCE_DIR}/include/*"
        )
        set(_PAIR_START TRUE)
        foreach(_ELEMENT IN LISTS _TERMINUS_LIB_CONFIGURE_FEATURE_HEADERS)
            if(_PAIR_START)
                set(_PAIR_FLAG ${_ELEMENT})
                set(_PAIR_START FALSE)
            else()
                if(NOT ${_PAIR_FLAG})
                    message(STATUS "Removing '${_ELEMENT}' directory from installed includes")
                    list(FILTER _HEADERS_TO_INSTALL EXCLUDE REGEX "${_ELEMENT}/.*")
                endif()
                set(_PAIR_START TRUE)
            endif()
        endforeach()
        foreach(_H IN LISTS _HEADERS_TO_INSTALL)
            get_filename_component(_DIR "${_H}" DIRECTORY)
            install(FILES "${PROJECT_SOURCE_DIR}/include/${_H}" DESTINATION "include/${_DIR}")
        endforeach()
    endif()

endfunction(terminus_lib_configure)

# terminus_lib_create_from_objects
#
# Given a CMake OBJECT library, creates both a SHARED and STATIC library from the objects and configures each target
# to be installed. The value of PROJECT_NAME is used to create the target names and the output names of the resulting
# artifacts.
#
# Expected Positional Parameters
# ------------------------------
# - (1) OBJECTS
#       The name of the CMake object library target to configure. The object files associated with this target will
#       be used to create the shared and static libraries that will be published as part of the library
#
# Options
# -------
# - NO_INSTALL_STATIC
#       Skips configuring the install target to include the static library created by this function. By default,
#       both the static and shared libraries are included in the install.
#
# - NO_INSTALL_SHARED
#       Skips configuring the install target to include the shared library created by this function. By default,
#       both the shared and static libraries are included in the install.
#
# Multi-valued Parameters
# -----------------------
# - FEATURE_HEADERS
#       The value of this parameter is forwarded to `terminus_lib_configure`. See the documentation for
#       `terminus_lib_configure` for more details.
#
function( terminus_lib_create_from_objects OBJECTS )

    # Set options
    cmake_parse_arguments(
        _TERMINUS_LIB_CREATE
        "NO_INSTALL_STATIC;NO_INSTALL_SHARED"
        ""
        "FEATURE_HEADERS"
        ${ARGN}
    )

    # Add conventional configuration to the OBJECT library
    set_target_properties(${OBJECTS} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
    )
    if( TERMINUS_CXX_FLAGS )
        target_compile_options(${OBJECTS} PRIVATE ${TERMINUS_CXX_FLAGS})
    endif()

    # Create and configure the shared library target
    set(SHARED_TARGET ${PROJECT_NAME})
    add_library(${SHARED_TARGET} SHARED $<TARGET_OBJECTS:${OBJECTS}>)
    if(_TERMINUS_LIB_CREATE_NO_INSTALL_SHARED)
        set(NO_INSTALL_SHARED NO_INSTALL)
    endif()
    if(_TERMINUS_LIB_CREATE_FEATURE_HEADERS)
        set(FEATURE_HEADERS FEATURE_HEADERS ${_TERMINUS_LIB_CREATE_FEATURE_HEADERS})
    endif()
    target_link_libraries(${SHARED_TARGET} PUBLIC ${OBJECTS})
    terminus_lib_configure(${SHARED_TARGET} ${NO_INSTALL_SHARED} ${FEATURE_HEADERS})

    # Create and configure the static library target
    set(STATIC_TARGET ${PROJECT_NAME}_static)
    add_library(${STATIC_TARGET} STATIC $<TARGET_OBJECTS:${OBJECTS}>)
    set_target_properties(${STATIC_TARGET} PROPERTIES
        OUTPUT_NAME ${PROJECT_NAME}
    )
    if(_TERMINUS_LIB_CREATE_NO_INSTALL_STATIC)
        set(NO_INSTALL_STATIC NO_INSTALL)
    endif()
    if(_TERMINUS_LIB_CREATE_FEATURE_HEADERS)
        set(FEATURE_HEADERS FEATURE_HEADERS ${_TERMINUS_LIB_CREATE_FEATURE_HEADERS})
    endif()
    target_link_libraries(${STATIC_TARGET} PUBLIC ${OBJECTS})
    terminus_lib_configure(${STATIC_TARGET} ${NO_INSTALL_STATIC} ${FEATURE_HEADERS})

    # Configure include paths
    target_include_directories(${OBJECTS} PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    )

endfunction( terminus_lib_create_from_objects )

# terminus_lib_create_header_only
#
# Creates an INTERFACE library target used as a header-only library. The name of the target is the
# same as PROJECT_NAME.
#
# Multi-valued Parameters
# -----------------------
# - FEATURE_HEADERS
#       The value of this parameter is forwarded to `terminus_lib_configure`. See the documentation for
#       `terminus_lib_configure` for more details.
#
function( terminus_lib_create_header_only )

    # Set options
    cmake_parse_arguments(
        _TERMINUS_LIB_CREATE
        ""
        ""
        "FEATURE_HEADERS"
        ${ARGN}
    )

    # Determine if we need feature headers enabled
    if(_TERMINUS_LIB_CREATE_FEATURE_HEADERS)
        set(FEATURE_HEADERS FEATURE_HEADERS ${_TERMINUS_LIB_CREATE_FEATURE_HEADERS})
    endif()

    # Create and configure the header-only library target (i.e. interface target)
    add_library(${PROJECT_NAME} INTERFACE)
    terminus_lib_configure(${PROJECT_NAME} HEADER_ONLY ${FEATURE_HEADERS})

endfunction( terminus_lib_create_header_only )