///|
extern "js" fn exit_process(code : Int) -> Unit =
  #| (code) => process.exit(code)

///|
fn parse_scenario(text : String) -> @parity.ScenarioRun? {
  try {
    let json_value = @json.parse(text)
    Some(@json.from_json(json_value))
  } catch {
    _ => None
  }
}

///|
fn parse_suite(text : String) -> Array[@parity.ScenarioRun]? {
  try {
    let json_value = @json.parse(text)
    Some(@json.from_json(json_value))
  } catch {
    _ => None
  }
}

///|
fn parse_contract_suite(text : String) -> Array[@parity.ContractScenario]? {
  try {
    let json_value = @json.parse(text)
    Some(@json.from_json(json_value))
  } catch {
    _ => None
  }
}

///|
fn read_scenario_file(path : String) -> Result[@parity.ScenarioRun, String] {
  let file = read_text_result_for_path(path)
  if !file.is_ok() {
    return Err(file.value())
  }
  match parse_scenario(file.value()) {
    Some(scenario) => Ok(scenario)
    None => Err("invalid scenario JSON")
  }
}

///|
fn read_suite_file(path : String) -> Result[Array[@parity.ScenarioRun], String] {
  let file = read_text_result_for_path(path)
  if !file.is_ok() {
    return Err(file.value())
  }
  match parse_suite(file.value()) {
    Some(scenarios) => Ok(scenarios)
    None => Err("invalid scenario suite JSON")
  }
}

///|
fn read_contract_suite_file(
  path : String,
) -> Result[Array[@parity.ContractScenario], String] {
  let file = read_text_result_for_path(path)
  if !file.is_ok() {
    return Err(file.value())
  }
  match parse_contract_suite(file.value()) {
    Some(contracts) => Ok(contracts)
    None => Err("invalid contract suite JSON")
  }
}

///|
fn main {
  let args = @env.args()
  if args.length() != 4 {
    println(
      "usage: moon run --target js cmd/main -- compare-json|compare-file|compare-suite-json|compare-suite-file|compare-contract-suite-file <JSON-or-path>",
    )
    exit_process(2)
  } else if args[2] == "compare-json" {
    match parse_scenario(args[3]) {
      None => {
        println("invalid scenario JSON")
        exit_process(2)
      }
      Some(scenario) => {
        let report = @parity.compare_scenario(scenario)
        println(@parity.report_to_json(report))
        exit_process(@parity.report_exit_code(report))
      }
    }
  } else if args[2] == "compare-suite-json" {
    match parse_suite(args[3]) {
      None => {
        println("invalid scenario suite JSON")
        exit_process(2)
      }
      Some(scenarios) => {
        let report = @parity.compare_suite(scenarios)
        println(@parity.suite_report_to_json(report))
        exit_process(@parity.suite_report_exit_code(report))
      }
    }
  } else if args[2] == "compare-file" {
    match read_scenario_file(args[3]) {
      Err(message) => {
        println("scenario file error: " + message)
        exit_process(2)
      }
      Ok(scenario) => {
        let report = @parity.compare_scenario(scenario)
        println(@parity.report_to_json(report))
        exit_process(@parity.report_exit_code(report))
      }
    }
  } else if args[2] == "compare-suite-file" {
    match read_suite_file(args[3]) {
      Err(message) => {
        println("scenario suite file error: " + message)
        exit_process(2)
      }
      Ok(scenarios) => {
        let report = @parity.compare_suite(scenarios)
        println(@parity.suite_report_to_json(report))
        exit_process(@parity.suite_report_exit_code(report))
      }
    }
  } else if args[2] == "compare-contract-suite-file" {
    match read_contract_suite_file(args[3]) {
      Err(message) => {
        println("contract suite file error: " + message)
        exit_process(2)
      }
      Ok(contracts) => {
        let report = @parity.compare_contract_suite(contracts)
        println(@parity.suite_report_to_json(report))
        exit_process(@parity.suite_report_exit_code(report))
      }
    }
  } else {
    println("unknown command: " + args[2])
    exit_process(2)
  }
}
