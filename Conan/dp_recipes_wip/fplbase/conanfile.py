from conans import ConanFile, CMake, tools


class NanaConan(ConanFile):
    name = "fplbase"
    version = "1.0.0"
    license = "<Put the package license here>"
    author = "<Put your name here> <And your email here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of Nana here>"
    topics = ("<Put some tag here>", "<here>", "<and here>")
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}
    generators = "cmake"
    user = "dp_recipe"
    channel = "stable"

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def configure(self):
        self.options["flatbuffers"].flatc = True
        self.options["flatbuffers"].flatbuffers = True
        self.options["flatbuffers"].options_from_context = False

    def requirements(self):
        self.requires("flatbuffers/1.12.0")
        self.requires("mathfu/1.1.0")
        self.requires("sdl2/2.0.14@bincrafters/stable")
        self.requires("libwebp/1.2.0")
        self.requires("stb/20200203")

    def source(self):
        git = tools.Git(folder="fplbase")
        git.clone("https://github.com/google/fplbase.git", "v1.0.0")

        # This small hack might be useful to guarantee proper /MT /MD linkage
        # in MSVC if the packaged project doesn't have variables to set it
        # properly
        tools.replace_in_file("fplbase/CMakeLists.txt", "project(fplbase)",
                              '''project(fplbase)
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
add_library(flatc INTERFACE IMPORTED)
target_link_libraries(flatc INTERFACE CONAN_PKG::flatc)
add_library(webp INTERFACE IMPORTED)
target_link_libraries(webp INTERFACE CONAN_PKG::libwebp)''')

        tools.replace_in_file("fplbase/CMakeLists.txt", '''add_subdirectory(${dependencies_mathfu_dir} ${tmp_dir}/mathfu)''', "")
        tools.replace_in_file("fplbase/CMakeLists.txt", '''mathfu_configure_flags(${target})''', "")

        tools.replace_in_file("fplbase/schemas/common.fbs", '''r:float = 1.0;''', '''r:float;''')
        tools.replace_in_file("fplbase/schemas/common.fbs", '''g:float = 1.0;''', '''g:float;''')
        tools.replace_in_file("fplbase/schemas/common.fbs", '''b:float = 1.0;''', '''b:float;''')
        tools.replace_in_file("fplbase/schemas/common.fbs", '''a:float = 1.0;''', '''a:float;''')

        gitFPlutil = tools.Git(folder="fplbase/dependencies/fplutil")
        gitFPlutil.clone("https://github.com/google/fplutil.git", "v1.1.0")

        tools.remove_files_by_mask(".", "contributing.md") # Because symbolic link cause problem on copy
        tools.remove_files_by_mask(".", "readme.md") # Because symbolic link cause problem on copy
        tools.remove_files_by_mask(".", "LICENSE") # Because symbolic link cause problem on copy

    def build(self):
        cmake = CMake(self)
        cmake.definitions["fplbase_use_external_sdl"] = "TRUE"
        cmake.definitions["fplbase_build_samples"] = "FALSE"
        cmake.definitions["fplbase_build_tests"] = "FALSE"
        cmake.configure(source_folder="fplbase")
        cmake.build()

    def package(self):
        self.copy("*", dst="include", src="fplbase/include")
        self.copy("*fplbase.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["fplbase"]

