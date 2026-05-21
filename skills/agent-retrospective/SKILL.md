---
name: agent-retrospective
description: Run a Codex task closeout retrospective when a substantial task shows detours or reusable lessons. Use after code or document changes, multi-step troubleshooting, failed-then-fixed tests, configuration or dependency changes, repeated searches or edits, user corrections, or multiple implementation pivots; write project-local lessons directly to category files or inbox candidates, and propose durable-memory candidates when configured.
---

# Agent Retrospective

## Overview

Use this skill to turn task detours into reusable project lessons without creating noise. The goal is not to summarize every task; it is to prevent the same avoidable path from being taken again.

## Mode Selection

Use `task closeout mode` when a substantial task has retrospective signals and may need lesson write-back.

Use `read-only review mode` when the user explicitly asks to inspect, review, audit, or evaluate a skill, memory mechanism, project convention, or retrospective setup. In read-only review mode, assess the material and propose fixes, but do not write project lessons, durable memory candidates, or skill changes unless the user explicitly asks for implementation.

## Trigger Check

Use this skill only when at least one signal is present:

- A command, test, build, script, conversion, or validation failed.
- A test or build failed once and later passed after changes.
- The task involved repeated searches, repeated edits to the same file, or multiple implementation pivots.
- The user corrected the approach, scope, source of truth, wording, or verification standard.
- The task changed dependencies, environment configuration, tool settings, memory rules, or project conventions.
- The task consumed unusual effort because a source of truth, entrypoint, command, or validation path was missed.

Do not use this skill for simple Q&A, read-only inspection, tiny one-pass edits, or text polishing that completed cleanly.

## Project Root Gate

Before writing any project-local lesson, confirm the target project root. Use the current workspace root unless the user names another root.

A supported project root should contain `AGENT_LESSONS.md` and `docs/agent_memory/` with the category files. If the expected project memory files are missing or the target path is ambiguous, report the gap and do not write a lesson to an unrelated directory.

## Workflow

1. Select `read-only review mode` or `task closeout mode`.
2. In task closeout mode, pass the Project Root Gate before writing project-local lessons.
3. Reconstruct only the high-signal path: goal, outcome, validation, detour signals, and the decisive fix.
4. Decide whether the lesson is project-local or cross-project.
5. For project-local lessons, decide whether the lesson is clearly reusable or still uncertain.
6. For cross-project durable memory, only create a pending candidate when `$env:CODEX_MEMORY_ROOT\scripts\suggest_memory.py` exists. Do not approve it automatically.
7. For skill improvements, propose the exact patch or target section; do not edit a global skill unless the user explicitly asks.
8. Keep the final user response concise: mention whether a retrospective was written and where.

## Write-Back Rules

Project-local write-back is allowed when the lesson is reusable, actionable, and has an obvious next-time path.

- If the lesson is clearly reusable and can state both `下次优先路径` and `下次避免`, write one concise bullet under the relevant category file's `## Active`.
- Each bullet MUST start with a trigger tag: `[触发: keyword1, keyword2, ...]` — list 2-5 scene-specific keywords that will help match the lesson to future tasks.
- Formal category files use one compressed bullet under `## Active`; do not paste the full retrospective template into category files.
- Use `docs/agent_memory/testing.md` for tests, builds, validation, and acceptance checks.
- Use `docs/agent_memory/dependencies.md` for interpreters, packages, tools, environment variables, and config paths.
- Use `docs/agent_memory/project-conventions.md` for stable project workflow rules.
- Use `docs/agent_memory/mistakes-to-avoid.md` for confirmed avoidances.
- Use `docs/agent_memory/inbox.md` only for uncertain, boundary-blurry, or not-yet-verified lessons. Inbox candidates use the full retrospective template and should include `触发关键词`.
- Promote to `AGENT_LESSONS.md` only when the lesson is stable, likely to recur, and useful as a hot index entry.

Never store API keys, tokens, cookies, full `.env` content, or long stdout/stderr. Summarize error types and commands instead.

## Formal Bullet Example

```markdown
- **[触发: PowerShell, 中文, UTF-8, 脚本]** Windows PowerShell 5.1 执行含中文模板的 `.ps1` 时，优先保存为 UTF-8 with BOM；下次避免只验证脚本文本而不跑真实 `powershell -File`。
```

## Retrospective Template

Use this full template for `docs/agent_memory/inbox.md` candidates, not for formal category `## Active` sections.

```markdown
## YYYY-MM-DD｜Short title

状态：candidate / active
分类：testing / dependencies / project-conventions / mistakes-to-avoid / other
来源任务：
触发关键词：keyword1, keyword2, keyword3

### 任务结果
- 是否完成：
- 验证方式：

### 绕路信号
- 失败命令：
- 重复尝试：
- 用户纠偏：
- 测试失败后成功：

### 根因

### 下次优先路径

### 下次避免

### 建议处理
- Keep / Promote / Delete / 提升到 AGENT_LESSONS / 生成 durable-memory 候选 / 提出 Skill 修改建议
```

