///|
test "unicode and utf8 contract" {
  let text = "MoonBit 月🚀"
  assert_eq(text.char_length(), 10)
  assert_eq(@utf8.encode(text).length(), 15)
  assert_true(text.contains("月"))
  assert_eq("MOONBIT".to_lower(), "moonbit")
}
