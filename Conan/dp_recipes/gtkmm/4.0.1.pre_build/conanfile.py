from conans import ConanFile, CMake, tools

class GtkmmConan(ConanFile):
    name = 'gtkmm'
    version = "4.0.1"
    user = "dp_recipe"
    channel = "pre_build"
    settings = "os", "compiler", "build_type", "arch"
    license = "<Put the package license here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of Nana here>"
    exports_sources = "*.zip"
	
    def build(self):
        if self.settings.os == "Windows" and self.settings.compiler == "Visual Studio" and self.settings.arch == "x86_64":
            if self.settings.build_type == "Debug":
                gtkmm_zip = "gtkmm-4.0.1-debug.zip" 
            else:
                gtkmm_zip = "gtkmm-4.0.1-release.zip" 
        else:
            raise Exception("Binary does not exist for these settings")
        tools.unzip(gtkmm_zip, "gtkmm")

    def package(self):
        self.copy("*", src="gtkmm")

    def package_info(self):
        self.cpp_info.includedirs = ["include/gtkmm-4.0",
                                     "lib/gtkmm-4.0/include",
                                     "lib/pangomm-2.48/include",
                                     "lib/glibmm-2.68/include",
                                     "include/glibmm-2.68",
                                     "include/glib-2.0",
                                     "lib/glib-2.0/include",
                                     "include/sigc++-3.0",
                                     "lib/sigc++-3.0/include",
                                     "include/giomm-2.68",
                                     "lib/giomm-2.68/include",
                                     "include/pangomm-2.48",
                                     "include/pango-1.0",
                                     "include/harfbuzz",
                                     "include/cairomm-1.16",
                                     "include/cairo",
                                     "include",
                                     "lib/cairomm-1.16/include",
                                     "include/gtk-4.0",
                                     "include/gdk-pixbuf-2.0",
                                     "include/graphene-1.0",
                                     "lib/graphene-1.0/include"]

        self.cpp_info.libdirs = ["lib"]
        self.cpp_info.libs = tools.collect_libs(self)        