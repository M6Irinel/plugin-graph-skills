param(
    [Parameter(Mandatory=$true)]
    [string[]]$folders
)

$projectRoot = Get-Location
$graphFile = "$projectRoot\graph_project.md"

if (!(Test-Path $graphFile)) {
    New-Item -Path $graphFile -ItemType File -Force | Out-Null
    Add-Content $graphFile "# PROJECT FILES`n"
}

foreach ($folder in $folders) {

    $folderName = ($folder -replace '\\','_')
    $mdFile = "$projectRoot\$folderName.md"

    # FILE LIST
    $files = Get-ChildItem $folder -Recurse -File | Select-Object FullName

    New-Item -Path $mdFile -ItemType File -Force | Out-Null
    Add-Content $mdFile "# FILES"

    $i = 1
    foreach ($f in $files) {
        Add-Content $mdFile "$i $($f.FullName)"
        $i++
    }

    # SYMBOL EXTRACTION
    Add-Content $mdFile "`n# SYMBOLS"
    powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\extract-symbols.ps1" $mdFile $folder

    # Update graph_project.md
    Add-Content $graphFile "$folderName.md"
}
