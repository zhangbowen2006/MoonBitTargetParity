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
} derive(ToJson, FromJson)

///|
pub extend ComparePolicy with ToJson::{to_json}

///|
pub extend ComparePolicy with @json.FromJson::{from_json}

///|
pub fn ComparePolicy::strict() -> ComparePolicy {
  {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: true,
    compare_stdout_as_json: false,
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
}

///|
pub(all) struct SuiteReport {
  status : Status
  scenario_count : Int
  passed : Int
  divergent : Int
  inconclusive : Int
  reports : Array[ParityReport]
}
