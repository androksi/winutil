function Initialize-WinUtilFontNative {
    <#

    .SYNOPSIS
        Loads the Win32 calls that make a per-user font usable without signing out

    .DESCRIPTION
        Windows loads per-user fonts from HKCU at sign-in. AddFontResource loads a new file into
        the current session, RemoveFontResource unloads it so the file can be deleted, and the
        WM_FONTCHANGE broadcast tells running programs to refresh their font lists.

    #>

    if (-not ([System.Management.Automation.PSTypeName]'WinUtilFontNative').Type) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class WinUtilFontNative {
    [DllImport("gdi32.dll", CharSet = CharSet.Unicode)]
    public static extern int AddFontResource(string lpFileName);

    [DllImport("gdi32.dll", CharSet = CharSet.Unicode)]
    public static extern bool RemoveFontResource(string lpFileName);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);

    public static void BroadcastFontChange() {
        IntPtr result;
        // HWND_BROADCAST, WM_FONTCHANGE, SMTO_ABORTIFHUNG
        SendMessageTimeout((IntPtr)0xffff, 0x001D, IntPtr.Zero, IntPtr.Zero, 0x0002, 1000, out result);
    }
}
"@
    }
}
