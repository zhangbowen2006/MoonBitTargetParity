///|
/// One target's observable result for a named, identical test scenario.
pub(all) struct Observation {
  target : String
  exit_code : Int
  stdout : String
  stderr : String
} derive(ToJson, FromJson)

///|
pub extend Observation with ToJson::{to_json}

///|
pub extend Observation with @json.FromJson::{from_json}

///|
/// Controls only explicitly documented normalization. Exit codes are always
/// compared; stdout is always compared; stderr can be opted out of.
pub(all) struct ComparePolicy {
  normalize_line_endings : Bool
  trim_one_final_newline : Bool
  compare_stderr : Bool
  compare_stdout_as_json : Bool
  strip_ansi_sgr : Bool
  trim_trailing_whitespace_per_line : Bool
  absolute_number_tolerance : Double
  ignored_json_pointers : Array[String]
} derive(ToJson)

///|
pub extend ComparePolicy with ToJson::{to_json}

///|
fn[T : @json.FromJson] json_object_field(
  fields : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> T raise @json.JsonDecodeError {
  match fields.get(key) {
    Some(value) => @json.from_json(value, path=path.add_key(key))
    None =>
      raise @json.JsonDecodeError((path.add_key(key), "missing required field"))
  }
}

///|
fn[T : @json.FromJson] json_object_field_or(
  fields : Map[String, Json],
  key : String,
  path : @json.JsonPath,
  fallback : T,
) -> T raise @json.JsonDecodeError {
  match fields.get(key) {
    Some(value) => @json.from_json(value, path=path.add_key(key))
    None => fallback
  }
}

///|
pub impl @json.FromJson for ComparePolicy with fn from_json(json, path) {
  guard json is Json::Object(fields) else {
    raise @json.JsonDecodeError(
      (path, "ComparePolicy::from_json: expected object"),
    )
  }
  {
    normalize_line_endings: json_object_field(
      fields, "normalize_line_endings", path,
    ),
    trim_one_final_newline: json_object_field(
      fields, "trim_one_final_newline", path,
    ),
    compare_stderr: json_object_field(fields, "compare_stderr", path),
    compare_stdout_as_json: json_object_field(
      fields, "compare_stdout_as_json", path,
    ),
    strip_ansi_sgr: json_object_field(fields, "strip_ansi_sgr", path),
    trim_trailing_whitespace_per_line: json_object_field(
      fields, "trim_trailing_whitespace_per_line", path,
    ),
    absolute_number_tolerance: json_object_field_or(
      fields, "absolute_number_tolerance", path, 0.0,
    ),
    ignored_json_pointers: json_object_field_or(
      fields,
      "ignored_json_pointers",
      path,
      [],
    ),
  }
}

///|
pub extend ComparePolicy with @json.FromJson::{from_json}

///|
pub fn ComparePolicy::strict() -> ComparePolicy {
  {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: true,
    compare_stdout_as_json: false,
    strip_ansi_sgr: false,
    trim_trailing_whitespace_per_line: false,
    absolute_number_tolerance: 0.0,
    ignored_json_pointers: [],
  }
}

///|
/// Declares the targets expected for one scenario and the captured outcomes.
/// Target names are labels; callers may use official MoonBit targets or
/// explicitly named host/runtime variants.
pub(all) struct ScenarioRun {
  schema_version : Int
  name : String
  expected_targets : Array[String]
  observations : Array[Observation]
  policy : ComparePolicy
} derive(ToJson, FromJson)

///|
pub extend ScenarioRun with ToJson::{to_json}

///|
pub extend ScenarioRun with @json.FromJson::{from_json}

///|
/// An optional accepted result contract for each declared target. When a
/// contract is provided, parity and expected-result checks both have to pass.
pub(all) struct ContractScenario {
  scenario : ScenarioRun
  expectations : Array[Observation]
} derive(ToJson, FromJson)

///|
pub extend ContractScenario with ToJson::{to_json}

///|
pub extend ContractScenario with @json.FromJson::{from_json}

///|
pub enum Status {
  Pass
  Divergent
  Inconclusive
}

///|
pub(all) struct FieldDifference {
  target : String
  kind : String
  field : String
  path : String?
  reference : String
  observed : String
} derive(ToJson)

///|
pub extend FieldDifference with ToJson::{to_json}

///|
pub(all) struct ParityReport {
  scenario : String
  status : Status
  diagnostics : Array[String]
  reference_target : String?
  compared_targets : Array[String]
  missing_targets : Array[String]
  unexpected_targets : Array[String]
  duplicate_targets : Array[String]
  differences : Array[FieldDifference]
  suppressed_differences : Array[SuppressedDifference]
}

///|
/// A comparison omitted by an explicit policy rule or numeric tolerance.
pub(all) struct SuppressedDifference {
  target : String
  path : String
  reason : String
} derive(ToJson)

///|
pub extend SuppressedDifference with ToJson::{to_json}

///|
pub(all) struct SuiteReport {
  status : Status
  scenario_count : Int
  passed : Int
  divergent : Int
  inconclusive : Int
  reports : Array[ParityReport]
}
