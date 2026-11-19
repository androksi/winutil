function Uninstall-WinUtilFont {
    <#

    .SYNOPSIS
        Removes a font that Install-WinUtilFont installed for the current user

    .DESCRIPTION
        Only the files recorded under HKCU:\Software\WinUtil\Fonts are touched, so a font the
        user installed some other way stays. A file still open in a running program cannot be
        deleted: it is unregistered, kept in the record, and removed by running this again
        once that program is closed.

    .PARAMETER Key
        The feature.json entry the font was installed from

    .PARAMETER Name
        The name shown in progress and the log

    #>
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $recordPath = "HKCU:\Software\WinUtil\Fonts\$Key"
    if (-not (Test-Path -Path $recordPath)) {
        Write-Host "$Name was not installed by WinUtil; nothing to remove."
        Write-WinUtilLog -Component "Fonts" -Message "$Name was not installed by WinUtil; nothing to remove."
        return
    }

    $fontRegistry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    Initialize-WinUtilFontNative

    $inUse = [System.Collections.Generic.List[string]]::new()
    $removed = 0
    foreach ($target in @((Get-ItemProperty -Path $recordPath).Files)) {
        if (-not $target) { continue }

        [void][WinUtilFontNative]::RemoveFontResource($target)
        $valueName = "$([System.IO.Path]::GetFileNameWithoutExtension($target)) (TrueType)"
        if ($null -ne (Get-ItemProperty -Path $fontRegistry -Name $valueName -ErrorAction SilentlyContinue)) {
            Remove-ItemProperty -Path $fontRegistry -Name $valueName -ErrorAction Stop
        }

        if (Test-Path -LiteralPath $target) {
            try {
                Remove-Item -LiteralPath $target -Force -ErrorAction Stop
            } catch {
                $inUse.Add($target)
                continue
            }
        }
        $removed++
    }

    [WinUtilFontNative]::BroadcastFontChange()

    if ($inUse.Count -gt 0) {
        New-ItemProperty -Path $recordPath -Name Files -Value ([string[]]$inUse) -PropertyType MultiString -Force | Out-Null
        $message = "$Name`: $removed file(s) removed; $($inUse.Count) are still open in a program. Close it and run Remove Fonts again."
        Write-Warning $message
        Write-WinUtilLog -Level "WARN" -Component "Fonts" -Message $message
        return
    }

    Remove-Item -Path $recordPath -Recurse -Force
    Write-Host "Removed $Name`: $removed file(s)."
    Write-WinUtilLog -Component "Fonts" -Message "Removed $Name for the current user: $removed file(s)."
}
