[CmdletBinding()]
param(
    [string]$SkillsRoot = (Join-Path $env:USERPROFILE ".codex\skills"),
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repoRoot "skills"

if (-not (Test-Path -LiteralPath $sourceRoot)) {
    throw "Missing repository skills directory: $sourceRoot"
}

New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null

$skills = @("agent-retrospective", "lesson-curator")
$installed = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]

foreach ($skill in $skills) {
    $source = Join-Path $sourceRoot $skill
    $target = Join-Path $SkillsRoot $skill

    if (-not (Test-Path -LiteralPath (Join-Path $source "SKILL.md"))) {
        throw "Missing skill entrypoint: $(Join-Path $source 'SKILL.md')"
    }

    if (Test-Path -LiteralPath $target) {
        if (-not $Force) {
            $skipped.Add($target) | Out-Null
            continue
        }
        Remove-Item -LiteralPath $target -Recurse -Force
    }

    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
    $installed.Add($target) | Out-Null
}

Write-Host "Codex retrospective skills install"
Write-Host "SkillsRoot: $SkillsRoot"
Write-Host ""
Write-Host "[installed]"
if ($installed.Count -eq 0) { Write-Host "- none" } else { $installed | ForEach-Object { Write-Host "- $_" } }
Write-Host ""
Write-Host "[skipped]"
if ($skipped.Count -eq 0) { Write-Host "- none" } else { $skipped | ForEach-Object { Write-Host "- $_" } }

if ($skipped.Count -gt 0) {
    Write-Host ""
    Write-Host "Use -Force to overwrite existing skills."
}

