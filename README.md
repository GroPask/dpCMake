# dpCMake

## Introduction
Simple CMake helper library.

## Examples

#### Getting dpCMake
```cmake
include(FetchContent)

FetchContent_Declare(dpCMake
    GIT_REPOSITORY https://github.com/GroPask/dpCMake.git
    GIT_TAG 0.0.1
)
FetchContent_MakeAvailable(dpCMake)

include(${dpcmake_SOURCE_DIR}/dpCMake.cmake)
```

#### Global configuration
```cmake
dp_configure_global(
    USE_FOLDERS
    DEFAULT_CONFIGURATIONS Debug Release
    GENERATED_SOURCE_GROUP Generated
)
```

#### Target configuration
```cmake
dp_configure_target(target
    DP_WARNINGS
    VS_STARTUP_PROJECT
    WIN32_RELEASE
    AUTO_SOURCE_GROUP
)
```
