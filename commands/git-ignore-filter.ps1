# Shared file discovery for organization-graph.ps1 / extract-symbols.ps1.
#
# Never descends into ignored directories (target/, node_modules/, .git/, ...) —
# filtering *after* a full recursive scan is too slow on huge build trees.
#
# Git repos: `git ls-files --cached --others --exclude-standard` walks the working
# tree itself and does not recurse into ignored directories, so it naturally honors
# every .gitignore found (root + nested) without us re-implementing gitignore rules.
# Non-git folders: manual stack-based walk that prunes known heavy dir names before
# pushing them, so it never opens node_modules/target/etc either.

$script:DenyDirNames = @(
    '.git', 'node_modules', 'target', 'dist', 'build', 'vendor',
    'bin', 'obj', '.venv', 'venv', '__pycache__'
)

function Get-FilesPrunedWalk {
    param([Parameter(Mandatory = $true)][string]$folder)

    $stack = [System.Collections.Generic.Stack[string]]::new()
    $stack.Push((Resolve-Path -LiteralPath $folder).Path)
    $results = New-Object System.Collections.Generic.List[object]

    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        $items = Get-ChildItem -LiteralPath $current -Force -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            if ($item.PSIsContainer) {
                if ($script:DenyDirNames -notcontains $item.Name) {
                    $stack.Push($item.FullName)
                }
            } else {
                $results.Add($item)
            }
        }
    }
    return $results.ToArray()
}

function Get-ProjectFiles {
    param(
        [Parameter(Mandatory = $true)][string]$folder,
        [Parameter(Mandatory = $true)][string]$projectRoot
    )

    $gitAvailable = Get-Command git -ErrorAction SilentlyContinue
    $isGitRepo = Test-Path -LiteralPath (Join-Path $projectRoot ".git")

    if ($gitAvailable -and $isGitRepo) {
        $resolvedFolder = (Resolve-Path -LiteralPath $folder).Path
        $relFolder = $resolvedFolder.Substring($projectRoot.TrimEnd('\').Length).TrimStart('\')
        if ([string]::IsNullOrEmpty($relFolder)) { $relFolder = '.' }

        $relPaths = & git -C $projectRoot ls-files --cached --others --exclude-standard --full-name -- $relFolder 2>$null

        $files = foreach ($rp in $relPaths) {
            if ([string]::IsNullOrWhiteSpace($rp)) { continue }
            $full = Join-Path $projectRoot ($rp -replace '/', '\')
            if (Test-Path -LiteralPath $full -PathType Leaf) {
                Get-Item -LiteralPath $full
            }
        }
        return @($files)
    }

    # No git repo available: fall back to a pruned manual walk.
    return @(Get-FilesPrunedWalk -folder $folder)
}
