import {mkdtempSync, readFileSync, rmSync, writeFileSync} from "node:fs";
import {tmpdir} from "node:os";
import {isAbsolute, join, resolve} from "node:path";
import {fileURLToPath} from "node:url";
import {spawnSync} from "node:child_process";

const repoRoot = fileURLToPath(new URL("../", import.meta.url));
const configPath = resolve(process.argv[2] ?? "examples/portable-json.json");
const targetOverride = process.env.MOON_PARITY_TARGETS;

function fail(message, status = 2) {
  console.error(message);
  process.exit(status);
}

let config;
try {
  config = JSON.parse(readFileSync(configPath, "utf8"));
} catch (error) {
  fail(`Could not load matrix config ${configPath}: ${error.message}`);
}

if (config.schema_version !== 1) fail("matrix config schema_version must be 1");
function validatePackagePath(packagePath) {
  if (
    typeof packagePath !== "string" ||
    packagePath.length === 0 ||
    isAbsolute(packagePath) ||
    packagePath.includes("\\") ||
    packagePath.split("/").includes("..") ||
    !/^[A-Za-z0-9_./-]+$/.test(packagePath)
  ) {
    fail("package_path must be a safe module-relative MoonBit package path");
  }
}
validatePackagePath(config.package_path);

const targets = (targetOverride ?? config.targets?.join(",") ?? "")
  .split(",")
  .map(target => target.trim())
  .filter(Boolean);
if (targets.length < 2) fail("at least two targets must be declared");
if (targets.some(target => !/^[A-Za-z0-9_-]+$/.test(target))) {
  fail("target labels may contain only letters, digits, _ and -");
}
if (new Set(targets).size !== targets.length) fail("target list contains duplicates");
if (!Array.isArray(config.scenarios) || config.scenarios.length === 0) {
  fail("matrix config must contain at least one scenario");
}

const timeoutMs = Number.isInteger(config.timeout_ms) && config.timeout_ms > 0
  ? config.timeout_ms
  : 30000;
const reportFormat = process.env.MOON_PARITY_FORMAT ?? config.report_format ?? "json";
if (!new Set(["json", "html"]).has(reportFormat)) {
  fail("report_format must be json or html");
}
const scenarios = [];
for (const scenario of config.scenarios) {
  if (typeof scenario.name !== "string" || !scenario.name.trim()) {
    fail("each scenario needs a non-empty name");
  }
  const args = scenario.args ?? [];
  const scenarioPackagePath = scenario.package_path ?? config.package_path;
  validatePackagePath(scenarioPackagePath);
  if (!Array.isArray(args) || args.some(arg => typeof arg !== "string")) {
    fail(`scenario ${scenario.name}: args must be an array of strings`);
  }
  if (scenario.stdin !== undefined && typeof scenario.stdin !== "string") {
    fail(`scenario ${scenario.name}: stdin must be a string`);
  }
  const policy = {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: false,
    compare_stdout_as_json: false,
    strip_ansi_sgr: false,
    trim_trailing_whitespace_per_line: false,
    absolute_number_tolerance: 0,
    ignored_json_pointers: [],
    ...(scenario.policy ?? {}),
  };
  const observations = [];

  for (const target of targets) {
    const moonArgs = ["run", "--target", target, scenarioPackagePath];
    if (args.length > 0) moonArgs.push("--", ...args);
    const run = spawnSync("moon", moonArgs, {
      cwd: repoRoot,
      encoding: "utf8",
      input: scenario.stdin ?? "",
      timeout: timeoutMs,
      maxBuffer: 16 * 1024 * 1024,
      windowsHide: true,
    });
    if (run.error || run.status === null) {
      const why = run.error?.message ?? `timeout after ${timeoutMs} ms`;
      console.error(`Target ${target} produced no run observation: ${why}`);
      continue;
    }
    // Some Windows runtimes surface an unavailable C toolchain as unsigned
    // 0xFFFFFFFF. It cannot be represented by MoonBit Int, so keep it missing.
    if (run.status > 2147483647 || run.status < -2147483648) {
      console.error(`Target ${target} produced no representable exit status; it will be missing.`);
      continue;
    }
    observations.push({
      target,
      exit_code: run.status,
      stdout: run.stdout,
      stderr: run.stderr,
    });
  }

  const expectations = [];
  for (const expected of scenario.expectations ?? []) {
    if (expected.target === "*") {
      for (const target of targets) expectations.push({...expected, target});
    } else if (targets.includes(expected.target)) {
      expectations.push(expected);
    }
  }
  scenarios.push({
    scenario: {
      schema_version: 1,
      name: scenario.name,
      expected_targets: targets,
      observations,
      policy,
    },
    expectations,
  });
}

const tempDirectory = mkdtempSync(join(tmpdir(), "moon-bit-target-parity-"));
const suiteFile = join(tempDirectory, "suite.json");
try {
  writeFileSync(suiteFile, JSON.stringify(scenarios), {encoding: "utf8", mode: 0o600});
  const report = spawnSync(
    "moon",
    [
      "run",
      "--target",
      "js",
      "cmd/main",
      "--",
      reportFormat === "html" ? "compare-contract-suite-html-file" : "compare-contract-suite-file",
      suiteFile,
    ],
    {cwd: repoRoot, encoding: "utf8", timeout: timeoutMs, maxBuffer: 16 * 1024 * 1024, windowsHide: true},
  );
  if (report.error) {
    console.error(`Could not run MoonBit comparator: ${report.error.message}`);
    process.exitCode = 2;
  } else {
    if (report.stdout) process.stdout.write(report.stdout);
    if (report.stderr) process.stderr.write(report.stderr);
    process.exitCode = report.status ?? 2;
  }
} finally {
  rmSync(tempDirectory, {recursive: true, force: true});
}
