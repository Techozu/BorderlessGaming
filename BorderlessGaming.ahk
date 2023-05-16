#SingleInstance
#UseHook On

;Get Total screen size of all monitors combined
SysGet, TotalWidth, 78
SysGet, TotalHeight, 79

;Read in config
SetWorkingDir,%A_ScriptDir%
FileName := "borderless_config.ini"
DefaultSection := "config"
ReadData()

if !FileExist(FileName)
{
  NewMainHotkey:="F12"
  gosub UpdateHotkey
  WriteData()
}

gosub UpdateHotkey

;Setup default text
WindowTextPrefix := "Current Window: "
GUITitle := "Borderless Gaming - AHK Edition"

;Setup GUI
Gui, Add, Text, x12 y19 w450 h20 +Center vCurrentWindowText, %WindowTextPrefix%

Gui, Add, Text, x12 y59 w60 h20 +Center, X Offset
Gui, Add, Edit, x72 y59 w95 h20 +Center gCheck Number vEditXOffset,
Gui, Add, UpDown, x167 y59 w0 h20 +Center 0x80 Range0-%TotalWidth% vXOffset, %XOffset%

Gui, Add, Text, x12 y99 w60 h20 +Center, Y Offset
Gui, Add, Edit, x72 y99 w95 h20 +Center gCheck Number vEditYOffset,
Gui, Add, UpDown, x167 y99 w0 h20 +Center 0x80 Range0-%TotalHeight% vYOffset, %YOffset%

Gui, Add, Text, x282 y59 w60 h20 +Center, Width
Gui, Add, Edit, x342 y59 w95 h20 +Center gCheck Number vEditResWidth,
Gui, Add, UpDown, x437 y59 w0 h20 +Center 0x80 Range0-%TotalWidth% vResWidth, %ResWidth%

Gui, Add, Text, x282 y99 w60 h20 +Center, Height
Gui, Add, Edit, x342 y99 w95 h20 +Center gCheck Number vEditResHeight,
Gui, Add, UpDown, x437 y99 w0 h20 +Center 0x80 Range0-%TotalHeight% vResHeight, %ResHeight%

Gui, Add, CheckBox, x22 y139 w140 h40 vHideTaskbar Checked%HideTaskbar%, Hide Taskbar and Start Button?

Gui, Add, Text, x282 y139 w60 h20 +Center, Hotkey
Gui, Add, Hotkey, x342 y139 w95 h20 +Center gUpdateHotkey vNewMainHotkey, %MainHotkey%

Gui, Add, Button, x180 y179 w140 h40 gSave Default, Save

;Setup tray options
Menu, Tray, Click, 2
Menu, Tray, NoStandard
Menu, Tray, Add, Show GUI, ShowGui
Menu, Tray, Add, Exit App, ExitApp
Menu, Tray, Default, Show GUI

;Display GUI
GUIOpen := 1
Gui, Show, w479 h250, %GUITitle%

;Setup a cleanup function if the script exits
OnExit("Cleanup")

while (1)
{
  if (WindowID)
  {
    tempID := WinExist("ahk_id " WindowID)
    if (not tempID)
    {
      ;Reset to Taskbar
      WinShow, ahk_class Shell_TrayWnd
      WinShow, Start ahk_class Button

      ;Clear the variables for good measure
      WindowState:=
      WindowID:=
      WindowTitle:=
      GuiControl, , CurrentWindowText, %WindowTextPrefix%
    }
  } else {
    Sleep, 500
  }
}

ChangeBorderlessMode:
  if (GUIOpen == 1)
  {
    return
  }

  WinGet, TempWindowID, ID, A
  If (WindowID != TempWindowID)
  {
    ;If we are in fullscreen reset old window first
    if (WindowState == 1 and WindowID)
    {
      Window()
    }

    ;Replace WindowID with our new window and reset the state
    WinGetTitle, WindowTitle, ahk_id %TempWindowID%
    GuiControl, , CurrentWindowText, %WindowTextPrefix%%WindowTitle%
    WindowID := TempWindowID
    WindowState := 0
  }

  ;If the state is 0 (normal window) we fullscreen it otherwise window it
  If (WindowState == 0)
  {
    Fullscreen()
  }
  Else
  {
    Window()
  }

  ;Switch the WindowState to the opposite
  WindowState := !WindowState
return

Fullscreen()
{
  global

  ;Get original window location
  WinGetPos, WinPosX, WinPosY, WindowWidth, WindowHeight, ahk_id %WindowID%

  ;Set window to be borderless
  WinSet, Style, -0xC40000, ahk_id %WindowID%

  ;Move window to new location at X and Y offset
  WinMove, ahk_id %WindowID%, , XOffset, YOffset, ResWidth, ResHeight

  ;Hide Windows Task Bar and Start Button if set to "True"
  if (HideTaskbar == 1)
  {
    WinHide, ahk_class Shell_TrayWnd
    WinHide, Start ahk_class Button
  }
}

Window()
{
  global

  ;Set window to be bordered
  WinSet, Style, +0xC40000, ahk_id %WindowID%

  ;Move window back to original coordinates
  WinMove, ahk_id %WindowID%, , WinPosX, WinPosY, WindowWidth, WindowHeight

  ;Show the task bar again
  WinShow, ahk_class Shell_TrayWnd
  WinShow, Start ahk_class Button
}

Cleanup(ExitReason, ExitCode)
{
  ;Put any fullsize app into a window state
  if (WindowState == 1)
  {
    Window()
  }
}

ReadData()
{
  global

  ;Read in all the variables we need with some defaults
  IniRead, XOffset, %FileName%, DefaultSection, XOffset, 0
  IniRead, YOffset, %FileName%, DefaultSection, YOffset, 0
  IniRead, ResWidth, %FileName%, DefaultSection, ResWidth, % TotalWidth / 2
  IniRead, ResHeight, %FileName%, DefaultSection, ResHeight, %TotalHeight%
  IniRead, HideTaskbar, %FileName%, DefaultSection, HideTaskbar, 1
  IniRead, NewMainHotkey, %FileName%, DefaultSection, MainHotkey

  if (NewMainHotkey = ERROR)
  {
    NewMainHotkey := ""
  }
}

WriteData()
{
  global

  ;Save all variables
  IniWrite, %XOffset%, %FileName%, DefaultSection, XOffset
  IniWrite, %YOffset%, %FileName%, DefaultSection, YOffset
  IniWrite, %ResWidth%, %FileName%, DefaultSection, ResWidth
  IniWrite, %ResHeight%, %FileName%, DefaultSection, ResHeight
  IniWrite, %HideTaskbar%, %FileName%, DefaultSection, HideTaskbar
  IniWrite, %MainHotkey%, %FileName%, DefaultSection, MainHotkey
}

Check:
  ;Check that each edit field only contains numbers (pasting circumvents the "Number" option of the edit)
  if (EditXOffset is integer)
  {
    GuiControl, , XOffset, %EditXOffset%
  }

  if (EditYOffset is integer)
  {
    GuiControl, , YOffset, %EditYOffset%
  }

  if (EditResWidth is integer)
  {
    GuiControl, , ResWidth, %EditResWidth%
  }

  if (EditResHeight is integer)
  {
    GuiControl, , ResHeight, %EditResHeight%
  }
return

UpdateHotkey:
  ;Check a valid hotkey was set
  if (NewMainHotkey is alnum) and (NewMainHotkey != "")
  {
    ;Disable old hotkey
    if (MainHotkey is alnum) and (MainHotkey != "")
    {
      Hotkey, %MainHotkey%, Off
    }

    ;Enable new hotkey
    MainHotkey := NewMainHotkey
    Hotkey, %MainHotkey%, ChangeBorderlessMode
  } else {
    IF (NewMainHotkey == "")
    {
      MainHotkey := ""
    }
  }
return

Save:
  ;If the "Save" button is pressed then do a submit sa all variables are filled
  Gui, Submit

  ;Save Data
  WriteData()

  GUIOpen := 0
return

ShowGui:
  ;Open GUI and inform script its oepn
  GUIOpen := 1
  Gui, Show, w479 h250, %GUITitle%
return

GuiClose:
GuiEscape:
  ;Close GUI and inform script its closed
  GUIOpen := 0
  Gui, Hide
return

ExitApp:
ExitApp
