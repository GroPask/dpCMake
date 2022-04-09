##############################################################
# dp_conan_vulkan_validation_layers_get_dirs
function (dp_conan_vulkan_validation_layers_get_dirs debugDirVar releaseDirVar)
    dp_conan_get_dirs_from_include(CONAN_PKG::vulkan-validationlayers debugDir releaseDir)

    set(${debugDirVar} ${debugDir} PARENT_SCOPE)
    set(${releaseDirVar} ${releaseDir} PARENT_SCOPE)
endfunction ()

##############################################################
# dp_conan_vulkan_validation_layers_setup_dll_copy
function (dp_conan_vulkan_validation_layers_setup_dll_copy target)
    dp_conan_vulkan_validation_layers_get_dirs(debugDir releaseDir)

    dp_conan_setup_all_bin_copy(${target} ${debugDir} ${releaseDir})
endfunction ()