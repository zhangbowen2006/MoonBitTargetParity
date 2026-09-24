///|
fn main {
  let largest = 2147483647
  let wrapped = largest + 1
  let sum = 19 + 23
  let json_line = "{\"sum\":" +
    sum.to_string() +
    ",\"int_wrap\":" +
    wrapped.to_string() +
    ",\"label\":\"MoonBit 月 🚀\",\"ok\":" +
    (sum == 42).to_string() +
    "}"
  println(json_line)
}
