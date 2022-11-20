include_guard()

function (dp_compute_fetch_content_name outFetchContentNameVar originalPath)
    set(fetchContentName ${originalPath})

    string(REGEX REPLACE "^https://" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE "^http://" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".git$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".zip$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".tar.gz$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".tar.qz$" "" fetchContentName "${fetchContentName}")
    string(REGEX REPLACE ".tar$" "" fetchContentName "${fetchContentName}")
    string(REPLACE "/" "_" fetchContentName "${fetchContentName}")
    string(REPLACE "." "_" fetchContentName "${fetchContentName}")
    string(TOLOWER "${fetchContentName}" fetchContentName)

    set(${outFetchContentNameVar} ${fetchContentName} PARENT_SCOPE)
endfunction ()

function (dp_add_relative_directory relativePath)
    dp_compute_fetch_content_name(fetchContentName ${relativePath})

    FetchContent_Declare(${fetchContentName}
        SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${relativePath}"
    )

    FetchContent_MakeAvailable(${fetchContentName})
endfunction ()
