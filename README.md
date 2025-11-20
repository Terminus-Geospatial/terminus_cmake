Terminus CMake Build System Utilities
=====================================

This repository contains reusable CMake helper modules for building C++ projects the
"Terminus way". The helpers standardize how we:

- Configure warning flags and C++ language features
- Build and install libraries (including header‑only libs)
- Build and install applications
- Configure and organize unit tests
- Enable and run code‑coverage
- Generate code from Protocol Buffers / gRPC definitions

The modules live under `cmake/` and are typically consumed via Conan and
`terminus-setup`, but they can also be used directly in standalone projects.


Requirements
------------

- **CMake**: version **4.0.0 or newer**
- A C++ compiler compatible with your project (GCC, Clang, MSVC, Emscripten, etc.)
- Optional, depending on which helpers you use:
  - **GoogleTest** for unit‑test helpers
  - **gcov** (or compatible) for coverage helpers
  - **Protobuf** and **gRPC** for protobuf helpers


Basic Usage
-----------

In a typical consumer project (for example, `terminus-log`), you bring in the
helpers by installing the `terminus-cmake` package (e.g., via Conan) and then
including the dispatcher module:

```cmake
cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )

project( my_project LANGUAGES CXX )

include( terminus_cmake )  # Provided by this repository

# Now you can call helpers such as:
#   terminus_lib_create_header_only()
#   terminus_app_configure(...)
#   terminus_test_prepare_unit()
#   terminus_coverage_enable()
```

The `terminus_cmake.cmake` dispatcher pulls in the following modules:

- `terminus_cmake_apps.cmake`
- `terminus_cmake_colors.cmake`
- `terminus_cmake_coverage.cmake`
- `terminus_cmake_libs.cmake`
- `terminus_cmake_project.cmake`
- `terminus_cmake_protobuf.cmake`
- `terminus_cmake_test.cmake`
- `terminus_cmake_util.cmake`


Configuring Warning Levels
--------------------------

`terminus_cmake_project.cmake` defines a standard way to control compiler
warning flags across all Terminus projects.

### Warning level selector

The primary knob is the cached variable:

- `TERMINUS_CXX_WARN_LEVEL` (cache STRING)
  - Valid values: `LOW`, `MEDIUM`, `HIGH`
  - **Default:** `MEDIUM`

You can set this per project *before* including `terminus_cmake`:

```cmake
set( TERMINUS_CXX_WARN_LEVEL "HIGH" CACHE STRING "Terminus C++ warning level" FORCE )
include( terminus_cmake )
```

If you do not set it, `MEDIUM` is used.

### Derived flag variables

Based on the selected level and the toolchain, the following variables are
populated:

- `TERMINUS_CXX_WARNING_FLAGS_LOW`
- `TERMINUS_CXX_WARNING_FLAGS_MEDIUM`
- `TERMINUS_CXX_WARNING_FLAGS_HIGH`
- `TERMINUS_CXX_WARNING_FLAGS` – the *active* set for this project
- `TERMINUS_CXX_FLAGS` – the set that helper functions actually apply to
  targets

You can still fully override flags if needed:

```cmake
set( TERMINUS_CXX_FLAGS -Wall -Wextra -Wpedantic -Werror )
include( terminus_cmake )
```

Since `TERMINUS_CXX_FLAGS` is only set by the helpers when it is not already
defined, project‑specific overrides win.


Library Helpers
---------------

Defined in `terminus_cmake_libs.cmake`.

### `terminus_lib_create_header_only()`

Creates an `INTERFACE` library target for header‑only projects, using the
current `PROJECT_NAME` as the target name.

Typical usage in a header‑only package:

```cmake
project( terminus_log LANGUAGES CXX )

include( terminus_cmake )

terminus_lib_create_header_only()

target_link_libraries( ${PROJECT_NAME} INTERFACE
    Boost::json
    Boost::log
    # ... other deps
)
```

This helper:

- Creates an `INTERFACE` target named `${PROJECT_NAME}`
- Configures standard include directories using
  `$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>` and
  `$<INSTALL_INTERFACE:include>`
- Installs headers found under `${PROJECT_SOURCE_DIR}/include` into
  the install prefix
- Optionally supports feature‑specific header directories via the
  `FEATURE_HEADERS` argument

### `terminus_lib_create_from_objects( OBJECTS ... )`

Given an `OBJECT` library, this helper creates both shared and static
libraries and configures them for installation.

Key behaviors:

- Creates `${PROJECT_NAME}` (shared) and `${PROJECT_NAME}_static` (static)
- Installs both, unless disabled with `NO_INSTALL_SHARED` / `NO_INSTALL_STATIC`
- Applies `TERMINUS_CXX_FLAGS` to the underlying object library
- Installs headers using the same conventions as the header‑only helper

Both helpers delegate most of the work to:

### `terminus_lib_configure( TARGET ... )`

This lower‑level helper is used internally to:

- Configure PIC and output directories for non‑header‑only targets
- Attach include directories
- Attach `TERMINUS_CXX_FLAGS` (for non‑INTERFACE targets)
- Install the target and its headers

Most projects do not call `terminus_lib_configure` directly; they use one of
the higher‑level creation helpers.


Application Helpers
-------------------

Defined in `terminus_cmake_apps.cmake`.

### `terminus_app_configure( TARGET )`

Applies common settings for C++ executables:

- Sets `RUNTIME_OUTPUT_DIRECTORY` to `${CMAKE_BINARY_DIR}/bin`
- Sets `INSTALL_RPATH` to `"$ORIGIN/../lib"`
- Applies `TERMINUS_CXX_FLAGS` (if set)
- Installs the target to `bin/`

Typical usage:

```cmake
add_executable( my_tool main.cpp )
target_link_libraries( my_tool PRIVATE terminus_log )

terminus_app_configure( my_tool )
```


Test Helpers
------------

Defined in `terminus_cmake_test.cmake`.

### `terminus_test_prepare_unit()`

Prepares a project for GoogleTest‑based unit tests by:

- Finding the GTest package
- Including `GoogleTest` helpers

Call this once before creating unit test targets.

### `terminus_test_add_unit( SUFFIX FILE [OPTIONS...] )`

Creates a unit test executable and registers it with CTest using
`gtest_discover_tests`.

Key parameters:

- `SUFFIX` – unique suffix used in the target name
- `FILE` – source file containing the tests

Options:

- `INCLUDES_MAIN` – test source defines its own `main()`

Single‑value arguments:

- `TARGET` – primary library target under test (defaults to `${PROJECT_NAME}`)

Multi‑value arguments:

- `EXTRA_LIBS` – extra libraries to link against

Example:

```cmake
enable_testing()
terminus_test_prepare_unit()

terminus_test_add_unit( logger TEST_Logger.cpp TARGET terminus_log )
```


Coverage Helpers
----------------

Defined in `terminus_cmake_coverage.cmake`.

### `terminus_coverage_enable()`

Sets global compiler flags required for coverage (e.g. GCC/Clang `--coverage`).
Call this **before** creating targets to ensure all relevant targets are built
with coverage instrumentation.

### `terminus_coverage_create_target( [IGNORE_TARGETS ...] )`

Creates a `coverage` custom target that:

- Runs tests (via `ctest`)
- Invokes `gcov` over all non‑INTERFACE library/executable targets
- Places reports under `${PROJECT_SOURCE_DIR}/coverage`

Use the `IGNORE_TARGETS` multi‑value argument to exclude specific targets
from coverage calculations.


Protobuf / gRPC Helpers
------------------------

Defined in `terminus_cmake_protobuf.cmake`.

### `terminus_protobuf_generate( SOURCES HEADERS LIBS ... )`

Generates C++ sources and headers from `.proto` definitions, including
optional gRPC service stubs.

High‑level behavior:

- Requires `find_package(Protobuf REQUIRED)` and `find_package(gRPC CONFIG REQUIRED)`
  to have been called in the project
- Invokes `protoc` to generate `.pb.cc` / `.pb.h` files (and `.grpc.pb.cc` /
  `.grpc.pb.h` if gRPC definitions are present)
- Populates three variables in the caller’s scope:
  - `SOURCES` – generated source files
  - `HEADERS` – generated headers
  - `LIBS` – libraries that must be linked against (protobuf and optionally gRPC)

Simplified usage sketch:

```cmake
find_package( Protobuf REQUIRED )
find_package( gRPC CONFIG REQUIRED )

terminus_protobuf_generate( PROTO_SOURCES PROTO_HEADERS PROTO_LIBS
    PROTO_PATH  "${CMAKE_CURRENT_SOURCE_DIR}/proto"
    PROTO_FILES person.proto
    GRPC_FILES  svc_directory.proto
)

add_executable( my_service
    main.cpp
    ${PROTO_SOURCES}
)

target_link_libraries( my_service PRIVATE ${PROTO_LIBS} )
```


Utility Helpers
---------------

Defined in `terminus_cmake_util.cmake`.

Two of the more commonly useful utilities are:

- `terminus_util_get_all_targets( OUT_VAR )`
  - Collects all CMake targets in the project (recursively) into `OUT_VAR`.
- `terminus_dump_cmake_variables( [REGEX] )`
  - Dumps current CMake variables to the log, optionally filtering by regex.

These helpers are especially handy when debugging CMake configurations or
coverage setups.


Colors and Logging Helpers
--------------------------

`terminus_cmake_colors.cmake` defines a set of ANSI color escape sequences for
use in messages on non‑Windows platforms. For example:

```cmake
message( STATUS "${YELLOW} This text will appear in yellow!${COLOR_RESET}" )
```

If the terminal does not support colors or the variables are not defined,
messages gracefully fall back to plain text.


Developing terminus-cmake Itself
--------------------------------

The top‑level `CMakeLists.txt` of this repository is primarily intended for
developing and testing the CMake helpers themselves.

Key points:

- `cmake_minimum_required( VERSION 4.0.0 FATAL_ERROR )` is enforced at the top level.
- If `TERMINUS_CMAKE_ENABLE_TESTS` is true, unit tests under `test/` are enabled.

When making changes to the helpers, you can:

1. Configure and build this repository with CMake as usual.
2. Turn on `TERMINUS_CMAKE_ENABLE_TESTS` to validate the helpers.
3. Install or export the CMake package so other Terminus repositories can
   consume the updated helpers.


Relationship to terminus-setup
-------------------------------

The [`terminus-setup`](https://github.com/Terminus-Geospatial/terminus-setup)
repository provides scripts and tooling for bootstrapping a Terminus
development environment. It typically handles installing CMake, Conan, and
the `terminus-cmake` package into a consistent layout.

This repository focuses on the **CMake logic itself**; `terminus-setup`
repo includes tools for building projects.

