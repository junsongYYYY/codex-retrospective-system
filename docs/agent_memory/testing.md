# Testing Lessons

记录测试、构建、验证链路中的可复用经验。

## Active

- **[触发: GitHub发布, clone验证, 换行差异]** 发布后必须从 GitHub 重新 clone 到临时目录跑完整回归；下次优先用 clone 后验证发现 `.gitattributes`/checkout 换行导致的 `-CheckOnly` 误报，并让受控区块比较做 newline normalization，避免只用本地工作区测试判断发布包可用。
