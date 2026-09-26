///|
fn main {
  let sum = 0.1 + 0.2
  let difference = sum - 0.3
  let payload = Json::object(
    Map::from_array([
      ("sum", Json::number(sum)),
      ("difference", Json::number(difference)),
      ("finite", Json::boolean(sum.is_nan() == false)),
    ]),
  )
  println(payload.stringify())
}
