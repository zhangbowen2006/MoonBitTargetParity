///|
fn main {
  let wrapped = 2147483647 + 1
  let quotient = -7 / 3
  let remainder = -7 % 3
  let shifted = 1 << 8
  let payload = Json::object(
    Map::from_array([
      ("int_wrap", Json::number(wrapped.to_double())),
      ("negative_quotient", Json::number(quotient.to_double())),
      ("negative_remainder", Json::number(remainder.to_double())),
      ("shifted", Json::number(shifted.to_double())),
    ]),
  )
  println(payload.stringify())
}
