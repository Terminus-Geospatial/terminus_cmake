############################# INTELLECTUAL PROPERTY RIGHTS #############################
##                                                                                    ##
##                           Copyright (c) 2024 Terminus LLC                          ##
##                                All Rights Reserved.                                ##
##                                                                                    ##
##          Use of this source code is governed by LICENSE in the repo root.          ##
##                                                                                    ##
############################# INTELLECTUAL PROPERTY RIGHTS #############################
#
from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout

class CMakeConan(ConanFile):

    name = "terminus_cmake"
    version = "1.0.9"

    exports_sources = (
        "CMakeLists.txt",
        "cmake/*",
        "cmake/**",
        "test/*",
        "test/**",
    )

    license = "Terminus Proprietary"
    author = "Marvin Smith <marvin_smith1@me.com>"
    url = "https://github.com/Terminus-Geospatial/terminus_cmake"
    description = "Collection of CMake functions and macros for use in Terminus CMake Projects"
    topics = ("terminus", "cmake", "build")

    options = { "with_tests": [True, False] }

    default_options = { "with_tests": False }

    settings = "os", "compiler", "build_type", "arch"

    def layout(self):
        cmake_layout(self)

    def build_requirements(self):
        self.build_requires("cmake/4.1.2")

    def _configure_cmake(self):
        cmake = CMake(self)
        cmake.configure()
        return cmake

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["CONAN_PKG_NAME"]        = self.name
        tc.variables["CONAN_PKG_VERSION"]     = self.version
        tc.variables["CONAN_PKG_DESCRIPTION"] = self.description
        tc.variables["CONAN_PKG_URL"]         = self.url

        tc.variables["TERMINUS_CMAKE_ENABLE_TESTS"] = "ON" if self.options.with_tests else "OFF"
        tc.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = self._configure_cmake()
        cmake.build()

    def package(self):
        cmake = self._configure_cmake()
        cmake.install()

    def package_info(self):
        self.cpp_info.builddirs = ["cmake"]

    def package_id(self):
        self.info.clear()
