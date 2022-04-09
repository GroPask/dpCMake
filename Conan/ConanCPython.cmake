##############################################################
# dp_conan_cpython_get_dirs
function (dp_conan_cpython_get_dirs debugDirVar releaseDirVar)
    dp_conan_get_dirs_from_include(CONAN_PKG::cpython debugDir releaseDir)

    set(${debugDirVar} ${debugDir} PARENT_SCOPE)
    set(${releaseDirVar} ${releaseDir} PARENT_SCOPE)
endfunction ()

##############################################################
# dp_conan_cpython_setup_dll_copy
function (dp_conan_cpython_setup_dll_copy target)
    dp_conan_cpython_get_dirs(debugDir releaseDir)

    dp_conan_setup_copy_debug(${target} ${debugDir} "python39_d.dll" "python39_d.zip")
    dp_conan_setup_copy_release(${target} ${releaseDir} "python39.dll" "python39.zip")
endfunction ()