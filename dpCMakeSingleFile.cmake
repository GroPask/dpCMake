include(FetchContent)

FetchContent_Declare(dpCMake URL https://github.com/GroPask/dpCMake/archive/refs/tags/v0.0.4.zip)
FetchContent_MakeAvailable(dpCMake)

include(${dpcmake_SOURCE_DIR}/dpCMake.cmake)
