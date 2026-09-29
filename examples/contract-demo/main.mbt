///|
/// These hand-authored results demonstrate the public API. The real backend
/// execution example is scripts/check_backends.mjs.
fn demo_reports() -> Array[@parity.ParityReport] {
  let passing = @parity.compare_scenario({
    schema_version: 1,
    name: "line-ending-portability",
    expected_targets: ["wasm", "js"],
    observations: [
      { target: "wasm", exit_code: 0, stdout: "{\"sum\":3}\r\n", stderr: "", },
      { target: "js", exit_code: 0, stdout: "{\"sum\":3}\n", stderr: "", },
    ],
    policy: @parity.ComparePolicy::strict(),
  })

  // Identical backends can still be wrong. Reviewed expectations catch that.
  let common_regression = @parity.compare_contract_scenario({
    scenario: {
      schema_version: 1,
      name: "shared-result-regression",
      expected_targets: ["wasm", "js"],
      observations: [
        { target: "wasm", exit_code: 0, stdout: "{\"sum\":4}\n", stderr: "", },
        { target: "js", exit_code: 0, stdout: "{\"sum\":4}\n", stderr: "", },
      ],
      policy: @parity.ComparePolicy::strict(),
    },
    expectations: [
      { target: "wasm", exit_code: 0, stdout: "{\"sum\":3}\n", stderr: "", },
      { target: "js", exit_code: 0, stdout: "{\"sum\":3}\n", stderr: "", },
    ],
  })

  let incomplete = @parity.compare_scenario({
    schema_version: 1,
    name: "missing-native-observation",
    expected_targets: ["wasm", "js", "native"],
    observations: [
      { target: "wasm", exit_code: 0, stdout: "ok\n", stderr: "", },
      { target: "js", exit_code: 0, stdout: "ok\n", stderr: "", },
    ],
    policy: @parity.ComparePolicy::strict(),
  })
  [passing, common_regression, incomplete]
}

///|
fn main {
  for report in demo_reports() {
    println(@parity.report_to_json(report))
  }
}
