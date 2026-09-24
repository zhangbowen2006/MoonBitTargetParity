# 第三方来源说明

- MoonBit 核心实现仅使用随 MoonBit 工具链提供的 `moonbitlang/core/json` 和语言内建功能；未复制其实现代码。
- `scripts/*.mjs` 使用 Node.js 内建模块，无 npm 运行时依赖。脚本由本项目原创。
- `examples/synthetic-divergence.json` 是人工构造的负向 fixture，不是外部项目的代码、线上故障或用户数据。
- 项目整体采用 Apache-2.0，完整条款见 `LICENSE`。
