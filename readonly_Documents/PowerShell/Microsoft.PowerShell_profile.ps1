# mise: activate for interactive PowerShell sessions (per-project tool versions + env vars like JAVA_HOME)
mise activate pwsh | Out-String | Invoke-Expression

# starship: cross-shell prompt
Invoke-Expression (&starship init powershell)

# PSReadLine: history-based predictions + menu-style tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
if (-not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
}

# zoxide: smarter cd (adds `z` and `zi`) — keep at end so it hooks the prompt last
Invoke-Expression (& { (zoxide init powershell | Out-String) })
