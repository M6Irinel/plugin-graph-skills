param(
    [string]$mdFile,
    [string]$folder
)

$files = Get-ChildItem $folder -Recurse -File

foreach ($file in $files) {

    # Skip blade.php
    if ($file.Name -like "*.blade.php") { continue }

    $index = (Select-String -Path $mdFile -Pattern $file.FullName).LineNumber

    switch ($file.Extension) {

        ".ts" { 
            $func = 'function\s+([A-Za-z0-9_]+)'
            $comp = 'export\s+default\s+function\s+([A-Za-z0-9_]+)'
        }

        ".tsx" {
            $func = 'function\s+([A-Za-z0-9_]+)'
            $comp = 'export\s+default\s+function\s+([A-Za-z0-9_]+)'
        }

        ".rs" {
            $func = 'fn\s+([A-Za-z0-9_]+)'
        }

        ".php" {
            $func = 'function\s+([A-Za-z0-9_]+)'
        }

        ".py" {
            $func = 'def\s+([A-Za-z0-9_]+)'
        }

        ".java" {
            $func = '(public|private|protected)\s+[A-Za-z0-9_<>

\[\]

]+\s+([A-Za-z0-9_]+)\s*\('
        }

        ".cs" {
            $func = '(public|private|protected)\s+[A-Za-z0-9_<>

\[\]

]+\s+([A-Za-z0-9_]+)\s*\('
        }

        ".vue" {
            $func = 'methods:\s*{([^}]*)}'
            $comp = 'export\s+default'
        }

        default { continue }
    }

    # Extract functions
    if ($func) {
        $symbols = Select-String -Pattern $func -Path $file.FullName
        foreach ($s in $symbols) {
            $name = $s.Matches[0].Groups[1].Value
            Add-Content $mdFile "f $($s.LineNumber)-$($s.LineNumber+20) $name $index"
        }
    }

    # Extract components (TSX, Vue)
    if ($comp) {
        $components = Select-String -Pattern $comp -Path $file.FullName
        foreach ($c in $components) {
            $name = $c.Matches[0].Groups[1].Value
            Add-Content $mdFile "c $($c.LineNumber)-$($c.LineNumber+50) $name $index"
        }
    }
}
