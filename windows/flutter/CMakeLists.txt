# Flutter framework configuration for Windows
cmake_minimum_required(VERSION 3.14)
project(flutter LANGUAGES CXX)

# This value is used when generating builds using the Flutter tools.
set(FLUTTER_EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
if(DEFINED FLUTTER_TARGET_PLATFORM)
  set(WRAPPER_ROOT "${FLUTTER_EPHEMERAL_DIR}/cpp_client_wrapper")
  add_subdirectory("${WRAPPER_ROOT}" "flutter_wrapper")
endif()
