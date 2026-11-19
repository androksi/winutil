function Invoke-WPFFontInstall {
    <#

    .SYNOPSIS
        Installs the selected fonts for the current user

    .DESCRIPTION
        Font checkboxes are feature.json entries that carry fontRepository, so they share the
        feature selection. Like Invoke-WPFFeatureInstall, the selection is read and checked here,
        before the job starts.

    #>

    $fonts = @($sync.selectedFeatures | Where-Object { $sync.configs.feature.$_.fontRepository } | ForEach-Object {
        $entry = $sync.configs.feature.$_
        @{ Key = $_; Name = $entry.Content; Repository = $entry.fontRepository; Asset = $entry.fontAsset }
    })

    if ($fonts.Count -eq 0) {
        Show-WinUtilMessage -Message "No font selected" -Title "WinUtil" -Button "OK" -Icon "Warning" | Out-Null
        return
    }

    Write-WinUtilLog -Component "Fonts" -Message "Fonts requested for install: $(($fonts | ForEach-Object { $_.Name }) -join ', ')"

    Start-WinUtilJob -Name "Fonts" -Description "Installing fonts" -QueueIfBusy -Parameters @{
        Fonts = $fonts
    } -ScriptBlock {
        param($Fonts)

        $total = @($Fonts).Count
        $completed = 0
        foreach ($font in $Fonts) {
            $completed++
            Step-WinUtilJob -Status "Installing $($font.Name) ($completed/$total)" -Percent ([int]((($completed - 1) / $total) * 100))
            Measure-WinUtilStep -Scope "Fonts" -Name $font.Name -ScriptBlock {
                # One unavailable download must not stop the remaining fonts
                try {
                    Install-WinUtilFont -Key $font.Key -Name $font.Name -Repository $font.Repository -Asset $font.Asset
                } catch {
                    Write-Warning "Could not install $($font.Name): $($_.Exception.Message)"
                    Write-WinUtilLog -Level "ERROR" -Component "Fonts" -Message "Could not install $($font.Name): $($_.Exception.Message)"
                }
            }
            Step-WinUtilJob -Status "Installed $($font.Name) ($completed/$total)" -Percent ([int](($completed / $total) * 100))
        }
        Write-Host "Programs that were already open may need to be restarted to list the new fonts."
    }
}
