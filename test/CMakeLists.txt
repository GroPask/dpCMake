cmake_minimum_required(VERSION 3.16.0...3.25.0)

project(Test VERSION 0.0.4 LANGUAGES CXX)

include(../dpCMake.cmake)

dp_configure_global(
    USE_FOLDERS
    DEFAULT_CONFIGURATIONS Debug Release
    GENERATED_SOURCE_GROUP Generated
    DEPENDENCIES_TARGETS_FOLDER Dependencies
)

function (patchFmt fmtSrcDir)
    dp_patch_file(${fmtSrcDir}/CMakeLists.txt ADD_LINE_BEFORE "option(FMT_DOC" [=[option(DP_CMAKE_TEST_OPTION_IN_FMT "" ON)]=])
endfunction ()

function (configureFmt)
    option(DP_CMAKE_TEST_CONFIGURE_FMT_OPTION "" ON)
endfunction ()

dp_download_and_add_dependency(
    URL https://github.com/fmtlib/fmt/archive/refs/tags/9.1.0.zip
    PATCH_FUNC patchFmt
    CONFIGURE_FUNC configureFmt
)

if (NOT DP_CMAKE_TEST_OPTION_IN_FMT)
    message(FATAL_ERROR "dpCMake: PATCH_FUNC is not working" )
endif ()

if (NOT DP_CMAKE_TEST_CONFIGURE_FMT_OPTION)
    message(FATAL_ERROR "dpCMake: CONFIGURE_FUNC is not working" )
endif ()

add_executable(${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME} fmt::fmt)
add_subdirectory(src)

if (WIN32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE DP_CMAKE_TEST_WIN32)
endif ()

dp_configure_target(${PROJECT_NAME}
    DP_WARNINGS
    VS_STARTUP_PROJECT
    WIN32_RELEASE
    AUTO_SOURCE_GROUP
)

dp_target_find_source(absoluteMainCpp ${PROJECT_NAME} "main.cpp")
dp_assert(${absoluteMainCpp} STREQUAL "src/main.cpp")

enable_testing()
add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
