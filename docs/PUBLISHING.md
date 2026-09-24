# Mooncakes 发布记录与清单

模块：`zhangbowen2006/moonbit-target-parity`<br>
仓库：<https://github.com/zhangbowen2006/MoonBitTargetParity>

## 每次发布前

1. 更新 `moon.mod` 版本和 `CHANGELOG.md`。
2. 执行 `moon info`、`moon fmt`、`moon check --target all --deny-warn`、`moon build --target all`、`moon test --target all --deny-warn`、`moon fmt --check`。
3. 执行 `moon package --list --frozen`，检查清单中无凭证、临时文件或构建产物。
4. 等待对应提交的 GitHub Actions 成功后再正式发布。
5. `moon publish --frozen` 成功后重新查询公开 manifest，记录版本、构建状态、包可用性与页面链接。

## 0.1.0 发布记录

2026-09-24，在提交 `6e863bff95b0a6ee35ec5f5f4302e07aee180727` 的
[Actions run 35987471426](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35987471426)
成功后，执行 `moon package --list --frozen` 和 `moon publish --frozen`。
发布命令退出码为 0，服务器返回 `200 OK`。随后公开 manifest 核验为：

- 模块：`zhangbowen2006/moonbit-target-parity`
- 最新版本：`0.1.0`
- `build_status=success`
- `has_package=true`，`yanked=false`

页面：[Mooncakes 文档](https://mooncakes.io/docs/zhangbowen2006/moonbit-target-parity)；
接口：[manifest](https://mooncakes.io/api/v0/manifest/zhangbowen2006/moonbit-target-parity)。
0.1.1 仅更新 README 和验收证据，不改变公共 API 或核心行为。

2026-09-24 文档同步版本 0.1.1：提交 `da21a2ad9debea23b763b06b7e330612293af38a` 的
[Actions run 35987911060](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35987911060)
成功后，执行 `moon package --list --frozen` 与 `moon publish --frozen`。
服务器返回 `200 OK`；公开 manifest 核验为版本 0.1.1、`build_status=success`、
`has_package=true`、`yanked=false`。包页仍为同一模块文档地址，安装命令已指向 0.1.1。

## 0.2.0 预期结果合同功能

2026-09-24，在提交 `f8887ef36a9196226c1e1770f4685d61515e0c06` 的
[Actions run 35990111751](https://github.com/zhangbowen2006/MoonBitTargetParity/actions/runs/35990111751)
成功后，执行 `moon package --list --frozen` 和 `moon publish --frozen`。
命令退出码为 0，服务器返回 `200 OK`。公开 manifest 核验为：

- 模块版本：`zhangbowen2006/moonbit-target-parity@0.2.0`
- `build_status=success`
- `has_package=true`，`yanked=false`

页面：[Mooncakes 文档](https://mooncakes.io/docs/zhangbowen2006/moonbit-target-parity)；
接口：[manifest](https://mooncakes.io/api/v0/manifest/zhangbowen2006/moonbit-target-parity)。
