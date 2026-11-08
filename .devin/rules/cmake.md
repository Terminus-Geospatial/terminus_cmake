---
trigger: always_on
---

# CMake standards

- Use modern target-based CMake and the project's existing `cmake_minimum_required` (Terminus C++ projects generally require 4.0.0 or newer). Do not lower requirements to bypass toolchain failures.
- Use Conan's generated toolchain before `project()`. Respect the recipe's generator/build layout: do not assume every toolchain is at `${CMAKE_BINARY_DIR}/conan_toolchain.cmake`. Preserve working preset/toolchain integration rather than including it twice.
- Prefer package config discovery with `CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE`. Use `find_package` and declared imported targets, not hardcoded cache paths.
- Include `terminus_cmake` in consuming projects. Use `terminus_lib_configure` and `terminus_app_configure` where appropriate; inspect their current behavior before adding duplicate installation, RPATH, or warning settings.
- Use C++23 as the baseline where required, `CMAKE_CXX_STANDARD_REQUIRED ON`, and `CMAKE_CXX_EXTENSIONS OFF`. Keep Conan's compiler standard compatible; do not assume a later CMake assignment cannot lower a higher standard selected by Conan.
- Use the high Terminus warning preset and warnings-as-errors for project targets where established. Inspect the current `TERMINUS_CXX_FLAGS_LOW`, `TERMINUS_CXX_FLAGS_MEDIUM`, and `TERMINUS_CXX_FLAGS_HIGH` definitions in `terminus_cmake` instead of duplicating compiler-specific flag lists. Do not weaken warnings globally to hide a local defect or impose project warning flags on third-party targets.
- Enable `CMAKE_EXPORT_COMPILE_COMMANDS` for supported generators (such as Ninja or Makefiles) to support editor indexing and analysis tools. Keep the generated compilation database out of source control.
- Set target include directories and link dependencies with correct `PUBLIC`, `PRIVATE`, or `INTERFACE` scope. Use build/install interfaces for exported headers and position-independent code when required.
- Pass `CONAN_PKG_NAME`, `CONAN_PKG_VERSION`, `CONAN_PKG_DESCRIPTION`, and `CONAN_PKG_URL` consistently from the recipe. Package and project versions must agree.
- Gate tests with the consuming project's own option, for example `TERMINUS_IPC_ENABLE_TESTS`, not a copied `TERMINUS_CMAKE_ENABLE_TESTS` name. Enable testing and add the actual test subtree; respect the repository's GoogleTest/CTest helpers.
- Export/install the headers, generated metadata, libraries, and CMake resources needed by consumers. Validate with a package consumer test, not only a local compilation.
