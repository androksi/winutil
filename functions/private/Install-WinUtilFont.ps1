function Get-WinUtilFontFile {
    <#

    .SYNOPSIS
        Picks the TrueType files to install from an extracted font release

    .DESCRIPTION
        Releases ship static and variable builds side by side, and static files work in every
        program. A release with a static folder installs only that folder; otherwise variable
        builds are skipped and every other .ttf is installed.

    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $root = (Resolve-Path -LiteralPath $Path).Path
    $files = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter *.ttf)

    $static = @($files | Where-Object { $_.FullName.Substring($root.Length) -match '[\\/]static[\\/]' })
    if ($static.Count -gt 0) {
        return $static
    }

    return @($files | Where-Object { $_.FullName.Substring($root.Length) -notmatch 'variable' })
}

function Install-WinUtilFont {
    <#

    .SYNOPSIS
        Installs a font for the current user from its project's latest GitHub release

    .DESCRIPTION
        Copies the release's TrueType files into the per-user font folder and registers them under
        HKCU, so no other account is affected. The files WinUtil added are recorded under
        HKCU:\Software\WinUtil\Fonts so Uninstall-WinUtilFont removes only those. A file of the
        same name that is already there is left alone.

    .PARAMETER Key
        The feature.json entry, used as the record's name

    .PARAMETER Name
        The name shown in progress and the log

    .PARAMETER Repository
        GitHub owner/name of the project that publishes the font

    .PARAMETER Asset
        Regular expression matching the release asset to download

    #>
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Repository,

        [Parameter(Mandatory)]
        [string]$Asset
    )

    # The progress bar slows Windows PowerShell downloads to a crawl
    $ProgressPreference = 'SilentlyContinue'
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases/latest" -TimeoutSec 30 -ErrorAction Stop
    $download = @($release.assets | Where-Object { $_.name -match $Asset }) | Select-Object -First 1
    if (-not $download) {
        throw "The latest $Repository release ($($release.tag_name)) has no file matching '$Asset'."
    }

    $workDir = Join-Path ([System.IO.Path]::GetTempPath()) "WinUtil_Font_$([guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null

    try {
        $sizeMB = [math]::Round($download.size / 1MB, 1)
        Write-Host "Downloading $Name $($release.tag_name) ($sizeMB MB)..."
        Write-WinUtilLog -Component "Fonts" -Message "Downloading $Name $($release.tag_name) from $($download.browser_download_url) ($sizeMB MB)"

        $zipPath = Join-Path $workDir $download.name
        Invoke-WebRequest -Uri $download.browser_download_url -OutFile $zipPath -UseBasicParsing -ErrorAction Stop

        $extractDir = Join-Path $workDir 'files'
        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force -ErrorAction Stop

        $files = @(Get-WinUtilFontFile -Path $extractDir)
        if ($files.Count -eq 0) {
            throw "$($download.name) contains no TrueType fonts."
        }

        $fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
        $fontRegistry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
        $recordPath = "HKCU:\Software\WinUtil\Fonts\$Key"
        foreach ($path in @($fontDir)) {
            if (-not (Test-Path -LiteralPath $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
        }
        foreach ($path in @($fontRegistry, $recordPath)) {
            if (-not (Test-Path -Path $path)) { New-Item -Path $path -Force | Out-Null }
        }

        $recorded = [System.Collections.Generic.List[string]]::new()
        foreach ($file in @((Get-ItemProperty -Path $recordPath).Files)) {
            if ($file) { $recorded.Add($file) }
        }

        Initialize-WinUtilFontNative
        $added = 0
        $present = 0
        foreach ($file in $files) {
            $target = Join-Path $fontDir $file.Name
            if (Test-Path -LiteralPath $target) {
                # Either an earlier run installed it, or it is the user's own copy; neither is replaced
                $present++
                continue
            }

            Copy-Item -LiteralPath $file.FullName -Destination $target -ErrorAction Stop
            New-ItemProperty -Path $fontRegistry -Name "$($file.BaseName) (TrueType)" -Value $target -PropertyType String -Force | Out-Null
            [void][WinUtilFontNative]::AddFontResource($target)
            $recorded.Add($target)
            $added++
        }

        New-ItemProperty -Path $recordPath -Name Files -Value ([string[]]$recorded) -PropertyType MultiString -Force | Out-Null
        New-ItemProperty -Path $recordPath -Name Version -Value ([string]$release.tag_name) -PropertyType String -Force | Out-Null
        [WinUtilFontNative]::BroadcastFontChange()

        Write-Host "Installed $Name`: $added file(s) added, $present already present."
        Write-WinUtilLog -Component "Fonts" -Message "Installed $Name $($release.tag_name) for the current user: $added file(s) added, $present already present."
    } finally {
        Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
