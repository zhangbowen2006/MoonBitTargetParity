///|
test "MoonBit consumer example covers pass, shared regression and missing target" {
  let reports = demo_reports()
  assert_eq(reports.length(), 3)
  assert_true(reports[0].status is @parity.Status::Pass)
  assert_eq(@parity.report_exit_code(reports[0]), 0)
  assert_true(reports[1].status is @parity.Status::Divergent)
  assert_eq(@parity.report_exit_code(reports[1]), 1)
  assert_eq(reports[1].differences.length(), 2)
  assert_eq(reports[1].differences[0].kind, "expected-result")
  assert_true(reports[2].status is @parity.Status::Inconclusive)
  assert_eq(@parity.report_exit_code(reports[2]), 2)
  assert_eq(reports[2].missing_targets, ["native"])
}
