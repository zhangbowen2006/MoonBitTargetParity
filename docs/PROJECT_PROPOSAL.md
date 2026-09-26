# MoonBit Target Parity｜MoonBit 多后端行为契约对照

申请人：张博文｜九月新项目赛道｜Apache-2.0<br>
新仓库：https://github.com/zhangbowen2006/MoonBitTargetParity<br>
0.5.0 远程 CI：https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36220634863<br>
Mooncakes 0.5.0：https://mooncakes.io/docs/zhangbowen2006/moonbit-target-parity<br>
项目模块：`zhangbowen2006/moonbit-target-parity`

MoonBit 项目可编译到 `wasm`、`wasm-gc`、`js`、`native` 等后端。对数字运算、编码器、协议解析器和命令行库，开发者常需要确认同一输入在目标后端上的退出码和输出是否一致。MoonBit 自带跨目标测试能力，适合验证各后端自己的断言；本项目补充一层可复用的行为契约比较：调用方在各目标运行相同场景，把捕获结果交给纯 MoonBit API，自动列出具体字段差异。

核心 API 支持目标矩阵、按声明顺序选参考目标、退出码/stdout/stderr 比较、明确换行规范、ANSI/行尾空白 opt-in 规范化、可选 JSON 结构比较、JSON Pointer 差异位置与排除、绝对数字容差、unified diff、自包含 HTML 报告、缺失/重复/未声明目标诊断，以及多场景报告聚合。被忽略或容差吸收的差异仍会列入报告。每目标已审核 expectations 能检测所有后端共同出现的错误结果。CLI 为 pass/divergent/inconclusive 返回 0/1/2，便于集成 CI。仓库内置六类可复用 MoonBit portability probes：整数运算、Unicode/UTF-8、排序与 Map、嵌套 JSON、Result/Option、浮点误差。

现有方案对照：`moon test --target all` 可把同一 MoonBit 测试套件分别交给多个后端；MoonBit 社区项目也有各自的跨后端断言和差异测试。本项目的独立边界是接收调用者采集的运行观察值，以固定 schema 进行可复用、可组合的契约比较和报告；它不替代编译器测试、项目单测或运行时沙箱。

核心比较、规范化、聚合和报告均由 MoonBit 实现；Node.js 脚本只负责启动工具链、捕获进程观察值和传递 JSON。项目不宣称证明所有输入的一致性，也不把合成负例称为真实缺陷。使用范围先覆盖文本输出及 JSON 文本；二进制 stdout、正则遮罩、相对浮点误差和自动测试用例生成暂不支持。

源代码采用 Apache-2.0，仅依赖工具链 core；Mooncakes 0.5.0 已发布并通过公开 manifest 核验。CI 运行严格检查、全目标构建/测试、格式、公共接口快照、CLI 负向路径、真实四目标探针和 HTML 报告 smoke test。请评审本项目是否以 MoonBit 生态用户问题为主体；目标矩阵在本机不可用时会如实标记证据不完整。
