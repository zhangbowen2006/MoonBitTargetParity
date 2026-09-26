///|
fn main {
  let text = "MoonBit 月🚀"
  let payload = Json::object(
    Map::from_array([
      ("characters", Json::number(text.char_length().to_double())),
      ("utf8_bytes", Json::number(@utf8.encode(text).length().to_double())),
      ("contains_cjk", Json::boolean(text.contains("月"))),
      ("ascii_lower", Json::string("MOONBIT".to_lower())),
    ]),
  )
  println(payload.stringify())
}
