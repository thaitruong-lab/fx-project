SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; =========================================================================
global excel := "ahk_exe EXCEL.EXE"
global mt4 := "ahk_exe terminal.exe"
global mt4Symbols := []

mt4ClickStart()
{
  ControlGetPos, X, Y, Width, Height, Button10
  MouseClick, left , X+Width/2, Y+Height/2
  Sleep, 100
  return
}
mt4ClickSettings()
{
  MouseClick, left , 60, 697
  Sleep, 100
  return
}
mt4ClickResults()
{
  MouseClick, left , 118, 700
  Sleep, 100
  return
}
mt4ChooseNextSymbol()
{
  ControlFocus, ComboBox3
  Send, {Down}
  return
}
mt4GetCurrentSymbol()
{
  activeWindow(mt4)
  Sleep, 200
  mt4ClickSettings()
  Sleep, 100
  ControlGetText, symbol, ComboBox3
  symbol:= SubStr(symbol, 1, 6)
  return symbol
}
;;
activeSheetExcel(sheetName)
{
  try
  {
    Xl := ComObjActive("Excel.Application")       	; connects to active Excel instance
    Xl.Worksheets(sheetName).Activate       		; selects (activates) the specified Excel "tab"
    WinActivate, % "ahk_exe EXCEL.EXE" Xl.Hwnd          ; brings most recently active Excel window to forefront of screen
    WinMaximize, % "ahk_exe EXCEL.EXE" Xl.Hwnd     	; maximizes most recently active Excel window
  }
  Sleep, 100
  return
}
activeWindow(ahkName)
{
  if WinExist(ahkName)
    WinActivate
  else
    {
      MsgBox, Khong tim thay %ahkName%
      Exit
    }

  WinWaitActive, %ahkName%,, 2
  if ErrorLevel
  {
      MsgBox, wWinWait timed out
      Exit
  }
  return
}
;;
copyResultDataToExcel()
{
  activeWindow(mt4)
  mt4ClickResults()
  Clipboard := ""
  Send, !a
  ClipWait, 2
  if ErrorLevel
  {
    activeWindow(Excel)
    Send, ^+Q
    return
  }

  activeWindow(Excel)
  activeSheetExcel("Buffer")
  Send, ^{Home 2}
  Send, ^v

  Sleep, 200
  Send, ^+Q
  return
}
activeMT4andRunNextSymbol()
{
  activeWindow(mt4)
  mt4ChooseNextSymbol()
  mt4ClickStart()
  return
}

activeMT4andRunThisSymbol(symbol)
{
  activeWindow(mt4)
  mt4ChooseSymbol(symbol)
  mt4ClickStart()
  return
}
;;
copyOptimizeDataToExcel()
{
  symbol := mt4GetCurrentSymbol()
  mt4ClickResults()
  Send, !a

  activeWindow(Excel)

  ControlClick, Edit1
  Send, B1
  Sleep, 100
  Send, {Enter}
  Send, ^{Down 3}
  Send, ^{Up}
  Send, {Down}

  addressBefore := ""
  ControlGetText, addressBefore, Edit1

  Send, ^v
  Send, ^{Down 3}
  Send, ^{Up}
  Sleep, 200

  addressAfter:= ""
  ControlGetText, addressAfter, Edit1

  Send, {Left}
  Send, ^+{Up}
  Sleep, 200
  Send, +{Down}
  Send, %symbol%
  Send, ^{Enter}

  return
}

waitCalculationFinish()
{
  activeWindow(mt4)
  Loop, 600
  {
    Sleep, 500
    ControlGetText, statuss, Button10
    If (statuss="Start")
      {
        Sleep, 200
        Break
      }
    If (A_Index=588)
      {
        MsgBox, % "Wait too long but calculation not done yet, gonna exit now"
        Exit
      }
  }
  return

}

excelGetSymbol()
{
  activeWindow(Excel)
  clipboard := ""
  Sleep, 200
  Send ^{Home 2}
  Send, {Right}
  Send, {Down 1}
  Send ^c
  ClipWait, 2
  if ErrorLevel
  {
    MsgBox, % "excelGetSymbol() error, exit program"
    Exit
  }
  symbol := SubStr(clipboard, 1, 6)
  Send, {Esc}
  Sleep, 100
  Return symbol
}

excelWaitMacroDone() ; excel have to be activated fist
{
  WinWaitActive, Macro finish,, 10
  if ErrorLevel
  {
    MsgBox, % "Macro can not finish"
    Exit
  }
  Send, {Enter}
}

playMusic()
{
  SoundBeep, 698.46, 150 ;F5
  SoundBeep, 349.23, 150 ;F4
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6
  SoundBeep, 1396.92, 150 ;F6

  return
}

mt4ChooseSymbol(symbol)
{
  activeWindow(mt4)
  mt4ClickSettings()
  ControlFocus, ComboBox3
  Send, {Home}
  Sleep, 100

  length := mt4Symbols.Length()
  i := 0

  Loop, % mt4Symbols.Length()
  {
    i := i + 1
    temp := mt4Symbols[i]
    if temp = %symbol%
    {

      Sleep, 50
      if i > 1
        Loop, % i-1
          Send, {Down}
      return
    }
  }

  MsgBox, % "Can not choose symbol, exit program"
  Exit

}

mt4GetSymbolsArray(ByRef symbolsArray)
{

  activeWindow(mt4)
  mt4ClickSettings()
  temp := ""
  ControlFocus, Combobox3
  Send, {Home}
  Loop, 50
  {
    ControlGetText, symbol, Combobox3
    if symbol = %temp%
      Return
    temp = %symbol%
    symbol := SubStr(symbol, 1, 6)
    symbolsArray.Push(symbol)
    Send, {Down}
    Sleep, 20
  }

  return symbolsArray
}
;; Tester Zone ---------------------
!p::Pause
;#If WinActive("ahk_exe EXCEL.EXE")
;#If WinActive("ahk_exe terminal.exe")
^+S::

mt4Symbols := []
mt4GetSymbolsArray(mt4Symbols)
mt4ChooseSymbol("GBPJPY")

return

; PLAY ZONE==================================================================
#If WinActive("ahk_exe EXCEL.EXE")
^+D::
mt4Symbols := []
mt4GetSymbolsArray(mt4Symbols)

symbol := excelGetSymbol()
activeMT4andRunThisSymbol(symbol)
waitCalculationFinish()
Sleep, 500
copyResultDataToExcel()
return

^+R::
mt4Symbols := []
mt4GetSymbolsArray(mt4Symbols)

temp := ""
Loop, 30
{
  symbol := excelGetSymbol()
  If symbol = %temp%
  {
    playMusic()
    MsgBox, Finished
    Exit
  }
  temp = %symbol%

  activeMT4andRunThisSymbol(symbol)
  waitCalculationFinish()
  Sleep, 500
  copyResultDataToExcel()
  excelWaitMacroDone()
}
mt4Symbols := []
return


#If WinActive("ahk_exe terminal.exe")
; =========================================================================
^+D::
copyResultDataToExcel()
Sleep, 2000
return