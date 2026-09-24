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
