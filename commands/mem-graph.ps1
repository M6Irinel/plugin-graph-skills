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
