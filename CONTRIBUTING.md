// Contributing

// Thank you for contributing to this regulated, production-grade app suite.

// Governance & Compliance
// - All changes require review by at least one maintainer.
// - Pull requests must pass CI (build all schemes, run all tests) before merge.
// - Use signed commits and signed tags for releases where possible.
// - Maintain traceability: reference issue IDs and include rationale in PR descriptions.

// Branching & Versioning
// - Default: trunk-based development with short-lived feature branches.
// - Release tags follow SemVer (MAJOR.MINOR.PATCH).
// - Keep a clean CHANGELOG.md; update it in the same PR when behavior changes.

// Code Style & Quality
// - Swift 5.10+; prefer Swift Concurrency (async/await).
// - Add tests for new code; prefer fast, deterministic tests.
// - Avoid mocks for critical paths; prefer integration tests against real services where feasible.

// Configuration & Secrets
// - Do not commit secrets. Inject via CI or local environment variables.
// - Use .xcconfig files to parameterize endpoints and flags.

// Build & Test Locally
// - Build all: `./scripts/build_all.sh`
// - Test all: `./scripts/test_all.sh`

// Pull Request Checklist
// - [ ] Code builds locally
// - [ ] Tests pass locally
// - [ ] CI green
// - [ ] CHANGELOG updated
// - [ ] Documentation updated (README/wiki)

// Reporting Security Issues
// - Please report security issues privately to the maintainers.
