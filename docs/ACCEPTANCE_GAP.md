# 验收差距表

更新：2026-09-29。此仓库是对初次驳回后更换选题的新项目；0.5.0 已通过远程四目标 CI 并发布到 Mooncakes。后续仓库源码修复已通过 CI，但尚未另发 Mooncakes 版本。

| 要求/反馈 | 当前证据 | 风险与下一步 |
| --- | --- | --- |
| 新选题申报书与仓库一致 | 两份申报书完全一致；模块名、仓库和主题身份检查已在 [Actions 36559411781](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36559411781) 通过 | 报名表仍须由申请人改用新项目并确认提交成功 |
| 直接服务 MoonBit 生态 | 面向 MoonBit 多后端包的可复用结果契约 API；项目主体和核心实现均为 MoonBit | 需让评审确认“开发工具/库”回应生态应用要求 |
| 实际需求与独立价值 | 官方提供多目标测试；本项目聚焦同一场景跨后端可观察输出的契约比较 | 没有外部 adopter；不宣称上游背书或绝对首创 |
| 功能真实可运行 | 本地 wasm/wasm-gc/js 七场景探针对照通过；纯 MoonBit API 示例及重复场景名修复均在 [Actions 36560171016](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36560171016) 验证成功 | 本机 native 缺 C 编译器；仓库源码新修复尚未另发 Mooncakes 版本 |
| MoonBit 主体 | 比较、归一化、suite 聚合和报告由 MoonBit 实现；Node 只负责运行外部矩阵 | 完成源文件占比核对和公开版本测试 |
| 代码规模 | 当前 7 个非测试、非示例 MoonBit 实现文件约 1,423 物理行、1,265 非空非注释行 | 仍低于此前提出的 4,000 有效行目标；官方说明项目不必刻意做大，不能通过复制、生成或无意义拆分凑数 |
| README/示例/API | 中文 README、JSON fixture、真实跨目标脚本及公共 API | 已有材料需随新仓库一起公开 |
| CI/构建/测试 | [Actions 36560171016](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36560171016) 对 `9f08583` 全部通过，含远程 native；本地 wasm、js、wasm-gc 各 32/32 测试通过 | 评审对选题价值仍需官方判断 |
| Mooncakes | 0.5.0 已通过 `moon publish --frozen` 发布；manifest 为 `build_status=success`、`has_package=true`、`yanked=false` | 发布条件满足；报名材料需链接新仓库和版本文档 |
| 许可证/来源 | Apache-2.0；core 为工具链依赖，Node 只用内建模块 | 发布前复核 license/package contents |
| 新旧项目关系 | 新建 `MoonBitTargetParity`，项目名称、核心功能和代码均与八月 MoonBVHKit 不同 | 报名表只提交新仓库，旧的 MoonKeyguard 链接不可继续当新选题 |
