import {resolve} from "node:path";
import {spawnSync} from "node:child_process";

const inputPath = process.argv[2];
if (!inputPath) {
  console.error("usage: node scripts/compare_file.mjs <scenario-run.json>");
  process.exit(2);
}

const result = spawnSync(
  "moon",
  ["run", "--target", "js", "cmd/main", "--", "compare-file", resolve(inputPath)],
  {encoding: "utf8", windowsHide: true},
);
if (result.error) {
  console.error(`Could not launch MoonBit CLI: ${result.error.message}`);
  process.exit(2);
}
if (result.stdout) process.stdout.write(result.stdout);
if (result.stderr) process.stderr.write(result.stderr);
process.exit(result.status ?? 2);
