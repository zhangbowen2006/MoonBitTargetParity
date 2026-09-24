///|
#module("node:fs")
extern "js" fn node_read_file(path : String, encoding : String) -> String = "readFileSync"

///|
#external
priv type NodeReadResult

///|
extern "js" fn read_text_result(
  read_file : (String, String) -> String,
  path : String,
) -> NodeReadResult =
  #| function(readFile, path) {
  #|   try {
  #|     return { ok: true, value: readFile(path, "utf8") }
  #|   } catch (error) {
  #|     return { ok: false, value: String(error?.message ?? error) }
  #|   }
  #| }

///|
extern "js" fn NodeReadResult::is_ok(self : Self) -> Bool =
  #| (result) => result.ok

///|
extern "js" fn NodeReadResult::value(self : Self) -> String =
  #| (result) => result.value

///|
fn read_text_result_for_path(path : String) -> NodeReadResult {
  read_text_result(node_read_file, path)
}
