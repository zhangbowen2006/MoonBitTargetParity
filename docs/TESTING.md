# 测试记录

2026-09-29 补充套件场景名唯一性检查后，本地隔离 MoonBit 0.10.14：
`moon info`、`moon fmt`、`moon fmt --check`、`moon check --target all --deny-warn`、
`moon build`、`moon test --deny-warn`、`moon test --target js --deny-warn`、
`moon test --target wasm-gc --deny-warn`、CLI 回归、申报书身份检查及
`moon package --list --frozen` 均通过。三个实际运行的测试目标分别为
32/32；`moon build --target all` 和 `moon test --target all` 因本机缺少
C 编译器，不能作为 native 通过的证据。新增行为还需等待新提交的远程 CI。

2026-09-29 公开提交 `974e9f1` 的
[Actions run 36559411781](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36559411781)
已成功，包括四目标构建、测试、真实矩阵和公开 API 示例。此记录只证明该提交，
不代表其后本地未推送的改进已通过远程 CI。

2026-09-29 新增公开 API 直接调用示例后，本地 MoonBit 0.10.14：
`moon check --deny-warn`、`moon test --deny-warn`（30/30）、`moon info`、
`moon fmt --check` 均通过；`moon run examples/contract-demo` 在 wasm、js、
wasm-gc 目标均输出预期的 pass/divergent/inconclusive 三份报告。
生成接口无意外变更，`moon package --list` 包含示例；对应的四目标远程 CI
结果见上方 `974e9f1` 记录。

2026-09-29 申报材料同步复验：`node scripts/verify_submission.mjs` 通过；
隔离 MoonBit 0.10.14 下 `moon check --deny-warn`、`moon build`、
`moon test --deny-warn`（29/29）、`moon info`、`moon fmt` 与
`moon fmt --check` 通过；CLI 回归通过，本机 wasm/wasm-gc/js 的七场景矩阵
7/7 通过；`moon package --list` 包含新申报书及身份检查脚本。
本次变动尚未推送，不能用旧 CI 代表新提交；本机 native 仍未运行。

本机复核：2026-09-26，隔离安装的 MoonBit 0.10.14（Windows）。下表是 0.5.0 工作树的实际结果；其中 `native` 目标依赖的 C 编译器未安装，因此本机不报告 native 通过。

## 本机 Windows 复验

使用隔离工具链 `moon 0.1.20260920` / `moonc 0.10.14`。本机与公开 CI 运行记录：

| 命令 | 结果 |
| --- | --- |
| `moon check --deny-warn`、`moon build` | 通过 |
| `moon test --deny-warn` | 29/29 通过（核心库 + 六个 probe package） |
| `moon fmt --check`、`moon info` | 通过；生成接口与 0.5.0 新 API 一致 |
| `moon package --list --frozen` | 通过，清单未包含构建产物或临时文件 |
| `wasm` / `wasm-gc` / `js` 的 check、build、test | 均通过；各目标测试 29/29 |
| `node scripts/test_cli.mjs` | pass/divergent/inconclusive/坏 JSON、旧版 schema v1 策略兼容、文件输入及真实 HTML 报告路径通过 |
| `MOON_PARITY_TARGETS=wasm,wasm-gc,js node scripts/check_backends.mjs` | 7/7 场景通过；浮点容差吸收的细微差异仍出现在报告中 |
| `native` 本地验证 | 未运行：Windows 环境缺 C 编译器；需等待公开 Ubuntu CI 的四目标结果 |

0.5.0 首次推送的 [Actions run 36220160658](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36220160658) 中，检查、构建和测试均成功；格式步骤因 0.10.14 对单行对象字面量新增尾逗号格式而失败。用同版本 formatter 修复后的提交 `d458d9ce21b40b1e1f017b43c0740cfd58316dec`，对应 [Actions run 36220634863](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36220634863) 全部通过。

测试覆盖参考目标顺序、stdout/exit code 差异、缺少/重复/未声明目标、schema 错误、CRLF 规范化、ANSI/空白规范化 opt-in、末尾换行策略、stderr 开关、JSON 对象/数组语义、JSON Pointer 转义定位/排除（含字段和数组元素新增/删除）、绝对数字容差、expected-result 基线、unified diff 与大矩阵资源上限、HTML escaping、旧 schema v1 策略兼容及 suite 聚合。公开 CI 在 Ubuntu 上对四个 `--target all` 目标执行检查、构建、测试和真实探针；0.5.0 对应的新 CI 结果待本次推送后记录。

首个公开提交 `045b9263b878e4e1d2de6e829a67bdca6fa68039` 的 [GitHub Actions run 35986962761](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35986962761) 已成功。复审材料同步提交 `6e863bff95b0a6ee35ec5f5f4302e07aee180727` 的 [run 35987471426](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35987471426) 也成功。Mooncakes 0.1.0 的正式发布命令返回 `200 OK`，公开 manifest 显示构建成功且包可用。每条 CI 证据只对应各自提交。

0.1.1 文档同步提交 `da21a2ad9debea23b763b06b7e330612293af38a` 的 [run 35987911060](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35987911060) 成功。随后 `moon publish --frozen` 返回 `200 OK`；公开 manifest 已更新为 0.1.1、构建成功且包可用。

0.2.0 基线合同提交 `f8887ef36a9196226c1e1770f4685d61515e0c06` 的 [run 35990111751](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35990111751) 成功。Ubuntu 对所有目标完成严格检查、构建、测试和实际探针。随后正式执行 `moon package --list --frozen` 与 `moon publish --frozen`；manifest 显示版本 0.2.0、构建成功、包可用且未撤回。

0.3.0 终端规范化/HTML 报告提交 `2a3da274caca9af77f24cfc54664e813489ceb86` 的 [run 35993578803](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35993578803) 成功。完整 4 target matrix、CLI 与真实 HTML report smoke test 均通过；随后已正式发布 Mooncakes 0.3.0，manifest 核验记录在 `docs/PUBLISHING.md`。
