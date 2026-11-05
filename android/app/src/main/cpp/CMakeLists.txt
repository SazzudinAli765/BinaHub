cmake_minimum_required(VERSION 3.22.1)

project("bina_media_engine" LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(bina_media_engine SHARED
    media_engine_native.cpp
    shredder_native.cpp
)

find_library(log-lib log)
find_library(android-lib android)
find_library(jnigraphics-lib jnigraphics)

target_include_directories(bina_media_engine PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(bina_media_engine
    ${log-lib}
    ${android-lib}
    ${jnigraphics-lib}
)
