# Mooncakes 发布记录与清单

模块：`zhangbowen2006/moonbit-target-parity`  
仓库：<https://github.com/zhangbowen2006/MoonBitTargetParity>

## 每次发布前

1. 更新 `moon.mod` 版本和 `CHANGELOG.md`。
2. 执行 `moon info`、`moon fmt`、`moon check --target all --deny-warn`、`moon build --target all`、`moon test --target all --deny-warn`、`moon fmt --check`。
3. 执行 `moon package --list --frozen`，检查清单中无凭证、临时文件或构建产物。
4. 等待对应提交的 GitHub Actions 成功后再正式发布。
5. `moon publish --frozen` 成功后重新查询公开 manifest，记录版本、构建状态、包可用性与页面链接。

本文件不把 dry-run、候选版本或本地包清单写作已发布。首次版本待上述步骤实际执行完成后补充结果。
