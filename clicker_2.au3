; ----------------------------------------------------------------------------
; Script Start
; ----------------------------------------------------------------------------

;Include constants
#include <GUIConstantsEx.au3>

#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <misc.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>

#include "cursor.au3"

; ============================================================================
Opt('MustDeclareVars', 1)

; ============================================================================
;Initialize variables
Global $AppName = "Clicker"
Global $AppVersion = "2.0"
Global $hGUI, $PosTarget[2] = [0, 0], $PosReturn[2] = [0, 0]
Global $GUIWidth = 330, $GUIHeight = 135
Global $LabelPos, $RadioTarget, $RadioReturn, $EditHelp
Global $Ini = @ScriptDir & "\clicker.ini"
Global $Icon = @ScriptDir & "\clicker.ico"

; ============================================================================
_Main()

; ============================================================================
Func _Main()
	AutoItSetOption("MouseClickDownDelay", 100)
	;AutoItSetOption("MouseClickDelay", 20)

	$hGUI = GUICreate("Clicker " & $AppVersion, $GUIWidth, $GUIHeight)
	$LabelPos = GUICtrlCreateLabel("Label1", 10, 10, 200, 20)
	$RadioTarget = GUICtrlCreateRadio("Drag to Target point", 10, 30, 120, 20)
	$RadioReturn = GUICtrlCreateRadio("Drag to Return point", 10, 50, 120, 20)
	GUICtrlSetState($RadioTarget, $GUI_CHECKED)
	$EditHelp = GUICtrlCreateEdit("Win+Insert - Do Click" & @CRLF & "Win+Home - Show/Hide Program" & _
			@CRLF & "Win+End - Mute/Unmute Sound" & _
			@CRLF & @CRLF & "(drag from Clicker to desired point)", _
			140, 30, 180, 80, $ES_READONLY)
	GUISetIcon($Icon)
	TraySetIcon($Icon)
	TraySetToolTip ($AppName & " " & $AppVersion)
	GUISetCursor(9)

	; Register notification messages
	GUIRegisterMsg($WM_LBUTTONDOWN, "WM_LBUTTONDOWN")

	; Win+Insert - click hotkey
	HotKeySet("#{INS}", "DoClick")
	HotKeySet("#{HOME}", "ShowHide")
	HotKeySet("#{END}", "Mute")

	; load options
	$PosTarget[0] = IniRead($Ini, "ROOT", "PosTargetX", 0)
	$PosTarget[1] = IniRead($Ini, "ROOT", "PosTargetY", 0)
	$PosReturn[0] = IniRead($Ini, "ROOT", "PosReturnX", 0)
	$PosReturn[1] = IniRead($Ini, "ROOT", "PosReturnY", 0)
	UpdatePos()

	; init cursor hider
	_InitAllCursors()

	; Show window
	GUISetState(@SW_SHOW)
	; Loop until user exits
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	; save options
	IniWrite($Ini, "ROOT", "PosTargetX", $PosTarget[0])
	IniWrite($Ini, "ROOT", "PosTargetY", $PosTarget[1])
	IniWrite($Ini, "ROOT", "PosReturnX", $PosReturn[0])
	IniWrite($Ini, "ROOT", "PosReturnY", $PosReturn[1])

EndFunc   ;==>_Main

; ============================================================================
Func WM_LBUTTONDOWN($hWnd, $iMsg, $iwParam, $ilParam)
	Local $timeout = 1, $timer = TimerInit()
	Do
		If Not _IsPressed("01") Then
			$timeout = 0
			ExitLoop
		EndIf
	Until TimerDiff($timer) > 400
	If $timeout Then
		Do
			Sleep(5)
		Until Not _IsPressed("01")
		If BitAND(GUICtrlRead($RadioTarget), $GUI_CHECKED) = $GUI_CHECKED Then
			$PosTarget = MouseGetPos()
		Else
			$PosReturn = MouseGetPos()
		EndIf
		UpdatePos()
	EndIf
EndFunc   ;==>WM_LBUTTONDOWN

; ============================================================================
Func UpdatePos()
	GUICtrlSetData($LabelPos, "Target: " & $PosTarget[0] & ", " & $PosTarget[1] & _
			"   Return: " & $PosReturn[0] & ", " & $PosReturn[1])
EndFunc   ;==>UpdatePos

; ============================================================================
Func DoClick()
	_HideAllCursors()
	MouseClick("left", $PosTarget[0], $PosTarget[1], 1, 2)
	MouseMove($PosReturn[0], $PosReturn[1], 2)
	_RestoreAllCursors()
EndFunc   ;==>DoClick
; ============================================================================
Func ShowHide()
	Local $ret = DllCall("user32.dll", "int", "IsWindowVisible", "hwnd", $hGUI)
	;MsgBox(0, "", "error: " & @error & "  state: " & $ret[0])
	If $ret[0] Then
		GUISetState(@SW_HIDE)
	Else
		GUISetState(@SW_SHOW)
	EndIf
EndFunc   ;==>ShowHide
 
; ============================================================================
Func Mute()
   Send("{VOLUME_MUTE}")
EndFunc   ;==>Mute
