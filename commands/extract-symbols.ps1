param(
    [Parameter(Mandatory = $true)][string]$mdFile,
    [Parameter(Mandatory = $true)][string]$folder
)

$projectRoot = (Get-Location).Path

# Map relative file path -> file index, reading the FILES section written by organization-graph.ps1.
# Lines look like: "12 \src\file.ts". Read once (symbols not appended yet).
$indexMap = @{}
foreach ($line in Get-Content -LiteralPath $mdFile) {
    if ($line -match '^\s*(\d+)\s+(.+)$') {
        $indexMap[$matches[2].Trim()] = $matches[1]
    }
}

$files = Get-ChildItem -LiteralPath $folder -Recurse -File

foreach ($file in $files) {

    # Skip Blade templates
    if ($file.Name -like '*.blade.php') { continue }

    $relPath = "\" + $file.FullName.Substring($projectRoot.TrimEnd('\').Length).TrimStart('\')
    $index = $indexMap[$relPath]
    if (-not $index) { $index = '?' }

    # Each pattern: Kind (f/c), Regex (group 1 = symbol name, unless Group=0 -> use file BaseName), Span (approx line range)
    $patterns = @()

    switch ($file.Extension.ToLower()) {

        '.ts' {
            $patterns += @{ Kind = 'f'; Regex = '(?:export\s+)?(?:async\s+)?function\s+([A-Za-z0-9_]+)'; Group = 1; Span = 20 }
            $patterns += @{ Kind = 'f'; Regex = '(?:export\s+)?const\s+([A-Za-z0-9_]+)\s*=\s*(?:async\s*)?(?:<[^>]*>\s*)?\('; Group = 1; Span = 20 }
        }

        '.tsx' {
            # Capitalized = React component (c), lowercase = helper (f)
            $patterns += @{ Kind = 'c'; Regex = '(?:export\s+)?(?:default\s+)?function\s+([A-Z][A-Za-z0-9_]*)'; Group = 1; Span = 50 }
            $patterns += @{ Kind = 'c'; Regex = '(?:export\s+)?const\s+([A-Z][A-Za-z0-9_]*)\s*=\s*(?:async\s*)?(?:<[^>]*>\s*)?\('; Group = 1; Span = 50 }
            $patterns += @{ Kind = 'f'; Regex = '(?:export\s+)?function\s+([a-z][A-Za-z0-9_]*)'; Group = 1; Span = 20 }
            $patterns += @{ Kind = 'f'; Regex = '(?:export\s+)?const\s+([a-z][A-Za-z0-9_]*)\s*=\s*(?:async\s*)?(?:<[^>]*>\s*)?\('; Group = 1; Span = 20 }
        }

        '.rs' {
            $patterns += @{ Kind = 'f'; Regex = '(?:pub\s+)?(?:async\s+)?fn\s+([A-Za-z0-9_]+)'; Group = 1; Span = 20 }
            $patterns += @{ Kind = 'c'; Regex = '(?:pub\s+)?struct\s+([A-Za-z0-9_]+)'; Group = 1; Span = 30 }
        }

        '.php' {
            $patterns += @{ Kind = 'f'; Regex = 'function\s+([A-Za-z0-9_]+)'; Group = 1; Span = 20 }
            $patterns += @{ Kind = 'c'; Regex = 'class\s+([A-Za-z0-9_]+)'; Group = 1; Span = 50 }
        }

        '.py' {
            $patterns += @{ Kind = 'f'; Regex = 'def\s+([A-Za-z0-9_]+)'; Group = 1; Span = 20 }
            $patterns += @{ Kind = 'c'; Regex = 'class\s+([A-Za-z0-9_]+)'; Group = 1; Span = 50 }
        }

        '.java' {
            $patterns += @{ Kind = 'f'; Regex = '(?:public|private|protected)\s+(?:static\s+)?[A-Za-z0-9_<>\[\],\s]+?\s+([A-Za-z0-9_]+)\s*\('; Group = 1; Span = 20 }
            $patterns += @{ Kind = 'c'; Regex = '(?:public\s+)?class\s+([A-Za-z0-9_]+)'; Group = 1; Span = 50 }
        }

        '.cs' {
            $patterns += @{ Kind = 'f'; Regex = '(?:public|private|protected|internal)\s+(?:static\s+)?[A-Za-z0-9_<>\[\],\s]+?\s+([A-Za-z0-9_]+)\s*\('; Group = 1; Span = 20 }
            $patterns += @{ Kind = 'c'; Regex = '(?:public\s+)?class\s+([A-Za-z0-9_]+)'; Group = 1; Span = 50 }
        }

        '.vue' {
            # Options API methods: "name(...) {" or "name: function"; also component export.
            $patterns += @{ Kind = 'c'; Regex = 'export\s+default'; Group = 0; Span = 50 }
            $patterns += @{ Kind = 'f'; Regex = '^\s*(?:async\s+)?([A-Za-z0-9_]+)\s*\([^)]*\)\s*\{'; Group = 1; Span = 15 }
        }

        '.json' { }   # index only, no symbols

        default { }
    }

    if ($patterns.Count -eq 0) { continue }

    foreach ($p in $patterns) {
        $hits = Select-String -LiteralPath $file.FullName -Pattern $p.Regex -AllMatches -CaseSensitive
        foreach ($hit in $hits) {
            foreach ($m in $hit.Matches) {
                if ($p.Group -eq 0) {
                    $name = $file.BaseName
                } else {
                    $name = $m.Groups[$p.Group].Value
                }
                if ([string]::IsNullOrWhiteSpace($name)) { continue }

                $start = $hit.LineNumber
                $end = $start + $p.Span
                Add-Content -LiteralPath $mdFile -Value "$($p.Kind) $start-$end $name $index" -Encoding UTF8
            }
        }
    }
}
