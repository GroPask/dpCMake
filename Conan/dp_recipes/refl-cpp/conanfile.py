from conans import ConanFile, CMake, tools


class ReflCppConan(ConanFile):
    name = "refl-cpp"
    version = "0.12.1"
    license = "<Put the package license here>"
    author = "<Put your name here> <And your email here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of ReflCpp here>"
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
        git = tools.Git(folder="refl-cpp")
        git.clone("https://github.com/veselink1/refl-cpp.git") # , "0.12.1")

    def package(self):
        self.copy("*", dst="include", src="refl-cpp/include")

