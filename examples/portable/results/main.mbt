///|
fn parse_or_default(text : String) -> Int {
  @string.parse_int(text) catch {
    _ => -1
  }
}

///|
fn main {
  let success : Result[Int, String] = Ok(parse_or_default("42"))
  let missing : Result[Int, String] = Err("missing")
  let first = match success {
    Ok(value) => value
    Err(_) => -1
  }
  let fallback = match missing {
    Ok(value) => value
    Err(_) => parse_or_default("not-a-number")
  }
  let payload = Json::object(
    Map::from_array([
      ("parsed", Json::number(first.to_double())),
      ("fallback", Json::number(fallback.to_double())),
      ("option_some", Json::boolean(Some(first) is Some(_))),
      ("option_none", Json::boolean((None : Int?) is None)),
    ]),
  )
  println(payload.stringify())
}
