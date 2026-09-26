# Changelog

## 0.5.0 — 2026-09-26

- Added a six-package portable behavior corpus for arithmetic, Unicode/UTF-8,
  collections, JSON, Result/Option, and floating point.
- Extended the matrix runner to select a package per scenario and expand a
  shared expected result to each explicitly declared target.
- Applied JSON Pointer exclusions to both value and structural differences,
  including added/removed object members and array elements.
- Kept earlier schema-v1 JSON inputs compatible: omitted new policy fields
  default to zero tolerance and no ignored paths.

## 0.4.0 — 2026-09-25

- Added JSON Pointer subtree exclusions and absolute numeric tolerances.
- Reports now record each policy-suppressed difference so exceptions remain
  reviewable.
- Added tests for invalid pointer policies, negative tolerances, accepted JSON
  drift rules, and structural-difference exclusions.

## 0.3.0 — 2026-09-24

- Added opt-in ANSI SGR stripping and per-line trailing whitespace trimming.
- Added bounded unified text diffs to Markdown reports.
- Added an escaped, self-contained HTML report for offline review.
- Added coverage for normalization policy and large-diff memory limits.

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
