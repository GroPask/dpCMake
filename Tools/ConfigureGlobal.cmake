include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/GlobalTools.cmake)

function (dp_configure_global)
    set(options USE_FOLDERS)
    set(oneValueArgs GENERATED_SOURCE_GROUP DEPENDENCIES_TARGETS_FOLDER)
    set(multiValueArgs DEFAULT_CONFIGURATIONS)
    cmake_parse_arguments(DP_CONFIGURE_GLOBAL_OPTIONS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (DEFINED DP_CONFIGURE_GLOBAL_OPTIONS_DEFAULT_CONFIGURATIONS)
        dp_global_set_default_configurations(${DP_CONFIGURE_GLOBAL_OPTIONS_DEFAULT_CONFIGURATIONS})
    endif ()

    if (DP_CONFIGURE_GLOBAL_OPTIONS_USE_FOLDERS)
        dp_global_use_folders()
    endif ()

    if (DEFINED DP_CONFIGURE_GLOBAL_OPTIONS_GENERATED_SOURCE_GROUP)
        dp_global_set_generated_source_group(${DP_CONFIGURE_GLOBAL_OPTIONS_GENERATED_SOURCE_GROUP})
    endif ()

    if (DEFINED DP_CONFIGURE_GLOBAL_OPTIONS_DEPENDENCIES_TARGETS_FOLDER)
        dp_set_dependencies_targets_folder(${DP_CONFIGURE_GLOBAL_OPTIONS_DEPENDENCIES_TARGETS_FOLDER})
    endif ()
endfunction ()
