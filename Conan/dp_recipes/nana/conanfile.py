from conans import ConanFile, CMake, tools


class NanaConan(ConanFile):
    name = "nana"
    version = "hotfix-1.7.4"
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
        git = tools.Git(folder="nana")
        git.clone("https://github.com/cnjinhao/nana.git", "hotfix-1.7.4")

        # This small hack might be useful to guarantee proper /MT /MD linkage
        # in MSVC if the packaged project doesn't have variables to set it
        # properly
        tools.replace_in_file("nana/CMakeLists.txt", "add_library(nana)",
                              '''include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
add_library(nana)''')

    def build(self):
        cmake = CMake(self)
        cmake.definitions["NANA_STATIC_STDLIB"] = "OFF" # Not sure
        cmake.definitions["MSVC_USE_STATIC_RUNTIME"] = "OFF"
        cmake.configure(source_folder="nana")
        cmake.build()

        # Explicit way:
        # self.run('cmake %s/nana %s'
        #          % (self.source_folder, cmake.command_line))
        # self.run("cmake --build . %s" % cmake.build_config)

    def package(self):
        self.copy("*", dst="include", src="nana/include")
        self.copy("*nana.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["nana"]

