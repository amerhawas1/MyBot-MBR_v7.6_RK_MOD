; #FUNCTION# ====================================================================================================================
; Name ..........:
; Description ...: This function will notify events and allow remote control of your bot on your mobile phone
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Full revamp of Notify by IceCube (2016-09)
; Modified ......: IceCube (2016-12) v1.5.1, CodeSLinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global Const $TELEGRAM_URL = "https://api.telegram.org/bot"
Global Const $HTTP_STATUS_OK = 200

Func NotifyRemoteControl()
	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyRemoteControl()")
	If $g_bNotifyRemoteEnable = True Then NotifyRemoteControlProc()
EndFunc   ;==>NotifyRemoteControl

Func NotifyReport()
	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyReport()")
	If $g_bNotifyAlertVillageReport = True Then
		Local $text = $g_sNotifyOrigin & ":" & "\n"
		$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold])
		$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & "\n"
		$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-DE_Info_01", "DE") & "]: " & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir])
		$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & _NumberFormat($g_aiCurrentLoot[$eLootTrophy]) & "\n"
		$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Free-Builders_Info_01", "No. of Free Builders") & "]: " & $g_iFreeBuilderCount
		NotifyPushToTelegram($text)
	EndIf
	If $g_bNotifyAlertLastAttack = True Then
		If Not ($g_iStatsLastAttack[$eLootGold] = "" And $g_iStatsLastAttack[$eLootElixir] = "") Then
			Local $text = $g_sNotifyOrigin & ":" & "\n"
			$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootGold])
			$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootElixir]) & "\n"
			$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-DE_Info_01", "DE") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootDarkElixir])
			$text &= " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootTrophy])
			NotifyPushToTelegram($text)
		EndIf
	EndIf
	If _Sleep($DELAYNOTIFY1) Then Return
	checkMainScreen(False)
EndFunc   ;==>NotifyReport

; GENERAL FUNCTION TO PUSH MSG
Func PushMsg($Message, $Source = "")
	If $g_bDebugSetlog Then SetDebugLog("Notify | PushMsg()")
	NotifyPushMessageToBoth($Message, $Source)
EndFunc   ;==>PushMsg

; EXECUTE NOTIFY PENDING ACTIONS
Func NotifyPendingActions()
	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyPendingActions()")
	If ($g_bNotifyTGEnable = False Or $g_sNotifyTGToken = "") Then Return

	NotifyRemoteControl()

	If $g_bTGRequestScreenshot = True Then
		$g_bNotifyForced = True
		PushMsg("RequestScreenshot")
	EndIf
	If $g_bTGRequestBuilderInfo = True Then
		$g_bNotifyForced = True
		PushMsg("BuilderInfo")
	EndIf
	If $g_bTGRequestShieldInfo = True Then
		$g_bNotifyForced = True
		PushMsg("ShieldInfo")
	EndIf
	PushMsg("BuilderIdle")
EndFunc   ;==>NotifyPendingActions

; ONLY PUSH TELEGRAM MSG
Func NotifyPushToTelegram($pMessage)

	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyPushToTelegram(" & $pMessage & " ): ")

	If Not $g_bNotifyTGEnable Or $g_sNotifyTGToken = "" Then Return

	If Not IsPlanUseTelegram($pMessage) Then Return

	If $g_bNotifyTGEnable And $g_sNotifyTGToken <> "" Then
		Local $oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
		If @error Then
			SetLog("Telegram Obj Error code: " & Hex(@error, 8), $COLOR_ERROR)
			Return
		EndIf
		$oHTTP.Open("Post", $TELEGRAM_URL & $g_sNotifyTGToken & "/sendMessage", False)
		If (@error) Then Return SetError(1, 0, "__HttpGet/Post Error")
		$oHTTP.SetRequestHeader("Content-Type", "application/json; charset=ISO-8859-1,utf-8")

		Local $Date = @YEAR & '-' & @MON & '-' & @MDAY
		Local $Time = @HOUR & '.' & @MIN
		Local $TGPushMsg = '{"text":"' & $pMessage & '\n' & $Date & '_' & $Time & '", "chat_id":' & $g_sTGChatID & '}}'
		$oHTTP.Send($TGPushMsg)
		If $oHTTP.Status <> $HTTP_STATUS_OK Then
			SetLog("Telegram status is: " & $oHTTP.Status, $COLOR_ERROR)
			Local $text = _StringBetween($oHTTP.ResponseText, '"description":"', '"}')
			Setlog($text[0])
			Return
		EndIf
	EndIf

EndFunc   ;==>NotifyPushToTelegram

; ONLY PUSH TELEGRAM FILES
Func NotifyPushFileToTelegram($File, $Folder, $FileType, $body)

	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyPushFileToTelegram($File, $Folder, $FileType, $body): " & $File & "," & $Folder & "," & $FileType & "," & $body)

	If Not $g_bNotifyTGEnable Or $g_sNotifyTGToken = "" Then Return

	If $g_bNotifyTGEnable And $g_sNotifyTGToken <> "" Then
		If FileExists($g_sProfilePath & "\" & $g_sProfileCurrentName & '\' & $Folder & '\' & $File) Then
			Local $oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
			If @error Then
				SetLog("Telegram Obj Error code: " & Hex(@error, 8), $COLOR_ERROR)
				Return
			EndIf
			Local $sCmd = "/sendPhoto"
			Local $sCmd1 = "photo"
			If $FileType = "text\/plain; charset=utf-8" Then
				$sCmd = "/sendDocument"
				$sCmd1 = "document"
			EndIf
			Local $telegram_urlAll = $TELEGRAM_URL & $g_sNotifyTGToken & $sCmd
			Local $Result = RunWait($g_sCurlPath & " -i -X POST " & $telegram_urlAll & ' -F chat_id="' & $g_sTGChatID & '" -F ' & $sCmd1 & '=@"' & $g_sProfilePath & "\" & $g_sProfileCurrentName & '\' & $Folder & '\' & $File & '"', "", @SW_HIDE)
			$oHTTP.Open("Post", $TELEGRAM_URL & $g_sNotifyTGToken & "/sendMessage", False)
			If (@error) Then Return SetError(1, 0, "__HttpGet/Post Error")
			$oHTTP.SetRequestHeader("Content-Type", "application/json; charset=ISO-8859-1,utf-8")
			Local $pPush = '{"text":"' & $body & '", "chat_id":' & $g_sTGChatID & '}}'
			$oHTTP.Send($pPush)
			If $oHTTP.Status <> $HTTP_STATUS_OK Then
				SetLog("Telegram status is: " & $oHTTP.Status, $COLOR_ERROR)
				Local $text = _StringBetween($oHTTP.ResponseText, '"description":"', '"}')
				Setlog($text[0])
				Return
			EndIf
			$oHTTP.WaitForResponse
			If $g_bDebugSetlog Then SetDebugLog("$oHTTP.ResponseText: " & $oHTTP.ResponseText)
		Else
			SetLog("Notify Telegram: Unable to send file " & $File, $COLOR_ERROR)
			NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Uploading-File_Info_03", "Unable to Upload File") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Uploading-File_Info_02", "Occured an error type 2 uploading file to Telegram server..."))
		EndIf

	EndIf
EndFunc   ;==>NotifyPushFileToTelegram

; GET LAST MSG ID USED AT MainLoop()
Func NotifyGetLastMessageFromTelegram()
	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyGetLastMessageFromTelegram()")

	Local $TGLastMessage = ""
	If Not $g_bNotifyTGEnable Or $g_sNotifyTGToken = "" Then Return

	Local $oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	If @error Then
		SetLog("Telegram Obj Error code: " & Hex(@error, 8), $COLOR_ERROR)
		Return
	EndIf

	$oHTTP.Open("Get", $TELEGRAM_URL & $g_sNotifyTGToken & "/getupdates", False)
	If (@error) Then Return SetError(1, 0, "__HttpGet/Post Error")
	$oHTTP.Send()
	$oHTTP.WaitForResponse
	Local $Result = $oHTTP.ResponseText
	If $oHTTP.Status <> 200 Then
		SetLog("Telegram status is: " & $oHTTP.Status, $COLOR_ERROR)
		Local $text = _StringBetween($oHTTP.ResponseText, '"description":"', '"}')
		Setlog($text[0])
		Return
	EndIf

	Local $chat_id = _StringBetween($Result, 'm":{"id":', ',"f')
	$g_sTGChatID = _ArrayPop($chat_id)
	If $g_bDebugSetlog Then SetDebugLog("Telegram $g_sTGChatID:" & $g_sTGChatID)

	Local $uid = _StringBetween($Result, 'update_id":', '"message"') ;take update id
	$g_sTGLast_UID = StringTrimRight(_ArrayPop($uid), 2)

	Local $findstr2 = StringRegExp(StringUpper($Result), '"TEXT":"')
	If $findstr2 = 1 Then
		Local $rmessage = _StringBetween($Result, 'text":"', '"}}') ;take message
		$TGLastMessage = _ArrayPop($rmessage) ;take last message
		If $g_bDebugSetlog Then SetDebugLog("Telegram $TGLastMessage:" & $TGLastMessage)
	EndIf

	If $g_bDebugSetlog Then SetDebugLog("Telegram $g_sTGLast_UID:" & $g_sTGLast_UID)

	$oHTTP.Open("Get", $TELEGRAM_URL & $g_sNotifyTGToken & "/getupdates?offset=" & $g_sTGLast_UID, False)
	If (@error) Then Return SetError(1, 0, "__HttpGet/Post Error")
	$oHTTP.Send()
	$oHTTP.WaitForResponse
	Local $Result2 = $oHTTP.ResponseText
	If $oHTTP.Status <> $HTTP_STATUS_OK Then
		SetLog("Telegram status is: " & $oHTTP.Status, $COLOR_ERROR)
		Local $text = _StringBetween($oHTTP.ResponseText, '"description":"', '"}')
		Setlog($text[0])
		Return
	EndIf
	If _IsInternet() < 1 Then
		SetLog("Telegram: Check your internet connection! No Connection..", $COLOR_ERROR)
		Return
	EndIf
	Local $findstr2 = StringRegExp(StringUpper($Result2), '"TEXT":"')
	If $findstr2 = 1 Then
		Local $rmessage = _StringBetween($Result2, 'text":"', '"}}') ;take message
		$TGLastMessage = _ArrayPop($rmessage) ;take last message
		If $TGLastMessage = "" Then
			Local $rmessage = _StringBetween($Result2, 'text":"', '","entities"') ;take message
			$TGLastMessage = _ArrayPop($rmessage) ;take last message
		EndIf
		If $g_bDebugSetlog Then SetDebugLog("Telegram - $TGLastMessage:" & $TGLastMessage)
		Return $TGLastMessage
	EndIf

EndFunc   ;==>NotifyGetLastMessageFromTelegram

; SENDING CUSTOM KEYBOARD
Func NotifyActivateKeyboardOnTelegram($TGMsg)
	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyActivateKeyboardOnTelegram($TGMsg): " & $TGMsg)

	Local $oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	If @error Then
		SetLog("Telegram Obj Error code: " & Hex(@error, 8), $COLOR_ERROR)
		Return
	EndIf
	$oHTTP.Open("Post", $TELEGRAM_URL & $g_sNotifyTGToken & "/sendMessage", False)
	If (@error) Then Return SetError(1, 0, "__HttpGet/Post Error")
	$oHTTP.SetRequestHeader("Content-Type", "application/json; charset=ISO-8859-1,utf-8")

	Local $TGPushMsg = '{"text": "' & $TGMsg & '", "chat_id":' & $g_sTGChatID & ', "reply_markup": {"keyboard": [["' & _
			'\ud83d\udcf7 ' & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT", "SCREENSHOT") & '","' & _
			'\ud83d\udd28 ' & GetTranslatedFileIni("MBR Func_Notify", "BUILDER", "BUILDER") & '","' & _
			'\ud83d\udd30 ' & GetTranslatedFileIni("MBR Func_Notify", "SHIELD", "SHIELD") & '"],["' & _
			'\ud83d\udcc8 ' & GetTranslatedFileIni("MBR Func_Notify", "STATS", "STATS") & '","' & _
			'\ud83d\udcaa ' & GetTranslatedFileIni("MBR Func_Notify", "TROOPS", "TROOPS") & '","' & _
			'\u2753 ' & GetTranslatedFileIni("MBR Func_Notify", "HELP", "HELP") & '"],["' & _
			'\u25aa ' & GetTranslatedFileIni("MBR Func_Notify", "STOP", "STOP") & '","' & _
			'\u25b6 ' & GetTranslatedFileIni("MBR Func_Notify", "START", "START") & '","' & _
			'\ud83d\udd00 ' & GetTranslatedFileIni("MBR Func_Notify", "PAUSE", "PAUSE") & '","' & _
			'\u25b6 ' & GetTranslatedFileIni("MBR Func_Notify", "RESUME", "RESUME") & '","' & _
			'\ud83d\udd01 ' & GetTranslatedFileIni("MBR Func_Notify", "RESTART", "RESTART") & '"],["' & _
			'\ud83d\udccb ' & GetTranslatedFileIni("MBR Func_Notify", "LOG", "LOG") & '","' & _
			'\ud83c\udf04 ' & GetTranslatedFileIni("MBR Func_Notify", "LASTRAID", "LASTRAID") & '","' & _
			'\ud83d\udcc4 ' & GetTranslatedFileIni("MBR Func_Notify", "LASTRAIDTXT", "LASTRAIDTXT") & '"],["' & _
			'\u2705 ' & GetTranslatedFileIni("MBR Func_Notify", "ATTACK ON ", "ATTACK ON") & '","' & _
			'\u274C ' & GetTranslatedFileIni("MBR Func_Notify", "ATTACK OFF", "ATTACK OFF") & '"],["' & _
			'\ud83d\udca4 ' & GetTranslatedFileIni("MBR Func_Notify", "HIBERNATE", "HIBERNATE") & '","' & _
			'\u26a1 ' & GetTranslatedFileIni("MBR Func_Notify", "SHUTDOWN", "SHUTDOWN") & '","' & _
			'\ud83d\udd06 ' & GetTranslatedFileIni("MBR Func_Notify", "STANDBY", "STANDBY") & '"]],"one_time_keyboard": false,"resize_keyboard":true}}'
	$oHTTP.Send($TGPushMsg)
	If $oHTTP.Status <> $HTTP_STATUS_OK Then
		SetLog("Telegram status is: " & $oHTTP.Status, $COLOR_ERROR)
		Setlog(_StringBetween($oHTTP.ResponseText, '"description":"', '"}'))
		Return
	EndIf

	$g_iTGLastRemote = $g_sTGLast_UID

EndFunc   ;==>NotifyActivateKeyboardOnTelegram

; CONTROL TELEGRAM ON MAINLOOP()
Func NotifyRemoteControlProcBtnStart()
	Local $bWasSilent = SetDebugLogSilent()
	If $g_bNotifyTGEnable And $g_sNotifyTGToken <> "" Then
		$g_sTGLastMessage = NotifyGetLastMessageFromTelegram()
		Local $TGActionMSG = StringUpper(StringStripWS($g_sTGLastMessage, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)) ;upercase & remove space laset message
		If $g_bDebugSetlog Then SetDebugLog("Telegram | NotifyRemoteControlProcBtnStart $TGActionMSG : " & $TGActionMSG)
		If $g_bDebugSetlog Then SetDebugLog("Telegram | NotifyRemoteControlProcBtnStart $g_iTGLastRemote : " & $g_iTGLastRemote)
		If $g_bDebugSetlog Then SetDebugLog("Telegram | NotifyRemoteControlProcBtnStart $g_sTGLast_UID : " & $g_sTGLast_UID)
		If $g_iTGLastRemote <> $g_sTGLast_UID Then
			$g_iTGLastRemote = $g_sTGLast_UID

			Switch $TGActionMSG
				Case GetTranslatedFileIni("MBR Func_Notify", "START", "START"), '\u25b6 ' & GetTranslatedFileIni("MBR Func_Notify", "START", "START")
					btnStart()
					NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Start_Info_01", "Request to Start...") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Start_Info_02", "Your bot is now starting..."))
				Case Else
					NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Start_Info_03", "Start MyBot first."))
			EndSwitch
		EndIf
	EndIf
	SetDebugLogSilent($bWasSilent)
EndFunc   ;==>NotifyRemoteControlProcBtnStart

; CONTROL TELEGRAM : REMOTE CONTROL
Func NotifyRemoteControlProc()
	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyRemoteControlProc()")
	Static $bShutdown = False
	Static $bHibernate = False
	Static $bStandby = False

	If Not $g_bNotifyTGEnable Or Not $g_bNotifyRemoteEnable Then Return

	If $g_bNotifyTGEnable And $g_sNotifyTGToken <> "" And $g_bRunState Then
		$g_sTGLastMessage = NotifyGetLastMessageFromTelegram()
		Local $TGActionMSG = StringUpper(StringStripWS($g_sTGLastMessage, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)) ;upercase & remove space laset message
		If $g_bDebugSetlog Then SetDebugLog("Telegram | NotifyRemoteControlProc $TGActionMSG : " & $TGActionMSG)
		If $g_bDebugSetlog Then SetDebugLog("Telegram | NotifyRemoteControlProc $g_iTGLastRemote : " & $g_iTGLastRemote)
		If $g_bDebugSetlog Then SetDebugLog("Telegram | NotifyRemoteControlProc $g_sTGLast_UID : " & $g_sTGLast_UID)
		If ($TGActionMSG = "/START" Or $TGActionMSG = "KEYB") And $g_iTGLastRemote <> $g_sTGLast_UID Then
			$g_iTGLastRemote = $g_sTGLast_UID
			NotifyActivateKeyboardOnTelegram($g_sBotTitle & " | Notify " & $g_sNotifyVersion)
		Else
			If $g_iTGLastRemote <> $g_sTGLast_UID Then
				$g_iTGLastRemote = $g_sTGLast_UID
				Switch $TGActionMSG
					Case GetTranslatedFileIni("MBR Func_Notify", "HELP", "HELP"), '\U2753 ' & GetTranslatedFileIni("MBR Func_Notify", "HELP", "HELP")
						Local $txtHelp = "Telegram " & GetTranslatedFileIni("MBR Func_Notify", "HELP", "HELP") & " " & GetTranslatedFileIni("MBR Func_Notify", "Bot_Info_01", "- You can remotely control your bot sending COMMANDS from the following list:")
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "HELP", -1) & " " & GetTranslatedFileIni("MBR Func_Notify", "HELP_Info_01", "- send this help message")
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "RESTART", "RESTART") & " " & GetTranslatedFileIni("MBR Func_Notify", "RESTART_Info_01", "- restart the Emulator and bot named") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "START", "START") & " " & GetTranslatedFileIni("MBR Func_Notify", "START_Info_01", "- start the bot named") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "STOP", "STOP") & " " & GetTranslatedFileIni("MBR Func_Notify", "STOP_Info_01", "- stop the bot named") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "PAUSE", "PAUSE") & " " & GetTranslatedFileIni("MBR Func_Notify", "PAUSE_Info_01", "- pause the bot named") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "RESUME", "RESUME") & " " & GetTranslatedFileIni("MBR Func_Notify", "RESUME_Info_01", "- resume the bot named") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "STATS", "STATS") & " " & GetTranslatedFileIni("MBR Func_Notify", "STATS_Info_01", "- send Village Statistics of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "LOG", "LOG") & GetTranslatedFileIni("MBR Func_Notify", "LOG_Info_01", "- send the current log file of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "LASTRAID", "LASTRAID") & " " & GetTranslatedFileIni("MBR Func_Notify", "LASTRAID_Info_01", "- send the last raid loot screenshot of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "LASTRAIDTXT", "LASTRAIDTXT") & " " & GetTranslatedFileIni("MBR Func_Notify", "LASTRAIDTXT_Info_01", "- send the last raid loot values of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT", "SCREENSHOT") & " " & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT_Info_01", "- send a screenshot of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOTHD", "SCREENSHOTHD") & " " & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOTHD_Info_01", "- send a screenshot in high resolution of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "BUILDER", "BUILDER") & " " & GetTranslatedFileIni("MBR Func_Notify", "BUILDER_Info_01", "- send a screenshot of builder status of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= '\n' & GetTranslatedFileIni("MBR Func_Notify", "SHIELD", "SHIELD") & " " & GetTranslatedFileIni("MBR Func_Notify", "SHIELD_Info_01", "- send a screenshot of shield status of") & " <" & $g_sNotifyOrigin & ">"
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "RESETSTATS", "RESETSTATS") & " " & GetTranslatedFileIni("MBR Func_Notify", "RESETSTATS_Info_01", "- reset Village Statistics")
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "TROOPS", "TROOPS") & " " & GetTranslatedFileIni("MBR Func_Notify", "TROOPS_Info_01", "- send Troops & Spells Stats")
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "HALTATTACKON", "HALTATTACKON") & " " & GetTranslatedFileIni("MBR Func_Notify", "ATTACK OFF_Info_01", "- Turn On 'Halt Attack' in the 'Misc' Tab with the 'stay online' option")
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "HALTATTACKOFF", "HALTATTACKOFF") & " " & GetTranslatedFileIni("MBR Func_Notify", "ATTACK ON_Info_01", "- Turn Off 'Halt Attack' in the 'Misc' Tab")
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "HIBERNATE", "HIBERNATE") & " " & GetTranslatedFileIni("MBR Func_Notify", "HIBERNATE_Info_01", "- Hibernate host PC")
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "SHUTDOWN", "SHUTDOWN") & " " & GetTranslatedFileIni("MBR Func_Notify", "SHUTDOWN_Info_01", "- Shut down host PC")
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "STANDBY", "STANDBY") & " " & GetTranslatedFileIni("MBR Func_Notify", "STANDBY_Info_01", "- Standby host PC")
                        $txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "GETCHATS", "GETCHATS") & " " & GetTranslatedFileIni("MBR Func_Notify", "GETCHATS_Info_01", "- GETCHATS <INTERVAL|NOW|STOP> - to get the latest clan chat as an image")
						$txtHelp &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "SENDCHAT", "SENDCHAT") & " " & GetTranslatedFileIni("MBR Func_Notify", "STANDBY_Info_01", "- SENDCHAT <chat message> - to send a chat to your clan")
						
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-For-Help_Info_02", "Request for Help") & "\n" & $txtHelp)
						SetLog("Notify Telegram: Your request has been received from " & $g_sNotifyOrigin & ". Help has been sent", $COLOR_SUCCESS)
					Case GetTranslatedFileIni("MBR Func_Notify", "RESTART", "RESTART"), '\UD83D\UDD01 ' & GetTranslatedFileIni("MBR Func_Notify", "RESTART", "RESTART")
						SetLog("Notify Telegram: Your request has been received.", $COLOR_SUCCESS)
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_16", "Request to Restart") & "...\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_09", "Your bot and Emulator are now restarting..."))
						SaveConfig()
						RestartBot()
					Case GetTranslatedFileIni("MBR Func_Notify", "START", "START"), '\u25b6 ' & GetTranslatedFileIni("MBR Func_Notify", "START", "START")
						If $g_bRunState = True Then
							SetLog("Notify Telegram" & ": " & "Your bot is currently started, no action was taken", $COLOR_SUCCESS)
							NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Start_Info_01", "Request to Start...") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Start_Info_03", "Your bot is currently started, no action was taken"))
						EndIf
					Case GetTranslatedFileIni("MBR Func_Notify", "STOP", "STOP"), '\U25AA ' & GetTranslatedFileIni("MBR Func_Notify", "STOP", "STOP")
						SetLog("Notify Telegram: Your request has been received. Bot is now stopped", $COLOR_SUCCESS)
						If $g_bRunState = True Then
							NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_02", "Request to Stop...") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_03", "Your bot is now stopping..."))
							btnStop()
						Else
							NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_02", "Request to Stop...") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_04", "Your bot is currently stopped, no action was taken"))
						EndIf
					Case GetTranslatedFileIni("MBR Func_Notify", "PAUSE", "PAUSE"), '\UD83D\UDD00 ' & GetTranslatedFileIni("MBR Func_Notify", "PAUSE", "PAUSE")
						If $g_bBotPaused = False And $g_bRunState = True Then
							If ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = False And IsAttackPage() Then
								SetLog("Notify Telegram: Unable to pause during attack", $COLOR_ERROR)
								NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_17", "Request to Pause") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_08", "Unable to pause during attack, try again later."))
							ElseIf ( _ColorCheck(_GetPixelColor($NextBtn[0], $NextBtn[1], True), Hex($NextBtn[2], 6), $NextBtn[3])) = True And IsAttackPage() Then
								ReturnHome(False, False)
								$g_bIsSearchLimit = True
								$g_bIsClientSyncError = True
								$g_bRestart = True
								TogglePauseImpl("Push")
								Return True
							Else
								TogglePauseImpl("Push")
							EndIf
						Else
							SetLog("Notify Telegram: Your bot is currently paused, no action was taken", $COLOR_SUCCESS)
							NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_17", "Request to Pause") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_11", "Your bot is currently paused, no action was taken"))
						EndIf
					Case GetTranslatedFileIni("MBR Func_Notify", "RESUME", "RESUME"), '\U25B6 ' & GetTranslatedFileIni("MBR Func_Notify", "RESUME", "RESUME")
						If $g_bBotPaused = True And $g_bRunState = True Then
							TogglePauseImpl("Push")
						Else
							SetLog("Notify Telegram: Your bot is currently resumed, no action was taken", $COLOR_SUCCESS)
							NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_18", "Request to Resume") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_12", "Your bot is currently resumed, no action was taken"))
						EndIf
					Case GetTranslatedFileIni("MBR Func_Notify", "STATS", "STATS"), '\UD83D\UDCC8 ' & GetTranslatedFileIni("MBR Func_Notify", "STATS", "STATS")
						SetLog("Notify Telegram: Your request has been received. Statistics sent", $COLOR_SUCCESS)
						Local $GoldGainPerHour = "0 / h"
						Local $ElixirGainPerHour = "0 / h"
						Local $DarkGainPerHour = "0 / h"
						Local $TrophyGainPerHour = "0 / h"
						If $g_iFirstAttack = 2 Then
							$GoldGainPerHour = _NumberFormat(Round($g_iStatsTotalGain[$eLootGold] / (Int(__TimerDiff($g_hTimerSinceStarted) + $g_iTimePassed)) * 3600)) & "K / h"
							$ElixirGainPerHour = _NumberFormat(Round($g_iStatsTotalGain[$eLootElixir] / (Int(__TimerDiff($g_hTimerSinceStarted) + $g_iTimePassed)) * 3600)) & "K / h"
						EndIf
						If $g_iStatsStartedWith[$eLootDarkElixir] <> "" Then
							$DarkGainPerHour = _NumberFormat(Round($g_iStatsTotalGain[$eLootDarkElixir] / (Int(__TimerDiff($g_hTimerSinceStarted) + $g_iTimePassed)) * 3600 * 1000)) & " / h"
						EndIf
						$TrophyGainPerHour = _NumberFormat(Round($g_iStatsTotalGain[$eLootTrophy] / (Int(__TimerDiff($g_hTimerSinceStarted) + $g_iTimePassed)) * 3600 * 1000)) & " / h"
						Local $txtStats = " | " & GetTranslatedFileIni("MBR Func_Notify", "Stats_Info_02", "Stats Village Report") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Stats_Info_05", "At Start") & "\n[" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_iStatsStartedWith[$eLootGold]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: "
						$txtStats &= _NumberFormat($g_iStatsStartedWith[$eLootElixir]) & " [D]: " & _NumberFormat($g_iStatsStartedWith[$eLootDarkElixir]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & $g_iStatsStartedWith[$eLootTrophy]
						$txtStats &= "\n\n" & GetTranslatedFileIni("MBR Func_Notify", "Stats-Now_Info_01", "Now (Current Resources)") & "\n[" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir])
						$txtStats &= " [D]: " & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & $g_aiCurrentLoot[$eLootTrophy] & " [GEM]: " & $g_iGemAmount
						$txtStats &= "\n\n" & GetTranslatedFileIni("MBR Func_Notify", "Stats_Info_04", "Gain per Hour") & ":\n[" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & $GoldGainPerHour & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & $ElixirGainPerHour
						$txtStats &= "\n[D]: " & $DarkGainPerHour & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & $TrophyGainPerHour
						$txtStats &= "\n\n" & GetTranslatedFileIni("MBR Func_Notify", "Free-Builders_Info_01", "No. of Free Builders") & ": " & $g_iFreeBuilderCount & "\n[" & GetTranslatedFileIni("MBR Func_Notify", "Wall-Up_Info_01", "No. of Wall Up") & "]: [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: "
						$txtStats &= $g_iNbrOfWallsUppedGold & "/ [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & $g_iNbrOfWallsUppedElixir & "\n\n" & GetTranslatedFileIni("MBR Func_Notify", "Attack_Info_01", "Attacked") & ": "
						$txtStats &= $g_aiAttackedCount & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Skip_Info_02", "Skipped") & ": " & $g_iSkippedVillageCount
						$txtStats &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "LOG_Info_07", "Run Time") & ": " & GUICtrlRead($g_hLblResultRuntime)
						$txtStats &= "\n\n" & "Clan Games:"
						$txtStats &= "\n" & "[T]: " & GUICtrlRead($g_hLblRemainTime) & " [S]: " & GUICtrlRead($g_hLblYourScore)
						$txtStats &= "\n" & " "
						NotifyPushToTelegram($g_sNotifyOrigin & $txtStats)
					Case GetTranslatedFileIni("MBR Func_Notify", "LOG", "LOG"), '\UD83D\UDCCB ' & GetTranslatedFileIni("MBR Func_Notify", "LOG", "LOG")
						SetLog("Notify Telegram: Your request has been received from " & $g_sNotifyOrigin & ". Log is now sent", $COLOR_SUCCESS)
						NotifyPushFileToTelegram($g_sLogFileName, "Logs", "text\/plain; charset=utf-8", $g_sNotifyOrigin & " | Current Log " & "\n")
					Case GetTranslatedFileIni("MBR Func_Notify", "LASTRAID", "LASTRAID"), '\UD83C\UDF04 ' & GetTranslatedFileIni("MBR Func_Notify", "LASTRAID", "LASTRAID")
						If $g_sLootFileName <> "" Then
							NotifyPushFileToTelegram($g_sLootFileName, "Loots", "image/jpeg", $g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Last-Raid_Info_05", "Last Raid") & "\n" & $g_sLootFileName)
							SetLog("Notify Telegram: Push Last Raid Snapshot...", $COLOR_SUCCESS)
						Else
							NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Last-Raid_Info_03", "There is no last raid screenshot."))
							SetLog("There is no last raid screenshot.")
							SetLog("Notify Telegram: Your request has been received. Last Raid txt sent", $COLOR_SUCCESS)
							NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Last-Raid_Info_04", "Last Raid txt") & "\n" & "[" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootGold]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootElixir]) & " [D]: " & _NumberFormat($g_iStatsLastAttack[$eLootDarkElixir]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & $g_iStatsLastAttack[$eLootTrophy])
						EndIf
					Case GetTranslatedFileIni("MBR Func_Notify", "LASTRAIDTXT", "LASTRAIDTXT"), '\UD83D\UDCC4 ' & GetTranslatedFileIni("MBR Func_Notify", "LASTRAIDTXT", "LASTRAIDTXT")
						SetLog("Notify Telegram: Your request has been received. Last Raid txt sent", $COLOR_SUCCESS)
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Last-Raid_Info_04", "Last Raid txt") & "\n" & "[" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootGold]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootElixir]) & " [D]: " & _NumberFormat($g_iStatsLastAttack[$eLootDarkElixir]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & $g_iStatsLastAttack[$eLootTrophy])
					Case GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT", "SCREENSHOT")
						SetLog("Notify Telegram: ScreenShot request received", $COLOR_SUCCESS)
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT_Info_03", "Chief, your request for Screenshot will be processed ASAP"))
						$g_bTGRequestScreenshot = True
					Case GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOTHD", "SCREENSHOTHD"), '\UD83D\UDCF7 ' & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT", "SCREENSHOT")
						SetLog("Notify Telegram: ScreenShot HD request received", $COLOR_SUCCESS)
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT_Info_03", "Chief, your request for Screenshot will be processed ASAP"))
						$g_bTGRequestScreenshot = True
						$g_bTGRequestScreenshotHD = True
						$g_bNotifyForced = False
					Case GetTranslatedFileIni("MBR Func_Notify", "BUILDER", "BUILDER"), '\UD83D\UDD28 ' & GetTranslatedFileIni("MBR Func_Notify", "BUILDER", "BUILDER")
						SetLog("Notify Telegram: Builder Status request received", $COLOR_SUCCESS)
						$g_bTGRequestBuilderInfo = True
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "BUILDER_Info_04", "Chief, your request for Builder Info will be processed ASAP"))
					Case GetTranslatedFileIni("MBR Func_Notify", "SHIELD", "SHIELD"), '\UD83D\UDD30 ' & GetTranslatedFileIni("MBR Func_Notify", "SHIELD", "SHIELD")
						SetLog("Notify Telegram: Shield Status request received", $COLOR_SUCCESS)
						$g_bTGRequestShieldInfo = True
						$g_bNotifyForced = False
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "SHIELD_Info_02", "Chief, your request for Shield Info will be processed ASAP"))
					Case GetTranslatedFileIni("MBR Func_Notify", "RESETSTATS", "RESETSTATS")
						btnResetStats()
						SetLog("Notify Telegram: Your request has been received. Statistics resetted", $COLOR_SUCCESS)
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "RESETSTATS_Info_02", "Statistics resetted."))
					Case GetTranslatedFileIni("MBR Func_Notify", "TROOPS", "TROOPS"), '\UD83D\UDCAA ' & GetTranslatedFileIni("MBR Func_Notify", "TROOPS", "TROOPS")
						SetLog("Notify Telegram: Your request has been received. Sending Troop/Spell Stats...", $COLOR_SUCCESS)
						Local $txtTroopStats = " | " & GetTranslatedFileIni("MBR Func_Notify", "Train_Info_01", "[Train Status]:\n")
						For $i = 0 To UBound($g_aiArmyCompTroops) - 1
							If $g_aiArmyCompTroops[$i] > 0 Then
								$txtTroopStats &= $g_asTroopShortNames[$i] & ": " & $g_aiCurrentTroops[$i] & " of " & $g_aiArmyCompTroops[$i] & "\n"
							EndIf
						Next
						For $i = 0 To UBound($g_aiArmyCompSpells) - 1
							If $g_aiArmyCompSpells[$i] > 0 Then
								$txtTroopStats &= $g_asSpellShortNames[$i] & ": " & $g_aiCurrentSpells[$i] & " of " & $g_aiArmyCompSpells[$i] & "\n"
							EndIf
						Next
						For $i = 0 To UBound($g_aiArmyCompSiegeMachine) - 1
							If $g_aiArmyCompSiegeMachine[$i] > 0 Then
								$txtTroopStats &= $g_asSiegeMachineShortNames[$i] & ": " & $g_aiArmyCompSiegeMachine[$i] & " of " & $g_aiArmyCompSiegeMachine[$i] & "\n"
							EndIf
						Next
						$txtTroopStats &= "\n" & GetTranslatedFileIni("MBR Func_Notify", "Train_Info_05", "Current Capacities") & ":"
						$txtTroopStats &= "\n" & " " & GetTranslatedFileIni("MBR Func_Notify", "Train_Info_06", "- Army Camp") & ": " & $g_CurrentCampUtilization & "/" & $g_iTotalCampSpace
						$txtTroopStats &= "\n" & " " & GetTranslatedFileIni("MBR Func_Notify", "Train_Info_04", "- Spells") & ": " & $g_iCurrentSpells & "/" & $g_iTotalTrainSpaceSpell

						NotifyPushToTelegram($g_sNotifyOrigin & $txtTroopStats)
					Case GetTranslatedFileIni("MBR Func_Notify", "HALTATTACKON", "HALTATTACKON"), '\U274C ' & StringUpper(GetTranslatedFileIni("MBR Func_Notify", "ATTACK OFF", "ATTACK OFF"))
						GUICtrlSetState($g_hChkBotStop, $GUI_CHECKED)
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "ATTACK ON_Info_02", "Set Halt Attack ON."))
						btnStop()
						$g_bChkBotStop = True ; set halt attack variable
						$g_iCmbBotCond = 18 ; set stay online
						btnStart()
					Case GetTranslatedFileIni("MBR Func_Notify", "HALTATTACKOFF", "HALTATTACKOFF"), '\U2705 ' & StringUpper(GetTranslatedFileIni("MBR Func_Notify", "ATTACK ON_Info_01", "ATTACK ON"))
						GUICtrlSetState($g_hChkBotStop, $GUI_UNCHECKED)
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "ATTACK OFF_Info_02", "Set Halt Attack OFF."))
						btnStop()
						btnStart()
					Case GetTranslatedFileIni("MBR Func_Notify", "HIBERNATE", "HIBERNATE"), '\UD83D\UDCA4 ' & GetTranslatedFileIni("MBR Func_Notify", "HIBERNATE", "HIBERNATE")
						SetLog("Notify Telegram: Your request has been received from " & $g_sNotifyOrigin & ". Hibernate PC", $COLOR_SUCCESS)
						$bHibernate = True
						NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "CONFIRM_Info_01", "Are you sure?, Please send") & " CONFIRM" & "\n" & _
								GetTranslatedFileIni("MBR Func_Notify", "CONFIRM_Info_02", "If isn't to continue send") & " CANCEL")
					Case GetTranslatedFileIni("MBR Func_Notify", "SHUTDOWN", "SHUTDOWN"), '\U26A1 ' & StringUpper(GetTranslatedFileIni("MBR Func_Notify", "SHUTDOWN", "SHUTDOWN"))
						SetLog("Notify Telegram: Your request has been received from " & $g_sNotifyOrigin & ". Shutdown PC", $COLOR_SUCCESS)
						$bShutdown = True
						NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "CONFIRM_Info_01", "Are you sure?, Please send") & " CONFIRM" & "\n" & _
								GetTranslatedFileIni("MBR Func_Notify", "CONFIRM_Info_02", "If isn't to continue send") & " CANCEL")
					Case GetTranslatedFileIni("MBR Func_Notify", "STANDBY", "STANDBY"), '\UD83d\UDD06 ' & GetTranslatedFileIni("MBR Func_Notify", "STANDBY", "STANDBY")
						SetLog("Notify Telegram: Your request has been received from " & $g_sNotifyOrigin & ". Standby PC", $COLOR_SUCCESS)
						NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "CONFIRM_Info_01", "Are you sure?, Please send") & " CONFIRM" & "\n" & _
								GetTranslatedFileIni("MBR Func_Notify", "CONFIRM_Info_02", "If isn't to continue send") & " CANCEL")
						$bStandby = True
					Case "CONFIRM"
						If $bShutdown Then
							NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "SHUTDOWN_Info_02", "PC Shutdown sequence initiated"))
							$bShutdown = False
							Shutdown(5)
						ElseIf $bHibernate Then
							NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "HIBERNATE_Info_02", "PC Hibernate sequence initiated"))
							$bHibernate = False
							Shutdown(64)
						ElseIf $bStandby Then
							NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "STANDBY_Info_02", "PC Standby sequence initiated"))
							$bStandby = False
							Shutdown(32)
						EndIf
					Case "CANCEL"
						NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "CANCEL_Info_01", "Canceled the last sequence"))
						$bShutdown = False
						$bHibernate = False
						$bStandby = False
					Case Else
                        NotifyPushToTelegram(GetTranslatedFileIni("MBR Func_Notify", "ELSE_Info_01", "Sorry Chief!, ") & $TGActionMSG & _
											 GetTranslatedFileIni("MBR Func_Notify", "ELSE_Info_02", " is not a valid command."))
						If StringInStr($TGActionMSG, "SENDCHAT") Then
						local $FoundChatMessage = 1
						local $chatMessage = StringRight($TGActionMSG, StringLen($TGActionMSG) - StringLen("SENDCHAT "))
							$chatMessage = StringLower($chatMessage)
							ChatbotPushbulletQueueChat($chatMessage)
							NotifyPushToTelegram($g_sNotifyOrigin & " | " &  "Chat queued, will send on next idle")
						ElseIf StringInStr($TGActionMSG, "GETCHATS") Then
							$FoundChatMessage = 1
							$Interval = StringRight($TGActionMSG, StringLen($TGActionMSG) - StringLen("GETCHATS ")
							If $Interval = "STOP" Then
								ChatbotPushbulletStopChatRead()
								NotifyPushToTelegram($g_sNotifyOrigin & " | " &  "Stopping interval sending")
							ElseIf $Interval = "NOW" Then
								ChatbotPushbulletQueueChatRead()
								NotifyPushToTelegram($g_sNotifyOrigin & " | " &  "Command queued, will send clan chat image on next idle")
							Else
								If Number($Interval) <> 0 Then
									ChatbotPushbulletIntervalChatRead(Number($Interval))
									NotifyPushToTelegram($g_sNotifyOrigint & " | " &  "Command queued, will send clan chat image on interval")
								Else
									SetLog("Telegram: received command syntax wrong, command ignored.", $COLOR_RED)
									NotifyPushToTelegram($g_sNotifyOrigin & " | " &  "Command not recognized" & "\n" &  "Please push BOT HELP to obtain a complete command list.")
								EndIf
							EndIf
						EndIf
                    ;=========================>
				EndSwitch
			EndIf
		EndIf
	EndIf
	;Telegram ---------------------------------------------------------------------------------

EndFunc   ;==>NotifyRemoteControlProc

; CONTROL TELEGRAM : UI ASKED PUSHES
Func NotifyPushMessageToBoth($Message, $Source = "")

	If Not $g_bNotifyTGEnable Then Return

	If $g_bDebugSetlog Then SetDebugLog("Notify | NotifyPushMessageToBoth($Message, $Source = ""): " & $Message & "," & $Source)
	Static $iReportIdleBuilder = 0

	If Not IsPlanUseTelegram($Message) Then Return

	$g_bNotifyForced = False

	Local $hBitmap_Scaled
	Switch $Message
		Case "Restarted"
			If $g_bNotifyRemoteEnable Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_10", "Bot restarted"))
		Case "OutOfSync"
			If $g_bNotifyAlertOutOfSync Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "LOG_Info_05", "Restarted after Out of Sync Error") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Stats_Info_06", "Attacking now") & "...")
		Case "LastRaid"
			If $g_bNotifyAlerLastRaidTXT Then
				NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Last-Raid_Info_02", "Last Raid txt") & "\n" & "[" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootGold]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootElixir]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-DE_Info_01", "DE") & "]: " & _NumberFormat($g_iStatsLastAttack[$eLootDarkElixir]) & " [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & $g_iStatsLastAttack[$eLootTrophy])
				If _Sleep($DELAYPUSHMSG1) Then Return
				SetLog("Notify Telegram: Last Raid Text has been sent!", $COLOR_SUCCESS)
			EndIf
			If $g_bNotifyAlerLastRaidIMG Then

				;create a temporary file to send with pushbullet...
				Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
				Local $Time = @HOUR & "." & @MIN
				If $g_bScreenshotLootInfo Then
					$g_sAttackFile = $g_sLootFileName
				Else
					_CaptureRegion()
					$g_sAttackFile = "Notify_" & $Date & "__" & $Time & ".jpg" ; separator __ is need  to not have conflict with saving other files if $TakeSS = 1 and $chkScreenshotLootInfo = 0
					$hBitmap_Scaled = _GDIPlus_ImageResize($g_hBitmap, _GDIPlus_ImageGetWidth($g_hBitmap) / 2, _GDIPlus_ImageGetHeight($g_hBitmap) / 2) ;resize image
					_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $g_sProfileLootsPath & $g_sAttackFile)
					_GDIPlus_ImageDispose($hBitmap_Scaled)
				EndIf
				;push the file
				SetLog("Notify Telegram: Last Raid screenshot has been sent!", $COLOR_SUCCESS)
				NotifyPushFileToTelegram($g_sAttackFile, "Loots", "image/jpeg", $g_sNotifyOrigin & " | " & "Last Raid" & "\n" & $g_sAttackFile)
				;wait a second and then delete the file
				If _Sleep($DELAYPUSHMSG1) Then Return
				Local $iDelete = FileDelete($g_sProfileLootsPath & $g_sAttackFile)
				If Not $iDelete Then
					SetLog("Notify Telegram: An error occurred deleting temporary screenshot file.", $COLOR_ERROR)
				EndIf
			EndIf
		Case "FoundWalls"
			If $g_bNotifyAlertUpgradeWalls Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Wall-Up_Info_02", "Found Wall level") & " " & $g_iCmbUpgradeWallsLevel + 4 & "\n" & " " & GetTranslatedFileIni("MBR Func_Notify", "Wall-Up_Info_04", "Wall segment has been located") & "...\n" & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_01", "Upgrading") & "...")
		Case "SkipWalls"
			If $g_bNotifyAlertUpgradeWalls Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Wall-Up_Info_03", "Cannot find Wall level") & $g_iCmbUpgradeWallsLevel + 4 & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_02", "Skip upgrade") & "...")
		Case "AnotherDevice3600"
			If $g_bNotifyAlertAnotherDevice Then NotifyPushToTelegram($g_sNotifyOrigin & " | 1. " & GetTranslatedFileIni("MBR Func_Notify", "Another-Device_Info_01", "Another Device has connected") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Another-Device_Info_02", "Another Device has connected, waiting") & " " & Floor(Floor($g_iAnotherDeviceWaitTime / 60) / 60) & " " & GetTranslatedFileIni("MBR Global GUI Design", "Hours", -1) & " " & Floor(Mod(Floor($g_iAnotherDeviceWaitTime / 60), 60)) & " " & GetTranslatedFileIni("MBR Global GUI Design", "Min", -1) & " " & Floor(Mod($g_iAnotherDeviceWaitTime, 60)) & " " & GetTranslatedFileIni("MBR Global GUI Design", "seconds", -1))
		Case "AnotherDevice60"
			If $g_bNotifyAlertAnotherDevice Then NotifyPushToTelegram($g_sNotifyOrigin & " | 2. " & GetTranslatedFileIni("MBR Func_Notify", "Another-Device_Info_01", "Another Device has connected") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Another-Device_Info_02", "Another Device has connected, waiting") & " " & Floor(Mod(Floor($g_iAnotherDeviceWaitTime / 60), 60)) & " " & GetTranslatedFileIni("MBR Global GUI Design", "Min", -1) & " " & Floor(Mod($g_iAnotherDeviceWaitTime, 60)) & " " & GetTranslatedFileIni("MBR Global GUI Design", "seconds", -1))
		Case "AnotherDevice"
			If $g_bNotifyAlertAnotherDevice Then NotifyPushToTelegram($g_sNotifyOrigin & " | 3. " & GetTranslatedFileIni("MBR Func_Notify", "Another-Device_Info_01", "Another Device has connected") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Another-Device_Info_02", "Another Device has connected, waiting") & " " & Floor(Mod($g_iAnotherDeviceWaitTime, 60)) & " " & GetTranslatedFileIni("MBR Global GUI Design", "seconds", -1))
		Case "TakeBreak"
			If $g_bNotifyAlertTakeBreak Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Need-Rest_Info_01", "Chief, we need some rest!") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Take-Break_Info_01", "Village must take a break.."))
		Case "Update"
			If $g_bNotifyAlertBOTUpdate Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "New-Version_Info_01", "Chief, there is a new version of the bot available"))
		Case "BuilderIdle"
			If $g_bNotifyAlertBulderIdle Then
				Local $iAvailBldr = $g_iFreeBuilderCount - ($g_bUpgradeWallSaveBuilder ? 1 : 0)
				If $iAvailBldr > 0 Then
					If $iReportIdleBuilder <> $iAvailBldr Then
						NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Stats_Info_03", "You have") & " " & $iAvailBldr & " " & GetTranslatedFileIni("MBR Func_Notify", "BUILDER_Info_03", "builder(s) idle."))
						SetLog("You have " & $iAvailBldr & " builder(s) idle.", $COLOR_SUCCESS)
						$iReportIdleBuilder = $iAvailBldr
					EndIf
				Else
					$iReportIdleBuilder = 0
				EndIf
			EndIf
		Case "CocError"
			If $g_bNotifyAlertOutOfSync Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "LOG_Info_04", "CoC Has Stopped Error") & ".....")
		Case "Pause"
			If $g_bNotifyRemoteEnable And $Source = "Push" Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_17", "Request to Pause") & "..." & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_13", "Your request has been received. Bot is now paused"))
		Case "Resume"
			If $g_bNotifyRemoteEnable And $Source = "Push" Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_18", "Request to Resume") & "..." & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Request-Stop_Info_14", "Your request has been received. Bot is now resumed"))
		Case "OoSResources"
			If $g_bNotifyAlertOutOfSync Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "LOG_Info_06", "Disconnected after") & " " & StringFormat("%3s", $g_iSearchCount) & " " & GetTranslatedFileIni("MBR Func_Notify", "Skip_Info_01", "skip(s)") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Attack_Info_02", "Cannot locate Next button, Restarting Bot") & "...")
		Case "MatchFound"
			If $g_bNotifyAlertMatchFound Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & $g_asModeText[$g_iMatchMode] & " " & GetTranslatedFileIni("MBR Func_Notify", "Match-Found_Info_01", "Match Found! after") & " " & StringFormat("%3s", $g_iSearchCount) & " " & GetTranslatedFileIni("MBR Func_Notify", "Skip_Info_01", "skip(s)") & "\n" & "[" & GetTranslatedFileIni("MBR Func_Notify", "Stats-G_Info_01", "G") & "]: " & _NumberFormat($g_iSearchGold) & "; [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-E_Info_01", "E") & "]: " & _NumberFormat($g_iSearchElixir) & "; [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-DE_Info_01", "DE") & "]: " & _NumberFormat($g_iSearchDark) & "; [" & GetTranslatedFileIni("MBR Func_Notify", "Stats-T_Info_01", "T") & "]: " & $g_iSearchTrophy)
		Case "UpgradeWithGold"
			If $g_bNotifyAlertUpgradeWalls Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_07", "Upgrade completed by using GOLD") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_03", "Complete by using GOLD") & "...")
		Case "UpgradeWithElixir"
			If $g_bNotifyAlertUpgradeWalls Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_08", "Upgrade completed by using ELIXIR") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_04", "Complete by using ELIXIR") & "...")
		Case "NoUpgradeWallButton"
			If $g_bNotifyAlertUpgradeWalls Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_05", "No Upgrade Gold Button") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_10", "Cannot find gold upgrade button") & "...")
		Case "NoUpgradeElixirButton"
			If $g_bNotifyAlertUpgradeWalls Then NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_09", "No Upgrade Elixir Button") & "\n" & GetTranslatedFileIni("MBR Func_Notify", "Upgrading_Info_06", "Cannot find elixir upgrade button") & "...")
		Case "RequestScreenshot"
			Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
			Local $Time = @HOUR & "." & @MIN
			_CaptureRegion()
			If $g_bTGRequestScreenshotHD Then
				$hBitmap_Scaled = $g_hBitmap
			Else
				$hBitmap_Scaled = _GDIPlus_ImageResize($g_hBitmap, _GDIPlus_ImageGetWidth($g_hBitmap) / 2, _GDIPlus_ImageGetHeight($g_hBitmap) / 2) ;resize image
			EndIf
			Local $Screnshotfilename = "Screenshot_" & $Date & "_" & $Time & ".jpg"
			_GDIPlus_ImageSaveToFile($hBitmap_Scaled, $g_sProfileTempPath & $Screnshotfilename)
			_GDIPlus_ImageDispose($hBitmap_Scaled)
			If $g_bTGRequestScreenshot Then
				If $g_bTGRequestScreenshot Then
					NotifyPushFileToTelegram($Screnshotfilename, "Temp", "image/jpeg", $g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "SCREENSHOT_Info_04", "Screenshot of your village") & " " & "\n" & $Screnshotfilename)
					SetLog("Notify Telegram: Screenshot sent!", $COLOR_SUCCESS)
				EndIf
			EndIf
			$g_bTGRequestScreenshot = False
			$g_bTGRequestScreenshotHD = False
			;wait a second and then delete the file
			If _Sleep($DELAYPUSHMSG2) Then Return
			Local $iDelete = FileDelete($g_sProfileTempPath & $Screnshotfilename)
			If Not $iDelete Then
				SetLog("Notify Telegram: An error occurred deleting temporary screenshot file.", $COLOR_ERROR)
			EndIf
		Case "BuilderInfo"
			ClickP($aAway, 1, 0, "#0112") ;Click Away to close the upgrade window
			; open the builders menu
			Click(295, 30)
			_Sleep(750)
			Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
			Local $Time = @HOUR & "." & @MIN
			_CaptureRegion(224, 74, 446, 240)
			Local $Screnshotfilename = "Screenshot_" & $Date & "_" & $Time & ".jpg"
			_GDIPlus_ImageSaveToFile($g_hBitmap, $g_sProfileTempPath & $Screnshotfilename)
			If $g_bTGRequestBuilderInfo Then
				If $g_bTGRequestBuilderInfo Then
					NotifyPushFileToTelegram($Screnshotfilename, "Temp", "image/jpeg", $g_sNotifyOrigin & " | " & "Builder Information" & "\n" & $Screnshotfilename)
					SetLog("Notify Telegram: Builder Information sent!", $COLOR_GREEN)
				EndIf
			EndIf
			$g_bTGRequestBuilderInfo = False
			;wait a second and then delete the file
			If _Sleep($DELAYPUSHMSG2) Then Return
			Local $iDelete = FileDelete($g_sProfileTempPath & $Screnshotfilename)
			If Not $iDelete Then
				SetLog("Notify Telegram: An error occurred deleting temporary screenshot file.", $COLOR_ERROR)
			EndIf
			ClickP($aAway, 1, 0, "#0112") ;Click Away to close the upgrade window
		Case "ShieldInfo"
			ClickP($aAway, 1, 0, "#0112") ;Click Away to close the upgrade window
			Click(435, 8)
			_Sleep(500)
			Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
			Local $Time = @HOUR & "." & @MIN
			_CaptureRegion(200, 165, 660, 568)
			Local $Screnshotfilename = "Screenshot_" & $Date & "_" & $Time & ".jpg"
			_GDIPlus_ImageSaveToFile($g_hBitmap, $g_sProfileTempPath & $Screnshotfilename)
			If $g_bTGRequestShieldInfo Then
				If $g_bTGRequestShieldInfo Then
					NotifyPushFileToTelegram($Screnshotfilename, "Temp", "image/jpeg", $g_sNotifyOrigin & " | " & "Shield Information" & "\n" & $Screnshotfilename)
					SetLog("Notify Telegram: Shield Information sent!", $COLOR_SUCCESS)
				EndIf
			EndIf
			$g_bTGRequestShieldInfo = False
			;wait a second and then delete the file
			If _Sleep($DELAYPUSHMSG2) Then Return
			Local $iDelete = FileDelete($g_sProfileTempPath & $Screnshotfilename)
			If Not $iDelete Then
				SetLog("Notify Telegram: An error occurred deleting temporary screenshot file.", $COLOR_ERROR)
			EndIf
			ClickP($aAway, 1, 0, "#0112") ;Click Away to close the upgrade window
		Case "CampFull"
			If $g_bNotifyAlertCampFull Then
				NotifyPushToTelegram($g_sNotifyOrigin & " | " & GetTranslatedFileIni("MBR Func_Notify", "Camps-Full_Info_01", "Your Army Camps are now Full"))
				SetLog("Notify Telegram: Your Army Camps are now Full", $COLOR_SUCCESS)
			EndIf
		Case "Misc"
			NotifyPushToTelegram($Message)
	EndSwitch
EndFunc   ;==>NotifyPushMessageToBoth

; CHECK IF WAS PLANNED TO USE TELEGRAM
Func IsPlanUseTelegram($Message)
	If Not $g_bNotifyForced And $Message <> "DeleteAllPBMessages" Then
		If $g_bNotifyScheduleWeekDaysEnable Then
			If $g_abNotifyScheduleWeekDays[@WDAY - 1] Then
				If $g_bNotifyScheduleHoursEnable Then
					Local $hour = StringSplit(_NowTime(4), ":", $STR_NOCOUNT)
					If Not $g_abNotifyScheduleHours[$hour[0]] Then
						SetLog("Notify not planned for this hour! Notification skipped", $COLOR_WARNING)
						SetLog($Message, $COLOR_ORANGE)
						Return False ; exit func if no planned
					EndIf
				EndIf
			Else
				Return False ; exit func if not planned
			EndIf
		Else
			If $g_bNotifyScheduleHoursEnable Then
				Local $hour = StringSplit(_NowTime(4), ":", $STR_NOCOUNT)
				If Not $g_abNotifyScheduleHours[$hour[0]] Then
					SetLog("Notify not planned for this hour! Notification skipped", $COLOR_WARNING)
					SetLog($Message, $COLOR_ORANGE)
					Return False ; exit func if no planned
				EndIf
			EndIf
		EndIf
	EndIf
	Return True
EndFunc   ;==>IsPlanUseTelegram



; ::: EXTRA TOOLS :::
; Checking the connection of the card to the Internet
Func _IsInternet()
	Local $Ret = DllCall('wininet.dll', 'int', 'InternetGetConnectedState', 'dword*', 0x20, 'dword', 0)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Local $Error = _WinAPI_GetLastError()
	Return SetError((Not ($Error = 0)), $Error, $Ret[0])
EndFunc   ;==>_IsInternet

; User's COM error function. Will be called if COM error occurs
Func __ErrFunc($oError)
	SetLog("COM Error intercepted !" & @CRLF & _
			"Scriptline is: " & $oError.scriptline & @CRLF & _
			"Number is: " & Hex($oError.number, 8) & @CRLF & _
			"Returncode is: " & Hex($oError.retcode, 8) & @CRLF & _
			"WinDescription is: " & $oError.windescription & @CRLF & _
			"Description is: " & $oError.description, $COLOR_RED)
EndFunc   ;==>__ErrFunc

Func __ObjEventIni()
	$g_oCOMErrorHandler = ObjEvent("AutoIt.Error", "__ErrFunc")
EndFunc   ;==>__ObjEventIni

Func __ObjEventEnds()
	$g_oCOMErrorHandler = 0
EndFunc   ;==>__ObjEventEnds

