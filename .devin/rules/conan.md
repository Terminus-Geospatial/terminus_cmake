---
trigger: always_on
---

# Conan standards

- Use Conan 2 APIs, `CMakeToolchain`, and `CMakeDeps`. Preserve the Terminus recipe banner and existing metadata conventions.
- Declare runtime dependencies with `requires`, build executables with `tool_requires`, and test dependencies with `test_requires`. Prefer these over deprecated `build_requires` calls in new/modified code.
- Require a compatible CMake executable directly in each recipe that invokes it. The current tested baseline is `cmake/4.1.2`; a transitive dependency on `terminus_cmake` alone does not make CMake available. Verify pins against the consuming project's minimum and supported platforms.
- Pin tested dependency versions and update downstream/package-test requirements together. Do not copy obsolete example pins such as `terminus_cmake/1.0.8` or old Log/Outcome versions without checking the current recipes.
- Follow semantic versioning: for stable releases, bump the major version for incompatible public API changes, the minor version for backward-compatible functionality, and the patch version for backward-compatible fixes. Before 1.0, document compatibility expectations explicitly and follow the project's release policy; do not imply that pre-1.0 minor releases are necessarily compatible. Keep recipe, CMake project, package-test requirements, and changelog versions aligned for releases.
- Prefer existing Terminus libraries when they provide a suitable maintained API rather than duplicating functionality or adding a parallel dependency. Verify ownership, behavior, and version compatibility before choosing one.
- `compiler.cppstd` is a Conan setting, not a package option: configure it in profiles or with `-s compiler.cppstd=23`, and validate the project's minimum when needed. Never put it in `default_options`.
- Expose appropriate `shared`, `with_tests`, `with_docs`, and `with_coverage` package options only where supported. Do not invent options on dependencies that do not declare them. Preserve validated shared/static choices rather than forcing the same setting on every package.
- Transfer package metadata and project-specific feature options into CMake variables consistently. Keep configure/build/package phases aligned with the actual recipe layout.
- Export the real source layout, including required library, template, application, test, and CMake files. Avoid copied `include/*` or `src/*` patterns when the project uses `library/`.
- Keep package IDs sensitive to ABI-affecting settings/options/dependencies for compiled libraries. Do not copy unconditional `self.info.clear()` from another recipe; use it only when the package's compatibility model genuinely permits it.
- Preserve minimum-release-age/security settings and avoid unbounded new dependencies. Inspect resolved graphs before changing versions, especially tightly coupled generated-code/runtime packages.
- Verify both local tests and downstream consumption. A successful export is not proof that tests passed, headers were exported, or runtime resources were deployed.
