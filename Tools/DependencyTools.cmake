include_guard()

include(FetchContent)

function (_dp_compute_fetch_content_name outFetchContentNameVar originalPath)
    set(fetchContentName ${originalPath})

    string(REGEX REPLACE "^https://" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE "^http://" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE "^github.com/" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".git$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".zip$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".tar.gz$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".tar.qz$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".tar$" "" fetchContentName "${fetchContentName}")
    string(REPLACE "archive/refs/heads/" "" fetchContentName "${fetchContentName}")
    string(REPLACE "archive/refs/tags/" "" fetchContentName "${fetchContentName}")
    string(REPLACE "/" "_" fetchContentName "${fetchContentName}")
    string(REPLACE "." "_" fetchContentName "${fetchContentName}")
    string(TOLOWER "${fetchContentName}" fetchContentName)

    set(${outFetchContentNameVar} ${fetchContentName} PARENT_SCOPE)
endfunction ()

function (dp_add_relative_directory relativePath)
    set(options)
    set(oneValueArgs BIN_DIR_VAR)
    set(multiValueArgs)
    cmake_parse_arguments(DP_ADD_RELATIVE_DIRECTORY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    _dp_compute_fetch_content_name(fetchContentName ${relativePath})
    
    set(srcDir ${CMAKE_CURRENT_SOURCE_DIR})
    cmake_path(APPEND srcDir ${relativePath})
    cmake_path(NORMAL_PATH srcDir)
    
    set(binDir ${CMAKE_BINARY_DIR})
    cmake_path(APPEND binDir _relative_deps)
    cmake_path(APPEND binDir ${fetchContentName}-build)
    cmake_path(NORMAL_PATH binDir)
    
    add_subdirectory(${srcDir} ${binDir})

    if (DEFINED DP_ADD_RELATIVE_DIRECTORY_BIN_DIR_VAR)   
        set(${DP_ADD_RELATIVE_DIRECTORY_BIN_DIR_VAR} ${binDir} PARENT_SCOPE)
    endif ()
endfunction ()

function (dp_add_relative_dependency relativePath)
    set(options)
    set(oneValueArgs BIN_DIR_VAR)
    set(multiValueArgs)
    cmake_parse_arguments(DP_ADD_RELATIVE_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    dp_add_relative_directory(${relativePath}
        BIN_DIR_VAR dependencyBinDir
    )
    
    set(relativeDependencyPath ${CMAKE_CURRENT_SOURCE_DIR})
    cmake_path(APPEND relativeDependencyPath ${relativePath})
    cmake_path(NORMAL_PATH relativeDependencyPath)
    
    _dp_cmake_manage_dependency_dir(${relativeDependencyPath})
    
    if (DEFINED DP_ADD_RELATIVE_DEPENDENCY_BIN_DIR_VAR)
        set(${DP_ADD_RELATIVE_DEPENDENCY_BIN_DIR_VAR} ${dependencyBinDir} PARENT_SCOPE)
    endif ()
endfunction ()

function (dp_download_dependency)
    set(options)
    set(oneValueArgs URL GIT_REPOSITORY SVN_REPOSITORY HG_REPOSITORY CVS_REPOSITORY PATCH_FUNC ALREADY_POPULATED_VAR SRC_DIR_VAR BIN_DIR_VAR)
    set(multiValueArgs)
    cmake_parse_arguments(DP_DOWNLOAD_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (DEFINED DP_DOWNLOAD_DEPENDENCY_URL)
        set(downloadMethod URL)
        set(downloadAddress ${DP_DOWNLOAD_DEPENDENCY_URL})
    elseif (DEFINED DP_DOWNLOAD_DEPENDENCY_GIT_REPOSITORY)
        set(downloadMethod GIT_REPOSITORY)
        set(downloadAddress ${DP_DOWNLOAD_DEPENDENCY_GIT_REPOSITORY})
    elseif (DEFINED DP_DOWNLOAD_DEPENDENCY_SVN_REPOSITORY)
        set(downloadMethod SVN_REPOSITORY)
        set(downloadAddress ${DP_DOWNLOAD_DEPENDENCY_SVN_REPOSITORY})
    elseif (DEFINED DP_DOWNLOAD_DEPENDENCY_HG_REPOSITORY)
        set(downloadMethod HG_REPOSITORY)
        set(downloadAddress ${DP_DOWNLOAD_DEPENDENCY_HG_REPOSITORY})
    elseif (DEFINED DP_DOWNLOAD_DEPENDENCY_CVS_REPOSITORY)
        set(downloadMethod CVS_REPOSITORY)
        set(downloadAddress ${DP_DOWNLOAD_DEPENDENCY_CVS_REPOSITORY})
    else ()
        message(AUTHOR_WARNING "dpCMake: No download method given to dp_download_dependency")
        return()
    endif ()

    _dp_compute_fetch_content_name(fetchContentName ${downloadAddress})

    FetchContent_Declare(${fetchContentName}
            ${downloadMethod} ${downloadAddress}
            QUIET
            SOURCE_DIR ${srcDir}
            SUBBUILD_DIR ${subBinDir}
            BINARY_DIR ${binDir}
            ${DP_DOWNLOAD_DEPENDENCY_UNPARSED_ARGUMENTS}
    )
    
    set(srcDir ${CMAKE_BINARY_DIR})
    cmake_path(APPEND srcDir _deps)
    cmake_path(APPEND srcDir ${fetchContentName}-src)
        
    set(subBinDir ${CMAKE_BINARY_DIR})
    cmake_path(APPEND subBinDir _deps)
    cmake_path(APPEND subBinDir ${fetchContentName}-subbuild)
        
    set(binDir ${CMAKE_BINARY_DIR})
    cmake_path(APPEND binDir _deps)
    cmake_path(APPEND binDir ${fetchContentName}-build)

    if (NOT ${fetchContentName}_POPULATED)
        set(${fetchContentName}_POPULATED ON CACHE INTERNAL "")
    
        set(alreadyPopulated false)
        
        message(STATUS "Downloading ${downloadAddress}")
    
        FetchContent_Populate(${fetchContentName}
            ${downloadMethod} ${downloadAddress}
            QUIET
            SOURCE_DIR ${srcDir}
            SUBBUILD_DIR ${subBinDir}
            BINARY_DIR ${binDir}
            ${DP_DOWNLOAD_DEPENDENCY_UNPARSED_ARGUMENTS}
        )

        if (DEFINED DP_DOWNLOAD_DEPENDENCY_PATCH_FUNC)
            set(patchMarkFile "${srcDir}/patchedByDpCMake.junk")
            if (NOT EXISTS ${patchMarkFile})
                cmake_language(CALL ${DP_DOWNLOAD_DEPENDENCY_PATCH_FUNC} ${srcDir})
                file(TOUCH ${patchMarkFile})
            endif ()   
        endif ()
    else ()
        set(alreadyPopulated TRUE)
    endif ()

    if (DEFINED DP_DOWNLOAD_DEPENDENCY_ALREADY_POPULATED_VAR)
        set(${DP_DOWNLOAD_DEPENDENCY_ALREADY_POPULATED_VAR} ${alreadyPopulated} PARENT_SCOPE)
    endif ()

    if (DEFINED DP_DOWNLOAD_DEPENDENCY_SRC_DIR_VAR)
        set(${DP_DOWNLOAD_DEPENDENCY_SRC_DIR_VAR} ${srcDir} PARENT_SCOPE)
    endif ()

    if (DEFINED DP_DOWNLOAD_DEPENDENCY_BIN_DIR_VAR)   
        set(${DP_DOWNLOAD_DEPENDENCY_BIN_DIR_VAR} ${binDir} PARENT_SCOPE)
    endif ()
endfunction ()

function (dp_download_and_add_dependency)
    set(options)
    set(oneValueArgs ALREADY_POPULATED_VAR SRC_DIR_VAR BIN_DIR_VAR)
    set(multiValueArgs)
    cmake_parse_arguments(DP_DOWNLOAD_AND_ADD_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    dp_download_dependency(
        ${DP_DOWNLOAD_AND_ADD_DEPENDENCY_UNPARSED_ARGUMENTS}
        ALREADY_POPULATED_VAR dependencyWasAlreadyPopulated
        SRC_DIR_VAR dependencySrcDir
        BIN_DIR_VAR dependencyBinDir
    )

    if (${CMAKE_VERSION} VERSION_LESS "3.25.0") 
        add_subdirectory(${dependencySrcDir} ${dependencyBinDir} EXCLUDE_FROM_ALL)
    else ()
        add_subdirectory(${dependencySrcDir} ${dependencyBinDir} EXCLUDE_FROM_ALL SYSTEM)
    endif ()
    
    _dp_cmake_manage_dependency_dir(${dependencySrcDir})

    if (DEFINED DP_DOWNLOAD_AND_ADD_DEPENDENCY_ALREADY_POPULATED_VAR)
        set(${DP_DOWNLOAD_AND_ADD_DEPENDENCY_ALREADY_POPULATED_VAR} ${dependencyWasAlreadyPopulated} PARENT_SCOPE)
    endif ()

    if (DEFINED DP_DOWNLOAD_AND_ADD_DEPENDENCY_SRC_DIR_VAR)
        set(${DP_DOWNLOAD_AND_ADD_DEPENDENCY_SRC_DIR_VAR} ${dependencySrcDir} PARENT_SCOPE)
    endif ()

    if (DEFINED DP_DOWNLOAD_AND_ADD_DEPENDENCY_BIN_DIR_VAR)   
        set(${DP_DOWNLOAD_AND_ADD_DEPENDENCY_BIN_DIR_VAR} ${dependencyBinDir} PARENT_SCOPE)
    endif ()
endfunction ()
