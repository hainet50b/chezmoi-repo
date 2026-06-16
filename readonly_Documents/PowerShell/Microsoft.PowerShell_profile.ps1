# UTF-8 everywhere (console I/O + pipeline to native commands)
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
} catch {}
$OutputEncoding = [System.Text.Encoding]::UTF8

# Editor
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# User Provided Binaries
$env:PATH += ";$HOME\.local\bin"

# codex: winget ships the binary under its target-triple name
Set-Alias codex codex-x86_64-pc-windows-msvc

# mise: activate for interactive PowerShell sessions (per-project tool versions + env vars like JAVA_HOME)
mise activate pwsh | Out-String | Invoke-Expression

# starship: cross-shell prompt
if (-not [Console]::IsOutputRedirected) {
    Invoke-Expression (&starship init powershell)
}

# PSReadLine: history-based predictions + menu-style tab completion, no bell
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -BellStyle None
if (-not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
}

# PSFzf: fuzzy history (Ctrl+r) and file (Ctrl+t) search via fzf
if (-not (Get-Module -ListAvailable -Name PSFzf)) {
    Install-Module -Name PSFzf -Scope CurrentUser -Force
}
Import-Module PSFzf
if (-not [Console]::IsOutputRedirected) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# PSScriptAnalyzer: PowerShell linter (Invoke-ScriptAnalyzer) + formatter (Invoke-Formatter)
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
}

# homeos: shell completion (static script written by the installer)
if (Test-Path "$HOME\.homeos\completion.ps1") {
    . "$HOME\.homeos\completion.ps1"
}

# zoxide: smarter cd (adds `z` and `zi`) — keep at end so it hooks the prompt last
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# y: run yazi and cd to its last directory on exit
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -LiteralPath $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

# Cheatsheet: traditional command -> modern replacement (type `cheat` to reshow)
function Show-Cheatsheet {
    Write-Host ""
    Write-Host "  modern CLI" -ForegroundColor Cyan -NoNewline
    Write-Host "  ·  traditional → replacement" -ForegroundColor DarkGray
    $rows = @(
        @('cat',   'bat',      'syntax-highlighted pager'),
        @('ls',    'eza',      'icons + git status'),
        @('find',  'fd',       'fast file search'),
        @('grep',  'rg',       'fast content search'),
        @('cd',    'z / zi',   'frecency jump (zoxide)'),
        @('diff',  'delta',    'prettier git diffs'),
        @('files', 'yazi / y', 'TUI manager (y = cd on exit)')
    )
    foreach ($r in $rows) {
        Write-Host ("    {0,-7}" -f $r[0]) -ForegroundColor DarkGray -NoNewline
        Write-Host "→ " -ForegroundColor Cyan -NoNewline
        Write-Host ("{0,-11}" -f $r[1]) -ForegroundColor Green -NoNewline
        Write-Host $r[2] -ForegroundColor DarkGray
    }
    Write-Host "    fuzzy  " -ForegroundColor DarkGray -NoNewline
    Write-Host "  Ctrl+R " -ForegroundColor Green -NoNewline
    Write-Host "history  " -ForegroundColor DarkGray -NoNewline
    Write-Host "Ctrl+T " -ForegroundColor Green -NoNewline
    Write-Host "files" -ForegroundColor DarkGray
    Write-Host ""
}
Set-Alias cheat Show-Cheatsheet
if (-not [Console]::IsOutputRedirected) { Show-Cheatsheet }
