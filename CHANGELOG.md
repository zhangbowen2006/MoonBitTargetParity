# Changelog

## 0.2.0 — 2026-09-24

- Added per-target expected-result contracts so regressions shared by all
  backends can be detected alongside cross-target differences.
- Added contract-suite JSON input and `expected-result` report classification.
- Extended the real matrix example with reviewed output baselines.
- The core API addition is backward-compatible with parity-only callers.

## 0.1.1 — 2026-09-24

- Updated README and acceptance evidence after publishing 0.1.0 to Mooncakes.
- No core behavior or public API changed.

## 0.1.0 — 2026-09-24

- Replaced the rejected VS Code shortcut topic with a MoonBit multi-backend
  behavior contract library.
- Added deterministic comparison of exit status, stdout, and optional stderr;
  explicit newline policy; optional structural JSON stdout comparison; suite
  aggregation; JSON Pointer diagnostics; and pass/divergent/inconclusive
  process statuses.
- Added a live four-target probe runner and retained explicit reporting when a
  requested target cannot run in the local environment.
