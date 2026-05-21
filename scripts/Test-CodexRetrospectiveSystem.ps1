[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Resolve-Root {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Project root does not exist: $Path"
    }

    return (Resolve-Path -LiteralPath $Path).Path
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Name,
        [string]$FailureDetail = ""
    )

    if ($Condition) {
        Write-Host "PASS $Name"
        return
    }

    if ($FailureDetail) {
        Write-Host "FAIL $Name :: $FailureDetail"
    } else {
        Write-Host "FAIL $Name"
    }
    $script:FailureCount += 1
}

function Invoke-CheckedScript {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string[]]$Arguments
    )

    & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments | Out-Null
    Assert-True -Condition ($LASTEXITCODE -eq 0) -Name $Name -FailureDetail "exit=$LASTEXITCODE"
}

function Remove-TestRoot {
    param(
        [string]$TestRoot,
        [string]$AllowedParent
    )

    if (-not (Test-Path -LiteralPath $TestRoot)) {
        return
    }

    $resolved = (Resolve-Path -LiteralPath $TestRoot).Path
    if (-not $resolved.StartsWith($AllowedParent)) {
        throw "Unsafe temp path: $resolved"
    }

    Remove-Item -LiteralPath $resolved -Recurse -Force
}

function Test-Utf8Bom {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    return $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
}

$root = Resolve-Root $ProjectRoot
$initScript = Join-Path $root "scripts\init_codex_retrospective_project.ps1"
$installScript = Join-Path $root "scripts\Install-CodexRetrospectiveSkills.ps1"
$testRoot = Join-Path $root ".tmp_self_evolution_tests"
$agentRetrospectiveSkill = Join-Path $root "skills\agent-retrospective\SKILL.md"
$lessonCuratorSkill = Join-Path $root "skills\lesson-curator\SKILL.md"
$script:FailureCount = 0

Assert-True -Condition (Test-Path -LiteralPath $initScript) -Name "init script exists" -FailureDetail $initScript
Assert-True -Condition (Test-Utf8Bom -Path $initScript) -Name "init script is UTF-8 BOM"
Assert-True -Condition (Test-Path -LiteralPath $installScript) -Name "install script exists" -FailureDetail $installScript
Assert-True -Condition (Test-Utf8Bom -Path $installScript) -Name "install script is UTF-8 BOM"
Assert-True -Condition (-not (Test-Path -LiteralPath (Join-Path $root "scripts\Invoke-CodexRetrospectiveGuard.ps1"))) -Name "guard script absent"
Assert-True -Condition (-not (Test-Path -LiteralPath (Join-Path $root ".claude"))) -Name "claude runtime absent"
Assert-True -Condition (Test-Path -LiteralPath $agentRetrospectiveSkill) -Name "repository agent-retrospective skill exists" -FailureDetail $agentRetrospectiveSkill
Assert-True -Condition (Test-Path -LiteralPath $lessonCuratorSkill) -Name "repository lesson-curator skill exists" -FailureDetail $lessonCuratorSkill

try {
    Remove-TestRoot -TestRoot $testRoot -AllowedParent $root
    New-Item -ItemType Directory -Path $testRoot | Out-Null

    Invoke-CheckedScript -Name "current init check" -ScriptPath $initScript -Arguments @("-ProjectRoot", $root, "-CheckOnly")

    $emptyProject = Join-Path $testRoot "empty_project"
    New-Item -ItemType Directory -Path $emptyProject | Out-Null
    Invoke-CheckedScript -Name "empty project bootstrap command" -ScriptPath $initScript -Arguments @("-ProjectRoot", $emptyProject)

    $expectedFiles = @(
        "AGENTS.md",
        "AGENT_LESSONS.md",
        "docs\agent_memory\README.md",
        "docs\agent_memory\inbox.md",
        "docs\agent_memory\testing.md",
        "docs\agent_memory\dependencies.md",
        "docs\agent_memory\project-conventions.md",
        "docs\agent_memory\mistakes-to-avoid.md"
    )
    $missing = @($expectedFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $emptyProject $_)) })
    Assert-True -Condition ($missing.Count -eq 0) -Name "empty project bootstrap files" -FailureDetail ($missing -join ", ")
    Assert-True -Condition (-not (Test-Path -LiteralPath (Join-Path $emptyProject "docs\agent_memory\CODEX_GUARD.md"))) -Name "empty project does not create CODEX_GUARD"

    $agentsText = [System.IO.File]::ReadAllText((Join-Path $emptyProject "AGENTS.md"), [System.Text.UTF8Encoding]::new($false, $true))
    Assert-True -Condition ($agentsText.Contains('直接读取 `AGENT_LESSONS.md`')) -Name "controlled block reads official lessons directly"
    Assert-True -Condition ($agentsText.Contains("lesson-curator")) -Name "controlled block mentions lesson-curator"
    Assert-True -Condition ($agentsText.Contains("[触发: keyword1, keyword2, ...]")) -Name "controlled block documents trigger tag write-back"
    Assert-True -Condition ($agentsText.Contains('$env:CODEX_MEMORY_ROOT')) -Name "controlled block uses portable memory root"
    Assert-True -Condition (-not $agentsText.Contains("Invoke-CodexRetrospectiveGuard")) -Name "controlled block has no guard command"

    $emptyInbox = [System.IO.File]::ReadAllText((Join-Path $emptyProject "docs\agent_memory\inbox.md"), [System.Text.UTF8Encoding]::new($false, $true))
    Assert-True -Condition ($emptyInbox.Contains("触发关键词")) -Name "empty project inbox template contains trigger keywords"

    Invoke-CheckedScript -Name "idempotent bootstrap command" -ScriptPath $initScript -Arguments @("-ProjectRoot", $emptyProject)
    $emptyAgents = [System.IO.File]::ReadAllText((Join-Path $emptyProject "AGENTS.md"), [System.Text.UTF8Encoding]::new($false, $true))
    $beginCount = ([regex]::Matches($emptyAgents, "<!-- codex-retro:begin -->")).Count
    Assert-True -Condition ($beginCount -eq 1) -Name "idempotent controlled block" -FailureDetail "beginCount=$beginCount"

    $utf8Project = Join-Path $testRoot "utf8_existing_agents"
    New-Item -ItemType Directory -Path $utf8Project | Out-Null
    $agentsPath = Join-Path $utf8Project "AGENTS.md"
    $original = "# 项目规则`n`n- 保留中文规则：不要破坏既有内容。`n"
    [System.IO.File]::WriteAllText($agentsPath, $original, [System.Text.UTF8Encoding]::new($false))
    Invoke-CheckedScript -Name "existing UTF-8 no BOM bootstrap command" -ScriptPath $initScript -Arguments @("-ProjectRoot", $utf8Project)
    $after = [System.IO.File]::ReadAllText($agentsPath, [System.Text.UTF8Encoding]::new($false, $true))
    Assert-True -Condition ($after.Contains("保留中文规则：不要破坏既有内容。")) -Name "preserve UTF-8 no BOM Chinese AGENTS" -FailureDetail $after

    $retroSkillText = [System.IO.File]::ReadAllText($agentRetrospectiveSkill, [System.Text.UTF8Encoding]::new($false, $true))
    foreach ($required in @("[触发:", "Project Root Gate", "read-only review mode", "CODEX_MEMORY_ROOT", "触发关键词")) {
        Assert-True -Condition ($retroSkillText.Contains($required)) -Name "agent-retrospective skill contains $required"
    }

    $skillText = [System.IO.File]::ReadAllText($lessonCuratorSkill, [System.Text.UTF8Encoding]::new($false, $true))
    foreach ($required in @("Promote", "Delete", "Keep", "inbox.md", "testing.md", "dependencies.md", "mistakes-to-avoid.md", "project-conventions.md")) {
        Assert-True -Condition ($skillText.Contains($required)) -Name "lesson-curator skill contains $required"
    }
    Assert-True -Condition ($skillText.Contains("[触发: keyword1, keyword2, ...]")) -Name "lesson-curator skill documents trigger tag promotion"

    $readmeText = [System.IO.File]::ReadAllText((Join-Path $root "README.md"), [System.Text.UTF8Encoding]::new($false, $true))
    Assert-True -Condition (-not $readmeText.Contains("Invoke-CodexRetrospectiveGuard")) -Name "README has no guard command"
    Assert-True -Condition ($readmeText.Contains("D:\path\to\project")) -Name "README uses portable project path example"

    $forbiddenUserPath = "C:\Users\" + "11650"
    $forbiddenSourcePath = "D:\000项目\" + "自进化系统"
    $forbiddenMemoryPath = "D:\codex" + "\memory"
    $allTextFiles = Get-ChildItem -LiteralPath $root -Recurse -Force -File |
        Where-Object { $_.FullName -notmatch "\\\.git\\" -and $_.Name -notmatch "\.(png|jpg|jpeg|gif|zip|7z|exe)$" }
    $forbidden = @()
    foreach ($file in $allTextFiles) {
        $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.UTF8Encoding]::new($false, $false))
        if ($text.Contains($forbiddenUserPath) -or $text.Contains($forbiddenSourcePath) -or $text.Contains($forbiddenMemoryPath)) {
            $forbidden += $file.FullName
        }
    }
    Assert-True -Condition ($forbidden.Count -eq 0) -Name "no personal absolute paths" -FailureDetail ($forbidden -join ", ")
}
finally {
    Remove-TestRoot -TestRoot $testRoot -AllowedParent $root
}

if ($script:FailureCount -gt 0) {
    Write-Host "FAILED $script:FailureCount test(s)"
    exit 1
}

Write-Host "ALL TESTS PASSED"
exit 0
