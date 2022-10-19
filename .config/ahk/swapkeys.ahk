#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CheckForErgodox()

OnMessage(0x219, "MonitorUsb")
Return

MonitorUsb(wParam, lParam, msg, hwnd)
{
    CheckForErgodox()
}

CheckForErgodox()
{
    static Swap := 0

    UpdateStatus("Checking for ergodox")
    RunWait, "C:\Program Files\PowerShell\7\pwsh.EXE" -File "%A_ScriptDir%\detect-usb-device.ps1" "Ergodox EZ" -OutputPath "%A_AppData%\swapkeys\ergodox-present", , Hide
    FileReadLine, ErgodoxPresent, %A_AppData%\swapkeys\ergodox-present, 1
    if (ErgodoxPresent != Swap)
    {
        Swap :=ErgodoxPresent
    }
    if (ErgodoxPresent)
    {
        UpdateStatus("Ergodox present")
    } else {
        UpdateStatus("Ergodox not present")
    }
}

UpdateStatus(status)
{
    Menu, Tray, Tip, swapkeys: %status%
}
