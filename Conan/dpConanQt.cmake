##############################################################
# dp_conan_qt_get_dirs
function (dp_conan_qt_get_dirs ConanQtDebugDirVar ConanQtReleaseDirVar)
    get_target_property(QtLinkedLibs CONAN_PKG::qt INTERFACE_LINK_LIBRARIES)

    foreach(QtLib ${QtLinkedLibs})
        if(${QtLib} MATCHES "Qt")
            if (${QtLib} MATCHES "Corerelease")
                get_target_property(LOC ${QtLib} IMPORTED_LOCATION)

                string(REGEX MATCH "^(.*)/lib/([^/]*).lib$" fullRegexMatch ${LOC})
                set(${ConanQtReleaseDirVar} ${CMAKE_MATCH_1} PARENT_SCOPE)

                if(DEFINED ${ConanQtDebugDirVar})
                    break()
                endif()
            elseif (${QtLib} MATCHES "Coreddebug")
                get_target_property(LOC ${QtLib} IMPORTED_LOCATION)

                string(REGEX MATCH "^(.*)/lib/([^/]*).lib$" fullRegexMatch ${LOC})
                set(${ConanQtDebugDirVar} ${CMAKE_MATCH_1} PARENT_SCOPE)

                if(DEFINED ${ConanQtReleaseDirVar})
                    break()
                endif()
            endif()
        endif()
    endforeach()
endfunction ()

set(CONAN_QT_GENERATED_PREFIX Generated)

##############################################################
## Copy From Qt CMake Files                                 ##
##############################################################
# macro used to create the names of output files preserving relative dirs
macro(_qt_internal_make_output_file infile prefix ext outfile )
    string(LENGTH ${CMAKE_CURRENT_BINARY_DIR} _binlength)
    string(LENGTH ${infile} _infileLength)
    set(_checkinfile ${CMAKE_CURRENT_SOURCE_DIR})
    if(_infileLength GREATER _binlength)
        string(SUBSTRING "${infile}" 0 ${_binlength} _checkinfile)
        if(_checkinfile STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
            file(RELATIVE_PATH rel ${CMAKE_CURRENT_BINARY_DIR} ${infile})
        else()
            file(RELATIVE_PATH rel ${CMAKE_CURRENT_SOURCE_DIR} ${infile})
        endif()
    else()
        file(RELATIVE_PATH rel ${CMAKE_CURRENT_SOURCE_DIR} ${infile})
    endif()
    if(WIN32 AND rel MATCHES "^([a-zA-Z]):(.*)$") # absolute path
        set(rel "${CMAKE_MATCH_1}_${CMAKE_MATCH_2}")
    endif()
    set(_outfile "${CMAKE_CURRENT_BINARY_DIR}/${CONAN_QT_GENERATED_PREFIX}/${rel}")
    string(REPLACE ".." "__" _outfile ${_outfile})
    get_filename_component(outpath ${_outfile} PATH)
    if(CMAKE_VERSION VERSION_LESS "3.14")
        get_filename_component(_outfile_ext ${_outfile} EXT)
        get_filename_component(_outfile_ext ${_outfile_ext} NAME_WE)
        get_filename_component(_outfile ${_outfile} NAME_WE)
        string(APPEND _outfile ${_outfile_ext})
    else()
        get_filename_component(_outfile ${_outfile} NAME_WLE)
    endif()
    file(MAKE_DIRECTORY ${outpath})
    set(${outfile} ${outpath}/${prefix}${_outfile}.${ext})
endmacro()

macro(_qt_internal_get_moc_flags _moc_flags)
    set(${_moc_flags})
    get_directory_property(_inc_DIRS INCLUDE_DIRECTORIES)

    if(CMAKE_INCLUDE_CURRENT_DIR)
        list(APPEND _inc_DIRS ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    foreach(_current ${_inc_DIRS})
        if("${_current}" MATCHES "\\.framework/?$")
            string(REGEX REPLACE "/[^/]+\\.framework" "" framework_path "${_current}")
            set(${_moc_flags} ${${_moc_flags}} "-F${framework_path}")
        else()
            set(${_moc_flags} ${${_moc_flags}} "-I${_current}")
        endif()
    endforeach()

    get_directory_property(_defines COMPILE_DEFINITIONS)
    foreach(_current ${_defines})
        set(${_moc_flags} ${${_moc_flags}} "-D${_current}")
    endforeach()

    if(WIN32)
        set(${_moc_flags} ${${_moc_flags}} -DWIN32)
    endif()
    if (MSVC)
        set(${_moc_flags} ${${_moc_flags}} --compiler-flavor=msvc)
    endif()
endmacro()

# helper macro to set up a moc rule
function(_qt_internal_create_moc_command infile outfile moc_cmd moc_flags moc_options moc_target moc_depends)
    # Pass the parameters in a file.  Set the working directory to
    # be that containing the parameters file and reference it by
    # just the file name.  This is necessary because the moc tool on
    # MinGW builds does not seem to handle spaces in the path to the
    # file given with the @ syntax.
    get_filename_component(_moc_outfile_name "${outfile}" NAME)
    get_filename_component(_moc_outfile_dir "${outfile}" PATH)
    if(_moc_outfile_dir)
        set(_moc_working_dir WORKING_DIRECTORY ${_moc_outfile_dir})
    endif()
    set (_moc_parameters_file ${outfile}_parameters)
    set (_moc_parameters ${moc_flags} ${moc_options} -o "${outfile}" "${infile}")
    string (REPLACE ";" "\n" _moc_parameters "${_moc_parameters}")

    if(moc_target)
        set(_moc_parameters_file ${_moc_parameters_file}$<$<BOOL:$<CONFIGURATION>>:_$<CONFIGURATION>>)
        set(targetincludes "$<TARGET_PROPERTY:${moc_target},INCLUDE_DIRECTORIES>")
        set(targetdefines "$<TARGET_PROPERTY:${moc_target},COMPILE_DEFINITIONS>")

        set(targetincludes "$<$<BOOL:${targetincludes}>:-I$<JOIN:${targetincludes},\n-I>\n>")
        set(targetdefines "$<$<BOOL:${targetdefines}>:-D$<JOIN:${targetdefines},\n-D>\n>")

        file (GENERATE
            OUTPUT ${_moc_parameters_file}
            CONTENT "${targetdefines}${targetincludes}${_moc_parameters}\n"
        )

        set(targetincludes)
        set(targetdefines)
    else()
        file(WRITE ${_moc_parameters_file} "${_moc_parameters}\n")
    endif()

    set(_moc_extra_parameters_file @${_moc_parameters_file})
    add_custom_command(OUTPUT ${outfile}
                       COMMAND ${moc_cmd} ${_moc_extra_parameters_file}
                       DEPENDS ${infile} ${moc_depends}
                       ${_moc_working_dir}
                       VERBATIM)
    set_source_files_properties(${infile} PROPERTIES SKIP_AUTOMOC ON)
    set_source_files_properties(${outfile} PROPERTIES SKIP_AUTOMOC ON)
    set_source_files_properties(${outfile} PROPERTIES SKIP_AUTOUIC ON)
endfunction()

function(_qt6_parse_qrc_file infile _out_depends _rc_depends)
    get_filename_component(rc_path ${infile} PATH)

    if(EXISTS "${infile}")
        #  parse file for dependencies
        #  all files are absolute paths or relative to the location of the qrc file
        file(READ "${infile}" RC_FILE_CONTENTS)
        string(REGEX MATCHALL "<file[^<]+" RC_FILES "${RC_FILE_CONTENTS}")
        foreach(RC_FILE ${RC_FILES})
            string(REGEX REPLACE "^<file[^>]*>" "" RC_FILE "${RC_FILE}")
            if(NOT IS_ABSOLUTE "${RC_FILE}")
                set(RC_FILE "${rc_path}/${RC_FILE}")
            endif()
            set(RC_DEPENDS ${RC_DEPENDS} "${RC_FILE}")
        endforeach()
        # Since this cmake macro is doing the dependency scanning for these files,
        # let's make a configured file and add it as a dependency so cmake is run
        # again when dependencies need to be recomputed.
        _qt_internal_make_output_file("${infile}" "" "qrc.depends" out_depends)
        configure_file("${infile}" "${out_depends}" COPYONLY)
    else()
        # The .qrc file does not exist (yet). Let's add a dependency and hope
        # that it will be generated later
        set(out_depends)
    endif()

    set(${_out_depends} ${out_depends} PARENT_SCOPE)
    set(${_rc_depends} ${RC_DEPENDS} PARENT_SCOPE)
endfunction()

##############################################################
## End Copy From Qt CMake Files                             ##
##############################################################

##############################################################
# dp_conan_qt_wrap_src
function (dp_conan_qt_wrap_src OutVarList)
    get_target_property(InterfaceLinkLibraries CONAN_PKG::qt INTERFACE_LINK_LIBRARIES)
    list(REMOVE_ITEM InterfaceLinkLibraries "CONAN_LIB::qt_Qt5Core_qobjectrelease")
    list(REMOVE_ITEM InterfaceLinkLibraries "CONAN_LIB::qt_Qt5Core_qobjectddebug")
    list(REMOVE_ITEM InterfaceLinkLibraries "CONAN_LIB::qt_Qt6Core_qobjectrelease")
    list(REMOVE_ITEM InterfaceLinkLibraries "CONAN_LIB::qt_Qt6Core_qobjectddebug")
    set_target_properties(CONAN_PKG::qt PROPERTIES INTERFACE_LINK_LIBRARIES "${InterfaceLinkLibraries}")

    dp_conan_qt_get_dirs(ConanQtDebugDir ConanQtReleaseDir)

    _qt_internal_get_moc_flags(moc_flags)
    set(moc_options)
    set(moc_target)
    set(moc_depends)
    set(rcc_options)
    
    set(UIC ${ConanQtReleaseDir}/bin/uic.exe)
    set(RCC ${ConanQtReleaseDir}/bin/rcc.exe)
    set(MOC ${ConanQtReleaseDir}/bin/moc.exe)

    foreach(file ${ARGN})
        get_filename_component(fileExtension ${file} EXT)
        string(TOLOWER ${fileExtension} fileExtensionLower)

        get_filename_component(inFile ${file} ABSOLUTE)   

        if (fileExtensionLower STREQUAL ".ui")
            get_filename_component(outFileName ${file} NAME_WE)
            set(outFile ${CMAKE_CURRENT_BINARY_DIR}/${CONAN_QT_GENERATED_PREFIX}/ui_${outFileName}.h)

            add_custom_command(
                OUTPUT ${outFile}
                DEPENDS ${UIC}
                COMMAND ${UIC} ARGS -o ${outFile} ${inFile}
                MAIN_DEPENDENCY ${inFile}
                VERBATIM
            )
        elseif (fileExtensionLower STREQUAL ".qrc")
            get_filename_component(outFileName ${file} NAME_WE)
            set(outFile ${CMAKE_CURRENT_BINARY_DIR}/${CONAN_QT_GENERATED_PREFIX}/qrc_${outFileName}.cpp)

            _qt6_parse_qrc_file(${inFile} _out_depends _rc_depends)

            add_custom_command(
                OUTPUT ${outFile}
                COMMAND ${RCC}
                ARGS ${rcc_options} --name ${outFileName} --output ${outFile} ${inFile}
                MAIN_DEPENDENCY ${inFile}
                DEPENDS ${_rc_depends} "${_out_depends}" ${RCC}
                VERBATIM
            )
        elseif (fileExtensionLower STREQUAL ".h" OR fileExtensionLower STREQUAL ".hpp")            
            _qt_internal_make_output_file(${inFile} moc_ cpp outFile)
            _qt_internal_create_moc_command(${inFile} ${outFile} ${MOC} "${moc_flags}" "${moc_options}" "${moc_target}" "${moc_depends}")
        endif ()

        list(APPEND ${OutVarList} ${outFile})
    endforeach()

    set(${OutVarList} ${${OutVarList}} PARENT_SCOPE)
    set(CONAN_QT_GENERATED_ROOT ${CMAKE_CURRENT_BINARY_DIR}/${CONAN_QT_GENERATED_PREFIX} PARENT_SCOPE)
endfunction ()

##############################################################
# dp_conan_qt_setup_dll_copy
function (dp_conan_qt_setup_dll_copy target)
    dp_conan_qt_get_dirs(ConanQtDebugDir ConanQtReleaseDir)

    set(wantedModules)
    foreach (module ${ARGN})
        list(APPEND wantedModules ${module})
    endforeach ()

    # Copy main Qt dll
    file(GLOB AllDllInDebugBin ${ConanQtDebugDir}/bin/*.dll)

    foreach(DllInDebugBin ${AllDllInDebugBin})
        if(${DllInDebugBin} MATCHES "Qt[456]([^/]*)d.dll$")
            if (${CMAKE_MATCH_1} IN_LIST wantedModules)
                add_custom_command(
                    TARGET ${target} 
                    POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Debug>,copy_if_different;${DllInDebugBin};$<TARGET_FILE_DIR:${target}>,true>"
                    COMMAND_EXPAND_LISTS)
            endif()
        else()
            add_custom_command(
                TARGET ${target}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${DllInDebugBin} $<TARGET_FILE_DIR:${target}>)
        endif()
    endforeach()

    file(GLOB AllDllInReleaseBin ${ConanQtReleaseDir}/bin/*.dll)

    foreach(DllInReleaseBin ${AllDllInReleaseBin})
        if(${DllInReleaseBin} MATCHES "Qt[456]([^/]*[^d]).dll$")
            if (${CMAKE_MATCH_1} IN_LIST wantedModules)
                add_custom_command(
                    TARGET ${target} 
                    POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Release>,copy_if_different;${DllInReleaseBin};$<TARGET_FILE_DIR:${target}>,true>"
                    COMMAND_EXPAND_LISTS)
            endif()
        else()
            add_custom_command(
                TARGET ${target}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${DllInReleaseBin} $<TARGET_FILE_DIR:${target}>)
        endif()
    endforeach()

    # Copy Qt plugins
    set(PlatformsRelativeDir "plugins/platforms")

    add_custom_command(
        TARGET ${target} 
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Debug>,copy_if_different;${ConanQtDebugDir}/${PlatformsRelativeDir}/qwindowsd.dll;$<TARGET_FILE_DIR:${target}>/${PlatformsRelativeDir}/qwindowsd.dll,true>"
        COMMAND_EXPAND_LISTS)

    add_custom_command(
        TARGET ${target} 
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Release>,copy_if_different;${ConanQtReleaseDir}/${PlatformsRelativeDir}/qwindows.dll;$<TARGET_FILE_DIR:${target}>/${PlatformsRelativeDir}/qwindows.dll,true>"
        COMMAND_EXPAND_LISTS)

    set(StylesRelativeDir "plugins/styles")

    add_custom_command(
        TARGET ${target} 
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Debug>,copy_if_different;${ConanQtDebugDir}/${StylesRelativeDir}/qwindowsvistastyled.dll;$<TARGET_FILE_DIR:${target}>/${StylesRelativeDir}/qwindowsvistastyled.dll,true>"
        COMMAND_EXPAND_LISTS)

    add_custom_command(
        TARGET ${target} 
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E "$<IF:$<CONFIG:Release>,copy_if_different;${ConanQtReleaseDir}/${StylesRelativeDir}/qwindowsvistastyle.dll;$<TARGET_FILE_DIR:${target}>/${StylesRelativeDir}/qwindowsvistastyle.dll,true>"
        COMMAND_EXPAND_LISTS)

    # Get GlibDir
    get_target_property(GlibLinkedLibs CONAN_PKG::glib INTERFACE_LINK_LIBRARIES)

    foreach(GlibLib ${GlibLinkedLibs})
        if(${GlibLib} MATCHES "glib-2.0")
            get_target_property(LOC ${GlibLib} IMPORTED_LOCATION)

            string(REGEX MATCH "^(.*)/lib/([^/]*).lib$" fullRegexMatch ${LOC})
            set(ConanGlibDir ${CMAKE_MATCH_1})

            break()
        endif()
    endforeach()

    # Copy Glib dll
    add_custom_command(
        TARGET ${target} 
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E "copy_if_different;${ConanGlibDir}/bin/glib-2.0-0.dll;$<TARGET_FILE_DIR:${target}>/glib-2.0-0.dll"
        COMMAND_EXPAND_LISTS)
endfunction ()