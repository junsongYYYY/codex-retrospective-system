# Codex Retrospective System Project Rules

## Core Rules

- User-facing explanations should use Chinese by default.
- Keep code, filenames, commands, and config keys in English.
- This repository publishes the Codex-only retrospective workflow.
- Do not add Claude runtime state, hooks, SQLite log parsing, or guard-file generation.
- Keep examples portable; avoid hard-coded personal absolute paths.

## Verification

- After changing scripts, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-CodexRetrospectiveSystem.ps1 -ProjectRoot .
```

- Before publishing, verify no API keys, tokens, cookies, or full `.env` content are present.

<!-- codex-retro:begin -->
## Codex 自进化复盘

- 复杂任务开始前，直接读取 `AGENT_LESSONS.md` 以及 `docs/agent_memory/testing.md`、`dependencies.md`、`mistakes-to-avoid.md`、`project-conventions.md` 中的正式经验；默认不读取 `inbox.md`。
- **任务结束触发条件**：在说"完成"或报告最终结果之前，快速回顾本次 session 是否存在以下任一情况：
  - 有命令/脚本执行失败后重试并成功
  - 尝试了多种方案/多次切换思路
  - 用户纠正了你的做法
  - 绕路排查了依赖、配置或环境问题
  - 测试先失败后通过
  → 满足任一条件时，在最终报告**之后**主动调用 `agent-retrospective` Skill 做复盘，不要等用户提醒
  → **如果全程一次通过、没有任何反复，则跳过复盘**
- 项目经验可自动写入 `docs/agent_memory/inbox.md` 或分类文件；正式分类文件的 bullet 必须以 `[触发: keyword1, keyword2, ...]` 开头，候选复盘必须填写 `触发关键词`；只有稳定、高频、可复用的经验才进入 `AGENT_LESSONS.md`。
- 定期使用 Codex 全局 `lesson-curator` Skill 人工清理 `inbox.md`：有价值的候选升级到分类文件，一次性或过时的候选删除。
- 如需跨项目 durable memory，先通过 `$env:CODEX_MEMORY_ROOT\scripts\suggest_memory.py` 创建候选；不要直接 approve。
- 不记录 API Key、token、cookie、完整 `.env` 或完整 stdout/stderr。
<!-- codex-retro:end -->

