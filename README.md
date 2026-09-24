# MoonBit Target Parity

**给 MoonBit 多后端项目使用的行为契约对照库。**同一个测试场景在 `wasm`、`wasm-gc`、`js`、`native` 等目标运行后，把退出码、标准输出和可选标准错误交给纯 MoonBit API；工具会指出哪些字段出现差异、缺少哪些目标证据，并生成 JSON 或 Markdown 报告。

公开仓库：[zhangbowen2006/MoonBitTargetParity](https://github.com/zhangbowen2006/MoonBitTargetParity) · [GitHub Actions](https://github.com/zhangbowen2006/MoonBitTargetParity/actions) · [Mooncakes 包页](https://mooncakes.io/docs/zhangbowen2006/moonbit-target-parity)

## 为什么做这个

MoonBit 项目可以面向多个编译后端。`moon test --target all` 能在多个目标上运行项目自己的断言；MoonBit Target Parity 补充的是同一组输入和场景下，对程序可观察结果进行跨目标对照，适合序列化器、协议解析器、数值库、命令行工具和其他需要保持输出一致的库。

它不推断未运行的场景。某个目标没有结果、目标重复、出现未声明目标或输入不完整时，状态为 `inconclusive`，不会把缺证据当成通过。

## 真实跨目标示例

安装 MoonBit 和 Node.js 后，在仓库根目录运行：

```sh
node scripts/check_backends.mjs
```

脚本会分别运行同一份 MoonBit 探针：

```sh
moon run --target wasm cmd/probe
moon run --target wasm-gc cmd/probe
moon run --target js cmd/probe
moon run --target native cmd/probe
```

然后将这些真实捕获结果交给 MoonBit 比较器。完整四目标矩阵要求本机具备相应 MoonBit 运行时和 native C 编译器。只想在支持的目标上做本地验证时，可显式指定，例如：

```powershell
$env:MOON_PARITY_TARGETS = 'wasm,wasm-gc,js'
node scripts/check_backends.mjs
```

显式省略某个目标只验证所列矩阵，不构成对未列目标的结论。若某目标在运行时无法启动，该目标按缺失证据报告。

运行器可接受自定义配置文件，声明 MoonBit package 路径、目标、场景名称、参数、stdin、超时及比较策略：

```sh
node scripts/check_backends.mjs examples/portable-json.json
```

`package_path` 必须是仓库内相对 package 路径；参数以数组传入，不经过 shell。适配器用临时文件把捕获结果交给 MoonBit CLI，并在退出时清除该临时目录。

仓库内的 `examples/synthetic-divergence.json` 是人工构造的负向报告例子，可运行：

```sh
node scripts/compare_file.mjs examples/synthetic-divergence.json
```

它会生成两个字段差异并以退出码 `1` 结束；该 fixture 不是实际后端输出或真实缺陷案例。

## MoonBit API

调用方负责在每个后端运行相同的场景，并把捕获结果传给库：

```moonbit
let run : @parity.ScenarioRun = {
  schema_version: 1,
  name: "portable-json",
  expected_targets: ["wasm", "js", "native"],
  observations: [
    { target: "wasm", exit_code: 0, stdout: "{\"ok\":true}\n", stderr: "" },
    { target: "js", exit_code: 0, stdout: "{\"ok\":true}\n", stderr: "" },
    { target: "native", exit_code: 0, stdout: "{\"ok\":true}\n", stderr: "" },
  ],
  policy: @parity.ComparePolicy::strict(),
}
let report = @parity.compare_scenario(run)
println(@parity.report_to_markdown(report))
```

安装已发布版本：

```sh
moon add zhangbowen2006/moonbit-target-parity@0.1.1
```

调用方的 `moon.pkg` 中导入：

```moonbit
import {
  "zhangbowen2006/moonbit-target-parity" @parity,
}
```

从仓库源码开发和复验：

```sh
moon test --deny-warn
node scripts/test_cli.mjs
node scripts/check_backends.mjs
```


## 比较规则

- **总是比较**退出码和 stdout。
- 默认把 `CRLF`/`CR` 统一为 `LF`；是否删除一个末尾换行由 `trim_one_final_newline` 明确控制。
- `compare_stderr` 默认开启；跨后端运行器自身日志可能混在 stderr 时，可对该场景显式关闭。退出码和 stdout 仍然比较。
- `compare_stdout_as_json` 开启后，合法 JSON stdout 按 JSON 结构比较：对象成员顺序不重要，数组顺序仍重要；差异报告包含转义过的 JSON Pointer 路径。JSON 无法解析时回退到文本精确比较；该选项不会替代 JSON 格式有效性测试。
- 第一个实际出现的 `expected_targets` 作为参考目标，目标顺序由调用者声明并写入报告。
- 已观察到差异时返回 `divergent`。没有差异但缺少、重复或多出目标，或者声明不足两个目标时返回 `inconclusive`。
- 一个场景可报告字段 `exit_code`、`stdout`、`stderr` 差异；套件 API 可聚合多个场景。

CLI/CI 状态码：`0` 通过、`1` 已确认差异、`2` 输入错误或证据不完整。

## 边界

库只比较调用方提供的文本结果，不启动隔离沙箱、不生成测试输入、不判定程序业务是否正确，也不能证明没列出的输入行为一致。二进制 stdout 暂不支持；调用方可先提供稳定编码或摘要。比较 JSON 时，对象字段顺序可忽略，但浮点容差、字段忽略规则和通用字符串遮罩暂不支持。

## 验证与 CI

GitHub Actions 执行严格检查、构建、测试、格式和公共接口快照；目标矩阵在 CI 上真实运行 `wasm`、`wasm-gc`、`js`、`native`。本地完整命令：

```sh
moon check --target all --deny-warn
moon build --target all
moon test --target all --deny-warn
moon fmt --check
moon info
node scripts/test_cli.mjs
node scripts/check_backends.mjs
moon package --list
```

## 项目资料

- [一页申报书](docs/PROJECT_PROPOSAL.md)
- [技术设计与边界](docs/ARCHITECTURE.md)
- [已有方案与相似项目核对](docs/DEDUPLICATION.md)
- [真实测试记录](docs/TESTING.md)
- [验收差距与重新申报说明](docs/ACCEPTANCE_GAP.md)
- [许可证](LICENSE) · [第三方来源](THIRD_PARTY_NOTICES.md) · [AI 使用](AI_USAGE.md)
