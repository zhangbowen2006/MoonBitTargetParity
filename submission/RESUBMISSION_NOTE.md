# 2026-09-24 重新申报说明

申请人：张博文。原项目 MoonKeyguard 因与 MoonBit 生态需求连接不足未通过初审。本次更换为 MoonBit Target Parity，使用新的公开仓库：https://github.com/zhangbowen2006/MoonBitTargetParity

新选题解决 MoonBit 多后端包的结果一致性验证：调用方在多个目标运行同一场景，MoonBit 核心比较退出码、标准输出和可选标准错误，输出可用于 CI 的差异报告。`docs/REJECTION_RESPONSE.md` 对照说明反馈，`docs/DEDUPLICATION.md` 记录现有方案核对，`docs/PROJECT_PROPOSAL.md` 为一页申报书。

项目当前 0.5.0 工作树在 Windows / MoonBit 0.10.14 上通过 29/29 测试、wasm/wasm-gc/js 三目标构建与七场景对照；还新增了 JSON Pointer 对字段和数组元素新增/删除差异的回归覆盖。此前 0.3.0 版本的公开 [远程 CI](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35993578803) 已在 Ubuntu 完成四目标验证。Mooncakes [0.3.0 已正式发布](https://mooncakes.io/docs/zhangbowen2006/moonbit-target-parity)，manifest 核验结果记在 `docs/PUBLISHING.md`。0.5.0 必须在本次修复提交对应的远程 CI 成功后再发布；截至本说明更新时，CI 与新版本发布仍待完成。
