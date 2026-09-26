///|
test "floating point arithmetic contract" {
  let sum = 0.1 + 0.2
  assert_true((sum - 0.3).abs() < 0.000000000000001)
  assert_true(!sum.is_nan())
}
