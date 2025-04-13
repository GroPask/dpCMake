include_guard()

function (dp_target_set_win32_executable_in_realease target)
    set_target_properties(${target} PROPERTIES WIN32_EXECUTABLE $<IF:$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>,true,false>)
endfunction ()

function (dp_target_set_vs_startup_project target)
    set_property(DIRECTORY ${PROJECT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${target})
endfunction ()

function (dp_target_auto_source_group target)
    get_target_property(sources ${target} SOURCES)

    get_target_property(targetSourceDir ${target} SOURCE_DIR)
    get_target_property(targetBinaryDir ${target} BINARY_DIR)

    foreach (source ${sources})
        get_filename_component(absoluteSource ${source} ABSOLUTE)

        if (${absoluteSource} MATCHES "^${targetBinaryDir}.*")
            source_group(TREE ${targetBinaryDir} FILES ${absoluteSource})
        elseif (${absoluteSource} MATCHES "^${targetSourceDir}.*")
            source_group(TREE ${targetSourceDir} FILES ${absoluteSource})
        elseif (${absoluteSource} MATCHES "^${CMAKE_CURRENT_BINARY_DIR}.*")
            source_group(TREE ${CMAKE_CURRENT_BINARY_DIR} FILES ${absoluteSource})
        elseif (${absoluteSource} MATCHES "^${CMAKE_CURRENT_SOURCE_DIR}.*")
            source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${absoluteSource})
        elseif (${absoluteSource} MATCHES "^${PROJECT_BINARY_DIR}.*")
            source_group(TREE ${PROJECT_BINARY_DIR} FILES ${absoluteSource})
        elseif (${absoluteSource} MATCHES "^${PROJECT_SOURCE_DIR}.*")
            source_group(TREE ${PROJECT_SOURCE_DIR} FILES ${absoluteSource})
        elseif (${absoluteSource} MATCHES "^${CMAKE_BINARY_DIR}.*")
            source_group(TREE ${CMAKE_BINARY_DIR} FILES ${absoluteSource})
        elseif (${absoluteSource} MATCHES "^${CMAKE_SOURCE_DIR}.*")
            source_group(TREE ${CMAKE_SOURCE_DIR} FILES ${absoluteSource})
        endif ()
    endforeach ()
endfunction ()

function (dp_target_find_source absoluteSourceOutVar target wantedSourceName)
    get_target_property(sources ${target} SOURCES)

    foreach (source ${sources})        
        get_filename_component(sourceName ${source} NAME)

        if (${sourceName} STREQUAL ${wantedSourceName})
            get_filename_component(absoluteSource ${source} ABSOLUTE)
            set(${absoluteSourceOutVar} ${absoluteSource} PARENT_SCOPE)

            return()
        endif ()        
    endforeach ()
endfunction ()

function (dp_target_generate_install target)
    set(options PUBLIC_HEADER_FROM_INTERFACE_SOURCES INSTALL_INCLUDE_FOLDER)
    set(oneValueArgs CONFIG_IN)
    set(multiValueArgs)
    cmake_parse_arguments(STANDARD_INSTALL_OPTIONS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    include(GNUInstallDirs)

    set(exporTargetsName ${target}Targets)
    set(exportDestDir ${CMAKE_INSTALL_LIBDIR}/cmake/${target})
    set(configOut ${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake)
    set(versionOut ${CMAKE_CURRENT_BINARY_DIR}/${target}ConfigVersion.cmake)

    include(CMakePackageConfigHelpers) 

    if (DEFINED STANDARD_INSTALL_OPTIONS_CONFIG_IN)
        configure_package_config_file(${STANDARD_INSTALL_OPTIONS_CONFIG_IN} ${configOut} INSTALL_DESTINATION ${exportDestDir})
    endif ()

    write_basic_package_version_file(${versionOut} COMPATIBILITY SameMajorVersion)

    if (STANDARD_INSTALL_OPTIONS_PUBLIC_HEADER_FROM_INTERFACE_SOURCES)
        get_target_property(interfaceSources ${target} INTERFACE_SOURCES)
        set_target_properties(${target} PROPERTIES PUBLIC_HEADER ${interfaceSources})
    endif ()

    install(TARGETS ${target} EXPORT ${exporTargetsName}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${target}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    if (STANDARD_INSTALL_OPTIONS_INSTALL_INCLUDE_FOLDER)
        install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ PATTERN CMakeLists.txt EXCLUDE)
    endif ()

    install(EXPORT ${exporTargetsName} DESTINATION ${exportDestDir} NAMESPACE ${target}:: FILE ${exporTargetsName}.cmake)

    if (DEFINED STANDARD_INSTALL_OPTIONS_CONFIG_IN)
        install(FILES ${configOut} DESTINATION ${exportDestDir})
    endif ()

    install(FILES ${versionOut} DESTINATION ${exportDestDir})
endfunction ()

function (dp_target_copy_known_dlls_near_executable target)
    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy -t $<TARGET_FILE_DIR:${target}> $<TARGET_RUNTIME_DLLS:${target}>
        COMMAND_EXPAND_LISTS
    )
endfunction ()
