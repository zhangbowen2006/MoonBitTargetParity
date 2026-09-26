# 验收差距表

更新：2026-09-26。此仓库是对初次驳回后更换选题的新项目；公开仓库、0.3.0 诊断功能 CI 和 Mooncakes 0.3.0 发布均已完成；0.5.0 本地严格验证已通过，待远程 CI 与发布。

| 要求/反馈 | 当前证据 | 风险与下一步 |
| --- | --- | --- |
| 直接服务 MoonBit 生态 | 面向 MoonBit 多后端包的可复用结果契约 API；项目主体和核心实现均为 MoonBit | 需让评审确认“开发工具/库”回应生态应用要求 |
| 实际需求与独立价值 | 官方提供多目标测试；本项目聚焦同一场景跨后端可观察输出的契约比较 | 没有外部 adopter；不宣称上游背书或绝对首创 |
| 功能真实可运行 | 本地 wasm/wasm-gc/js 七场景探针对照通过；核心库与 portable packages 共 29 项测试；Actions 35993578803 验证过此前版本四目标 | 本机 native 缺 C 编译器；0.5.0 需本轮远程 CI 验证 |
| MoonBit 主体 | 比较、归一化、suite 聚合和报告由 MoonBit 实现；Node 只负责运行外部矩阵 | 完成源文件占比核对和公开版本测试 |
| 代码规模 | 约 1,490 行非测试 MoonBit 实现；含示例和测试的 `.mbt` 共 2,129 行 | 仍低于此前提出的 4,000 行目标；不通过复制、生成或无意义拆分凑数，需继续增加有真实用户价值的核心能力 |
| README/示例/API | 中文 README、JSON fixture、真实跨目标脚本及公共 API | 已有材料需随新仓库一起公开 |
| CI/构建/测试 | [Actions 35993578803](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35993578803) 对此前版本 all targets 执行严格检查、构建、测试和真实矩阵并成功；本地 29/29 测试通过 | 0.5.0 对应的远程 CI 待推送后验证；评审对选题价值仍需官方判断 |
| Mooncakes | 0.3.0 已通过 `moon publish --frozen` 正式发布；公开 manifest build_status=success、has_package=true、yanked=false | 0.5.0 必须等 CI 成功后再发布 |
| 许可证/来源 | Apache-2.0；core 为工具链依赖，Node 只用内建模块 | 发布前复核 license/package contents |
| 新旧项目关系 | 新建 `MoonBitTargetParity`，项目名称、核心功能和代码均与八月 MoonBVHKit 不同 | 报名表只提交新仓库，旧的 MoonKeyguard 链接不可继续当新选题 |
