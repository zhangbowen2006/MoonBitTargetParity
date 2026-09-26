///|
test "result and option branch contract" {
  assert_eq(parse_or_default("42"), 42)
  assert_eq(parse_or_default("not-a-number"), -1)
  let success : Result[Int, String] = Ok(7)
  let missing : Result[Int, String] = Err("missing")
  assert_true(success is Ok(7))
  assert_true(missing is Err("missing"))
}
