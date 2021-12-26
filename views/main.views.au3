#include-once

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>

#include <..\services\facebook.service.au3>
#include <..\utils\array.util.au3>

Global $mvForm, $mvInpCookie, $mvBtnLogin, $mvLbName, $mvInpSpaceRemeoveStart, $mvInpSpaceRemoveEnd, _
		$mvInpCountSleep, $mvInpSleepStart, $mvInpSleepEnd, $mvCbbStyleRemove, $mvInpCountRemove, _
		$mvInpUidRemove, $mvInpGetMessageOnePerRequest, $mvLbCountDone, $mvLbCountFail, _
		$mvBtnRemoveMessage, $mvTaLogs, $mvBtnContact ;

Global $mvFbData = Null ;

Func _mv_init()
	$mvForm = GUICreate("ARM V1.0", 332, 529)
	GUICtrlCreateGroup("Bảng đăng nhập:", 8, 8, 313, 97)
	GUICtrlCreateLabel("Cookie: ", 16, 32, 43, 17)
	$mvInpCookie = GUICtrlCreateInput("", 80, 32, 225, 21)
	$mvBtnLogin = GUICtrlCreateButton("Đăng nhập", 232, 64, 75, 25)
	GUICtrlCreateLabel("Xin chào: ", 16, 72, 50, 17)
	$mvLbName = GUICtrlCreateLabel("............................", 80, 72, 120, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("Bảng điều khiển:", 8, 112, 313, 241)
	GUICtrlCreateLabel("Khoảng cách gỡ 2 TN từ: ", 24, 136, 150, 17)
	$mvInpSpaceRemeoveStart = GUICtrlCreateInput("2500", 168, 128, 57, 21)
	GUICtrlCreateLabel("đến", 232, 136, 24, 17)
	$mvInpSpaceRemoveEnd = GUICtrlCreateInput("3500", 256, 128, 57, 21)
	GUICtrlCreateLabel("Cứ gỡ mỗi: ", 24, 168, 57, 17)
	$mvInpCountSleep = GUICtrlCreateInput("100", 88, 160, 33, 21)
	GUICtrlCreateLabel("TN, nghỉ từ ", 128, 168, 54, 17)
	$mvInpSleepStart = GUICtrlCreateInput("120000", 184, 160, 49, 21)
	GUICtrlCreateLabel("đến", 240, 168, 24, 17)
	$mvInpSleepEnd = GUICtrlCreateInput("180000", 264, 160, 49, 21)
	GUICtrlCreateLabel("Phong cách gỡ: ", 24, 200, 83, 17)
	$mvCbbStyleRemove = GUICtrlCreateCombo("Từ mới nhất xuống cũ nhất.", 120, 192, 185, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $CBS_DROPDOWNLIST))
	GUICtrlSetData(-1, "Từ cũ nhất lên mới nhất")
	GUICtrlCreateLabel("Số lượng tin nhắn sẽ gỡ: ", 24, 232, 122, 17)
	$mvInpCountRemove = GUICtrlCreateInput("0", 152, 224, 81, 21)
	GUICtrlCreateLabel("UID: ", 24, 264, 29, 17)
	$mvInpUidRemove = GUICtrlCreateInput("", 56, 256, 129, 21)
	GUICtrlCreateLabel("(0 là gỡ tất cả)", 240, 232, 72, 17)
	GUICtrlCreateLabel("Lấy ", 192, 264, 22, 17)
	$mvInpGetMessageOnePerRequest = GUICtrlCreateInput("5000", 216, 256, 57, 21)
	GUICtrlCreateLabel("tn/1rq", 280, 264, 33, 17)
	GUICtrlCreateLabel("Xóa: ", 16, 328, 50, 17)
	$mvLbCountDone = GUICtrlCreateLabel("0", 72, 328, 16, 17)
	GUICtrlCreateLabel("OK, ", 88, 328, 34, 17)
	$mvLbCountFail = GUICtrlCreateLabel("0", 128, 328, 16, 17)
	GUICtrlCreateLabel("Lỗi", 152, 328, 17, 17)
	$mvBtnRemoveMessage = GUICtrlCreateButton("Xóa T.Nhắn", 232, 320, 83, 25)
	GUICtrlCreateGroup("Log", 8, 352, 313, 121)
	$mvTaLogs = GUICtrlCreateEdit("", 16, 368, 297, 97)
	GUICtrlCreateGroup("Liên hệ", 8, 480, 313, 41)
	$mvBtnContact = GUICtrlCreateButton("Liên hệ", 240, 488, 75, 25)
	GUICtrlCreateLabel("ARM v1.0 - Code by ThienDepZaii", 40, 496, 180, 17)
EndFunc   ;==>_mv_init

Func _mv_setState($state = @SW_SHOW)
	GUISetState($state)
EndFunc   ;==>_mv_setState

Func _mv_waitEvent()
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Exit
			Case $mvBtnLogin
				__mv_loginHandle() ;
			Case $mvBtnRemoveMessage
				__mv_removeMessageHandle() ;
			Case $mvBtnContact
		EndSwitch
	WEnd
EndFunc   ;==>_mv_waitEvent


Func _mv_setStateAllBtn($state = $GUI_DISABLE)
	GUICtrlSetState($mvInpCookie, $state)
	GUICtrlSetState($mvBtnLogin, $state)
	GUICtrlSetState($mvInpSpaceRemeoveStart, $state)
	GUICtrlSetState($mvInpSpaceRemoveEnd, $state)
	GUICtrlSetState($mvInpCountSleep, $state)
	GUICtrlSetState($mvInpSleepStart, $state)
	GUICtrlSetState($mvInpSleepEnd, $state)
	GUICtrlSetState($mvCbbStyleRemove, $state)
	GUICtrlSetState($mvInpCountRemove, $state)
	GUICtrlSetState($mvInpUidRemove, $state)
	GUICtrlSetState($mvBtnRemoveMessage, $state)
	GUICtrlSetState($mvInpGetMessageOnePerRequest, $state)
	GUICtrlSetState($mvBtnContact, $state)
EndFunc   ;==>_mv_setStateAllBtn


Func _mv_addLog($text)
	$time = "[" & _timeUt_getCurrentStrTime() & "]" ;
	$logs = GUICtrlRead($mvTaLogs) ;
	GUICtrlSetData($mvTaLogs, $time & " " & $text & @CRLF & $logs) ;
EndFunc   ;==>_mv_addLog

Func __mv_loginHandle()
	_mv_setStateAllBtn() ;
	GUICtrlSetData($mvLbCountDone, 0);
	GUICtrlSetData($mvLbCountFail, 0);
	GUICtrlSetData($mvTaLogs, "");
	$mvFbData = Null ;
	$cookie = GUICtrlRead($mvInpCookie) ;
	$fbData = _fb_login($cookie) ;
	If @error Then
		GUICtrlSetData($mvLbName, "............................") ;
		MsgBox(16, "Lỗi", $fbData) ;
		Return _mv_setStateAllBtn($GUI_ENABLE) ;
	EndIf
	$mvFbData = $fbData ;
	GUICtrlSetData($mvLbName, $fbData[2]) ;
	_mv_setStateAllBtn($GUI_ENABLE) ;
EndFunc   ;==>__mv_loginHandle

Func __mv_removeMessageHandle()
	If $mvFbData == Null Then
		Return MsgBox(16, "Lỗi", "Bạn phải đăng nhập trước.") ;
	EndIf
	_mv_setStateAllBtn() ;
	GUICtrlSetData($mvLbCountDone, 0);
	GUICtrlSetData($mvLbCountFail, 0);
	GUICtrlSetData($mvTaLogs, "");
	$uidRemove = GUICtrlRead($mvInpUidRemove) ;
	$countRemove = GUICtrlRead($mvInpCountRemove) ;
	$getMessOnePerRequest = GUICtrlRead($mvInpGetMessageOnePerRequest) ;
	$spaceRemoveStart = GUICtrlRead($mvInpSpaceRemeoveStart) ;
	$spaceRemoveEnd = GUICtrlRead($mvInpSpaceRemoveEnd) ;
	$countSleep = GUICtrlRead($mvInpCountSleep) ;
	$sleepStart = GUICtrlRead($mvInpSleepStart) ;
	$sleepEnd = GUICtrlRead($mvInpSleepEnd) ;

	Dim $listMessages[1][2] ;
	$lastTime = -1 ;
	While 1
		_mv_addLog("Đang lấy danh sách " & $getMessOnePerRequest & " tin nhắn....") ;
		$list = _fb_getMessageList($mvFbData, $uidRemove, $lastTime, $getMessOnePerRequest) ;
		If @error Then
			ExitLoop ;
		EndIf
		$lastTime = $list[0][0] - 1 ;
		if $lastTime == -2 Then
			ExitLoop;
		EndIf
		_ArrayDelete($list, 0) ;
		_ArrayConcatenate($list, $listMessages) ;
		$listMessages = $list ;
		If $countRemove <> 0 And UBound($listMessages) > $countRemove Then
			ExitLoop ;
		EndIf
		Sleep(1000) ;
	WEnd
	$countRemoveStr = $countRemove == 0 ? "tất cả" : $countRemove;
	_mv_addLog("Lấy " & $countRemoveStr & " tin nhắn thành công.") ;
	If _GUICtrlComboBox_GetCurSel($mvCbbStyleRemove) == 0 Then
		$listMessages = _arrUt_reverse2DArray($listMessages) ;
		_ArrayDelete($listMessages, 0) ;
	Else
		_ArrayDelete($listMessages, UBound($listMessages) - 1) ;
	EndIf
	$lengthMessages = UBound($listMessages) ;
	$removeDone = 0 ;
	$removeFail = 0 ;
	For $i = 0 To $lengthMessages - 1
		$messageId = $listMessages[$i][0] ;
		$text = $listMessages[$i][1] ;
		$status = _fb_removeMessage($mvFbData, $messageId) ;
		$statusStr = $status ? "OK" : "FAIL" ;
		If $status Then
			$removeDone += 1 ;
			GUICtrlSetData($mvLbCountDone, $removeDone) ;
		Else
			$removeFail += 1 ;
			GUICtrlSetData($mvLbCountFail, $removeFail) ;
		EndIf
		If $removeDone + $removeFail > 0 And Mod($removeDone + $removeFail, $countSleep) == 0 Then
			$timeSleep = Random($sleepStart, $sleepEnd, 1) ;
			_mv_addLog("Xóa thành công " & $countSleep & " TN, chờ " & $timeSleep & "milis.") ;
			Sleep($timeSleep) ;
			ContinueLoop ;
		EndIf
		$timeSleep = Random($spaceRemoveStart, $spaceRemoveEnd, 1) ;
		_mv_addLog("Xóa '" & $text & "' " & $statusStr & ", chờ " & $timeSleep & "milis.") ;
		Sleep($timeSleep) ;
	Next
	MsgBox(64, "Thông báo", "Xóa thành công.") ;
	_mv_setStateAllBtn($GUI_ENABLE) ;
EndFunc   ;==>__mv_removeMessageHandle
