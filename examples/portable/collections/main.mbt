///|
fn sorted_values() -> Array[Int] {
  let values = [5, 1, 3, 1]
  values.sort()
  values
}

///|
fn main {
  let table : Map[String, Int] = Map([])
  table.set("left", 10)
  table.set("right", 32)
  let values = sorted_values()
  let values_json = Json::array(
    values.map(value => Json::number(value.to_double())),
  )
  let selected = table.get("right").unwrap_or(0)
  let payload = Json::object(
    Map::from_array([
      ("sorted", values_json),
      ("map_lookup", Json::number(selected.to_double())),
      ("contains_left", Json::boolean(table.contains("left"))),
    ]),
  )
  println(payload.stringify())
}
