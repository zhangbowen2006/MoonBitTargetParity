///|
test "integer arithmetic contract" {
  assert_eq(2147483647 + 1, -2147483648)
  assert_eq(-7 / 3, -2)
  assert_eq(-7 % 3, -1)
  assert_eq(1 << 8, 256)
}
