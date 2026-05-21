---
name: lesson-curator
description: Curate project retrospective inbox candidates for Codex self-evolution systems. Use when the user asks to整理 inbox, 清理经验库, process docs/agent_memory/inbox.md, review candidate lessons, promote candidates to formal lesson files, delete stale one-off candidates, or run lesson-curator for project memory maintenance.
---

# Lesson Curator

## Purpose

Use this skill to clean a project's `docs/agent_memory/inbox.md`. The goal is to keep uncertain candidates out of daily work while preserving useful lessons in formal category files.

Do not use this skill for normal task closeout. Use `agent-retrospective` for producing a new retrospective after a task. Use this skill later to curate existing inbox candidates.

## Required Inputs

Work in the current project root unless the user names another root. A supported project normally has:

- `AGENT_LESSONS.md`
- `docs/agent_memory/inbox.md`
- `docs/agent_memory/testing.md`
- `docs/agent_memory/dependencies.md`
- `docs/agent_memory/mistakes-to-avoid.md`
- `docs/agent_memory/project-conventions.md`

If `inbox.md` is missing, report that there are no candidates to curate.

## Workflow

1. Read `AGENT_LESSONS.md` and every formal category file under `docs/agent_memory/` to understand existing official lessons.
2. Read `docs/agent_memory/inbox.md` and split candidates by second-level headings such as `## YYYY-MM-DD｜标题`.
3. For each candidate, extract `状态`, `分类`, `来源任务`, `下次优先路径`, `下次避免`, and `建议处理`.
4. Classify each candidate as `Promote`, `Delete`, or `Keep`.
5. First show a concise review table unless the user explicitly requested execution.
6. Only when the user clearly asks to execute cleanup, move or delete candidates.

## Decision Rules

Use `Promote` when a candidate is reusable, actionable, and has enough evidence:

- It has clear `下次优先路径` and `下次避免`.
- It is not a one-off path typo, transient network failure, temporary filename issue, or casual wording correction.
- It repeats an existing pattern, or a later test/fix proves the lesson is valid.
- `建议处理` explicitly says to move into a category file or promote.

Use `Delete` when the candidate should not become project memory:

- It is one-off, stale, already obsolete, or only records a temporary accident.
- It has no actionable next-time rule.
- It duplicates an existing formal lesson without adding new information.
- `建议处理` explicitly says delete, expired, obsolete, or one-off.

Use `Keep` when evidence is incomplete:

- The category is unclear.
- The next-time rule is not specific enough.
- It may be reusable but has not repeated and has not been verified.

## Promotion Targets

Move promoted lessons into the matching file's `## Active` section:

- Testing, builds, validation, regression checks -> `docs/agent_memory/testing.md`
- Dependencies, interpreters, tools, environment variables, config paths -> `docs/agent_memory/dependencies.md`
- Confirmed avoidances and known bad paths -> `docs/agent_memory/mistakes-to-avoid.md`
- Stable project workflow, naming, structure, maintenance conventions -> `docs/agent_memory/project-conventions.md`

Promote to `AGENT_LESSONS.md` only as a short index entry when the lesson is high-frequency or cross-task. Do not put ordinary detailed lessons there.

## Execution Rules

When executing cleanup:

- Preserve the inbox template.
- Remove candidates from `inbox.md` only after promoting or deleting them.
- Do not duplicate a formal lesson if the same rule already exists in a target file.
- Keep wording direct and future-facing, such as "When X, do Y" or "Do not do Z".
- When promoting, add a `[触发: keyword1, keyword2, ...]` tag (2-5 scene-specific keywords) if the candidate lacks one.
- Do not write API keys, tokens, cookies, full `.env` content, or long stdout/stderr.
- Do not write project lessons into durable memory final stores. Cross-project durable memory still requires a pending candidate.

## Review Output Format

Use this format when reviewing:

```markdown
| Candidate | Decision | Target | Reason |
|---|---|---|---|
| YYYY-MM-DD｜标题 | Promote / Delete / Keep | testing.md / dependencies.md / mistakes-to-avoid.md / project-conventions.md / AGENT_LESSONS.md / inbox.md | concise reason |
```

After execution, report:

- promoted candidates and target files
- deleted candidates
- kept candidates
- validation performed

