# Mistakes To Avoid

记录已经确认会导致重复绕路、误写记忆或污染经验库的做法。

## Active

- **[触发: public-release, secrets, logs]** 公开发布前必须扫描 API Key、token、cookie、完整 `.env` 和大段 stdout/stderr；不要把本机私有配置写入仓库。
- **[触发: portable, paths, examples]** README 和脚本示例使用 `D:\path\to\project`、`$env:USERPROFILE` 或 `$env:CODEX_MEMORY_ROOT`，避免硬编码个人路径。

