import { spawnSync } from 'node:child_process';

const minimum = [0, 10, 14];
const result = spawnSync('moon', ['version', '--all'], { encoding: 'utf8' });
if (result.error || result.status !== 0) {
  console.error('FAIL: cannot run moon version --all');
  process.exit(1);
}

const output = `${result.stdout ?? ''}\n${result.stderr ?? ''}`;
const match = output.match(/^moonc v(\d+)\.(\d+)\.(\d+)(?:\+|\b)/m);
if (!match) {
  console.error('FAIL: cannot determine moonc version from moon version --all');
  process.exit(1);
}

const actual = match.slice(1).map(Number);
let comparison = 0;
for (let index = 0; index < minimum.length; index += 1) {
  if (actual[index] !== minimum[index]) {
    comparison = actual[index] - minimum[index];
    break;
  }
}

if (comparison < 0) {
  console.error(`FAIL: moonc v${actual.join('.')} is below required v${minimum.join('.')}`);
  process.exit(1);
}
console.log(`PASS: moonc v${actual.join('.')} meets minimum v${minimum.join('.')}`);
