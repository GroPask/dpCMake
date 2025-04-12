cmake_minimum_required(VERSION 3.16.0...3.25.0)

project(Example VERSION 0.0.4 LANGUAGES CXX)

include(../dpCMake.cmake)

dp_configure_global(
    USE_FOLDERS_IF_TOP_LEVEL
    DEFAULT_CONFIGURATIONS_IF_TOP_LEVEL Debug Release
    GENERATED_SOURCE_GROUP Generated
    DEPENDENCIES_TARGETS_FOLDER Dependencies
)

include(cmake/Dependencies.cmake)

add_executable(${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} spdlog::spdlog)

add_subdirectory(cmake)
add_subdirectory(src)

dp_configure_target(${PROJECT_NAME}
    DP_WARNINGS
    VS_STARTUP_PROJECT_IF_TOP_LEVEL
    AUTO_SOURCE_GROUP
)
