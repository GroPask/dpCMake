from conans import ConanFile, CMake, tools

class GtkConan(ConanFile):
    name = 'gtk'
    version = "4.3.0"
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
                gtk_zip = "gtk-4.3.0-debug.zip" 
            else:
                gtk_zip = "gtk-4.3.0-release.zip" 
        else:
            raise Exception("Binary does not exist for these settings")
        tools.unzip(gtk_zip, "gtk")

    def package(self):
        self.copy("*", src="gtk")

    def package_info(self):
        self.cpp_info.includedirs = ["include/gtk-4.0", 
                                     "include/glib-2.0",
                                     "lib/glib-2.0/include",
                                     "include/cairo",
                                     "include/pango-1.0",
                                     "include/harfbuzz",
                                     "include/gdk-pixbuf-2.0",
                                     "include/graphene-1.0",
                                     "lib/graphene-1.0/include"]
        self.cpp_info.libdirs = ["lib"]
        self.cpp_info.libs = tools.collect_libs(self)        