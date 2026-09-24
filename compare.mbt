///|
fn contains_string(values : Array[String], value : String) -> Bool {
  for item in values {
    if item == value {
      return true
    }
  }
  false
}

///|
fn normalize_output(text : String, policy : ComparePolicy) -> String {
  let normalized = if policy.normalize_line_endings {
    text.replace_all(old="\r\n", new="\n").replace_all(old="\r", new="\n")
  } else {
    text
  }
  if policy.trim_one_final_newline && normalized.has_suffix("\n") {
    normalized[0:normalized.length() - 1].to_owned()
  } else {
    normalized
  }
}

///|
/// Compare captured outcomes for one scenario. Missing, duplicate, or
/// undeclared target observations make the report inconclusive unless a
/// concrete divergence has already been observed.
pub fn compare_scenario(run : ScenarioRun) -> ParityReport {
  let missing_targets : Array[String] = []
  let unexpected_targets : Array[String] = []
  let duplicate_targets : Array[String] = []
  let diagnostics : Array[String] = []
  let seen_expected : Array[String] = []
  let compared_targets : Array[String] = []
  let differences : Array[FieldDifference] = []
  let seen_observations : Array[String] = []
  let mut reference : Observation? = None

  if run.schema_version != 1 {
    diagnostics.push("unsupported schema_version; expected 1")
  }
  if run.name.trim().is_empty() {
    diagnostics.push("scenario name must not be empty")
  }
  if run.expected_targets.length() < 2 {
    diagnostics.push("at least two expected targets are required")
  }

  for expected in run.expected_targets {
    if contains_string(seen_expected, expected) {
      if !contains_string(duplicate_targets, expected) {
        duplicate_targets.push(expected)
      }
    } else {
      seen_expected.push(expected)
      if !has_observation(run.observations, expected) {
        missing_targets.push(expected)
      } else {
        compared_targets.push(expected)
      }
    }
  }

  for observation in run.observations {
    if !contains_string(run.expected_targets, observation.target) {
      if !contains_string(unexpected_targets, observation.target) {
        unexpected_targets.push(observation.target)
      }
    }
    if contains_string(seen_observations, observation.target) {
      if !contains_string(duplicate_targets, observation.target) {
        duplicate_targets.push(observation.target)
      }
    } else {
      seen_observations.push(observation.target)
    }
  }

  for expected in run.expected_targets {
    match reference {
      None =>
        for observation in run.observations {
          if observation.target == expected {
            reference = Some(observation)
            break
          }
        }
      Some(_) => break
    }
  }

  match reference {
    None => ()
    Some(reference_observation) =>
      for expected in run.expected_targets {
        if expected != reference_observation.target {
          for observation in run.observations {
            if observation.target == expected {
              compare_observation_fields(
                reference_observation,
                observation,
                run.policy,
                differences,
              )
              break
            }
          }
        }
      }
  }

  let status = if differences.length() > 0 {
    Status::Divergent
  } else if missing_targets.length() > 0 ||
    unexpected_targets.length() > 0 ||
    duplicate_targets.length() > 0 ||
    diagnostics.length() > 0 {
    Status::Inconclusive
  } else {
    Status::Pass
  }
  {
    scenario: run.name,
    status,
    diagnostics,
    reference_target: reference.map(value => value.target),
    compared_targets,
    missing_targets,
    unexpected_targets,
    duplicate_targets,
    differences,
  }
}

///|
fn has_observation(observations : Array[Observation], target : String) -> Bool {
  for observation in observations {
    if observation.target == target {
      return true
    }
  }
  false
}

///|
fn compare_observation_fields(
  reference : Observation,
  observed : Observation,
  policy : ComparePolicy,
  differences : Array[FieldDifference],
) -> Unit {
  if reference.exit_code != observed.exit_code {
    differences.push({
      target: observed.target,
      field: "exit_code",
      path: None,
      reference: reference.exit_code.to_string(),
      observed: observed.exit_code.to_string(),
    })
  }
  let reference_stdout = normalize_output(reference.stdout, policy)
  let observed_stdout = normalize_output(observed.stdout, policy)
  if policy.compare_stdout_as_json {
    match
      (parse_json_output(reference_stdout), parse_json_output(observed_stdout)) {
      (Some(reference_json), Some(observed_json)) =>
        if !reference_json.equal(observed_json) {
          collect_json_differences(
            reference_json,
            observed_json,
            observed.target,
            "",
            0,
            differences,
          )
        }
      _ =>
        if reference_stdout != observed_stdout {
          differences.push({
            target: observed.target,
            field: "stdout",
            path: None,
            reference: reference_stdout,
            observed: observed_stdout,
          })
        }
    }
  } else if reference_stdout != observed_stdout {
    differences.push({
      target: observed.target,
      field: "stdout",
      path: None,
      reference: reference_stdout,
      observed: observed_stdout,
    })
  }
  if policy.compare_stderr {
    let reference_stderr = normalize_output(reference.stderr, policy)
    let observed_stderr = normalize_output(observed.stderr, policy)
    if reference_stderr != observed_stderr {
      differences.push({
        target: observed.target,
        field: "stderr",
        path: None,
        reference: reference_stderr,
        observed: observed_stderr,
      })
    }
  }
}

///|
fn parse_json_output(text : String) -> Json? {
  Some(@json.parse(text)) catch {
    _ => None
  }
}

///|
/// Collect deterministic JSON Pointer paths for nested differences.
fn collect_json_differences(
  reference : Json,
  observed : Json,
  target : String,
  path : String,
  depth : Int,
  differences : Array[FieldDifference],
) -> Unit {
  if reference.equal(observed) {
    return
  }
  if depth >= 64 {
    differences.push({
      target,
      field: "stdout_json",
      path: Some(if path == "" { "/" } else { path }),
      reference: "<maximum comparison depth>",
      observed: "<maximum comparison depth>",
    })
    return
  }
  match (reference, observed) {
    (Json::Object(reference_object), Json::Object(observed_object)) => {
      let keys = reference_object.keys().to_array()
      for key in observed_object.keys() {
        if !keys.contains(key) {
          keys.push(key)
        }
      }
      keys.sort()
      for key in keys {
        let child_path = path + "/" + escape_json_pointer_segment(key)
        match (reference_object.get(key), observed_object.get(key)) {
          (Some(reference_value), Some(observed_value)) =>
            collect_json_differences(
              reference_value,
              observed_value,
              target,
              child_path,
              depth + 1,
              differences,
            )
          (Some(reference_value), None) =>
            push_json_difference(
              target,
              child_path,
              reference_value,
              Json::string("<missing>"),
              differences,
            )
          (None, Some(observed_value)) =>
            push_json_difference(
              target,
              child_path,
              Json::string("<missing>"),
              observed_value,
              differences,
            )
          (None, None) => ()
        }
      }
    }
    (Json::Array(reference_array), Json::Array(observed_array)) => {
      let shared_length = if reference_array.length() < observed_array.length() {
        reference_array.length()
      } else {
        observed_array.length()
      }
      let mut index = 0
      while index < shared_length {
        collect_json_differences(
          reference_array[index],
          observed_array[index],
          target,
          path + "/" + index.to_string(),
          depth + 1,
          differences,
        )
        index += 1
      }
      if reference_array.length() != observed_array.length() {
        differences.push({
          target,
          field: "stdout_json",
          path: Some(path + "/length"),
          reference: reference_array.length().to_string(),
          observed: observed_array.length().to_string(),
        })
      }
    }
    _ => push_json_difference(target, path, reference, observed, differences)
  }
}

///|
fn push_json_difference(
  target : String,
  path : String,
  reference : Json,
  observed : Json,
  differences : Array[FieldDifference],
) -> Unit {
  differences.push({
    target,
    field: "stdout_json",
    path: Some(if path == "" { "/" } else { path }),
    reference: reference.stringify(),
    observed: observed.stringify(),
  })
}

///|
fn escape_json_pointer_segment(segment : String) -> String {
  segment.replace_all(old="~", new="~0").replace_all(old="/", new="~1")
}

///|
/// Compare a batch of independent scenarios and aggregate their status.
pub fn compare_suite(runs : Array[ScenarioRun]) -> SuiteReport {
  let reports = runs.map(run => compare_scenario(run))
  let mut passed = 0
  let mut divergent = 0
  let mut inconclusive = 0
  for report in reports {
    match report.status {
      Pass => passed += 1
      Divergent => divergent += 1
      Inconclusive => inconclusive += 1
    }
  }
  let status = if divergent > 0 {
    Status::Divergent
  } else if inconclusive > 0 || reports.length() == 0 {
    Status::Inconclusive
  } else {
    Status::Pass
  }
  {
    status,
    scenario_count: reports.length(),
    passed,
    divergent,
    inconclusive,
    reports,
  }
}
