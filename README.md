# dpCMake

## Introduction
Simple CMake helper library.

## Reference
List of all available features.

Named arguments are generally optionals.

#### Getting dpCMake
```cmake
include(FetchContent)

FetchContent_Declare(dpCMake URL https://github.com/GroPask/dpCMake/archive/refs/tags/v0.0.4.zip)
FetchContent_MakeAvailable(dpCMake)

include(${dpcmake_SOURCE_DIR}/dpCMake.cmake)
```

#### Global configuration
```cmake
dp_set_use_folders()
dp_set_default_configurations(Debug Release)
dp_set_generated_source_group(Generated)
dp_set_dependencies_targets_folder(Dependencies)

# Or

dp_configure_global(
    USE_FOLDERS
    DEFAULT_CONFIGURATIONS Debug Release
    GENERATED_SOURCE_GROUP Generated
    DEPENDENCIES_TARGETS_FOLDER Dependencies
)
```

#### Target configuration
```cmake
dp_target_configure_warnings(target)
dp_target_set_vs_startup_project(target)
dp_target_set_win32_executable_in_realease(target)
dp_target_auto_source_group(target)

# Or

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

dp_download_and_adddependency(
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git    # Or URL, SVN_REPOSITORY, HG_REPOSITORY, CVS_REPOSITORY
    GIT_TAG 9.1.0                                       # Or anything supported by FetchContent_Declare
    PATCH_FUNC patchFmt
    CONFIGURE_FUNC configureFmt
    ALREADY_POPULATED_VAR fmtWasAlreadyPopulated
    SRC_DIR_VAR fmtSrcDir
    BIN_DIR_VAR fmtBinDir
)
```

#### Misc tools
```cmake
dp_patch_file(filePath
    REPLACE "ToReplace" "ReplacingString"
    REMOVE "ToRemove"
    ADD_BEFORE "RefText" "ToAddBefore"
    ADD_AFTER "RefText" "ToAddAfter"
    ADD_LINE_BEFORE "RefText" "LineToAddBefore"
    ADD_LINE_AFTER "RefText" "LineToAddAfter"
    APPEND_LINE "LineToAppend"
)

dp_get_targets_list(
    targetsList
    DIRECTORY mySubDir # Default to CMAKE_CURRENT_SOURCE_DIR
    RECURSE
)
```

## License

dpCMake is licensed under the zlib License, see [LICENSE.md](https://github.com/GroPask/dpCMake/blob/main/LICENSE.md) for more information.
