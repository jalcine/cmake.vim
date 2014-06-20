cmake_minimum_required(VERSION 2.8)

set(CMAKE_INCLUDE_CURRENT_SOURCE_DIR ON)

add_executable(sample-binary ./binary_main.cpp)
add_library(sample-library SHARED ./plugin_main.cpp)
