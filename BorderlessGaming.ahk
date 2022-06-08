#UseHook On
F12::
  XOffset = 1280
  ResWidth = 2540
  ResHeight = 1440

  WinGet, TempWindowID, ID, A
  If (WindowID != TempWindowID)
  {
    WindowID:=TempWindowID
    WindowState:=0
  }
  If (WindowState != 1)
  {
    WinGetPos, WinPosX, WinPosY, WindowWidth, WindowHeight, ahk_id %WindowID%
    WinSet, Style, -0xC40000, ahk_id %WindowID%
    WinMove, ahk_id %WindowID%, , XOffset, 0, ResWidth, ResHeight
    ;Hide Windows Task Bar and Start Button. (Remove the following two lines if you don't want that behaviour)
    WinHide ahk_class Shell_TrayWnd
    WinHide Start ahk_class Button
  }
  Else
  {
    WinSet, Style, +0xC40000, ahk_id %WindowID%
    WinMove, ahk_id %WindowID%, , WinPosX, WinPosY, WindowWidth, WindowHeight
    ;Show the task bar again
    WinShow ahk_class Shell_TrayWnd
    WinShow Start ahk_class Button
  }
  WindowState:=!WindowState
return
