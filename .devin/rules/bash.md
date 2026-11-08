---
trigger: always_on
---

# Bash standards

- Start executable scripts with `#!/usr/bin/env bash` and use `set -euo pipefail` before operational work. Handle expected failures explicitly instead of globally ignoring errors.
- Organize work into descriptive snake_case functions and a `main` entry point. Use snake_case local variables, `local` inside functions, and readonly UPPER_CASE constants where appropriate.
- If a script supports being sourced, guard its entry point with `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi` so sourcing it does not execute the command. Keep operational setup, including strict-mode changes, inside the guarded execution path when it must not alter the caller's shell.
- Use braced expansions such as `"${variable}"`; quote paths and expansions to prevent word splitting/globbing. Use arrays for command arguments rather than assembling shell command strings.
- Use `[[ ... ]]` for conditionals. Check command exit status and emit actionable errors to stderr with nonzero exit codes.
- Resolve repository-relative paths from `BASH_SOURCE[0]`, not the caller's working directory. Distinguish workspace, source-repository, build, deployment, and output roots.
- Parse arguments before builds, logging side effects, environment setup, or network access. `--help` must exit successfully without building; invalid options must fail before operational work.
- Preserve the existing script header. Explain genuinely complex behavior when comments are requested; do not churn comments or copy stale example metadata.
- Do not log credentials or pass secrets as Docker build arguments. Use the established env-file/secrets mechanism and avoid shell tracing around secret handling.
- Do not delete existing build/deployment/data directories without explicit authorization for that action. Prefer targeted incremental verification or preserve old deployment output when applicable.
- Validate syntax with `bash -n`; use ShellCheck when available. Mock expensive/destructive integrations during argument/path tests, then distinguish those checks from real builds.
