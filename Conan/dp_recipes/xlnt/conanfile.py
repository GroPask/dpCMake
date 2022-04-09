from conans import ConanFile, CMake, tools


class NanaConan(ConanFile):
    name = "xlnt"
    version = "1.5.0"
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

    def source(self):
        git = tools.Git(folder="xlnt")
        git.clone("https://github.com/tfussell/xlnt.git", "v1.5.0")

        tools.remove_files_by_mask(".", "SUMMARY.md") # Because symbolic link cause problem on copy

        # This small hack might be useful to guarantee proper /MT /MD linkage
        # in MSVC if the packaged project doesn't have variables to set it
        # properly
        tools.replace_in_file("xlnt/CMakeLists.txt", "project(xlnt_all)",
                              '''project(xlnt_all)
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()''')

    def build(self):
        cmake = CMake(self)
        cmake.definitions["STATIC"] = "ON"
        cmake.configure(source_folder="xlnt")
        cmake.build()

    def package(self):
        self.copy("*", dst="include", src="xlnt/include")
        self.copy("*xlnt.lib", dst="lib", keep_path=False)
        self.copy("*xlntd.lib", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.release.libs = ["xlnt"]
        self.cpp_info.debug.libs = ["xlntd"]
        self.cpp_info.defines = ["XLNT_STATIC"]

