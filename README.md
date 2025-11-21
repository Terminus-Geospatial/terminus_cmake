Terminus CMake Build System Utilities
=====================================

Reusable CMake modules for Terminus C++ projects.  These scripts codify best practices for
warnings, target layout, testing, coverage, and protobuf integration so new apps and libraries can
share a consistent build configuration.  The utilities complement the
[`terminus-setup`](https://github.com/Terminus-Geospatial/terminus-setup) development tooling but
can be consumed independently.

Features
--------
1. **Project bootstrap (`terminus_cmake_project.cmake`)** – establishes Terminus warning presets
   (low/medium/high with `-Werror`), sets sane defaults, and exposes variables such as
   `TERMINUS_CXX_FLAGS` for downstream targets.
2. **Application helpers (`terminus_cmake_apps.cmake`)** – standardizes binary output directories,
   rpath settings, and automatically applies the selected warning tier to each executable target.
3. **Library helpers (`terminus_cmake_libs.cmake`)** – configures shared/static/header-only targets,
   handles install rules, feature-gated header copies, and object-library promotion.
4. **Testing utilities (`terminus_cmake_test.cmake`)** – wraps GoogleTest discovery, links the
   correct gtest/gmock artifacts, and creates per-suite executables with minimal boilerplate.
5. **Code coverage (`terminus_cmake_coverage.cmake`)** – enables coverage compilation flags and
   creates a `coverage` target that orchestrates `ctest`, `gcov`, and report directory management.
6. **Protobuf & gRPC generation (`terminus_cmake_protobuf.cmake`)** – drives `protoc` for protobuf
   and gRPC files, wiring up include paths, generated sources, and required linkage information.
7. **Colorized messaging (`terminus_cmake_colors.cmake`)** – defines ANSI color helpers for
   consistent CLI output when running CMake flows.
8. **General utilities (`terminus_cmake_util.cmake`)** – helper macros for enumerating targets and
   dumping CMake variables, used by coverage and other workflows.

Getting Started
---------------
1. Add this repository as a dependency (e.g., via Conan) and include the top-level module from your
   root `CMakeLists.txt`:

   ```cmake
   include("cmake/terminus_cmake.cmake")
   ```

2. Call the helpers as needed:

   ```cmake
   terminus_app_configure(my_tool)
   terminus_lib_configure(my_library)
   terminus_test_add_unit(core ping_test tests/ping_test.cpp)
   terminus_protobuf_generate(PROTO_SRCS PROTO_HDRS PROTO_LIBS
       PROTO_PATH ${CMAKE_CURRENT_SOURCE_DIR}/proto
       PROTO_FILES ping.proto
   )
   ```

3. Toggle the desired warning level by setting `TERMINUS_CXX_FLAGS` (LOW, MEDIUM, or HIGH) before
   including individual components.  HIGH is the default.

Contributions
-------------
Issues and pull requests are welcome.  Please document notable changes in `changelog.md` and ensure
new modules follow the Terminus licensing and header conventions.
