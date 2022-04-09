from conans import ConanFile, Meson, tools
from conans.errors import ConanInvalidConfiguration
import os

required_conan_version = ">=1.33.0"


class GtkConan(ConanFile):
    name = "gtk"
    version = "4.3.0"
    user = "dp_recipe"    
    channel = "stable"
    description = "libraries used for creating graphical user interfaces for applications."
    topics = ("conan", "gtk", "widgets")
    url = "https://github.com/conan-io/conan-center-index"
    homepage = "https://www.gtk.org"
    license = "LGPL-2.1-or-later"
    generators = "pkg_config"
    short_paths = True # Added by DP

    settings = "os", "arch", "compiler", "build_type"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "with_wayland": [True, False],
        "with_x11": [True, False],
        "with_pango": [True, False]
        }
    default_options = {
        "shared": False,
        "fPIC": True,
        "with_wayland": False,
        "with_x11": True,
        "with_pango": True}

    @property
    def _source_subfolder(self):
        return "source_subfolder"

    @property
    def _build_subfolder(self):
        return "build_subfolder"

    @property
    def _gtk4(self):
        return tools.Version("4.0.0") <= tools.Version(self.version) < tools.Version("5.0.0")
    @property

    def _gtk3(self):
        return tools.Version("3.0.0") <= tools.Version(self.version) < tools.Version("4.0.0")

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC
        if self.settings.os != "Linux":
            del self.options.with_wayland
            del self.options.with_x11

    def validate(self):
        if self.settings.compiler == "gcc" and tools.Version(self.settings.compiler.version) < "5":
            raise ConanInvalidConfiguration("this recipes does not support GCC before version 5. contributions are welcome")

    def configure(self):
        if self.options.shared:
            del self.options.fPIC
        del self.settings.compiler.libcxx
        del self.settings.compiler.cppstd
        if self.settings.os == "Linux":
            if self.options.with_wayland or self.options.with_x11:
                if not self.options.with_pango:
                    raise ConanInvalidConfiguration("with_pango option is mandatory when with_wayland or with_x11 is used")
        if self.settings.os == "Windows": # Added by DP
            self.options["cairo"].shared = True # Because cairo cannot be build not shared... # Added by DP
        # if self.settings.os == "Windows": # COMMENTED BY DP
        #     raise ConanInvalidConfiguration("GTK recipe is not yet compatible with Windows. Contributions are welcome.") # COMMENTED BY DP

    def build_requirements(self):
        self.build_requires("meson/0.57.1")
        self.build_requires("pkgconf/1.7.3")
        if self._gtk4:
            self.build_requires("sassc/3.6.1@dp_recipe/stable") # MODIFIED BY DP

    def requirements(self):
        self.requires("gdk-pixbuf/2.42.4")
        self.requires("glib/2.68.0")
        # if self.settings.compiler != "Visual Studio": # COMMENTED BY DP 
        self.requires("cairo/1.17.4")
        if self._gtk4:
            self.requires("graphene/1.10.4")
        if self.settings.os == "Linux":
            if self._gtk4:
                self.requires("xkbcommon/1.1.0")
            if self._gtk3:
                self.requires("at-spi2-atk/2.38.0")
            if self.options.with_wayland:
                if self._gtk3:
                    self.requires("xkbcommon/1.1.0")
                self.requires("wayland/1.19.0")
            if self.options.with_x11:
                self.requires("xorg/system")
        if self._gtk3:
            self.requires("atk/2.36.0")
        self.requires("libepoxy/1.5.5")
        if self.options.with_pango:
            self.requires("pango/1.48.3")

    def source(self):
        tools.get(**self.conan_data["sources"][self.version], strip_root=True, destination=self._source_subfolder)
        if not self.options.shared: # Added by DP
            tools.replace_in_file(self._source_subfolder + "/gtk/gtkwin32.c", '''DllMain (HINSTANCE hinstDLL,''', '''DllMainBis (HINSTANCE hinstDLL,''') # Added by DP
            tools.replace_in_file(self._source_subfolder + "/gtk/meson.build", '''libgtk = shared_library('gtk-4',''', '''libgtk = static_library('gtk-4',''') # Added by DP
        if self.settings.os == "Windows": # Added by DP
            tools.save(self._source_subfolder + "/build-aux/meson/check-dir.py", '''#!/usr/bin/env python3
import os
import sys
gtk_datadir = sys.argv[1]
icon_path = os.path.join(gtk_datadir, 'icons', 'hicolor')
if not os.path.exists(icon_path):
    os.makedirs(icon_path)''') # Added by DP
            tools.replace_in_file(self._source_subfolder + "/meson.build", '''if meson.version().version_compare('>=0.57.0')''', '''meson.add_install_script('build-aux/meson/check-dir.py',
                         gtk_datadir)
if meson.version().version_compare('>=0.57.0')''') # Added by DP

    def _configure_meson(self):
        meson = Meson(self)
        defs = {}
        if self.settings.os == "Linux":
            defs["wayland_backend" if self._gtk3 else "wayland-backend"] = "true" if self.options.with_wayland else "false"
            defs["x11_backend" if self._gtk3 else "x11-backend"] = "true" if self.options.with_x11 else "false"
        defs["introspection"] = "false" if self._gtk3 else "disabled"
        defs["documentation"] = "false"
        defs["man-pages"] = "false"
        defs["tests" if self._gtk3 else "build-tests"] = "false"
        defs["examples" if self._gtk3 else "build-examples"] = "false"
        defs["demos"] = "false"
        defs["datadir"] = os.path.join(self.package_folder, "res", "share")
        defs["localedir"] = os.path.join(self.package_folder, "res", "share", "locale")
        defs["sysconfdir"] = os.path.join(self.package_folder, "res", "etc")
        args=[]
        args.append("--wrap-mode=nofallback")
        meson.configure(defs=defs, build_folder=self._build_subfolder, source_folder=self._source_subfolder, pkg_config_paths=[self.install_folder], args=args)
        return meson

    def build(self):
        if self._gtk3:
            tools.replace_in_file(os.path.join(self._source_subfolder, "meson.build"), "\ntest(\n", "\nfalse and test(\n")
        with tools.environment_append(tools.RunEnvironment(self).vars):
            meson = self._configure_meson()
            meson.build()

    def package(self):
        self.copy(pattern="LICENSE", dst="licenses", src=self._source_subfolder)
        meson = self._configure_meson()
        with tools.environment_append({
            "PKG_CONFIG_PATH": self.install_folder,
            "PATH": [os.path.join(self.package_folder, "bin")]}):
            meson.install()

        self.copy(pattern="COPYING", src=self._source_subfolder, dst="licenses")
        tools.rmdir(os.path.join(self.package_folder, "lib", "pkgconfig"))
        if self.settings.os == "Windows" and not self.options.shared: # Added by DP
            tools.rename(os.path.join(self.package_folder, "lib", "libgtk-4.a"), os.path.join(self.package_folder, "lib", "gtk-4.lib")) # Added by DP

    def package_info(self):
        if self._gtk3:
            self.cpp_info.components["gdk-3.0"].libs = ["gdk-3"]
            self.cpp_info.components["gdk-3.0"].includedirs = [os.path.join("include", "gtk-3.0")]
            self.cpp_info.components["gdk-3.0"].requires = []
            if self.options.with_pango:
                self.cpp_info.components["gdk-3.0"].requires.extend(["pango::pango_", "pango::pangocairo"])
            self.cpp_info.components["gdk-3.0"].requires.append("gdk-pixbuf::gdk-pixbuf")
            if self.settings.compiler != "Visual Studio":
                self.cpp_info.components["gdk-3.0"].requires.extend(["cairo::cairo", "cairo::cairo-gobject"])
            if self.settings.os == "Linux":
                self.cpp_info.components["gdk-3.0"].requires.extend(["glib::gio-unix-2.0", "cairo::cairo-xlib"])
                if self.options.with_x11:
                    self.cpp_info.components["gdk-3.0"].requires.append("xorg::xorg")
            self.cpp_info.components["gdk-3.0"].requires.append("libepoxy::libepoxy")
            self.cpp_info.components["gdk-3.0"].names["pkg_config"] = "gdk-3.0"

            self.cpp_info.components["gtk+-3.0"].libs = ["gtk-3"]
            self.cpp_info.components["gtk+-3.0"].requires = ["gdk-3.0", "atk::atk"]
            if self.settings.compiler != "Visual Studio":
                self.cpp_info.components["gtk+-3.0"].requires.extend(["cairo::cairo", "cairo::cairo-gobject"])
            self.cpp_info.components["gtk+-3.0"].requires.extend(["gdk-pixbuf::gdk-pixbuf", "glib::gio-2.0"])
            if self.settings.os == "Linux":
                self.cpp_info.components["gtk+-3.0"].requires.append("at-spi2-atk::at-spi2-atk")
            self.cpp_info.components["gtk+-3.0"].requires.append("libepoxy::libepoxy")
            if self.options.with_pango:
                self.cpp_info.components["gtk+-3.0"].requires.append('pango::pangoft2')
            if self.settings.os == "Linux":
                self.cpp_info.components["gtk+-3.0"].requires.append("glib::gio-unix-2.0")
            self.cpp_info.components["gtk+-3.0"].includedirs = [os.path.join("include", "gtk-3.0")]
            self.cpp_info.components["gtk+-3.0"].names["pkg_config"] = "gtk+-3.0"

            self.cpp_info.components["gail-3.0"].libs = ["gailutil-3"]
            self.cpp_info.components["gail-3.0"].requires = ["gtk+-3.0", "atk::atk"]
            self.cpp_info.components["gail-3.0"].includedirs = [os.path.join("include", "gail-3.0")]
            self.cpp_info.components["gail-3.0"].names["pkg_config"] = "gail-3.0"
        elif self._gtk4:
            self.cpp_info.requires.extend(["gdk-pixbuf::gdk-pixbuf"])
            self.cpp_info.requires.extend(["glib::glib", "glib::gio-windows-2.0"])
            self.cpp_info.requires.extend(["cairo::cairo", "cairo::cairo-gobject", "cairo::cairo-win32"])
            self.cpp_info.requires.extend(["graphene::graphene"])
            self.cpp_info.requires.extend(["libepoxy::libepoxy"])
            self.cpp_info.requires.extend(["pango::pango", "pango::pangowin32", "pango::pangocairo"])
            self.cpp_info.names["pkg_config"] = "gtk4"
            self.cpp_info.libs = ["gtk-4"]
            self.cpp_info.includedirs.append(os.path.join("include", "gtk-4.0"))
            if self.settings.os == "Windows": # Added by DP
                if not self.options.shared: # Added by DP
                    self.cpp_info.system_libs = ["Dwmapi.lib", "imm32.lib", "winmm.lib", "Ws2_32.lib", "Setupapi.lib", "comctl32.lib", "Crypt32.lib"] # Added by DP