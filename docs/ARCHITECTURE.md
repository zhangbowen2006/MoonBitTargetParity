# 技术设计

## 数据路径

1. JSON 矩阵配置声明 package 路径、相同场景的参数/stdin、目标列表和比较策略。
2. Node 适配器逐个执行 `moon run --target ... <package>`，用无 shell 的参数数组传递输入，记录 target、exit code、stdout、stderr。
3. 一个版本化 `ScenarioRun` 声明目标清单、观察结果和比较策略，可选 `ContractScenario` 再附上每个目标的已审核期望输出。
4. MoonBit 核心按 expected target 顺序选择第一个可用参考目标，比较其余观察值；有 expectations 时还逐目标对照固定基线。
5. 每个字段差异保留目标、比较类型（跨后端/预期契约）、字段、JSON Pointer 路径、参考值和观察值；suite 聚合每个场景状态。
6. JSON/Markdown 报告与 CLI 退出码由同一核心结果导出。

## 正确性策略

- exit code 与 stdout 永远比较。
- 提交 expectations 后要求覆盖每个目标；基线不完整时不能放行。这样可以检测所有后端共同产生、但偏离已接受结果的回归。
- 文本模式默认仅统一 CRLF/CR 与 LF。末尾换行策略必须由调用方显式选择。
- JSON 模式在两侧都能解析时按 core Json 结构比较；对象成员的插入顺序不构成差异，数组顺序构成差异。任意一侧无法解析时退回规范化文本精确比较。
- 结构化 JSON 差异逐层定位到 JSON Pointer 路径；对象键先排序，保证报告顺序稳定。嵌套超过 64 层时输出深度边界项，避免递归无界。
- stderr 比较是策略项，适合屏蔽运行器自身日志；关闭时不会关闭 stdout 或退出码检查。
- 缺失、重复、未声明目标、空场景名、错误 schema 版本和少于两个目标会阻止 pass。已观察到差异优先报告 divergent。
- 报告顺序由 expected_targets 与输入 observations 保持稳定，不依赖哈希遍历顺序。

## 进程边界

纯 MoonBit 核心库不启动子进程。仓库的 Node 脚本是无 shell 的工具链适配器：按配置运行 MoonBit package，收集结果，再调用 JS 目标构建的 MoonBit CLI。用户可以修改配置，也可用其他 CI/运行器采集结果后直接调用 `compare_scenario`。缺少运行时/编译器的目标没有 observation，核心会返回 inconclusive。

## 安全与资源

此版本解析调用方提供的 JSON 字符串；不执行 JSON 中的命令，不访问网络，不写入用户项目。报告会包含差异两侧的文本，因此调用方应避免输入秘密或将含敏感输出的 artifact 公开上传。当前没有对抗性输入沙箱或大输出截断；CI 应按自身数据策略保存报告。

## 非目标

- 不替代 `moon test`、编译器检查、WASI/Node 等执行器或系统集成测试。
- 不生成随机输入、不证明未执行的场景、也不根据两种结果自动判断哪种业务逻辑正确。
- 不比较任意二进制 stdout，不支持忽略字段路径/正则遮罩/浮点误差容忍。
