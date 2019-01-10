; ================================================================================
Global Const $OCR_NORMAL = 32512
Global Const $OCR_IBEAM = 32513
Global Const $OCR_WAIT = 32514
Global Const $OCR_CROSS = 32515
Global Const $OCR_UP = 32516
Global Const $OCR_SIZENWSE = 32642
Global Const $OCR_SIZENESW = 32643
Global Const $OCR_SIZEWE = 32644
Global Const $OCR_SIZENS = 32645
Global Const $OCR_SIZEALL = 32646
Global Const $OCR_NO = 32648
Global Const $OCR_HAND = 32649
Global Const $OCR_APPSTARTING = 32650

Global Const $OCR_CURSORCNT = 13
Global Const $OCR_CURSORS[13] = [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]
; ================================================================================

Global $hDefaultCursors[13] = [0,0,0,0,0,0,0,0,0,0,0,0,0]
Global $hEmptyCursor

; ================================================================================
Func _HideAllCursors()
	For $i=0 To $OCR_CURSORCNT-1
		Local $hCur = _CopyCursor($hEmptyCursor)
		If @error Then
			MsgBox(0, "Error", "cursor.au3:_HideAllCursors(): Error copying empty cursor: " & $i)
			Exit
		EndIf
		_SetSystemCursor($hCur, $OCR_CURSORS[$i])
		If @error Then
			MsgBox(0, "Error", "cursor.au3:_HideAllCursors(): Error setting cursor: " & $OCR_CURSORS[$i])
			Exit
		EndIf
	Next
EndFunc

; ================================================================================
Func _RestoreAllCursors()
	For $i=0 To $OCR_CURSORCNT-1
		Local $hCur = _CopyCursor($hDefaultCursors[$i])
		If @error Then
			MsgBox(0, "Error", "cursor.au3:_RestoreAllCursors(): Error copying cursor: " & $OCR_CURSORS[$i])
			Exit
		EndIf
		_SetSystemCursor($hCur, $OCR_CURSORS[$i])
		If @error Then
			MsgBox(0, "Error", "cursor.au3:_RestoreAllCursors(): Error setting cursor: " & $OCR_CURSORS[$i])
			Exit
		EndIf
	Next
EndFunc

; ================================================================================
Func _InitAllCursors()
	; load empty cursor
	Local $sFile = @ScriptDir & "\empty.cur"
	$hEmptyCursor = _LoadCursorFromFile($sFile)
	If @error Then
		MsgBox(0, "Error", "cursor.au3:_InitAllCursors(): Error loading empty cursor: " & $sFile)
		Exit
	EndIf
	; store system cursors
	For $i=0 To $OCR_CURSORCNT-1
		Local $hCur = _LoadCursor($OCR_CURSORS[$i])
		If @error Then
			MsgBox(0, "Error", "cursor.au3:_InitAllCursors(): Error loading system cursor: " & $OCR_CURSORS[$i])
			Exit
		EndIf
		$hDefaultCursors[$i] = _CopyCursor($hCur)
		If @error Then
			MsgBox(0, "Error", "cursor.au3:_InitAllCursors(): Error copying system cursor: " & $OCR_CURSORS[$i])
			Exit
		EndIf
	Next
EndFunc
; ================================================================================

Func _LoadCursorFromFile($iCursor)
    Return SetError(@error, @extended, _API(DllCall("user32.dll", "int", "LoadCursorFromFile", "str", $iCursor)))
EndFunc  ;==>_LoadCursorFromFile

Func _LoadCursor($iCursor)
    Return SetError(@error, @extended, _API(DllCall("user32.dll", "int", "LoadCursorA", "hwnd", 0, "int", $iCursor)))
EndFunc  ;==>_LoadCursor

Func _SetSystemCursor($hCursor, $iCursor)
    Return SetError(@error, @extended, _API(DllCall("user32.dll", "int", "SetSystemCursor", "int", $hCursor, "int", $iCursor)))
EndFunc  ;==>_SetSystemCursor

Func _CopyCursor_($iCursor); <--- check your user32.dll for CopyCursor function. Is it there?
    Return SetError(@error, @extended, _API(DllCall("user32.dll", "int", "CopyCursor", "hwnd", $iCursor)))
EndFunc  ;==>_CopyCursor_

Func _DestroyCursor($iCursor)
    Return SetError(@error, @extended, _API(DllCall("user32.dll", "int", "DestroyCursor", "hwnd", $iCursor)))
EndFunc  ;==>_DestroyCursor

Func _API($v_ret)
    Local $err = @error
    Local $ext = @extended
    If Not $err Then
        If IsArray($v_ret) Then
            Return $v_ret[0]
        Else
            Return $v_ret
        EndIf
    EndIf
    Return SetError($err, $ext, 0)
EndFunc  ;==>_API


Func _CopyCursor($hCursor)

    Local $aCall = DllCall("user32.dll", "hwnd", "CopyImage", _
            "hwnd", $hCursor, _
            "dword", 2, _; IMAGE_CURSOR
            "int", 0, _; same width as the original
            "int", 0, _; same height as the original
            "dword", 16384); LR_COPYFROMRESOURCE

    If @error Or Not $aCall[0] Then
        Return SetError(1, 0, 0)
    EndIf

    Return SetError(0, 0, $aCall[0])

EndFunc  ;==>_CopyCursor