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

function (dp_generate_install_for_target target)
    include(GNUInstallDirs)

    set(exportDestDir ${CMAKE_INSTALL_LIBDIR}/cmake/${target})
    set(configOut ${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake)
    set(versionOut ${CMAKE_CURRENT_BINARY_DIR}/${target}ConfigVersion.cmake)

    include(CMakePackageConfigHelpers) 
    configure_package_config_file(cmake/${target}Config.cmake.in ${configOut} INSTALL_DESTINATION ${exportDestDir})
    write_basic_package_version_file(${versionOut} COMPATIBILITY SameMajorVersion)

    install(TARGETS ${target} EXPORT ${target}Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_LIBDIR}/${target}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ PATTERN CMakeLists.txt EXCLUDE)
    install(EXPORT ${target}Targets DESTINATION ${exportDestDir} NAMESPACE ${target}:: FILE ${target}Targets.cmake)    
    install(FILES ${configOut} ${versionOut} DESTINATION ${exportDestDir})
endfunction ()
