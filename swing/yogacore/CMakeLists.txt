# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_VERBOSE_MAKEFILE on)

# configure import libs
set(yogacore_DIR ${CMAKE_SOURCE_DIR}/../..)

set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin CACHE STRING "" )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin CACHE STRING "" )

add_compile_options(
    -fno-omit-frame-pointer
    -fexceptions
    -fvisibility=hidden
    -ffunction-sections
    -fdata-sections
    -Wall
    -std=c++11)

file(GLOB_RECURSE yogacore_SRC ${yogacore_DIR}/yoga/*.cpp)
add_library(yogacore SHARED ${yogacore_SRC})

target_include_directories(yogacore PUBLIC ${yogacore_DIR})

target_link_libraries(yogacore)
set_target_properties(yogacore PROPERTIES CXX_STANDARD 11)
