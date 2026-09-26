///|
test "nested json round trip contract" {
  let value = @corejson.parse("{\"a\":[1,true,null]}")
  let encoded = value.stringify()
  let decoded = @corejson.parse(encoded)
  assert_true(value.equal(decoded))
}
