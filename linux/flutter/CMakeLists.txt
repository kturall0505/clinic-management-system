cmake_minimum_required(VERSION 3.10...21)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(FLUTTER_VERSION "3.24.0")

project(runner LANGUAGES CXX)

set(BINARY_NAME "clinic_management")
set(APPLICATION_ID "com.example.clinic_management")

add_subdirectory(flutter "${CMAKE_CURRENT_BINARY_DIR}/flutter")

include_directories(.)

add_subdirectory("runner")
