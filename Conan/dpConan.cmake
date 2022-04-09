# Create template recipe with : conan new hello/0.1 --template=cmake_lib
# For now Layout and ToolChain do not works for local recipe
# So we need to adapt the recipe and test package
# We also adapt our recipe to match the multiple version structure
# See ponder or tinyobjloader for most recent adapted recipe

# Example:
# conan new tinyobjloader/2.0.0rc9 --template=cmake_lib
# Remove Layout and ToolChain stuff
# Addapt recipe too match multiple version structure
# conan create ./all tinyobjloader/2.0.0rc9@dp/stable
# conan upload "tinyobjloader/2.0.0rc9@dp/stable" -r=dp-conan

# To export with builded
# conan upload "tinyobjloader/2.0.0rc9@dp/stable" --all -r=dp-conan

##############################################################
# dp_check_conan_available
function (dp_check_conan_available)
    if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
        message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
        file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/develop/conan.cmake" "${CMAKE_BINARY_DIR}/conan.cmake" TLS_VERIFY ON)
        #file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/v0.16.1/conan.cmake" "${CMAKE_BINARY_DIR}/conan.cmake" TLS_VERIFY ON)

        include(${CMAKE_BINARY_DIR}/conan.cmake)

        conan_check(REQUIRED)

        execute_process(
            COMMAND ${CONAN_CMD} remote list
            OUTPUT_VARIABLE REMOTE_LIST_OUTPUT
        )

        string(FIND "${REMOTE_LIST_OUTPUT}" "center.conan" existingRemote)
        if (${existingRemote} EQUAL -1)
            conan_add_remote(
                NAME conancenter
                URL https://center.conan.io
            )
        endif ()

        string(FIND "${REMOTE_LIST_OUTPUT}" "dp-conan" existingRemote)
        if (${existingRemote} EQUAL -1)
            conan_add_remote(
                NAME dp-conan
                INDEX 0
                URL http://213.32.17.231:9300
            )
        endif ()
    else ()
        include(${CMAKE_BINARY_DIR}/conan.cmake)
    endif ()
endfunction ()

set(PERSONAL_CONAN_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})

##############################################################
# dp_export_dp_recipe_if_needed
function (dp_export_dp_recipe_if_needed relativePath keyWord)
    execute_process(
        COMMAND ${CONAN_CMD} search ${keyWord} 
        OUTPUT_VARIABLE SEARCH_OUTPUT
    )
    
    if (SEARCH_OUTPUT)
        string(FIND ${SEARCH_OUTPUT} "Existing package recipes:" EXISTING)
        if (NOT ${EXISTING} EQUAL 0)    
            execute_process(COMMAND ${CONAN_CMD} export "${PERSONAL_CONAN_CMAKE_DIR}/${relativePath}")
        endif ()
    else ()
        execute_process(COMMAND ${CONAN_CMD} export "${PERSONAL_CONAN_CMAKE_DIR}/${relativePath}")
    endif ()
endfunction ()

##############################################################
# dp_check_is_dp_recipe
function (dp_check_is_dp_recipe maybeRecipe dpRecipeName dpRecipeFolder)
    if (${maybeRecipe} STREQUAL ${dpRecipeName})
        foreach (arg IN LISTS ARGN)
            dp_check_is_one_of_dp_recipes(${arg})
        endforeach ()

        dp_export_dp_recipe_if_needed(${dpRecipeFolder} ${dpRecipeName})
    endif ()
endfunction ()

##############################################################
# dp_check_is_one_of_dp_recipes
function (dp_check_is_one_of_dp_recipes conanLib)
    dp_check_is_dp_recipe(${conanLib} "cpython/3.9.3@dp_recipe/stable"          "dp_recipes/cpython")
    dp_check_is_dp_recipe(${conanLib} "fplbase/1.0.0@dp_recipe/stable"          "dp_recipes_wip/fplbase")
    dp_check_is_dp_recipe(${conanLib} "gtk/4.3.0@dp_recipe/pre_build"           "dp_recipes/gtk/4.3.0.pre_build")
    dp_check_is_dp_recipe(${conanLib} "gtkmm/4.0.1@dp_recipe/pre_build"         "dp_recipes/gtkmm/4.0.1.pre_build")
    dp_check_is_dp_recipe(${conanLib} "nana/hotfix-1.7.4@dp_recipe/stable"      "dp_recipes/nana")
    dp_check_is_dp_recipe(${conanLib} "p4api/2020.1@dp_recipe/stable"           "dp_recipes/p4api")
    dp_check_is_dp_recipe(${conanLib} "refl-cpp/0.12.1@dp_recipe/stable"        "dp_recipes/refl-cpp")
    dp_check_is_dp_recipe(${conanLib} "rttr/0.9.7@dp_recipe/stable"             "dp_recipes/rttr")
    dp_check_is_dp_recipe(${conanLib} "xlnt/1.5.0@dp_recipe/stable"             "dp_recipes/xlnt")

    # Wip
    #dp_check_is_dp_recipe(${conanLib} "libsass/3.6.4@dp_recipe/stable"      "dp_recipes_wip/libsass")
    #dp_check_is_dp_recipe(${conanLib} "sassc/3.6.1@dp_recipe/stable"        "dp_recipes_wip/sassc"                "libsass/3.6.4@dp_recipe/stable")
    #dp_check_is_dp_recipe(${conanLib} "gtk/4.3.0@dp_recipe/stable"          "dp_recipes_wip/gtk/4.3.0"            "sassc/3.6.1@dp_recipe/stable")
endfunction ()

##############################################################
# dp_get_conan_generate_conan_file
function (dp_get_conan_generate_conan_file_string outStringVar)
    set(stringVar "")

    string(APPEND stringVar "import os\n")
    string(APPEND stringVar "from conans import ConanFile, CMake\n")
    string(APPEND stringVar "class SuperProject(ConanFile):\n")
    string(APPEND stringVar "    settings = \"os\", \"compiler\", \"build_type\", \"arch\"\n")

    string(APPEND stringVar "    requires = ")
    set(first TRUE)
    foreach (arg IN LISTS ARGN)
        if (first)
            set(first FALSE)
        else ()
            string(APPEND stringVar ", ")
        endif ()

        string(APPEND stringVar "\"${arg}\"")
    endforeach ()
    string(APPEND stringVar "\n")

    string(APPEND stringVar "    default_options = \"qt:shared=True\", \"imgui:shared=True\", \"glad:shared=True\", \"glfw:shared=True\"\n")

    string(APPEND stringVar "    generators = \"cmake\"\n")
    string(APPEND stringVar "    def imports(self):\n")
    string(APPEND stringVar "        dest = os.getenv(\"CONAN_IMPORT_PATH\", \"bin\")\n")
    string(APPEND stringVar "        self.copy(\"*.dll\", dst=dest, src=\"bin\")\n")
    string(APPEND stringVar "        self.copy(\"*.dylib*\", dst=dest, src=\"lib\")\n")

    string(APPEND stringVar "        self.copy(\"python39*.dll\", dst=dest, src=\"\")\n") # For CPython
    string(APPEND stringVar "        self.copy(\"python39*.zip\", dst=dest, src=\"\")\n") # For CPython
    string(APPEND stringVar "        self.copy(\"gdbus.exe\", dst=dest, src=\"bin\")\n") # For Gtk
    string(APPEND stringVar "        self.copy(\"gdbus.exe\", dst=dest, src=\"tools/glib\")\n") # For Gtkmm
    string(APPEND stringVar "        self.copy(\"*\", dst=dest, src=\"res/archdatadir/plugins\")\n") # For Qt
    string(APPEND stringVar "        self.copy(\"*.json\", dst=dest, src=\"bin\")\n") # For VulkanValidationLayer
    string(APPEND stringVar "        self.copy(\"*.h\", dst=\"imguiBindings\", src=\"res/bindings\")\n") # For ImGui bindings
    string(APPEND stringVar "        self.copy(\"*.cpp\", dst=\"imguiBindings\", src=\"res/bindings\")\n") # For ImGui bindings

    set(${outStringVar} ${stringVar} PARENT_SCOPE)
endfunction ()

##############################################################
# dp_get_conan_lib
function (dp_get_conan_lib)
    set(options)
    set(oneValueArgs CONAN_IMPORT_PATH_PREFIX)
    set(multiValueArgs)
    cmake_parse_arguments(DP_CONAN_OPTIONS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    dp_check_conan_available()

    set(conanFilePath "${CMAKE_CURRENT_BINARY_DIR}/conanfile.py")

    dp_get_conan_generate_conan_file_string(conanFileWantedContent ${DP_CONAN_OPTIONS_UNPARSED_ARGUMENTS})

    set(shouldRerunConanInstall true)
    if (EXISTS ${conanFilePath})
        file(READ ${conanFilePath} conanFileContent)

        if (conanFileWantedContent STREQUAL conanFileContent)
            set(shouldRerunConanInstall false)
        endif ()
    endif ()

    set(CONAN_CMAKE_MULTI ON)

    if (${shouldRerunConanInstall})
        foreach (arg IN LISTS DP_CONAN_OPTIONS_UNPARSED_ARGUMENTS)
            dp_check_is_one_of_dp_recipes(${arg})
        endforeach ()

        file(WRITE ${conanFilePath} ${conanFileWantedContent})        

        #conan_cmake_run(
        #    CONANFILE ${conanFilePath}
        #    BASIC_SETUP CMAKE_TARGETS
        #    BUILD missing
        #)

        foreach(CMAKE_BUILD_TYPE ${CMAKE_CONFIGURATION_TYPES})
            if (DEFINED DP_CONAN_OPTIONS_CONAN_IMPORT_PATH_PREFIX)
                set(ENV{CONAN_IMPORT_PATH} ${DP_CONAN_OPTIONS_CONAN_IMPORT_PATH_PREFIX}${CMAKE_BUILD_TYPE})
            else ()
                set(ENV{CONAN_IMPORT_PATH} ${CMAKE_BUILD_TYPE})
            endif ()

            conan_cmake_settings(settings)

            old_conan_cmake_install(
                SETTINGS ${settings}
                CONANFILE ${conanFilePath}
                BUILD missing
            )
        endforeach()
    endif ()

    conan_load_buildinfo()
    conan_basic_setup(TARGETS)
endfunction ()

##############################################################
# dp_print_target_properties
execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)

string(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
string(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

function(dp_print_target_properties tgt)
    if(NOT TARGET ${tgt})
      message("There is no target named '${tgt}'")
      return()
    endif()

    foreach (prop ${CMAKE_PROPERTY_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
    # Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
    ### if(prop STREQUAL "LOCATION" OR prop MATCHES "^LOCATION_" OR prop MATCHES "_LOCATION$")
    ###     continue()
    ### endif()
        # message ("Checking ${prop}")
        get_property(propval TARGET ${tgt} PROPERTY ${prop} SET)
        if (propval)
            get_target_property(propval ${tgt} ${prop})
            message ("${tgt} ${prop} = ${propval}")
        endif()
    endforeach(prop)
endfunction()

##############################################################
# dp_conan_get_dirs_from_include
function (dp_conan_get_dirs_from_include lib debugDirVar releaseDirVar)
    get_target_property(includeDirs ${lib} INTERFACE_INCLUDE_DIRECTORIES)

    foreach(includeDir ${includeDirs})
        if (${includeDir} MATCHES "CONFIG:Release")
            string(REGEX MATCH "^(.*)>:(.*)/include>$" fullRegexMatch ${includeDir})

            set(${releaseDirVar} ${CMAKE_MATCH_2} PARENT_SCOPE)

            if(DEFINED ${debugDirVar})
                break()
            endif()
        elseif (${includeDir} MATCHES "CONFIG:Debug")
            string(REGEX MATCH "^(.*)>:(.*)/include>$" fullRegexMatch ${includeDir})

            set(${debugDirVar} ${CMAKE_MATCH_2} PARENT_SCOPE)

            if(DEFINED ${releaseDirVar})
                break()
            endif()
        endif()
    endforeach()
endfunction ()

##############################################################
# dp_conan_setup_all_bin_copy
function (dp_conan_setup_all_bin_copy target debugDir releaseDir)
    file(GLOB debugBinFiles "${debugDir}/bin/*")
    file(GLOB releaseBinFiles "${releaseDir}/bin/*")

    add_custom_command(
        TARGET ${target} 
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Debug>,copy_if_different;${debugBinFiles};$<TARGET_FILE_DIR:${target}>,true>"
        COMMAND_EXPAND_LISTS)

    add_custom_command(
        TARGET ${target} 
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Release>,copy_if_different;${releaseBinFiles};$<TARGET_FILE_DIR:${target}>,true>"
        COMMAND_EXPAND_LISTS)
endfunction ()

##############################################################
# dp_conan_setup_copy_debug
function (dp_conan_setup_copy_debug target debugDir)
    foreach (file ${ARGN})
        add_custom_command(
            TARGET ${target} 
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Debug>,copy_if_different;${debugDir}/${file};$<TARGET_FILE_DIR:${target}>,true>"
            COMMAND_EXPAND_LISTS)
    endforeach ()
endfunction ()

##############################################################
# dp_conan_setup_copy_release
function (dp_conan_setup_copy_release target releaseDir)
    foreach (file ${ARGN})
        add_custom_command(
            TARGET ${target} 
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Release>,copy_if_different;${releaseDir}/${file};$<TARGET_FILE_DIR:${target}>,true>"
            COMMAND_EXPAND_LISTS)
    endforeach ()
endfunction ()

##############################################################
# dp_conan_setup_copy
function (dp_conan_setup_copy target debugDir releaseDir)
    dp_conan_setup_copy_debug(${target} ${debugDir} ${ARGN})
    dp_conan_setup_copy_release(${target} ${releaseDir} ${ARGN})
endfunction ()

#include(${CMAKE_CURRENT_LIST_DIR}/ConanCPython.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/ConanLibClang.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/dpConanQt.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/ConanVulkan.cmake)

macro (dp_catch_discover_tests)
    dp_conan_get_dirs_from_include(CONAN_PKG::catch2 catch2DebugDir catch2ReleaseDir)
    list(APPEND CMAKE_MODULE_PATH "${catch2ReleaseDir}/lib/cmake/Catch2")

    include(Catch)
    
    catch_discover_tests(${ARGN})
endmacro ()
