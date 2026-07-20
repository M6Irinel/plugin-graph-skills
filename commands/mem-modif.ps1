$projectRoot = (Get-Location).Path
$memFile = Join-Path $projectRoot "mem-modif.md"
$graphFile = Join-Path $projectRoot "graph_project.md"

# Must be a git repo.
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Non e un repository git."
    exit 1
}

# Lightweight summary: file + righe aggiunte/rimosse (non il diff grezzo).
$stat = git diff --numstat
if (-not $stat) {
    Write-Host "Nessuna modifica non committata."
    exit 0
}

if (!(Test-Path -LiteralPath $memFile)) {
    Set-Content -LiteralPath $memFile -Value "# MEMORIA MODIFICHE" -Encoding UTF8
}

Add-Content -LiteralPath $memFile -Value "`n## MODIFICA $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -Encoding UTF8

foreach ($line in $stat) {
    $parts = $line -split "`t"
    if ($parts.Count -ge 3) {
        $added = $parts[0]
        $removed = $parts[1]
        $path = $parts[2]
        Add-Content -LiteralPath $memFile -Value "- $path (+$added / -$removed)" -Encoding UTF8
    }
}

# Ensure the graph index references the change log.
if (Test-Path -LiteralPath $graphFile) {
    $g = Get-Content -LiteralPath $graphFile
    if ($g -notcontains "mem-modif.md") {
        Add-Content -LiteralPath $graphFile -Value "mem-modif.md" -Encoding UTF8
    }
}

Write-Host "Modifiche registrate in $memFile"
