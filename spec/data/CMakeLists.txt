CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

INCLUDE_DIRECTORIES(
  "/usr/include"
  ${CMAKE_CURRENT_SOURCE_DIR}
)

ADD_EXECUTABLE(sample-binary binary_main.cpp)
ADD_LIBRARY(sample-library SHARED plugin.cpp)

TARGET_LINK_LIBRARIES(sample-binary sample-library)
TARGET_LINK_LIBRARIES(sample-library dl)
