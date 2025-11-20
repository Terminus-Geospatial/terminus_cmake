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
#    File:    terminus_cmake_colors.cmake
#    Author:  Marvin Smith
#    Date:    7/5/2023
#
#    Purpose: Provide color info
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

#These variables allow you to use colors on unix based systems
#Example:
# message(STATUS "${YELLOW} This text will appear in yellow!${COLOR_RESET}")

#Ensure that you end with a COLOR_RESET otherwise all subsequent text until another
#color change will be the color sepcified.
#If these variables are not defined but still in message calls, they will simply evaluate to an empty string
#so no errors will occur

message(STATUS "Loading Terminus CMake - Colors")

if(NOT WIN32)
  string(ASCII 27 Esc)
  set(COLOR_RESET "${Esc}[m")
  set(COLOR_BOLD  "${Esc}[1m")
  set(RED         "${Esc}[31m")
  set(GREEN       "${Esc}[32m")
  set(YELLOW      "${Esc}[33m")
  set(BLUE        "${Esc}[34m")
  set(MAGENTA     "${Esc}[35m")
  set(CYAN        "${Esc}[36m")
  set(WHITE       "${Esc}[37m")
  set(BOLD_RED     "${Esc}[1;31m")
  set(BOLD_GREEN   "${Esc}[1;32m")
  set(BOLD_YELLOW  "${Esc}[1;33m")
  set(BOLD_BLUE    "${Esc}[1;34m")
  set(BOLD_MAGENTA "${Esc}[1;35m")
  set(BOLD_CYAN    "${Esc}[1;36m")
  set(BOLD_WHITE   "${Esc}[1;37m")
endif()