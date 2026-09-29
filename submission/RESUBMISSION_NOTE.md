# 重新申报说明（2026-09-29 核验）

申请人：张博文。原项目 MoonKeyguard 因与 MoonBit 生态需求连接不足未通过初审。本次更换为 MoonBit Target Parity，使用新的公开仓库：https://github.com/zhangbowen2006/MoonBitTargetParity

新选题解决 MoonBit 多后端包的结果一致性验证：调用方在多个目标运行同一场景，MoonBit 核心比较退出码、标准输出和可选标准错误，输出可用于 CI 的差异报告。`docs/REJECTION_RESPONSE.md` 对照说明反馈，`docs/DEDUPLICATION.md` 记录现有方案核对，`docs/PROJECT_PROPOSAL.md` 为一页申报书。

项目 0.5.1 在 Windows / MoonBit 0.10.14 上通过 wasm、wasm-gc、js 各 32/32 测试与七场景对照；套件中重复场景名不会再误判为通过。本机缺少 native C 编译器，不声称本地 native 通过。提交 `78df61ef9447eeb51b0490b84b06b2738fbab569` 的公开 [远程 CI](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/36560754312) 已在 Ubuntu 完成四目标严格检查、构建、测试与真实矩阵。Mooncakes [0.5.1 已正式发布](https://mooncakes.io/docs/zhangbowen2006/moonbit-target-parity)，公开 manifest 为 `build_status=success`、`has_package=true`、`yanked=false`；详细记录见 `docs/PUBLISHING.md`。
