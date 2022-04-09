##############################################################
# dp_conan_libclang_get_dirs
function (dp_conan_libclang_get_dirs debugDirVar releaseDirVar)
    dp_conan_get_dirs_from_include(CONAN_PKG::libclang debugDir releaseDir)

    set(${debugDirVar} ${debugDir} PARENT_SCOPE)
    set(${releaseDirVar} ${releaseDir} PARENT_SCOPE)
endfunction ()

##############################################################
# dp_conan_libclang_setup_dll_copy
function (dp_conan_libclang_setup_dll_copy target)
    dp_conan_libclang_get_dirs(debugDir releaseDir)

    dp_conan_setup_copy(${target} ${debugDir} ${releaseDir} "bin/libclang.dll")
endfunction ()