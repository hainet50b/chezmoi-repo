# mise: activate for interactive PowerShell sessions (per-project tool versions + env vars like JAVA_HOME)
mise activate pwsh | Out-String | Invoke-Expression

# starship: cross-shell prompt
Invoke-Expression (&starship init powershell)

# PSReadLine: history-based predictions + menu-style tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
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

# zoxide: smarter cd (adds `z` and `zi`) — keep at end so it hooks the prompt last
Invoke-Expression (& { (zoxide init powershell | Out-String) })
