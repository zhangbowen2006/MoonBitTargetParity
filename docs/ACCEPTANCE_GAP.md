# 验收差距表

更新：2026-09-24。此仓库是对初次驳回后更换选题的新项目；公开仓库、基线功能远程 CI 和 Mooncakes 0.2.0 发布均已完成。

| 要求/反馈 | 当前证据 | 风险与下一步 |
| --- | --- | --- |
| 直接服务 MoonBit 生态 | 面向 MoonBit 多后端包的可复用结果契约 API；项目主体和核心实现均为 MoonBit | 需让评审确认“开发工具/库”回应生态应用要求 |
| 实际需求与独立价值 | 官方提供多目标测试；本项目聚焦同一场景跨后端可观察输出的契约比较 | 没有外部 adopter；不宣称上游背书或绝对首创 |
| 功能真实可运行 | 本地 wasm/wasm-gc/js 探针一致；核心 19 项测试覆盖差异及错误状态；Actions 35990111751 验证四目标 | 0.3.0 新增报告功能，待新 CI 复核 |
| MoonBit 主体 | 比较、归一化、suite 聚合和报告由 MoonBit 实现；Node 只负责运行外部矩阵 | 完成源文件占比核对和公开版本测试 |
| README/示例/API | 中文 README、JSON fixture、真实跨目标脚本及公共 API | 已有材料需随新仓库一起公开 |
| CI/构建/测试 | [Actions 35990111751](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35990111751) 对 0.2.0 baseline 功能执行 all-target check/build/test 与四目标探针并成功；本地 19/19 测试通过 | 0.3.0 报告功能需等待新 CI 复核；评审对选题价值仍需官方判断 |
| Mooncakes | 0.2.0 已通过 `moon publish --frozen` 正式发布；公开 manifest build_status=success、has_package=true、yanked=false | 0.3.0 新增终端输出归一化和 HTML 报告，待新 CI/发布 |
| 许可证/来源 | Apache-2.0；core 为工具链依赖，Node 只用内建模块 | 发布前复核 license/package contents |
| 新旧项目关系 | 新建 `MoonBitTargetParity`，项目名称、核心功能和代码均与八月 MoonBVHKit 不同 | 报名表只提交新仓库，旧的 MoonKeyguard 链接不可继续当新选题 |
