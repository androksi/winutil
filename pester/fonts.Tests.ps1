#===========================================================================
# Tests - Font installation
#===========================================================================

BeforeAll {
    $script:repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    . (Join-Path $script:repoRoot "functions\private\Install-WinUtilFont.ps1")

    function New-FontTree {
        param([string[]]$RelativePaths)

        $root = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        foreach ($relativePath in $RelativePaths) {
            $file = Join-Path $root $relativePath
            New-Item -ItemType File -Path $file -Force | Out-Null
        }
        return $root
    }
}

Describe "Get-WinUtilFontFile" {
    It "installs only the static folder when a release has one" {
        $root = New-FontTree @("ttf/CascadiaCode.ttf", "ttf/static/CascadiaCode-Regular.ttf", "ttf/static/CascadiaMono-Bold.ttf", "otf/static/CascadiaCode-Regular.otf")

        $names = @(Get-WinUtilFontFile -Path $root | ForEach-Object Name | Sort-Object)

        $names | Should -Be @("CascadiaCode-Regular.ttf", "CascadiaMono-Bold.ttf")
    }

    It "skips variable builds when there is no static folder" {
        $root = New-FontTree @("ttf/FiraCode-Regular.ttf", "ttf/FiraCode-Bold.ttf", "variable_ttf/FiraCode-VF.ttf", "woff2/FiraCode-Regular.woff2")

        $names = @(Get-WinUtilFontFile -Path $root | ForEach-Object Name | Sort-Object)

        $names | Should -Be @("FiraCode-Bold.ttf", "FiraCode-Regular.ttf")
    }

    It "takes every TrueType file from a flat release" {
        $root = New-FontTree @("HackNerdFont-Regular.ttf", "HackNerdFontMono-Regular.ttf", "LICENSE.md", "README.md")

        @(Get-WinUtilFontFile -Path $root).Count | Should -Be 2
    }
}

Describe "Font entries in feature.json" {
    BeforeAll {
        $script:feature = Get-Content (Join-Path $script:repoRoot "config\feature.json") -Raw | ConvertFrom-Json
        $script:fontEntries = @($script:feature.PSObject.Properties | Where-Object { $_.Value.fontRepository })
    }

    It "keeps the feature selection prefix and names a release file" {
        $script:fontEntries.Count | Should -BeGreaterThan 0
        foreach ($entry in $script:fontEntries) {
            $entry.Name | Should -Match '^WPFFeatureFont'
            $entry.Value.fontRepository | Should -Match '^[\w.-]+/[\w.-]+$'
            { [regex]::new($entry.Value.fontAsset) } | Should -Not -Throw
            $entry.Value.category | Should -Be "Fonts"
        }
    }

    It "wires the install and remove buttons" {
        $script:feature.WPFFontInstall.function | Should -Be "Invoke-WPFFontInstall"
        $script:feature.WPFFontUninstall.function | Should -Be "Invoke-WPFFontUninstall"
    }
}
