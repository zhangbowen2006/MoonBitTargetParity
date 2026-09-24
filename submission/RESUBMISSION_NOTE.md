# 2026-09-24 重新申报说明

申请人：张博文。原项目 MoonKeyguard 因与 MoonBit 生态需求连接不足未通过初审。本次更换为 MoonBit Target Parity，使用新的公开仓库：https://github.com/zhangbowen2006/MoonBitTargetParity

新选题解决 MoonBit 多后端包的结果一致性验证：调用方在多个目标运行同一场景，MoonBit 核心比较退出码、标准输出和可选标准错误，输出可用于 CI 的差异报告。`docs/REJECTION_RESPONSE.md` 对照说明反馈，`docs/DEDUPLICATION.md` 记录现有方案核对，`docs/PROJECT_PROPOSAL.md` 为一页申报书。

项目当前本地 MoonBit 测试为 19/19；Windows 本机 wasm、wasm-gc、js 实际探针对照通过。0.2.0 基线合同版的公开 [远程 CI](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35990111751) 已在 Ubuntu 完成四目标验证。Mooncakes [0.2.0 已正式发布](https://mooncakes.io/docs/zhangbowen2006/moonbit-target-parity)，manifest 核验结果记在 `docs/PUBLISHING.md`。0.3.0 报告功能需等待新 CI 与发布。
