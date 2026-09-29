// Keep the copy-ready September proposal aligned with this repository.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = relative => readFileSync(path.join(root, relative), 'utf8').replace(/\r\n/g, '\n');
const canonical = read('docs/PROJECT_PROPOSAL.md');
const copyReady = read('submission/MoonBitTargetParity_9月黑客松申报书_报名版.md');
const moduleText = read('moon.mod');
const field = name => {
  const match = moduleText.match(new RegExp(`^\\s*${name}\\s*=\\s*"([^"]+)"`, 'm'));
  assert.ok(match, `moon.mod missing ${name}`);
  return match[1];
};
const repository = field('repository').replace(/\.git$/, '');
const moduleName = field('name');
const version = field('version');

assert.equal(copyReady, canonical, 'Copy-ready and canonical proposals differ');
assert.equal(repository, 'https://github.com/zhangbowen2006/MoonBitTargetParity');
assert.equal(moduleName, 'zhangbowen2006/moonbit-target-parity');
for (const required of [
  '# MoonBit Target Parity｜MoonBit 多后端行为契约对照',
  '申请人：张博文',
  `新仓库：${repository}`,
  `项目模块：\`${moduleName}\``,
  `Mooncakes ${version}：`,
  'MoonBit 多后端',
]) {
  assert.ok(canonical.includes(required), `Proposal missing: ${required}`);
}
for (const oldTopic of ['MoonKeyguard', 'VS Code 扩展快捷键', 'MoonBVHKit']) {
  assert.ok(!canonical.includes(oldTopic), `Proposal contains another project: ${oldTopic}`);
}
console.log('PASS: new-topic proposal copies and repository identity match.');
