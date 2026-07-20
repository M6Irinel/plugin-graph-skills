$projectRoot = Get-Location
$memFile = "$projectRoot\mem-modif.md"
$graphFile = "$projectRoot\graph_project.md"

if (!(Test-Path $memFile)) {
    New-Item -Path $memFile -ItemType File -Force | Out-Null
    Add-Content $graphFile "mem-modif.md"
}

Add-Content $memFile "`n# MODIFICA $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

$diff = git diff --unified=0

$diff | ForEach-Object {
    Add-Content $memFile $_
}
