cmake_minimum_required(VERSION 3.10)
project(linuxfetch VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(linuxfetch linuxfetch.cpp)

target_include_directories(linuxfetch PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_link_libraries(linuxfetch)
endif()

install(TARGETS linuxfetch DESTINATION bin)
