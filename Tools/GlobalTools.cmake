include_guard()

function (dp_set_default_configurations)
    if (NOT DEFINED CMAKE_BUILD_TYPE AND NOT DEFINED ENV{CMAKE_BUILD_TYPE})
        set(CMAKE_CONFIGURATION_TYPES ${ARGN} CACHE STRING INTERNAL FORCE)
    elseif (DEFINED CMAKE_BUILD_TYPE)
        set(CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE} CACHE STRING INTERNAL FORCE)
    else ()
        set(CMAKE_CONFIGURATION_TYPES $ENV{CMAKE_BUILD_TYPE} CACHE STRING INTERNAL FORCE)
    endif ()
endfunction ()

function (dp_set_use_folders)
    set_property(GLOBAL PROPERTY USE_FOLDERS ON)    
endfunction ()

function (dp_set_generated_source_group generatedSourceGroup)
    set_property(GLOBAL PROPERTY AUTOGEN_SOURCE_GROUP ${generatedSourceGroup})
endfunction ()

function (dp_set_dependencies_targets_folder folder)
    set_property(GLOBAL PROPERTY DP_DEPENDENCIES_TARGETS_FOLDER ${folder})  
endfunction ()
