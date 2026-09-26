///|
fn main {
  let input = "{\"nested\":{\"ok\":true,\"items\":[1,2,3]},\"label\":\"月🚀\"}"
  let payload = @corejson.parse(input) catch { _ => Json::null() }
  println(payload.stringify())
}
