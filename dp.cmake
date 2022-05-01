include(FetchContent)

if (NOT DEFINED CMAKE_BUILD_TYPE AND NOT DEFINED ENV{CMAKE_BUILD_TYPE})
    set(CMAKE_CONFIGURATION_TYPES Debug Release CACHE STRING INTERNAL FORCE) # Forced to use global variable to do this
elseif (DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE} CACHE STRING INTERNAL FORCE) # Forced to use global variable to do this
else ()
    set(CMAKE_CONFIGURATION_TYPES $ENV{CMAKE_BUILD_TYPE} CACHE STRING INTERNAL FORCE) # Forced to use global variable to do this
endif ()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

#set(CMAKE_VERBOSE_MAKEFILE ON)

include(${CMAKE_CURRENT_LIST_DIR}/dpCompilerWarnings.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Conan/dpConan.cmake)

##############################################################
# Clang Tidy
option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)
if (ENABLE_CLANG_TIDY)
    find_program(CLANGTIDY clang-tidy HINTS "I:/Portable/winlibs-x86_64-posix-seh-gcc-10.2.0-llvm-11.0.0-mingw-w64-8.0.0-r5/mingw64/bin")
    if (CLANGTIDY)
        message(STATUS "clang-tidy found: ${CLANGTIDY})")
    
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
        
        set(CMAKE_CXX_CLANG_TIDY ${CLANGTIDY})
        configure_file(${CMAKE_CURRENT_LIST_DIR}/.clang-tidy ${CMAKE_BINARY_DIR}/.clang-tidy COPYONLY)
    else ()
        message(AUTHOR_WARNING "clang-tidy not found")
    endif ()
endif ()

##############################################################
# Include What You Use
#find_program(INCLUDE_WHAT_YOU_USE include-what-you-use HINTS "I:/Portable/include-what-you-use-0.8-x86-win32/bin")
#if (INCLUDE_WHAT_YOU_USE)
#    message(STATUS "include-what-you-use found: ${INCLUDE_WHAT_YOU_USE})")
#
#    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
#
#    set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE} --driver-mode=cl)
#else ()
#    message(AUTHOR_WARNING "include-what-you-use not found")
#endif ()

##############################################################
# dp_add_target
function (dp_add_target target targetType)
    set(options VS_STARTUP_PROJECT WIN32_IN_RELEASE ADD_PROJECT_PARENT_FOLDER REMOVE_TARGET_FIRST_PARENT_FOLDER)
    set(oneValueArgs ADDITIONAL_FOLDER)
    set(multiValueArgs)
    cmake_parse_arguments(MY_OPTIONS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (targetType STREQUAL "EXECUTABLE")
        add_executable(${target} ${MY_OPTIONS_UNPARSED_ARGUMENTS})
    elseif (targetType STREQUAL "LIBRARY")
        add_library(${target} ${MY_OPTIONS_UNPARSED_ARGUMENTS})
    elseif (targetType STREQUAL "CUSTOM")
        add_custom_target(${target} ${MY_OPTIONS_UNPARSED_ARGUMENTS})
    endif ()

    if (${MY_OPTIONS_VS_STARTUP_PROJECT})
        set_property(DIRECTORY ${PROJECT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${target})
    endif ()

    if (${MY_OPTIONS_WIN32_IN_RELEASE})
        if (WIN32)
            if (targetType STREQUAL "EXECUTABLE")
                set_target_properties(${target} PROPERTIES WIN32_EXECUTABLE $<IF:$<CONFIG:Debug>,false,true>)
            endif ()
        endif ()
    endif ()

    set(projectRootDir ${PROJECT_SOURCE_DIR})
    if (DEFINED DP_CMAKE_PROJECT_ROOT_DIR)
        set(projectRootDir ${DP_CMAKE_PROJECT_ROOT_DIR})
    endif ()

    set(folder "")
    if (${MY_OPTIONS_ADD_PROJECT_PARENT_FOLDER})
        string(REPLACE "/" ";" projectSourceList ${projectRootDir})
        list(POP_BACK projectSourceList projectParent)

        set(folder ${projectParent})
    endif ()

    if (${CMAKE_CURRENT_SOURCE_DIR} MATCHES "^${projectRootDir}.+")
        file(RELATIVE_PATH relativePathFromProject ${projectRootDir} ${CMAKE_CURRENT_SOURCE_DIR})

        set(newFolderPart ${relativePathFromProject})

        if (${MY_OPTIONS_REMOVE_TARGET_FIRST_PARENT_FOLDER})    
            if (relativePathFromProject MATCHES ".*/.*")
                string(REPLACE "/" ";" relativePathFromProjectParent ${relativePathFromProject})
                list(POP_BACK relativePathFromProjectParent relativePathFromProjectLastDir)
                string(REPLACE ";" "/" relativePathFromProjectParent "${relativePathFromProjectParent}")

                set(newFolderPart ${relativePathFromProjectParent})
            else ()
                set(newFolderPart "")
            endif ()
        endif ()

        if (NOT newFolderPart STREQUAL "")
            if (folder STREQUAL "")
                set(folder ${newFolderPart})
            else ()
                set(folder ${folder}/${newFolderPart})
            endif ()
        endif ()
    endif ()

    if (DEFINED MY_OPTIONS_ADDITIONAL_FOLDER)
        if (folder STREQUAL "")
            set(folder ${MY_OPTIONS_ADDITIONAL_FOLDER})
        else ()
            set(folder ${folder}/${MY_OPTIONS_ADDITIONAL_FOLDER})
        endif ()
    endif ()

    if (NOT folder STREQUAL "")
        set_target_properties(${target} PROPERTIES FOLDER ${folder})
    endif ()

    foreach (file ${MY_OPTIONS_UNPARSED_ARGUMENTS})
        get_filename_component(absoluteFile ${file} ABSOLUTE)
        if (${absoluteFile} MATCHES "^${CMAKE_CURRENT_BINARY_DIR}.*")
            source_group(TREE ${CMAKE_CURRENT_BINARY_DIR} FILES ${file})
        elseif (${absoluteFile} MATCHES "^${CMAKE_BINARY_DIR}.*")
            source_group(TREE ${CMAKE_BINARY_DIR} FILES ${file})
        else ()
            source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${file})
        endif ()
    endforeach ()

    if (NOT targetType STREQUAL "CUSTOM")
        set(COMPILE_OPTIONS_SCOPE PRIVATE)
        if (targetType STREQUAL "INTERFACE")
            set(COMPILE_OPTIONS_SCOPE INTERFACE)
        else ()
            SetTargetWarnings(${target})
        endif ()
    
        target_compile_features(${target} ${COMPILE_OPTIONS_SCOPE} cxx_std_23)
    
        # Clang doesn't link with pthread while MinGW do
        target_link_options(${target} ${COMPILE_OPTIONS_SCOPE} $<$<CXX_COMPILER_ID:Clang>:-pthread>)
    endif ()
endfunction ()

##############################################################
# dp_add_executable
function (dp_add_executable target)
    dp_add_target(${target} EXECUTABLE ${ARGN})
endfunction ()

##############################################################
# dp_add_library
function (dp_add_library target)
    dp_add_target(${target} LIBRARY ${ARGN})
endfunction ()

##############################################################
# dp_custom_target
function (dp_add_custom_target target)
    dp_add_target(${target} CUSTOM ${ARGN})
endfunction ()

##############################################################
# dp_add_relative_project
function (dp_add_relative_project relativePath)
    string(REPLACE "/" "_" fetchName ${relativePath})
    string(REPLACE ".." "_" fetchName ${fetchName})

    FetchContent_Declare(
        ${fetchName}
        SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${relativePath}"
    )

    FetchContent_MakeAvailable(${fetchName})
endfunction ()
