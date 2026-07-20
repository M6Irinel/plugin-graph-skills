$projectRoot = (Get-Location).Path
$graphFile = Join-Path $projectRoot "graph_project.md"

if (!(Test-Path -LiteralPath $graphFile)) {
    Write-Host "Graph non esiste. Lancia /organization-graph."
    exit 1
}

Write-Host "# MEMORIA PROGETTO"
Write-Host "-- indice: graph_project.md --"
Get-Content -LiteralPath $graphFile

$missing = 0

# Load every .md file listed in the graph index.
foreach ($line in Get-Content -LiteralPath $graphFile) {
    $name = $line.Trim()
    if ($name -notlike '*.md') { continue }

    $mdPath = Join-Path $projectRoot $name
    if (Test-Path -LiteralPath $mdPath) {
        Write-Host "`n===== $name ====="
        Get-Content -LiteralPath $mdPath
    } else {
        Write-Warning "File mancante: $name"
        $missing++
    }
}

if ($missing -gt 0) {
    Write-Host "`n$missing file mancanti. Rilancia /organization-graph per rigenerarli."
    exit 2
}

# Write a dedicated rule file under .claude/rules/ so Claude Code auto-loads it
# at the start of every future session (official rules mechanism), without
# needing a manual /memory-graph call each time. This file is owned entirely
# by this command and is fully overwritten on each run (no markers needed).
$rulesDir = Join-Path $projectRoot ".claude\rules"
if (!(Test-Path -LiteralPath $rulesDir)) {
    New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
}
$ruleFile = Join-Path $rulesDir "project-graph.md"
$ruleContent = @"
# Memoria di progetto (auto-generata da /project-graph:memory-graph)

Prima di iniziare qualsiasi task in questo progetto, leggi:
- ``graph_project.md`` nella root (indice dei file .md generati)
- ogni file .md elencato al suo interno (creati da /project-graph:organization-graph): struttura, file, funzioni e componenti del progetto

Se ``graph_project.md`` non esiste o è incompleto, esegui prima /project-graph:organization-graph per rigenerarlo.
"@
Set-Content -LiteralPath $ruleFile -Value $ruleContent -Encoding UTF8

Write-Host "`nRule file aggiornato: $ruleFile"
