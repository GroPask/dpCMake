from conans import ConanFile, CMake, tools

class P4Api(ConanFile):
    name = 'p4api'
    version = "2020.1"
    user = "dp_recipe"
    channel = "stable"
    settings = "os", "compiler", "build_type", "arch"
    license = "<Put the package license here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of Nana here>"
    requires = "openssl/1.1.1j"
	
    def build(self):
        if self.settings.os == "Windows" and self.settings.compiler == "Visual Studio" and self.settings.arch == "x86_64":
            if self.settings.build_type == "Debug":
                url = "https://cdist2.perforce.com/perforce/r20.1/bin.ntx64/p4api_vs2017_dyn_vsdebug_openssl1.1.1.zip"
            else:
                url = "https://cdist2.perforce.com/perforce/r20.1/bin.ntx64/p4api_vs2017_dyn_openssl1.1.1.zip"
        else:
            raise Exception("Binary does not exist for these settings")
        tools.download(url, "p4api.zip")
        tools.unzip("p4api.zip", strip_root=True)
        tools.remove_files_by_mask(".", "p4api.zip")

    def package(self):
        self.copy("*") # assume package as-is, but you can also copy specific files or rearrange

    def package_info(self):
        self.cpp_info.libs = ["libclient.lib", "libp4api.lib", "libp4script.lib", "libp4script_c.lib", "libp4script_curl.lib", "libp4script_sqlite.lib", "librpc.lib", "libsupp.lib"]