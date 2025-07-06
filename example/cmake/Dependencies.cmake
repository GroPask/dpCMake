dp_download_and_add_dependency(URL https://github.com/fmtlib/fmt/archive/refs/tags/9.1.0.zip)

function (patchSpdlog spdlogSrcDir)
    dp_patch_file(${spdlogSrcDir}/CMakeLists.txt ADD_BEFORE "set(CMAKE_BUILD_TYPE" "#")
endfunction ()

option(SPDLOG_FMT_EXTERNAL "" ON)

dp_download_and_add_dependency(
    URL https://github.com/gabime/spdlog/archive/refs/tags/v1.11.0.zip
    PATCH_FUNC patchSpdlog
)
