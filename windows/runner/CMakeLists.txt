cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "run_loop.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "Runner.rc"
  "resource.h"
)

# Apply standard C++17 configuration
target_compile_features(${BINARY_NAME} PRIVATE cxx_std_17)

target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../flutter/ephemeral"
)

target_link_libraries(${BINARY_NAME} PRIVATE
  flutter
  flutter_wrapper_app
  dwmapi.lib
  imm32.lib
)

# Include generated plugins libraries
include(flutter/generated_plugins.cmake OPTIONAL)
if(DEFINED PLUGIN_LIBRARIES)
  target_link_libraries(${BINARY_NAME} PRIVATE ${PLUGIN_LIBRARIES})
endif()

# Apply the standard set of build settings.
if(MSVC)
  target_compile_options(${BINARY_NAME} PRIVATE /W4 /WX- /EHsc)
endif()
