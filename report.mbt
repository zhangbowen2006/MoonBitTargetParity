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
      ("suppressed_differences", @json.to_json(report.suppressed_differences)),
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
  if report.suppressed_differences.length() > 0 {
    output += "Policy-tolerated differences:\n"
    for item in report.suppressed_differences {
      output += "- `" +
        item.target +
        "` " +
        item.reason +
        " at `" +
        item.path +
        "`\n"
    }
    output += "\n"
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
    for difference in report.differences {
      if difference.field == "stdout" || difference.field == "stderr" {
        output += "\n<details><summary>Text diff for `" +
          difference.target +
          "` / `" +
          difference.field +
          "`</summary>\n\n<pre>"
        output += escape_html(
          unified_text_diff(difference.reference, difference.observed),
        )
        output += "</pre>\n</details>\n"
      }
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
/// Render a self-contained, dependency-free HTML summary for browser review.
pub fn suite_report_to_html(report : SuiteReport) -> String {
  let mut output = "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
  output += "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
  output += "<title>MoonBit Target Parity</title><style>"
  output += "body{font:15px system-ui,sans-serif;max-width:1100px;margin:2rem auto;padding:0 1rem;color:#18212b;background:#f7f9fb}"
  output += "header,section{background:white;border:1px solid #d8e0e8;border-radius:10px;padding:1rem 1.25rem;margin:1rem 0}"
  output += ".pass{color:#176b37}.divergent{color:#a11b1b}.inconclusive{color:#865900}"
  output += "table{width:100%;border-collapse:collapse;margin:.8rem 0}th,td{text-align:left;vertical-align:top;border-bottom:1px solid #e2e7ec;padding:.5rem}pre{white-space:pre-wrap;overflow-wrap:anywhere;background:#f1f4f7;padding:.65rem;border-radius:5px}code{overflow-wrap:anywhere}"
  output += "</style></head><body><header><h1>MoonBit Target Parity</h1>"
  output += "<p class=\"" +
    status_label(report.status) +
    "\"><strong>" +
    status_label(report.status) +
    "</strong></p>"
  output += "<p>Scenarios: " +
    report.scenario_count.to_string() +
    " · Passed: " +
    report.passed.to_string() +
    " · Divergent: " +
    report.divergent.to_string() +
    " · Inconclusive: " +
    report.inconclusive.to_string() +
    "</p></header>"
  for item in report.reports {
    output += "<section><h2>" + escape_html(item.scenario) + "</h2>"
    output += "<p class=\"" +
      status_label(item.status) +
      "\"><strong>" +
      status_label(item.status) +
      "</strong></p>"
    if item.reference_target is Some(target) {
      output += "<p>Reference target: <code>" +
        escape_html(target) +
        "</code></p>"
    }
    if item.diagnostics.length() > 0 {
      output += "<ul>"
      for diagnostic in item.diagnostics {
        output += "<li>" + escape_html(diagnostic) + "</li>"
      }
      output += "</ul>"
    }
    if item.suppressed_differences.length() > 0 {
      output += "<p>Policy-tolerated differences:</p><ul>"
      for suppressed in item.suppressed_differences {
        output += "<li><code>" +
          escape_html(suppressed.target) +
          "</code> " +
          escape_html(suppressed.reason) +
          " at <code>" +
          escape_html(suppressed.path) +
          "</code></li>"
      }
      output += "</ul>"
    }
    if item.missing_targets.length() > 0 {
      output += "<p>Missing targets: " +
        escape_html(item.missing_targets.join(", ")) +
        "</p>"
    }
    if item.differences.length() > 0 {
      output += "<table><thead><tr><th>Target</th><th>Check</th><th>Field</th><th>Path</th><th>Expected/reference</th><th>Observed</th></tr></thead><tbody>"
      for difference in item.differences {
        output += "<tr><td><code>" +
          escape_html(difference.target) +
          "</code></td>"
        output += "<td>" + escape_html(difference.kind) + "</td>"
        output += "<td>" + escape_html(difference.field) + "</td>"
        output += "<td><code>" +
          escape_html(difference.path.unwrap_or("")) +
          "</code></td>"
        output += "<td><pre>" +
          escape_html(difference.reference) +
          "</pre></td>"
        output += "<td><pre>" +
          escape_html(difference.observed) +
          "</pre></td></tr>"
      }
      output += "</tbody></table>"
    }
    output += "</section>"
  }
  output + "</body></html>"
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

///|
fn escape_html(value : String) -> String {
  value
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\"", new="&quot;")
  .replace_all(old="'", new="&#39;")
}
