#Requires AutoHotkey >=2.0.2
#SingleInstance
#UseHook true

;Get Total screen size of all monitors combined
TotalWidth := SysGet(78)
TotalHeight := SysGet(79)

;Prepare some Temp variable
WinPosX := 0
WinPosY := 0
WindowWidth := 0
WindowHeight := 0
WindowID := 0
TempWindowID := 0
WindowState := 0
NewMainHotkey := ""
MainHotkey := ""

;Read in config
SetWorkingDir(A_ScriptDir)
FileName := "borderless_config.ini"
DefaultSection := "config"
ReadData()

if (!FileExist(FileName))
{
  NewMainHotkey := "F12"
  UpdateHotkey({},0)
  WriteData()
} else {
  UpdateHotkey({},0)
}

;Setup default text
WindowTextPrefix := "Current Window: "
GUITitle := "Borderless Gaming - AHK Edition"

;Setup GUI
MainWindow := Gui("+MinSize479x250", GUITitle)
MainWindow.OnEvent("Close", GuiClose, 1)
MainWindow.OnEvent("Escape", GuiClose, 1)

CurrentWindowText := MainWindow.Add("Text", "x12 y19 w450 h20 Center", WindowTextPrefix)

MainWindow.Add("Text", "x12 y59 w60 h20 +Center", "X Offset")
EditXOffset := MainWindow.Add("Edit", "x72 y59 w95 h20 +Center Number", )
ControlXOffset := MainWindow.Add("UpDown", "x167 y59 w0 h20 +Center 0x80 Range0-" TotalWidth, XOffset)
EditXOffset.OnEvent("Change", UpdateNumbers, 1)
ControlXOffset.OnEvent("Change", UpdateNumbers, 1)

MainWindow.Add("Text", "x12 y99 w60 h20 +Center", "Y Offset")
EditYOffset := MainWindow.Add("Edit", "x72 y99 w95 h20 +Center Number", )
ControlYOffset := MainWindow.Add("UpDown", "x167 y99 w0 h20 +Center 0x80 Range0-" TotalHeight, YOffset)
EditYOffset.OnEvent("Change", UpdateNumbers, 1)
ControlYOffset.OnEvent("Change", UpdateNumbers, 1)

MainWindow.Add("Text", "x282 y59 w60 h20 +Center", "Width")
EditResWidth := MainWindow.Add("Edit", "x342 y59 w95 h20 +Center Number", )
ControlResWidth := MainWindow.Add("UpDown", "x437 y59 w0 h20 +Center 0x80 Range0-" TotalWidth, ResWidth)
EditResWidth.OnEvent("Change", UpdateNumbers, 1)
ControlResWidth.OnEvent("Change", UpdateNumbers, 1)

MainWindow.Add("Text", "x282 y99 w60 h20 +Center", "Height")
EditResHeight := MainWindow.Add("Edit", "x342 y99 w95 h20 +Center Number", )
ControlResHeight := MainWindow.Add("UpDown", "x437 y99 w0 h20 +Center 0x80 Range0-" TotalHeight, ResHeight)
EditResHeight.OnEvent("Change", UpdateNumbers, 1)
ControlResHeight.OnEvent("Change", UpdateNumbers, 1)

ControlHideTaskbar := MainWindow.Add("CheckBox", "x22 y139 w140 h40 Checked" HideTaskbar, "Hide Taskbar and Start Button?")
ControlHideTaskbar.OnEvent("Click", UpdateCheckbox, 1)

MainWindow.Add("Text", "x282 y139 w60 h20 +Center", "Hotkey")
ControlHotkey := MainWindow.Add("Hotkey", "x342 y139 w95 h20 +Center", MainHotkey)
ControlHotkey.OnEvent("Change", UpdateHotkey, 1)

ButtonSave := MainWindow.Add("Button", "x180 y179 w140 h40 Default", "Save")
ButtonSave.OnEvent("Click", Save, 1)

;Setup tray options
A_TrayMenu.Delete() ;Remove the default tray items
A_TrayMenu.Add("Show GUI", ShowGui)
A_TrayMenu.Add("Exit App", ExitGui)
A_TrayMenu.Default := "Show GUI"

;Display GUI
GUIOpen := 1
MainWindow.Show()

;Setup a cleanup function if the script exits
OnExit(Cleanup)

while (1)
{
  if (WindowID)
  {
    tempID := WinExist("ahk_id " WindowID)
    if (tempID == 0)
    {
      ;Reset to Taskbar
      try WinShow("ahk_class Shell_TrayWnd")
      try WinShow("Start ahk_class Button")

      ;Clear the variables for good measure
      WindowState:=0
      WindowID:=0
      WindowTitle:=""
      CurrentWindowText.Value := WindowTextPrefix
    }
  } else {
    Sleep(500)
  }
}

ChangeBorderlessMode(_) {
  global

  if (GUIOpen == 1)
  {
    return
  }

  TempWindowID := WinGetID("A")
  If (WindowID != TempWindowID)
  {
    ;If we are in fullscreen reset old window first
    if (WindowState == 1 && WindowID)
    {
      Window()
    }

    ;Replace WindowID with our new window and reset the state
    WindowTitle := WinGetTitle("ahk_id " TempWindowID)
    CurrentWindowText.Value := WindowTextPrefix WindowTitle
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
}

Fullscreen()
{
  global

  ;Get original window location
  WinGetPos(&WinPosX, &WinPosY, &WindowWidth, &WindowHeight, "ahk_id " WindowID)

  ;Set window to be borderless
  WinSetStyle("-0xC40000", "ahk_id " WindowID)

  ;Move window to new location at X and Y offset
  WinMove(XOffset, YOffset, ResWidth, ResHeight, "ahk_id " WindowID)

  ;Hide Windows Task Bar and Start Button if set to "True"
  if (HideTaskbar == 1)
  {
    try WinHide("ahk_class Shell_TrayWnd")
    try WinHide("Start ahk_class Button")
  }
}

Window()
{
  global

  ;Set window to be bordered
  WinSetStyle("+0xC40000", "ahk_id " WindowID)

  ;Move window back to original coordinates
  WinMove(WinPosX, WinPosY, WindowWidth, WindowHeight, "ahk_id " WindowID)

  ;Show the task bar again
  try WinShow("ahk_class Shell_TrayWnd")
  try WinShow("Start ahk_class Button")
}

Cleanup(ExitReason, ExitCode)
{
  global

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
  XOffset := IniRead(FileName, "DefaultSection", "XOffset", 0)
  YOffset := IniRead(FileName, "DefaultSection", "YOffset", 0)
  ResWidth := IniRead(FileName, "DefaultSection", "ResWidth", TotalWidth / 2)
  ResHeight := IniRead(FileName, "DefaultSection", "ResHeight", TotalHeight)
  HideTaskbar := IniRead(FileName, "DefaultSection", "HideTaskbar", 1)
  NewMainHotkey := IniRead(FileName, "DefaultSection", "MainHotkey", "")

  if (NewMainHotkey = "ERROR")
  {
    NewMainHotkey := ""
  }
}

WriteData()
{
  global

  ;Save all variables
  IniWrite(XOffset, FileName, "DefaultSection", "XOffset")
  IniWrite(YOffset, FileName, "DefaultSection", "YOffset")
  IniWrite(ResWidth, FileName, "DefaultSection", "ResWidth")
  IniWrite(ResHeight, FileName, "DefaultSection", "ResHeight")
  IniWrite(HideTaskbar, FileName, "DefaultSection", "HideTaskbar")
  IniWrite(MainHotkey, FileName, "DefaultSection", "MainHotkey")
}

UpdateCheckbox(_, __) {
  global

  HideTaskbar := ControlHideTaskbar.Value
}

UpdateNumbers(_, __) {
  global

  ;Check that each edit field only contains numbers (pasting circumvents the "Number" option of the edit)
  if (isInteger(EditXOffset))
  {
    ControlXOffset.Value := EditXOffset.Value
  }

  if (isInteger(EditYOffset))
  {
    ControlYOffset.Value := EditYOffset.Value
  }

  if (isInteger(EditResWidth))
  {
    ControlResWidth.Value := EditResWidth.Value
  }

  if (isInteger(EditResHeight))
  {
    ControlResheight.Value := EditResHeight.Value
  }

  XOffset := ControlXOffset.Value
  YOffset := ControlYOffset.Value
  ResWidth := ControlResWidth.Value
  ResHeight := ControlResHeight.Value
}

UpdateHotkey(_, __) {
  global

  if (NewMainHotkey == "" && IsSet(ControlHotkey)) {
    NewMainHotkey := ControlHotkey.Value
  }

  ;Check a valid hotkey was set
  if (isAlnum(NewMainHotkey) && NewMainHotkey !== "")
  {
    ;Disable old hotkey
    if (isAlnum(MainHotkey) && MainHotkey !== "")
    {
      Hotkey MainHotkey, "Off"
    }

    ;Enable new hotkey
    MainHotkey := NewMainHotkey
    NewMainHotkey := ""
    Hotkey(MainHotkey, ChangeBorderlessMode)
  } else {
    if (NewMainHotkey == "")
    {
      MainHotkey := ""
    }
  }
}

Save(_, __) {
  global

  ;If the "Save" button is pressed then do a submit sa all variables are filled
  MainWindow.Submit()

  ;Save Data
  WriteData()

  GUIOpen := 0
}

ShowGui(_, __, ___) {
  global

  ;Open GUI and inform script its oepn
  GUIOpen := 1
  MainWindow.Show()
}

GuiClose(_) {
  global

  ;Close GUI and inform script its closed
  GUIOpen := 0
  MainWindow.Hide()
}

ExitGui(_, __, ___) {
  ExitApp()
}
