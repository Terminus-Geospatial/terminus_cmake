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
cmake_minimum_required(VERSION 4.0.0 FATAL_ERROR)

include_guard()

message(STATUS "Loading Terminus CMake - Protobuf")

include(CMakeParseArguments)

# terminus_protobuf_generate
#
# Generates C++ source and header files for Google Protocol Buffer definitions. Includes support for gRPC definitions.
# The file will be generated in CMAKE_CURRENT_BINARY_DIR, so you will most likely need to add this to the include
# path of your library/executable in order for the compiler to find the generated files. This can be done using the
# `target_include_directories` CMake command.
#
# You must include the gRPC and Protobuf libraries using `find_package` prior to calling this function.
#
# Expected Positional Parameters
# ------------------------------
# - (1) PROTO_SOURCES_VAR
#       The name of the CMake variable where a list of all the generated source files (.pb.cc) are stored.
#
# - (2) PROTO_HEADERS_VAR
#       The name of the CMake variable where a list of all the generated header files (.pb.h) are stored.
#
# - (3) PROTO_LIBS_VAR
#       The name of the CMake variable where a list of all the required libraries are stored. These must be linked
#       against the target using the generated sources in order for it to compile correctly.
#
# Single-value Parameters
# -----------------------
# - PROTO_PATH
#       Path to the directory containing the protocol buffer definitions. This is used to help `ptoroc` understand what
#       directory the `import` statements in the definitions are relative to. If not provided, then import statements
#       the definitions will be relative to CMAKE_CURRENT_SOURCE_DIR.
#
# Multi-valued Parameters
# ----------------------
# - PROTO_FILES
#       A list of '.proto' files containing ONLY protocol buffer definitions. If gRPC service definitions are included
#       in the file, list it under GRPC_FILES. If PROTO_PATH is provided and values here are relative, then they will
#       be relative to the PROTO_PATH. Otherwise, they will be relative to CMAKE_CURRENT_SOURCE_DIR.
#
# - GRPC_FILES
#       A list of '.proto' files containing protocol buffer definitions AND/OR gRPC service definitions. If the file
#       only contains protocol buffer definitions, list it under PROTO_FILES. If PROTO_PATH is provided and values here
#       are relative, then they will be relative to the PROTO_PATH. Otherwise, they will be relative to
#       CMAKE_CURRENT_SOURCE_DIR.
#
function(terminus_protobuf_generate PROTO_SOURCES_VAR PROTO_HEADERS_VAR PROTO_LIBS_VAR)

    cmake_parse_arguments(
        _TERMINUS_PROTO
        ""
        "PROTO_PATH"
        "PROTO_FILES;GRPC_FILES"
        ${ARGN}
    )

    # Make sure Protobufs are installed
    if(NOT Protobuf_FOUND)
        string(CONCAT _MESSAGE
            "Failed to generate Protobuf files: 'terminus_protobuf_generate' was called without the 'Protobuf' module \n "
            "being found. Make sure Protobuf is installed on the system and the command \n"
            "'find_package(Protobuf REQUIRED)' is used prior to calling 'terminus_protobuf_generate'."
        )
        message(FATAL_ERROR "${_MESSAGE}")
    endif()

    # Extract the information we need from the installation

    set(_PROTOC $<TARGET_FILE:protobuf::protoc>)
    get_filename_component(_PROTOC_LIBRARY_DIR $<TARGET_FILE:protobuf::libprotoc> PATH)
    get_target_property(_PROTOC_LIBRARY_DIR protobuf::libprotoc INTERFACE_LINK_DIRECTORIES)
    if(NOT _PROTOC_LIBRARY_DIR)
        get_target_property(_PROTOC_LIBRARY_LOCATION protobuf::libprotoc IMPORTED_LOCATION_RELEASE)
        get_filename_component(_PROTOC_LIBRARY_DIR "${_PROTOC_LIBRARY_LOCATION}" PATH)
    endif()
    set(_PROTOC_LD_LIBRARY_PATH ${_PROTOC_LIBRARY_DIR})

    # Get the full absolute path to PROTO_PATH if one is provided. Otherwise, default to the current source directory.
    if(_TERMINUS_PROTO_PROTO_PATH)
        get_filename_component(_TERMINUS_PROTO_PROTO_PATH "${_TERMINUS_PROTO_PROTO_PATH}" ABSOLUTE)
    else()
        set(_TERMINUS_PROTO_PROTO_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Set up arguments and environment for the `protoc` command

    set(_PROTOC_ARGS
        "--cpp_out=${CMAKE_CURRENT_BINARY_DIR}"
        "--proto_path=${_TERMINUS_PROTO_PROTO_PATH}"
    )

    set(_PROTOC_ENV "LD_LIBRARY_PATH=${_PROTOC_LD_LIBRARY_PATH}")

    # Process protocol buffer definitions

    foreach(_PROTO IN LISTS _TERMINUS_PROTO_PROTO_FILES)
        # Determine this proto file's relative location to the PROTO_PATH
        get_filename_component(_PROTO_ABS "${_PROTO}" ABSOLUTE BASE_DIR "${_TERMINUS_PROTO_PROTO_PATH}")
        string(REPLACE "${_TERMINUS_PROTO_PROTO_PATH}" "" _PROTO_ABS_PARENT_DIRS "${_PROTO_ABS}")
        get_filename_component(_PROTO_ABS_PARENT_DIRS "${_PROTO_ABS_PARENT_DIRS}" PATH)
        if(_PROTO_ABS_PARENT_DIRS STREQUAL "/")
            unset(_PROTO_ABS_PARENT_DIRS)
        endif()

        # Extract the basename of the proto file, which will be used as the name for the generated files.
        get_filename_component(_PROTO_BASENAME "${_PROTO}" NAME_WLE)

        # Construct the output paths
        set(_PROTO_CC "${CMAKE_CURRENT_BINARY_DIR}${_PROTO_ABS_PARENT_DIRS}/${_PROTO_BASENAME}.pb.cc")
        set(_PROTO_H "${CMAKE_CURRENT_BINARY_DIR}${_PROTO_ABS_PARENT_DIRS}/${_PROTO_BASENAME}.pb.h" )

        # Configure CMake to invoke `protoc`
        add_custom_command(
            OUTPUT "${_PROTO_CC}" "${_PROTO_H}"
            COMMAND ${CMAKE_COMMAND} -E env ${_PROTOC_ENV} ${_PROTOC}
            ARGS
                ${_PROTOC_ARGS}
                ${_PROTO_ABS}
        )

        # Set the necessary output variables
        list(APPEND ${PROTO_SOURCES_VAR} "${_PROTO_CC}")
        list(APPEND ${PROTO_HEADERS_VAR} "${_PROTO_H}")

    endforeach(_PROTO)

    # Process gRPC service definitions if there are any

    if(_TERMINUS_PROTO_GRPC_FILES)

        # Make sure gRPC is installed
        if(NOT gRPC_FOUND)
            string(CONCAT _MESSAGE
                "Failed to generate Protobuf files: 'terminus_protobuf_generate' was given gRPC files, but \n "
                "gRPC was not found by CMake. Make sure gRPC is installed on the system and the command \n"
                "'find_package(gRPC CONFIG REQUIRED)' is used prior to calling 'terminus_protobuf_generate'."
            )
            message(FATAL_ERROR "${_MESSAGE}")
        endif()

        # Extract installation information to use when constructing the `protoc` command
        set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:gRPC::grpc_cpp_plugin>)
        get_target_property(_GRPC_LIBRARY_DIR gRPC::grpc++ INTERFACE_LINK_DIRECTORIES)
        if(NOT _GRPC_LIBRARY_DIR)
            get_target_property(_GRPC_LIBRARY_LOCATION gRPC::grpc++ IMPORTED_LOCATION_RELEASE)
            if(NOT _GRPC_LIBRARY_LOCATION)
                get_target_property(_GRPC_LIBRARY_LOCATION gRPC::grpc++ IMPORTED_LOCATION_NOCONFIG)
            endif()
            get_filename_component(_GRPC_LIBRARY_DIR "${_GRPC_LIBRARY_LOCATION}" PATH)
        endif()
        set(_PROTOC_LD_LIBRARY_PATH_GRPC "${_PROTOC_LD_LIBRARY_PATH}:${_GRPC_LIBRARY_DIR}")

        # Add additional gRPC-specific arguments to `protoc`
        list(APPEND _PROTOC_ARGS
            "--plugin=protoc-gen-grpc=${_GRPC_CPP_PLUGIN_EXECUTABLE}"
            "--grpc_out=${CMAKE_CURRENT_BINARY_DIR}"
        )

        # Update the environment to include the gRPC library when the custom command is run
        set(_PROTOC_ENV "LD_LIBRARY_PATH=${_PROTOC_LD_LIBRARY_PATH_GRPC}")

        foreach(_PROTO IN LISTS _TERMINUS_PROTO_GRPC_FILES)

            # Determine this proto file's relative location to the PROTO_PATH
            get_filename_component(_PROTO_ABS "${_PROTO}" ABSOLUTE BASE_DIR "${_TERMINUS_PROTO_PROTO_PATH}" ABSOLUTE)
            string(REPLACE "${_TERMINUS_PROTO_PROTO_PATH}" "" _PROTO_ABS_PARENT_DIRS "${_PROTO_ABS}")
            get_filename_component(_PROTO_ABS_PARENT_DIRS "${_PROTO_ABS_PARENT_DIRS}" PATH)
            if(_PROTO_ABS_PARENT_DIRS STREQUAL "/")
                unset(_PROTO_ABS_PARENT_DIRS)
            endif()

            # Extract the basename of the proto file, which will be used as the name for the generated files.
            get_filename_component(_PROTO_BASENAME "${_PROTO}" NAME_WLE)

            # Construct the output paths
            set(_PROTO_CC_GRPC "${CMAKE_CURRENT_BINARY_DIR}${_PROTO_ABS_PARENT_DIRS}/${_PROTO_BASENAME}.grpc.pb.cc")
            set(_PROTO_H_GRPC "${CMAKE_CURRENT_BINARY_DIR}${_PROTO_ABS_PARENT_DIRS}/${_PROTO_BASENAME}.grpc.pb.h")
            set(_PROTO_CC "${CMAKE_CURRENT_BINARY_DIR}${_PROTO_ABS_PARENT_DIRS}/${_PROTO_BASENAME}.pb.cc")
            set(_PROTO_H "${CMAKE_CURRENT_BINARY_DIR}${_PROTO_ABS_PARENT_DIRS}/${_PROTO_BASENAME}.pb.h")

            # Configure CMake to invoke `protoc`
            add_custom_command(
                OUTPUT "${_PROTO_CC_GRPC}" "${_PROTO_H_GRPC}" "${_PROTO_CC}" "${_PROTO_H}"
                COMMAND ${CMAKE_COMMAND} -E env ${_PROTOC_ENV} ${_PROTOC}
                ARGS
                    ${_PROTOC_ARGS}
                    ${_PROTO_ABS}
            )

            # Set the necessary output variables
            list(APPEND ${PROTO_SOURCES_VAR} "${_PROTO_CC_GRPC}")
            list(APPEND ${PROTO_HEADERS_VAR} "${_PROTO_H_GRPC}")
            list(APPEND ${PROTO_SOURCES_VAR} "${_PROTO_CC}")
            list(APPEND ${PROTO_HEADERS_VAR} "${_PROTO_H}")

        endforeach(_PROTO)

    endif()

    # Propagate the output variables into the parent scope

    set(${PROTO_SOURCES_VAR} ${${PROTO_SOURCES_VAR}} PARENT_SCOPE)
    set(${PROTO_HEADERS_VAR} ${${PROTO_HEADERS_VAR}} PARENT_SCOPE)
    set(_PROTO_LIBS protobuf::libprotobuf)
    if(_TERMINUS_PROTO_GRPC_FILES)
        list(APPEND _PROTO_LIBS gRPC::grpc++)
    endif()
    set(${PROTO_LIBS_VAR} ${_PROTO_LIBS} PARENT_SCOPE)

endfunction()