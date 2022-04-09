from conans import ConanFile, CMake, tools


class FlatUiConan(ConanFile):
    name = "flatui"
    version = "1.1.0"
    license = "<Put the package license here>"
    author = "<Put your name here> <And your email here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of ReflCpp here>"
    topics = ("<Put some tag here>", "<here>", "<and here>")
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}
    generators = "cmake"
    user = "PersonnalRecipe"
    channel = "stable"
    requires = "flatbuffers/1.12.0", "mathfu/1.1.0", "sdl2/2.0.14@bincrafters/stable", "harfbuzz/2.8.0", "freetype/2.10.4", "libwebp/1.2.0"

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def source(self):
        git = tools.Git(folder="flatui")
        git.clone("https://github.com/google/flatui.git", "1.1.0")

        #git.run("clone --recurse-submodules -j8 --branch 1.1.0 https://github.com/google/flatui.git")
        #return

       	# This small hack might be useful to guarantee proper /MT /MD linkage
        # in MSVC if the packaged project doesn't have variables to set it
        # properly
        tools.replace_in_file("flatui/CMakeLists.txt", "project(flatui)",
                              '''project(flatui)
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
add_library(flatc INTERFACE IMPORTED)
add_library(harfbuzz INTERFACE IMPORTED)
target_link_libraries(harfbuzz INTERFACE CONAN_PKG::harfbuzz)
add_library(freetype INTERFACE IMPORTED)
target_link_libraries(freetype INTERFACE CONAN_PKG::freetype)
add_library(webp INTERFACE IMPORTED)
target_link_libraries(webp INTERFACE CONAN_PKG::webp)''')

        tools.replace_in_file("flatui/CMakeLists.txt", '''add_subdirectory(${dependencies_mathfu_dir} ${tmp_dir}/mathfu)''', "")
        tools.replace_in_file("flatui/CMakeLists.txt", '''mathfu_configure_flags(flatui)''', "")
        tools.replace_in_file("flatui/CMakeLists.txt", '''# Include motive.''', '''add_subdirectory("${fpl_root}/fplbase" ${tmp_dir}/fplbase)

# Include motive.''')

        gitFPlutil = tools.Git(folder="flatui/dependencies/fplutil")
        gitFPlutil.clone("https://github.com/google/fplutil.git", "v1.1.0")

        gitFPlbase = tools.Git(folder="flatui/dependencies/fplbase")
        gitFPlbase.clone("https://github.com/google/fplbase.git", "v1.0.0")
        tools.replace_in_file("flatui/dependencies/fplbase/CMakeLists.txt", '''add_subdirectory(${dependencies_mathfu_dir} ${tmp_dir}/mathfu)''', "")
        tools.replace_in_file("flatui/dependencies/fplbase/CMakeLists.txt", '''mathfu_configure_flags(${target})''', "")
        tools.replace_in_file("flatui/dependencies/fplbase/CMakeLists.txt", '''build_flatbuffers''', '''message("DEBUGDEBUGDEBUGDEBUG")
build_flatbuffers''')

        gitMotive = tools.Git(folder="flatui/dependencies/motive")
        gitMotive.clone("https://github.com/google/motive.git", "v1.2.0")
        tools.replace_in_file("flatui/dependencies/motive/CMakeLists.txt", '''add_subdirectory(${dependencies_mathfu_dir} ${tmp_dir}/mathfu)''', "")
        tools.replace_in_file("flatui/dependencies/motive/CMakeLists.txt", '''mathfu_set_ios_attributes(motive)''', "")
        tools.replace_in_file("flatui/dependencies/motive/CMakeLists.txt", '''mathfu_configure_flags(motive)''', "")

        gitGumbo = tools.Git(folder="flatui/dependencies/gumbo-parser")
        gitGumbo.clone("https://github.com/google/gumbo-parser.git")
        gitGumbo.checkout("aa91b27b02")

        gitUnibreak = tools.Git(folder="flatui/dependencies/libunibreak")
        gitUnibreak.clone("https://github.com/adah1972/libunibreak.git", "libunibreak_4_3")

        #add_library(CONAN_PKG::flatc INTERFACE IMPORTED)

        #gitFlatBuffers = tools.Git(folder="flatui/dependencies/flatbuffers")
        #gitFlatBuffers.clone("https://github.com/google/flatbuffers.git", "v1.12.0")

        #gitMathFu = tools.Git(folder="flatui/dependencies/mathfu")
        #gitMathFu.clone("https://github.com/google/mathfu.git", "v1.1.0")

        tools.remove_files_by_mask(".", "contributing.md") # Because symbolic link cause problem on copy
        tools.remove_files_by_mask(".", "readme.md") # Because symbolic link cause problem on copy
        tools.remove_files_by_mask(".", "LICENSE") # Because symbolic link cause problem on copy

    def build(self):
        cmake = CMake(self)
        #cmake.definitions["dependencies_flatbuffers_dir"] = self.deps_cpp_info["flatbuffers"].rootpath
        cmake.definitions["flatui_build_tests"] = "OFF"
        cmake.definitions["flatui_build_samples"] = "OFF"
        cmake.definitions["fplbase_use_external_sdl"] = "TRUE"
        cmake.configure(source_folder="flatui")
        cmake.build()

        # Explicit way:
        # self.run('cmake %s/hello %s'
        #          % (self.source_folder, cmake.command_line))
        # self.run("cmake --build . %s" % cmake.build_config)

    def package(self):
        self.copy("*.h", dst="include", src="flatui")
        self.copy("*flatui.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["flatui"]
