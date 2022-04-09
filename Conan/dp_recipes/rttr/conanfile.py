from conans import ConanFile, tools, CMake

class RttrConan(ConanFile):
    name = "rttr"
    version = "0.9.7"
    user = "dp_recipe"
    channel = "stable"

    # Optional metadata
    license = "<Put the package license here>"
    author = "<Put your name here> <And your email here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of Rttr here>"
    topics = ("<Put some tag here>", "<here>", "<and here>")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}

    @property
    def _source_subfolder(self):
        return "rttr"

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def source(self):
        git = tools.Git(folder=self._source_subfolder)
        git.clone("https://github.com/rttrorg/rttr.git", "master")

    def _configure_cmake(self):
        cmake = CMake(self)
        cmake.definitions["BUILD_RTTR_DYNAMIC"] = self.options.shared
        cmake.definitions["BUILD_STATIC"] = not self.options.shared
        cmake.definitions["BUILD_WITH_RTTI"] = "OFF"
        cmake.definitions["BUILD_UNIT_TESTS"] = "OFF"
        cmake.definitions["BUILD_EXAMPLES"] = "OFF"
        cmake.definitions["BUILD_DOCUMENTATION"] = "OFF"
        cmake.definitions["BUILD_PACKAGE"] = "OFF"
        cmake.configure(source_folder=self._source_subfolder, build_folder="build")
        return cmake

    def build(self):
        cmake = self._configure_cmake()
        cmake.build()

    def package(self):
        cmake = self._configure_cmake()
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = tools.collect_libs(self)
