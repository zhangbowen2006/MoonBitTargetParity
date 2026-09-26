# 相似方案核对

检索日期：2026-09-24。检索范围包括 MoonBit 官方工具文档、`moonbitlang/moon` issue、Mooncakes 和 GitHub 中的 MoonBit 多后端测试项目。检索不能证明绝对首创。

| 方案 | 已有能力 | 本项目边界 |
| --- | --- | --- |
| Moon 命令 `moon test --target all` | 对支持的目标运行 MoonBit 测试 | 本项目不替代单测；比较不同 target 对同一已命名场景实际产生的退出码、标准输出/错误，提供可复用数据模型与差异报告 |
| MoonBit Pathfinding 等多后端库 | 各项目维护自身 target 矩阵、断言及部分产物比较 | 本项目把 scenario/result schema、缺证据处理、JSON/Markdown 报告封装成独立 MoonBit 核心，可供不同库复用 |
| MoonJust 等针对其他程序的差分验证 | 对各自实现与官方工具进行兼容性对照 | 被比较对象和契约不同；MoonBit Target Parity 比较 MoonBit 同一实现跨编译后端的运行观察 |
| 上游 `moon` 的 related test/bench 讨论 | 讨论根据依赖图选择受改动影响的测试 | 与本项目的运行输出跨后端等价判定不是同一功能，本项目不实现受影响测试选择 |

当前 `examples/portable/` 中的六个 package 是项目自有的最小可运行语义探针，不复制第三方实现；分别覆盖数值、Unicode/UTF-8、集合、JSON、错误/Option 和浮点用法，用来演示同一行为合同如何跨目标执行。

来源：

- [Moon 命令文档](https://docs.moonbitlang.com/en/latest/toolchain/moon/commands.html)
- [Moon 包配置：supported_targets](https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html#supported-targets)
- [上游 related tests issue #1906](https://github.com/moonbitlang/moon/issues/1906)
- [MoonBit Pathfinding](https://github.com/Suquster/moonbit-pathfinding)
- [MoonJust](https://github.com/moonbit-community/MoonJust)

方向选择记录：`.mbti` API 兼容检查已有 MoonGuard 等项目；MoonBit 依赖健康、SBOM 与 license 审计也已有 Depsight、MoonSeal、MoonSPDX、Mooncakes SBOM 等方案。故不沿用这些高重叠选题。
