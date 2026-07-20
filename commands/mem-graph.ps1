$projectRoot = Get-Location
$graphFile = "$projectRoot\graph_project.md"

if (!(Test-Path $graphFile)) {
    Write-Host "Graph non esiste, lancio /organization-graph"
    exit 1
}

Write-Host "Memoria caricata:"
Get-Content $graphFile
