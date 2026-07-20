param(
    [string[]]$folders = @(".")
)

$projectRoot = (Get-Location).Path
$graphFile = Join-Path $projectRoot "graph_project.md"

# Rebuild graph index fresh each run (avoids duplicate entries).
Set-Content -LiteralPath $graphFile -Value "# PROJECT FILES" -Encoding UTF8

$listed = @()

foreach ($folder in $folders) {

    if (!(Test-Path -LiteralPath $folder -PathType Container)) {
        Write-Warning "Skip: folder '$folder' non esiste."
        continue
    }

    $resolvedFolder = (Resolve-Path -LiteralPath $folder).Path
    if ($resolvedFolder -eq $projectRoot) {
        $folderName = Split-Path $projectRoot -Leaf
    } else {
        $folderName = ($folder -replace '[\\/:]', '_').Trim('_.')
    }
    $mdFile = Join-Path $projectRoot "$folderName.md"

    # FILE LIST
    $files = Get-ChildItem -LiteralPath $folder -Recurse -File
    Set-Content -LiteralPath $mdFile -Value "# FILES" -Encoding UTF8

    $i = 1
    foreach ($f in $files) {
        Add-Content -LiteralPath $mdFile -Value "$i $($f.FullName)" -Encoding UTF8
        $i++
    }

    # SYMBOL EXTRACTION (same-process call, handles paths with spaces)
    Add-Content -LiteralPath $mdFile -Value "`n# SYMBOLS" -Encoding UTF8
    & "$PSScriptRoot\extract-symbols.ps1" -mdFile $mdFile -folder $folder

    # Register in graph index (dedup)
    $entry = "$folderName.md"
    if ($listed -notcontains $entry) {
        Add-Content -LiteralPath $graphFile -Value $entry -Encoding UTF8
        $listed += $entry
    }
}

# Preserve the change-log reference if it already exists.
$memFile = Join-Path $projectRoot "mem-modif.md"
if ((Test-Path -LiteralPath $memFile) -and ($listed -notcontains "mem-modif.md")) {
    Add-Content -LiteralPath $graphFile -Value "mem-modif.md" -Encoding UTF8
}

Write-Host "Graph aggiornato: $graphFile"
