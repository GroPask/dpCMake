# mklink CMakeUserPresets.json C:\Users\Damien\Desktop\MyPrivGit\CMake\CMakeUserPresets.json

function (dp_get_conan_lib)
    PersonalCheckConanAvailable()

    foreach (arg IN LISTS ARGN)
        dp_check_is_one_of_dp_recipes(${arg})
    endforeach ()

    conan_cmake_run(
        REQUIRES ${ARGN}
        BASIC_SETUP CMAKE_TARGETS
        BUILD missing
    )

    #conan_cmake_run(
    #    REQUIRES ${ARGN}
    #    BASIC_SETUP CMAKE_TARGETS
    #    BUILD missing
    #    IMPORTS "bin, *.dll -> ./bin"
    #)


    #conan_cmake_configure(
    #    REQUIRES ${ARGN}
    #    GENERATORS cmake_find_package
    #)
    #
    #conan_cmake_autodetect(settings)
    #
    #conan_cmake_install(
    #    PATH_OR_REFERENCE .
    #    BUILD missing
    #    SETTINGS ${settings}
    #)

    #foreach (arg IN LISTS ARGN)
    #    string(REGEX MATCH "^(.)(.*)/.*$" fullRegexMatch ${arg})
    #    string(TOUPPER ${CMAKE_MATCH_1} firstLetter)
    #
    #    #find_package(${firstLetter}${CMAKE_MATCH_2})
    #endforeach ()
endfunction ()

function (UseConanLib_Old)
    PersonalCheckConanAvailable()

    foreach (arg IN LISTS ARGN)
        if (${arg} STREQUAL nana)            
            ExportPersonnalRecipeIfNeeded("PersonnalRecipes/nana" "nana")

            conan_cmake_run(
                REQUIRES nana/hotfix-1.7.4@PersonnalRecipe/stable
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing
            )

        elseif (${arg} STREQUAL imgui-sfml)
            if (WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
                ExportPersonnalRecipeIfNeeded("Recipes/libpng/all" "libpng/1.6.37@PersonnalRecipe")

                conan_cmake_run(
                    REQUIRES
                        imgui-sfml/2.1@bincrafters/stable
                        libpng/1.6.37@PersonnalRecipe/stable # Libpng on server do not compil on Windows with Clang
                    OPTIONS sfml:audio=False # Because flac do not compil on Windows with Clang
                    BASIC_SETUP CMAKE_TARGETS
                    BUILD missing
                )
            else ()
                conan_cmake_run(
                    REQUIRES imgui-sfml/2.1@bincrafters/stable
                    BASIC_SETUP CMAKE_TARGETS
                    BUILD missing
                )
            endif ()
        elseif (${arg} STREQUAL wxwidgets)
            if (WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
                message(FATAL_ERROR "wxWidgets can't compil on Windows with Clang")
                # conan_cmake_run(
                #     REQUIRES wxwidgets/3.1.3@bincrafters/stable
                #     OPTIONS
                #         wxwidgets:tiff=off # because libtiff use xz_utils wich do not compil on Windows with Clang
                #         wxwidgets:stc=False # do not compil on Windows
                #     BASIC_SETUP CMAKE_TARGETS
                #     BUILD missing
                # )
            else ()
                conan_cmake_run(
                    REQUIRES wxwidgets/3.1.3@bincrafters/stable
                    BASIC_SETUP CMAKE_TARGETS
                    BUILD missing
                )
            endif ()
        elseif (${arg} STREQUAL Qt)
            conan_cmake_run(
                REQUIRES qt/6.0.0@bincrafters/stable
                BASIC_SETUP CMAKE_TARGETS
                IMPORTS "bin, *.dll -> ./bin"
                BUILD missing
            )
            # ExportPersonnalRecipeIfNeeded("Recipes/qt/all" "qt/5.15.0@PersonnalRecipe")
            # 
            # conan_cmake_run(
            #     REQUIRES qt/5.15.0@PersonnalRecipe/stable
            #     OPTIONS qt:widgets=True
            #     GENERATORS cmake_find_package_multi
            #     BUILD missing
            # )
            # 
            # list(APPEND CMAKE_PREFIX_PATH ${CMAKE_CURRENT_BINARY_DIR})
            # find_package(Qt5 REQUIRED COMPONENTS Widgets CONFIG)
            # 
            # set(CMAKE_AUTOMOC ON PARENT_SCOPE)
            # set(CMAKE_AUTORCC ON PARENT_SCOPE)
            # set(CMAKE_AUTOUIC ON PARENT_SCOPE)
        elseif (${arg} STREQUAL fmt)
            conan_cmake_run(
                REQUIRES fmt/7.1.3
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing
            )
        else ()
            conan_cmake_run(
                REQUIRES ${arg}
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing
            )
        endif ()
    endforeach ()
endfunction ()

##############################################################
# Robocopy example
# COMMAND (robocopy ${releaseDir}/DLLs $<TARGET_FILE_DIR:${target}>/Python/DLLs * /mt /e /NJH /NJS) & SET errorlevel="0"

