function Switch-WinUtilAppxCategory {
    <#

    .SYNOPSIS
        Selects every app in an AppX Removal category, or clears them if all are already selected

    .DESCRIPTION
        The category header carries the keys of its entries in Tag. Only checkboxes currently shown
        are changed, so a category filtered down by the search box changes only what the user sees.
        Setting IsChecked raises the checkboxes' own events, which keep the selection list in step.

    .PARAMETER Label
        The category header that was clicked

    #>
    param(
        [Parameter(Mandatory)]
        $Label
    )

    $boxes = @($Label.Tag | ForEach-Object { $sync[$_] } | Where-Object {
        $_ -is [System.Windows.Controls.CheckBox] -and $_.IsVisible
    })
    if ($boxes.Count -eq 0) {
        return
    }

    $select = @($boxes | Where-Object { -not $_.IsChecked }).Count -gt 0
    foreach ($box in $boxes) {
        $box.IsChecked = $select
    }
}
