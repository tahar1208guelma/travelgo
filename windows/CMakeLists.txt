# Project-level CMakeLists.txt for TRAVELGO Windows Desktop application
cmake_minimum_required(VERSION 3.14)
project(travelgo LANGUAGES CXX)

set(BINARY_NAME "travelgo")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build options.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Configuration: Debug Profile Release"
      FORCE)
  endif()
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

# Set compilation flags
if(MSVC)
  add_compile_options(
    $<$<CONFIG:Release>:/O2 /GL>
    /EHsc
    /W4
    /WX-
  )
endif()

# Flutter wrapper and plugins
add_subdirectory(flutter)
add_subdirectory(runner)

include(flutter/generated_plugins.cmake OPTIONAL)
