cmake_minimum_required(VERSION 3.16.0...3.25.0)

project(Test VERSION 0.0.1 LANGUAGES CXX)

include(../dpCMake.cmake)

dp_configure_global(
    USE_FOLDERS
    DEFAULT_CONFIGURATIONS Debug Release
    GENERATED_SOURCE_GROUP Generated
    DEPENDENCIES_TARGETS_FOLDER Dependencies
)

dp_download_and_add_dependency(URL https://github.com/fmtlib/fmt/archive/refs/tags/9.1.0.zip)

add_executable(${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} fmt::fmt)
add_subdirectory(src)

dp_configure_target(${PROJECT_NAME}
    DP_WARNINGS
    VS_STARTUP_PROJECT
    WIN32_RELEASE
    AUTO_SOURCE_GROUP
)

enable_testing()
add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
