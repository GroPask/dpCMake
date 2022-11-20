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
