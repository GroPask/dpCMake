include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/TargetTools.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Warnings.cmake)

function (dp_configure_target target)
    set(options WARNINGS RELEASE_WIN32 VS_STARTUP_PROJECT AUTO_SOURCE_GROUP)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(DP_CONFIGURE_TARGET_OPTIONS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (DP_CONFIGURE_TARGET_OPTIONS_ARNINGS)
        dp_target_configure_warnings(${target})
    endif ()

    if (DP_CONFIGURE_TARGET_OPTIONS_RELEASE_WIN32)
        dp_target_set_win32_executable_in_realease(${target})
    endif ()

    if (DP_CONFIGURE_TARGET_OPTIONS_VS_STARTUP_PROJECT)
        dp_target_set_vs_startup_project(${target})
    endif ()

    if (DP_CONFIGURE_TARGET_OPTIONS_AUTO_SOURCE_GROUP)
        dp_target_auto_source_group(${target})
    endif ()
endfunction ()