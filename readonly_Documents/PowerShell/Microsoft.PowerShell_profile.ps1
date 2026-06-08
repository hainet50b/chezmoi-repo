# UTF-8 everywhere (console I/O + pipeline to native commands)
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
} catch {}
$OutputEncoding = [System.Text.Encoding]::UTF8

# mise: activate for interactive PowerShell sessions (per-project tool versions + env vars like JAVA_HOME)
mise activate pwsh | Out-String | Invoke-Expression

# starship: cross-shell prompt
Invoke-Expression (&starship init powershell)

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

# homeos: shell completion (static script written by the installer)
if (Test-Path "$HOME\.homeos\completion.ps1") {
    . "$HOME\.homeos\completion.ps1"
}

# zoxide: smarter cd (adds `z` and `zi`) — keep at end so it hooks the prompt last
Invoke-Expression (& { (zoxide init powershell | Out-String) })
