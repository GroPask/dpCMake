cmake_minimum_required(VERSION 3.16.0)

project(Example VERSION 0.0.1 LANGUAGES CXX)

include(cmake/Dependencies.cmake)

dp_configure_global(
    USE_FOLDERS
    DEFAULT_CONFIGURATIONS Debug Release
    GENERATED_SOURCE_GROUP Generated
)

add_executable(${PROJECT_NAME})

add_subdirectory(cmake)
add_subdirectory(src)

dp_configure_target(${PROJECT_NAME}
    DP_WARNINGS
    VS_STARTUP_PROJECT
    WIN32_RELEASE
    AUTO_SOURCE_GROUP
)