function Invoke-WPFFontUninstall {
    <#

    .SYNOPSIS
        Removes the selected fonts that WinUtil installed for the current user

    #>

    $fonts = @($sync.selectedFeatures | Where-Object { $sync.configs.feature.$_.fontRepository } | ForEach-Object {
        @{ Key = $_; Name = $sync.configs.feature.$_.Content }
    })

    if ($fonts.Count -eq 0) {
        Show-WinUtilMessage -Message "No font selected" -Title "WinUtil" -Button "OK" -Icon "Warning" | Out-Null
        return
    }

    Write-WinUtilLog -Component "Fonts" -Message "Fonts requested for removal: $(($fonts | ForEach-Object { $_.Name }) -join ', ')"

    Start-WinUtilJob -Name "Fonts" -Description "Removing fonts" -QueueIfBusy -Parameters @{
        Fonts = $fonts
    } -ScriptBlock {
        param($Fonts)

        $total = @($Fonts).Count
        $completed = 0
        foreach ($font in $Fonts) {
            $completed++
            Step-WinUtilJob -Status "Removing $($font.Name) ($completed/$total)" -Percent ([int]((($completed - 1) / $total) * 100))
            Measure-WinUtilStep -Scope "Fonts" -Name $font.Name -ScriptBlock {
                try {
                    Uninstall-WinUtilFont -Key $font.Key -Name $font.Name
                } catch {
                    Write-Warning "Could not remove $($font.Name): $($_.Exception.Message)"
                    Write-WinUtilLog -Level "ERROR" -Component "Fonts" -Message "Could not remove $($font.Name): $($_.Exception.Message)"
                }
            }
            Step-WinUtilJob -Status "Removed $($font.Name) ($completed/$total)" -Percent ([int](($completed / $total) * 100))
        }
    }
}
