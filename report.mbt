///|
fn status_label(status : Status) -> String {
  match status {
    Pass => "pass"
    Divergent => "divergent"
    Inconclusive => "inconclusive"
  }
}

///|
/// Process status contract for CI: 0 pass, 1 known divergence, 2 incomplete data.
pub fn report_exit_code(report : ParityReport) -> Int {
  match report.status {
    Pass => 0
    Divergent => 1
    Inconclusive => 2
  }
}

///|
pub fn report_to_json(report : ParityReport) -> String {
  let reference_target = match report.reference_target {
    Some(target) => Json::string(target)
    None => Json::null()
  }
  Json::object(
    Map::from_array([
      ("scenario", Json::string(report.scenario)),
      ("status", Json::string(status_label(report.status))),
      ("diagnostics", @json.to_json(report.diagnostics)),
      ("reference_target", reference_target),
      ("compared_targets", @json.to_json(report.compared_targets)),
      ("missing_targets", @json.to_json(report.missing_targets)),
      ("unexpected_targets", @json.to_json(report.unexpected_targets)),
      ("duplicate_targets", @json.to_json(report.duplicate_targets)),
      ("differences", @json.to_json(report.differences)),
    ]),
  ).stringify()
}

///|
pub fn report_to_markdown(report : ParityReport) -> String {
  let mut output = "# MoonBit target parity: " + report.scenario + "\n\n"
  output += "Status: **" + status_label(report.status) + "**\n\n"
  for diagnostic in report.diagnostics {
    output += "Diagnostic: " + diagnostic + "\n\n"
  }
  match report.reference_target {
    Some(target) => output += "Reference target: `" + target + "`\n\n"
    None => output += "Reference target: unavailable\n\n"
  }
  if report.missing_targets.length() > 0 {
    output += "Missing targets: " + report.missing_targets.join(", ") + "\n\n"
  }
  if report.unexpected_targets.length() > 0 {
    output += "Undeclared targets: " +
      report.unexpected_targets.join(", ") +
      "\n\n"
  }
  if report.duplicate_targets.length() > 0 {
    output += "Duplicate targets: " +
      report.duplicate_targets.join(", ") +
      "\n\n"
  }
  if report.differences.length() > 0 {
    output += "| Target | Check | Field | JSON path | Reference | Observed |\n"
    output += "| --- | --- | --- | --- | --- | --- |\n"
    for difference in report.differences {
      output += "| `" +
        difference.target +
        "` | `" +
        difference.kind +
        "` | `" +
        difference.field +
        "` | `" +
        difference.path.unwrap_or("") +
        "` | `" +
        escape_cell(difference.reference) +
        "` | `" +
        escape_cell(difference.observed) +
        "` |\n"
    }
  } else if report.status is Status::Pass {
    output += "All declared targets produced matching observable results.\n"
  }
  output
}

///|
pub fn suite_report_to_json(report : SuiteReport) -> String {
  let mut reports_json = "["
  for i, item in report.reports {
    if i > 0 {
      reports_json += ","
    }
    reports_json += report_to_json(item)
  }
  reports_json += "]"
  "{\"status\":" +
  Json::string(status_label(report.status)).stringify() +
  ",\"scenario_count\":" +
  report.scenario_count.to_string() +
  ",\"passed\":" +
  report.passed.to_string() +
  ",\"divergent\":" +
  report.divergent.to_string() +
  ",\"inconclusive\":" +
  report.inconclusive.to_string() +
  ",\"reports\":" +
  reports_json +
  "}"
}

///|
pub fn suite_report_exit_code(report : SuiteReport) -> Int {
  match report.status {
    Pass => 0
    Divergent => 1
    Inconclusive => 2
  }
}

///|
fn escape_cell(value : String) -> String {
  value
  .replace_all(old="|", new="\\|")
  .replace_all(old="\n", new="<br>")
  .replace_all(old="\r", new="")
}
