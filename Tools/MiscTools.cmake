include_guard()

function (dp_replace_in_file filePath)
    file(READ ${filePath} fileContent)

    list(LENGTH ARGN argumentCount)
    while (${argumentCount} GREATER 1)
        list(POP_FRONT ARGN toReplace replacing)
        list(LENGTH ARGN argumentCount)

        string(REPLACE ${toReplace} ${replacing} fileContent "${fileContent}")
    endwhile ()

    if (NOT ${argumentCount} EQUAL 0)
        message(AUTHOR_WARNING "dpCMake: Bad number of arguments given to dp_replace_in_file")
    endif ()

    file(WRITE ${filePath} ${fileContent})
endfunction ()

function (dp_get_targets_list outTargetsListVar)
    set(options RECURSE)
    set(oneValueArgs DIRECTORY)
    set(multiValueArgs)
    cmake_parse_arguments(DP_GET_TARGETS_LIST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
    if (DEFINED DP_GET_TARGETS_LIST_DIRECTORY)
        set(dir ${DP_GET_TARGETS_LIST_DIRECTORY})
    else ()
        set(dir ${CMAKE_CURRENT_SOURCE_DIR})
    endif ()

    get_property(targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)

    if (DP_GET_TARGETS_LIST_RECURSE)
        get_property(subDirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)

        foreach (subDir ${subDirs})
            dp_get_targets_list(subDirTargets DIRECTORY ${subDir} RECURSE)
            list(APPEND targets ${subDirTargets})
        endforeach ()

        list(REMOVE_DUPLICATES targets)
    endif ()

    set(${outTargetsListVar} ${targets} PARENT_SCOPE)
endfunction ()
