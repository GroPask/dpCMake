include(FetchContent)

FetchContent_Declare(dpCMake
    GIT_REPOSITORY https://github.com/GroPask/dpCMake.git
    GIT_TAG 0.0.1
)
FetchContent_MakeAvailable(dpCMake)

include(${dpcmake_SOURCE_DIR}/dpCMake.cmake)