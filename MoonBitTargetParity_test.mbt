///|
test "identical observations pass" {
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "stable-json",
    expected_targets: ["js", "wasm", "native"],
    observations: [
      { target: "js", exit_code: 0, stdout: "{\"ok\":true}\n", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "{\"ok\":true}\n", stderr: "", },
      { target: "native", exit_code: 0, stdout: "{\"ok\":true}\n", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  })
  assert_true(report.status is @moonbit-target-parity.Status::Pass)
  assert_eq(report.reference_target, Some("js"))
  assert_eq(report.differences.length(), 0)
}

///|
test "changed stdout and exit status are reported" {
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "overflow-boundary",
    expected_targets: ["wasm", "js"],
    observations: [
      { target: "wasm", exit_code: 0, stdout: "2147483647", stderr: "", },
      { target: "js", exit_code: 1, stdout: "-2147483648", stderr: "panic", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  })
  assert_true(report.status is @moonbit-target-parity.Status::Divergent)
  assert_eq(report.differences.length(), 3)
}

///|
test "missing target is inconclusive" {
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "missing-native",
    expected_targets: ["js", "wasm", "native"],
    observations: [
      { target: "js", exit_code: 0, stdout: "ok", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "ok", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  })
  assert_true(report.status is @moonbit-target-parity.Status::Inconclusive)
  assert_eq(report.missing_targets, ["native"])
}

///|
test "duplicate and undeclared target never silently pass" {
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "bad-matrix",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "ok", stderr: "", },
      { target: "js", exit_code: 0, stdout: "ok", stderr: "", },
      { target: "host-x", exit_code: 0, stdout: "ok", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  })
  assert_true(report.status is @moonbit-target-parity.Status::Inconclusive)
  assert_eq(report.duplicate_targets, ["js"])
  assert_eq(report.unexpected_targets, ["host-x"])
}

///|
test "newline normalization is explicit and opt-in" {
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "line-endings",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "a\r\nb\r\n", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "a\nb\n", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  })
  assert_eq(report.differences.length(), 0)
  assert_true(report.status is @moonbit-target-parity.Status::Pass)
}

///|
test "one trailing newline policy does not trim more" {
  let policy : @moonbit-target-parity.ComparePolicy = {
    normalize_line_endings: false,
    trim_one_final_newline: true,
    compare_stderr: true,
    compare_stdout_as_json: false,
    strip_ansi_sgr: false,
    trim_trailing_whitespace_per_line: false,
  }
  let equal = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "one-newline",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "a", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "a\n", stderr: "", },
    ],
    policy,
  })
  assert_true(equal.status is @moonbit-target-parity.Status::Pass)
  let not_equal = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "two-newlines",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "a", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "a\n\n", stderr: "", },
    ],
    policy,
  })
  assert_true(not_equal.status is @moonbit-target-parity.Status::Divergent)
}

///|
test "diagnostic mode can omit stderr but never stdout or exit code" {
  let policy : @moonbit-target-parity.ComparePolicy = {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: false,
    compare_stdout_as_json: false,
    strip_ansi_sgr: false,
    trim_trailing_whitespace_per_line: false,
  }
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "stderr-policy",
    expected_targets: ["js", "native"],
    observations: [
      { target: "js", exit_code: 0, stdout: "same", stderr: "host warning A", },
      {
        target: "native",
        exit_code: 0,
        stdout: "same",
        stderr: "host warning B",
      },
    ],
    policy,
  })
  assert_true(report.status is @moonbit-target-parity.Status::Pass)
}

///|
test "JSON stdout comparison ignores object member order but preserves array order" {
  let policy : @moonbit-target-parity.ComparePolicy = {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: true,
    compare_stdout_as_json: true,
    strip_ansi_sgr: false,
    trim_trailing_whitespace_per_line: false,
  }
  let object_order = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "json-object-order",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "{\"a\":1,\"b\":2}", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "{\"b\":2,\"a\":1}", stderr: "", },
    ],
    policy,
  })
  assert_true(object_order.status is @moonbit-target-parity.Status::Pass)
  let array_order = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "json-array-order",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "[1,2]", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "[2,1]", stderr: "", },
    ],
    policy,
  })
  assert_true(array_order.status is @moonbit-target-parity.Status::Divergent)
  assert_eq(array_order.differences[0].path, Some("/0"))
}

///|
test "JSON differences identify escaped nested pointer paths" {
  let policy : @moonbit-target-parity.ComparePolicy = {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: true,
    compare_stdout_as_json: true,
    strip_ansi_sgr: false,
    trim_trailing_whitespace_per_line: false,
  }
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "json-pointer",
    expected_targets: ["wasm", "js"],
    observations: [
      {
        target: "wasm",
        exit_code: 0,
        stdout: "{\"outer\":{\"a/b\":{\"~key\":1}}}",
        stderr: "",
      },
      {
        target: "js",
        exit_code: 0,
        stdout: "{\"outer\":{\"a/b\":{\"~key\":2}}}",
        stderr: "",
      },
    ],
    policy,
  })
  assert_true(report.status is @moonbit-target-parity.Status::Divergent)
  assert_eq(report.differences.length(), 1)
  assert_eq(report.differences[0].field, "stdout_json")
  assert_eq(report.differences[0].path, Some("/outer/a~1b/~0key"))
}

///|
test "suite aggregates independent scenarios without hiding divergence" {
  let pass : @moonbit-target-parity.ScenarioRun = {
    schema_version: 1,
    name: "same",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "ok", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "ok", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  }
  let missing : @moonbit-target-parity.ScenarioRun = {
    schema_version: 1,
    name: "missing",
    expected_targets: ["js", "wasm"],
    observations: [{ target: "js", exit_code: 0, stdout: "ok", stderr: "", }],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  }
  let suite = @moonbit-target-parity.compare_suite([pass, missing])
  assert_true(suite.status is @moonbit-target-parity.Status::Inconclusive)
  assert_eq(suite.passed, 1)
  assert_eq(suite.inconclusive, 1)
  assert_eq(suite.reports.length(), 2)
  assert_eq(@moonbit-target-parity.suite_report_exit_code(suite), 2)
}

///|
test "invalid schema, empty scenario, and one-target contract are inconclusive" {
  let report = @moonbit-target-parity.compare_scenario({
    schema_version: 9,
    name: "",
    expected_targets: ["js"],
    observations: [{ target: "js", exit_code: 0, stdout: "ok", stderr: "", }],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  })
  assert_true(report.status is @moonbit-target-parity.Status::Inconclusive)
  assert_eq(report.diagnostics.length(), 3)
}

///|
test "suite divergence takes precedence over missing target evidence" {
  let divergent : @moonbit-target-parity.ScenarioRun = {
    schema_version: 1,
    name: "changed-output",
    expected_targets: ["js", "wasm"],
    observations: [
      { target: "js", exit_code: 0, stdout: "one", stderr: "", },
      { target: "wasm", exit_code: 0, stdout: "two", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  }
  let missing : @moonbit-target-parity.ScenarioRun = {
    schema_version: 1,
    name: "missing-native",
    expected_targets: ["js", "native"],
    observations: [{ target: "js", exit_code: 0, stdout: "ok", stderr: "", }],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  }
  let suite = @moonbit-target-parity.compare_suite([divergent, missing])
  assert_true(suite.status is @moonbit-target-parity.Status::Divergent)
  assert_eq(@moonbit-target-parity.suite_report_exit_code(suite), 1)
}

///|
test "unified text diff preserves context and marks removed and added lines" {
  let diff = @moonbit-target-parity.unified_text_diff(
    "first\nold value\nlast\n", "first\nnew value\nlast\n",
  )
  assert_true(diff.contains(" first\n"))
  assert_true(diff.contains("-old value\n"))
  assert_true(diff.contains("+new value\n"))
  assert_true(diff.contains(" last\n"))
}

///|
test "unified text diff handles empty and unchanged files" {
  let added = @moonbit-target-parity.unified_text_diff("", "one\ntwo")
  assert_true(added.contains("+one\n"))
  assert_true(added.contains("+two\n"))
  let unchanged = @moonbit-target-parity.unified_text_diff("same\n", "same\n")
  assert_true(unchanged.contains(" same\n"))
  assert_true(!unchanged.contains("+same"))
  assert_true(!unchanged.contains("-same"))
}

///|
test "ANSI SGR and trailing whitespace normalization are opt-in" {
  let policy : @moonbit-target-parity.ComparePolicy = {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: true,
    compare_stdout_as_json: false,
    strip_ansi_sgr: true,
    trim_trailing_whitespace_per_line: true,
  }
  let normalized = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "terminal-formatting",
    expected_targets: ["native", "js"],
    observations: [
      {
        target: "native",
        exit_code: 0,
        stdout: "\u{1b}[31mred\u{1b}[0m  \nplain\t",
        stderr: "",
      },
      { target: "js", exit_code: 0, stdout: "red\nplain", stderr: "", },
    ],
    policy,
  })
  assert_true(normalized.status is @moonbit-target-parity.Status::Pass)

  let strict_policy : @moonbit-target-parity.ComparePolicy = {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: true,
    compare_stdout_as_json: false,
    strip_ansi_sgr: false,
    trim_trailing_whitespace_per_line: false,
  }
  let strict = @moonbit-target-parity.compare_scenario({
    schema_version: 1,
    name: "terminal-formatting-strict",
    expected_targets: ["native", "js"],
    observations: [
      {
        target: "native",
        exit_code: 0,
        stdout: "\u{1b}[31mred\u{1b}[0m  \nplain\t",
        stderr: "",
      },
      { target: "js", exit_code: 0, stdout: "red\nplain", stderr: "", },
    ],
    policy: strict_policy,
  })
  assert_true(strict.status is @moonbit-target-parity.Status::Divergent)
}

///|
test "large unified diffs stop before allocating an unbounded matrix" {
  let mut expected = ""
  let mut observed = ""
  let mut i = 0
  while i < 1001 {
    expected += "old\n"
    observed += "new\n"
    i += 1
  }
  let diff = @moonbit-target-parity.unified_text_diff(expected, observed)
  assert_true(diff.contains("diff omitted"))
}

///|
test "HTML suite report escapes untrusted scenario and output text" {
  let run : @moonbit-target-parity.ScenarioRun = {
    schema_version: 1,
    name: "<script>scenario</script>",
    expected_targets: ["wasm", "js"],
    observations: [
      {
        target: "wasm",
        exit_code: 0,
        stdout: "<script>1</script>",
        stderr: "",
      },
      { target: "js", exit_code: 0, stdout: "<script>2</script>", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  }
  let report = @moonbit-target-parity.compare_suite([run])
  let html = @moonbit-target-parity.suite_report_to_html(report)
  assert_true(html.contains("&lt;script&gt;scenario&lt;/script&gt;"))
  assert_true(html.contains("&lt;script&gt;1&lt;/script&gt;"))
  assert_true(!html.contains("<script>1"))
  assert_true(html.contains("<meta charset=\"utf-8\">"))
}

///|
test "expected-result contracts catch identical cross-target regressions" {
  let scenario : @moonbit-target-parity.ScenarioRun = {
    schema_version: 1,
    name: "shared-regression",
    expected_targets: ["wasm", "js"],
    observations: [
      { target: "wasm", exit_code: 0, stdout: "{\"value\":2}", stderr: "", },
      { target: "js", exit_code: 0, stdout: "{\"value\":2}", stderr: "", },
    ],
    policy: {
      normalize_line_endings: true,
      trim_one_final_newline: false,
      compare_stderr: true,
      compare_stdout_as_json: true,
      strip_ansi_sgr: false,
      trim_trailing_whitespace_per_line: false,
    },
  }
  let report = @moonbit-target-parity.compare_contract_scenario({
    scenario,
    expectations: [
      { target: "wasm", exit_code: 0, stdout: "{\"value\":1}", stderr: "", },
      { target: "js", exit_code: 0, stdout: "{\"value\":1}", stderr: "", },
    ],
  })
  assert_true(report.status is @moonbit-target-parity.Status::Divergent)
  assert_eq(report.differences.length(), 2)
  assert_eq(report.differences[0].kind, "expected-result")
  assert_eq(report.differences[0].path, Some("/value"))
}

///|
test "partial expected-result contract is inconclusive" {
  let scenario : @moonbit-target-parity.ScenarioRun = {
    schema_version: 1,
    name: "partial-contract",
    expected_targets: ["wasm", "js"],
    observations: [
      { target: "wasm", exit_code: 0, stdout: "same", stderr: "", },
      { target: "js", exit_code: 0, stdout: "same", stderr: "", },
    ],
    policy: @moonbit-target-parity.ComparePolicy::strict(),
  }
  let report = @moonbit-target-parity.compare_contract_scenario({
    scenario,
    expectations: [
      { target: "wasm", exit_code: 0, stdout: "same", stderr: "", },
    ],
  })
  assert_true(report.status is @moonbit-target-parity.Status::Inconclusive)
  assert_true(
    report.diagnostics.contains("missing expected-result contract for js"),
  )
}
