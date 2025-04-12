include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/GlobalTools.cmake)

function (dp_configure_global)
    set(options USE_FOLDERS USE_FOLDERS_IF_TOP_LEVEL)
    set(oneValueArgs GENERATED_SOURCE_GROUP DEPENDENCIES_TARGETS_FOLDER)
    set(multiValueArgs DEFAULT_CONFIGURATIONS DEFAULT_CONFIGURATIONS_IF_TOP_LEVEL)
    cmake_parse_arguments(DP_CONFIGURE_GLOBAL_OPTIONS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (DEFINED DP_CONFIGURE_GLOBAL_OPTIONS_DEFAULT_CONFIGURATIONS)
        dp_set_default_configurations(${DP_CONFIGURE_GLOBAL_OPTIONS_DEFAULT_CONFIGURATIONS})
    endif ()

    if (DEFINED DP_CONFIGURE_GLOBAL_OPTIONS_DEFAULT_CONFIGURATIONS_IF_TOP_LEVEL)
        if (PROJECT_IS_TOP_LEVEL)
            dp_set_default_configurations(${DP_CONFIGURE_GLOBAL_OPTIONS_DEFAULT_CONFIGURATIONS_IF_TOP_LEVEL})
        endif ()
    endif ()

    if (DP_CONFIGURE_GLOBAL_OPTIONS_USE_FOLDERS)
        dp_set_use_folders()
    endif ()

    if (DP_CONFIGURE_GLOBAL_OPTIONS_USE_FOLDERS_IF_TOP_LEVEL)
        if (PROJECT_IS_TOP_LEVEL)
            dp_set_use_folders()
        endif ()
    endif ()

    if (DEFINED DP_CONFIGURE_GLOBAL_OPTIONS_GENERATED_SOURCE_GROUP)
        dp_set_generated_source_group(${DP_CONFIGURE_GLOBAL_OPTIONS_GENERATED_SOURCE_GROUP})
    endif ()

    if (DEFINED DP_CONFIGURE_GLOBAL_OPTIONS_DEPENDENCIES_TARGETS_FOLDER)
        dp_set_dependencies_targets_folder(${DP_CONFIGURE_GLOBAL_OPTIONS_DEPENDENCIES_TARGETS_FOLDER})
    endif ()
endfunction ()
