# Codex Retrospective System

一个面向 Codex 的本地项目复盘系统。目标很简单：把复杂任务里的失败命令、测试失败后成功、用户纠偏和排障绕路，沉淀成下次任务开始前会被直接读取的项目经验。

当前版本只做 Codex 侧能力：

- 不做 Hook。
- 不解析 Codex SQLite 日志。
- 不生成任务前 guard 文件。
- 不依赖固定个人目录。
- 不记录 API Key、token、cookie、完整 `.env` 或完整 stdout/stderr。

## 安装 skills

先把仓库内的 Codex skills 安装到本机：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install-CodexRetrospectiveSkills.ps1
```

如果你要覆盖已有同名 skill：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install-CodexRetrospectiveSkills.ps1 -Force
```

默认安装位置是：

```text
$env:USERPROFILE\.codex\skills
```

## 给项目接入

初始化或补齐一个项目：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\init_codex_retrospective_project.ps1 -ProjectRoot D:\path\to\project
```

只检查不修改：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\init_codex_retrospective_project.ps1 -ProjectRoot D:\path\to\project -CheckOnly
```

初始化脚本会创建或补齐：

- `AGENTS.md`
- `AGENT_LESSONS.md`
- `docs/agent_memory/README.md`
- `docs/agent_memory/inbox.md`
- `docs/agent_memory/testing.md`
- `docs/agent_memory/dependencies.md`
- `docs/agent_memory/project-conventions.md`
- `docs/agent_memory/mistakes-to-avoid.md`
- `docs/agent_memory/archive/`

已有文件不会被覆盖。已有 `AGENTS.md` 只更新 `<!-- codex-retro:begin -->` 到 `<!-- codex-retro:end -->` 之间的受控区块。

## 日常工作方式

复杂任务开始前读取：

```text
AGENT_LESSONS.md
docs/agent_memory/testing.md
docs/agent_memory/dependencies.md
docs/agent_memory/mistakes-to-avoid.md
docs/agent_memory/project-conventions.md
```

复杂任务结束前，如果出现失败命令、测试失败后成功、重复尝试、用户纠偏、配置/依赖绕路或多次切换方案，使用 `agent-retrospective` skill 写回经验。

写回规则：

```text
明确可复用、有下次优先路径和下次避免
  -> 写入分类文件 ## Active，并以 [触发: keyword1, keyword2, ...] 开头

不确定、边界模糊、暂时无法判断
  -> 写入 docs/agent_memory/inbox.md，并填写 触发关键词

高频/跨任务通用
  -> 写入 AGENT_LESSONS.md 作为索引
```

`lesson-curator` 用于定期整理 `inbox.md`，把有价值的候选升级到分类文件，把一次性或过时候选删除。

如果你有单独的 durable memory 工作区，可以配置：

```powershell
$env:CODEX_MEMORY_ROOT = "D:\path\to\codex-memory"
```

跨项目 durable memory 仍只允许先通过 `$env:CODEX_MEMORY_ROOT\scripts\suggest_memory.py` 生成候选，不直接 approve。

## 测试

运行完整回归：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-CodexRetrospectiveSystem.ps1 -ProjectRoot .
```

成功时输出：

```text
ALL TESTS PASSED
```

测试覆盖：

- 初始化脚本存在且是 UTF-8 BOM。
- 当前项目 `-CheckOnly` 通过。
- 空项目初始化生成完整文件。
- 重复初始化不会重复追加受控区块。
- 已有 UTF-8 no BOM 中文 `AGENTS.md` 初始化后不乱码。
- 仓库内 `agent-retrospective` 和 `lesson-curator` skills 存在且包含必要规则。
- README 不包含 guard 旧入口。

## 上传 GitHub

安装 GitHub CLI：

```powershell
winget install --id GitHub.cli
```

登录：

```powershell
gh auth login
gh auth status
```

创建公开仓库并 push：

```powershell
git init
git branch -M main
git add .
git commit -m "Initial Codex retrospective system"
gh repo create codex-retrospective-system --public --source . --remote origin --push
```

