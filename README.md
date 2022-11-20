# dpCMake

## Introduction
Simple CMake helper library.

## Reference
List of all available features.

Named arguments are generally optionals.

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
    DEPENDENCIES_TARGETS_FOLDER Dependencies
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
#### Dependency tools
```cmake
dp_add_relative_directory("../MyRelativeProject")

dp_download_dependency(                                 # Or dp_download_and_add_dependency
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git    # Or URL, SVN_REPOSITORY, HG_REPOSITORY, CVS_REPOSITORY
    GIT_TAG 9.1.0                                       # Or anything supported by FetchContent_Declare
    PATCH_SRC_FUNC fmtPathFunc
    ALREADY_POPULATED_VAR fmtWasAlreadyPopulated
    SRC_DIR_VAR fmtSrcDir
    BIN_DIR_VAR fmtBinDir
)
```

#### Misc tools
```cmake
dp_replace_in_file(filePath "ToReplace" "ReplacingString")

dp_get_targets_list(
    targetsList
    DIRECTORY mySubDir # Default to CMAKE_CURRENT_SOURCE_DIR
    RECURSE
)
```
