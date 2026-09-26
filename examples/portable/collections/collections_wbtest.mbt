///|
test "sorted arrays and map lookup contract" {
  assert_eq(sorted_values(), [1, 1, 3, 5])
  let table : Map[String, Int] = Map([])
  table.set("right", 32)
  assert_eq(table.get("right"), Some(32))
  assert_eq(table.contains("left"), false)
}
