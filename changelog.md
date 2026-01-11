# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.10] - 2026-01-11

### Changed
* Updating Terminus CMake Test script with rpath updates. 

## [1.0.9] - 2025-11-21

### Changed
- updated `terminus_cmake_libs.cmake` to look for include paths in `./library` folder.
- updated `terminus_cmake_libs.cmake` to set the rpath for apple differently than other platforms.

## [1.0.8] - 2025-11-20

### Added
- Updated `terminus_lib_create_header_only` to install headers from `${PROJECT_SOURCE_DIR}/library/include` to `${CMAKE_INSTALL_PREFIX}/include`

## [1.0.7] - 2025-11-20

### Added
- Updated TERMINUS_CXX_FLAGS to use HIGH by default
- Updated CMake minimum version to 4.0.0

## [0.0.6] - 2025-11-19

### Added
* This changelog now added.

