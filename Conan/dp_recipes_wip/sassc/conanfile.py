from conans import ConanFile, AutoToolsBuildEnvironment, tools, MSBuild
from conans.errors import ConanInvalidConfiguration
import os

# Modified version of
# https://github.com/conan-io/conan-center-index/blob/master/recipes/sassc/all/conanfile.py

class SasscConan(ConanFile):
    name = "sassc"
    version = "3.6.1"
    user = "dp_recipe"    
    channel = "stable"
    license = "MIT"
    homepage = "https://sass-lang.com/libsass"
    url = "https://github.com/conan-io/conan-center-index"
    description = "libsass command line driver"
    topics = ("Sass", "sassc", "compiler")
    settings = "os", "compiler", "build_type", "arch"

    requires = "libsass/3.6.4@dp_recipe/stable"

    _autotools = None

    @property
    def _source_subfolder(self):
        return "source_subfolder"

    @property
    def _is_visual_studio(self):
        return self.settings.os == "Windows" and self.settings.compiler == "Visual Studio"

    def config_options(self):
        del self.settings.compiler.libcxx
        del self.settings.compiler.cppstd

    def configure(self):
        if self.settings.os not in ["Linux", "FreeBSD", "Macos", "Windows"]:
            raise ConanInvalidConfiguration("sassc supports only Linux, FreeBSD, Macos and Windows at this time, contributions are welcomed")

    def build_requirements(self):
        if self.settings.os != "Windows":
            self.build_requires("autoconf/2.69")
            self.build_requires("libtool/2.4.6")
            
    def source(self):
        tools.get(**self.conan_data["sources"][self.version])
        extracted_dir = self.name + "-" + self.version
        tools.rename(extracted_dir, self._source_subfolder)
        proj_path = os.path.join(self._source_subfolder, "win", "sassc.vcxproj")
        tools.replace_in_file(proj_path, '''<Import Project="$(LIBSASS_DIR)\win\libsass.targets" />''', "")

    def _configure_autotools(self):
        if self._autotools:
            return self._autotools
        self.run("autoreconf -fiv", run_environment=True)
        self._autotools = AutoToolsBuildEnvironment(self)
        self._autotools.configure(args=["--disable-tests"])
        return self._autotools

    def _build_autotools(self):
        with tools.chdir(self._source_subfolder):
            tools.save(path="VERSION", content="%s" % self.version)
            autotools = self._configure_autotools()
            autotools.make()

    def _build_visual_studio(self):
        env_vars = {"LIBSASS_DIR": self.deps_cpp_info["libsass"].rootpath}
        with tools.environment_append(env_vars):
            sln_path = os.path.join(self._source_subfolder, "win", "sassc.sln")
            msbuild = MSBuild(self)
            msbuild.build(sln_path, platforms={'x86': 'Win32', 'x86_64': 'Win64'})  

    def build(self):
        if self._is_visual_studio:
            self._build_visual_studio()
        else:
            self._build_autotools()

    def _install_autotools(self):
        with tools.chdir(self._source_subfolder):
            autotools = self._configure_autotools()
            autotools.install()

    def _install_visual_studio(self):
        self.copy("*.exe", dst="bin", src=os.path.join(self._source_subfolder, "bin"))

    def package(self):
        self.copy("LICENSE", src=self._source_subfolder, dst="licenses")
        if self._is_visual_studio:
            self._install_visual_studio()
        else:
            self._install_autotools()        

    def package_info(self):
        bin_path = os.path.join(self.package_folder, "bin")
        self.output.info("Appending PATH env var with : {}".format(bin_path))
        self.env_info.PATH.append(bin_path)