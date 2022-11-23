cmake_minimum_required(VERSION 3.16.0...3.25.0)

project(Example VERSION 0.0.1 LANGUAGES CXX)

include(FetchContent)
FetchContent_Declare(dpCMake URL https://github.com/GroPask/dpCMake/archive/refs/tags/v0.0.3.zip)
FetchContent_MakeAvailable(dpCMake)
include(${dpcmake_SOURCE_DIR}/dpCMake.cmake)

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
