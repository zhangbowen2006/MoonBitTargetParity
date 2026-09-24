# 测试记录

## 本机 Windows 复验

使用隔离工具链 `moon 0.1.20260920` / `moonc 0.10.14`。运行记录：

| 命令 | 结果 |
| --- | --- |
| `moon check --deny-warn` | 通过 |
| `moon test --deny-warn` | 12/12 通过 |
| `moon info`、`moon fmt` | 通过；生成接口待随提交检查 |
| `moon check --target js --deny-warn` | 通过 |
| `moon build --target js` | 通过 |
| `node scripts/test_cli.mjs` | pass/divergent/inconclusive/坏 JSON 四条真实 CLI 子进程路径通过 |
| `MOON_PARITY_TARGETS=wasm,wasm-gc,js node scripts/check_backends.mjs` | 配置文件驱动的三个真实目标结果相同，报告 pass |
| 默认四目标矩阵 | wasm、wasm-gc、js 完成；native 因本机没有 C 编译器而缺证，报告 inconclusive，未伪装成 pass |

测试覆盖参考目标顺序、stdout/exit code 差异、缺少/重复/未声明目标、schema 错误、CRLF 规范化、末尾换行策略、stderr 开关、JSON 对象/数组语义、JSON Pointer 转义定位及 suite 聚合。综合 CI 会在 Ubuntu 上对四个 `--target all` 目标执行检查、构建、测试和真实探针；在其真实运行前不预写 CI 通过结果。
