import {spawnSync} from "node:child_process";

const root = new URL("../", import.meta.url);
const base = {
  schema_version: 1,
  name: "cli-contract",
  expected_targets: ["js", "wasm"],
  policy: {
    normalize_line_endings: true,
    trim_one_final_newline: false,
    compare_stderr: true,
    compare_stdout_as_json: false,
  },
};

function run(payload) {
  return spawnSync(
    "moon",
    ["run", "--target", "js", "cmd/main", "--", "compare-json", JSON.stringify(payload)],
    {cwd: root, encoding: "utf8", windowsHide: true},
  );
}

const pass = run({
  ...base,
  observations: [
    {target: "js", exit_code: 0, stdout: "ok\n", stderr: ""},
    {target: "wasm", exit_code: 0, stdout: "ok\n", stderr: ""},
  ],
});
if (pass.status !== 0 || JSON.parse(pass.stdout).status !== "pass") {
  throw new Error(`Expected pass exit 0; got ${pass.status}: ${pass.stdout}${pass.stderr}`);
}

const divergent = run({
  ...base,
  observations: [
    {target: "js", exit_code: 0, stdout: "ok\n", stderr: ""},
    {target: "wasm", exit_code: 1, stdout: "bad\n", stderr: "failure"},
  ],
});
if (divergent.status !== 1 || JSON.parse(divergent.stdout).status !== "divergent") {
  throw new Error(`Expected divergence exit 1; got ${divergent.status}: ${divergent.stdout}${divergent.stderr}`);
}

const incomplete = run({
  ...base,
  observations: [{target: "js", exit_code: 0, stdout: "ok\n", stderr: ""}],
});
if (incomplete.status !== 2 || JSON.parse(incomplete.stdout).status !== "inconclusive") {
  throw new Error(`Expected incomplete exit 2; got ${incomplete.status}: ${incomplete.stdout}${incomplete.stderr}`);
}

const malformed = spawnSync(
  "moon",
  ["run", "--target", "js", "cmd/main", "--", "compare-json", "{"],
  {cwd: root, encoding: "utf8", windowsHide: true},
);
if (malformed.status !== 2 || !malformed.stdout.includes("invalid scenario JSON")) {
  throw new Error(`Expected malformed-input exit 2; got ${malformed.status}: ${malformed.stdout}${malformed.stderr}`);
}

console.log("PASS: CLI pass/divergent/inconclusive/malformed-input paths");

const fileFixture = spawnSync(
  "node",
  ["scripts/compare_file.mjs", "examples/synthetic-divergence.json"],
  {cwd: root, encoding: "utf8", windowsHide: true},
);
if (fileFixture.status !== 1 || JSON.parse(fileFixture.stdout).status !== "divergent") {
  throw new Error(`Expected file fixture divergence exit 1; got ${fileFixture.status}: ${fileFixture.stdout}${fileFixture.stderr}`);
}

console.log("PASS: file-based JSON input path");
