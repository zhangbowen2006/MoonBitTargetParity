///|
/// Render a deterministic full-context unified diff for textual output.
/// Inputs above one million line-pairs use a bounded summary instead of an
/// unbounded quadratic table.
pub fn unified_text_diff(expected : String, observed : String) -> String {
  let expected_lines = split_diff_lines(expected)
  let observed_lines = split_diff_lines(observed)
  let old_count = expected_lines.length()
  let new_count = observed_lines.length()
  let mut output = "--- expected\n+++ observed\n"
  if old_count > 0 && new_count > 1000000 / old_count {
    output += "@@ diff omitted: line matrix exceeds 1,000,000 pairs @@\n"
    output += "- expected output: " + old_count.to_string() + " lines\n"
    output += "+ observed output: " + new_count.to_string() + " lines\n"
    return output
  }

  let table : Array[Array[Int]] = []
  let mut row = 0
  while row <= old_count {
    table.push(Array::make(new_count + 1, 0))
    row += 1
  }
  let mut old_index = old_count - 1
  while old_index >= 0 {
    let mut new_index = new_count - 1
    while new_index >= 0 {
      if expected_lines[old_index] == observed_lines[new_index] {
        table[old_index][new_index] = table[old_index + 1][new_index + 1] + 1
      } else if table[old_index + 1][new_index] >=
        table[old_index][new_index + 1] {
        table[old_index][new_index] = table[old_index + 1][new_index]
      } else {
        table[old_index][new_index] = table[old_index][new_index + 1]
      }
      new_index -= 1
    }
    old_index -= 1
  }

  output += "@@ -1," +
    old_count.to_string() +
    " +1," +
    new_count.to_string() +
    " @@\n"
  old_index = 0
  let mut new_index = 0
  while old_index < old_count || new_index < new_count {
    if old_index < old_count &&
      new_index < new_count &&
      expected_lines[old_index] == observed_lines[new_index] {
      output += " " + expected_lines[old_index] + "\n"
      old_index += 1
      new_index += 1
    } else if old_index < old_count &&
      (
        new_index >= new_count ||
        table[old_index + 1][new_index] >= table[old_index][new_index + 1]
      ) {
      output += "-" + expected_lines[old_index] + "\n"
      old_index += 1
    } else {
      output += "+" + observed_lines[new_index] + "\n"
      new_index += 1
    }
  }
  output
}

///|
fn split_diff_lines(text : String) -> Array[String] {
  let lines : Array[String] = []
  for view in text.split("\n") {
    lines.push(view.to_owned())
  }
  if text.has_suffix("\n") &&
    lines.length() > 0 &&
    lines[lines.length() - 1] == "" {
    lines.pop() |> ignore
  }
  lines
}
