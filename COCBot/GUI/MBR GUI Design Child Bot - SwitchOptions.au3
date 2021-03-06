; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design Bot - SwitchOptions
; Description ...: This file creates the "Switch Accounts" & "Farming Schedule" tab under the "Profiles" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: NguyenAnhHD (03-2018)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_SWITCH_OPTIONS = 0, _
	   $g_hGUI_SWITCH_OPTIONS_TAB = 0, $g_hGUI_SWITCH_OPTIONS_TAB_ITEM1 = 0, $g_hGUI_SWITCH_OPTIONS_TAB_ITEM2 = 0

Global $g_hGUI_LOG_SA = 0

Global $g_hChkSwitchAcc = 0, $g_hCmbSwitchAcc = 0, $g_hChkSharedPrefs = 0, $g_hCmbTotalAccount = 0, $g_hChkSmartSwitch = 0, $g_hCmbTrainTimeToSkip = 0, $g_hChkDonateLikeCrazy = 0, _
	   $g_ahChkAccount[8], $g_ahCmbProfile[8], $g_ahChkDonate[8], _
	   $g_hRadSwitchGooglePlay = 0, $g_hRadSwitchSuperCellID = 0, $g_hRadSwitchSharedPrefs = 0

Global $g_ahChkSetFarm[8], _
	   $g_ahCmbAction1[8], $g_ahCmbCriteria1[8], $g_ahTxtResource1[8], $g_ahCmbTime1[8], _
	   $g_ahCmbAction2[8], $g_ahCmbCriteria2[8], $g_ahTxtResource2[8], $g_ahCmbTime2[8]

Global $g_hTxtSALog = 0

Func CreateSwitchOptions()
	; GUI Tab for Switch Accounts & Farm Schedule
	$g_hGUI_LOG_SA = _GUICreate("", 205, 200, 235, 150, BitOR($WS_CHILD, 0), -1, $g_hGUI_SWITCH_OPTIONS)

	GUISwitch($g_hGUI_SWITCH_OPTIONS)
	$g_hGUI_SWITCH_OPTIONS_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab2 + 2, $g_iSizeHGrpTab4 + 5, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
	$g_hGUI_SWITCH_OPTIONS_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_20_STab_01", "Switch Accounts"))
		CreateSwitchAccount()
	$g_hGUI_SWITCH_OPTIONS_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_21_STab_01", "Farming Schedule"))
		CreateFarmSchedule()

	; This dummy is used in btnStart and btnStop to disable/enable all labels, text, buttons etc. on all tabs.
	$g_hLastControlToHide = GUICtrlCreateDummy()
	ReDim $g_aiControlPrevState[$g_hLastControlToHide + 1]
	CreateBotSwitchAccLog() ; Set SwitchAcc Log
	GUICtrlCreateTabItem("")

EndFunc   ;==>CreateBotProfileSchedule

#Region Switch Accounts tab
Func CreateSwitchAccount()

	Local $x = 15, $y = 30
	$x -= 8
		$g_hCmbSwitchAcc = GUICtrlCreateCombo("", $x, $y, 175, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		Local $s = "No Switch Accounts Group"
		For $i = 1 To UBound($g_ahChkAccount)
			$s &= "|Switch Accounts Group " & $i
		Next
		GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "CmbSwitchAcc", $s), "No Switch Accounts Group")
		GUICtrlSetOnEvent(-1, "cmbSwitchAcc")

	$y += 25
		$g_hChkSwitchAcc = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ChkSwitchAcc", "Enable Switch Accounts"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkSwitchAcc")
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ChkSwitchAcc_Info_01", "Enable or disable current selected Switch Accounts Group"))

		$g_hCmbTotalAccount = GUICtrlCreateCombo("", $x + 345, $y - 1, 77, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		GUICtrlSetData(-1, "2 accounts|3 accounts|4 accounts|5 accounts|6 accounts|7 accounts|8 accounts", "2 accounts")
		GUICtrlSetOnEvent(-1, "cmbTotalAcc")
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "CmbTotalAccount", "Total CoC Accounts") & ": ", $x + 220, $y + 4, -1, -1)

		$g_hRadSwitchGooglePlay = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchGooglePlay", "Google Play"), $x + 185, $y - 38, -1, -1)	;AltuFaltu-m
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchGooglePlay_Info_01", "Only support for all Google Play accounts"))
		GUICtrlSetState(-1, $GUI_CHECKED)
		GUICtrlSetOnEvent(-1, "chkAccSwitchMode")
		$g_hRadSwitchSuperCellID = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSuperCellID", "SuperCell ID"), $x + 265, $y - 38, -1, -1)	;AltuFaltu-m
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSuperCellID_Info_01", "Only support for all SuperCell ID accounts"))
		GUICtrlSetOnEvent(-1, "chkAccSwitchMode")
		$g_hRadSwitchSharedPrefs = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSharedPrefs", "Shared_prefs"), $x + 345, $y - 38, -1, -1)	;AltuFaltu-m
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadSwitchSharedPrefs_Info_01", "Support for Google Play and SuperCell ID accounts"))
		GUICtrlSetOnEvent(-1, "chkAccSwitchMode")
		$g_hRadAltuFaltuSCID = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadAltuFaltuSCID", "AltuFaltu SCID Click Ver_1.5"), $x + 185, $y - 20, -1, -1)	;AltuFaltu-s
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "RadAltuFaltuSCID_Info_01", "Simple Click Methode to Switch SUPERCELL IDs."))
			GUICtrlSetOnEvent(-1, "chkAccSwitchMode")
		$btnScanSCIDAcc = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ScanSCIDAcc", "AF Scan SCID"), $x + 345, $y - 20, -1, 18)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "BtnScanSCIDAcc_Info_01", "Use This Button to Scan Images of Your SCIDs Which are Updated in Mods ImgAccs Folder."))
			GUICtrlSetOnEvent(-1, "ScanSCIDAcc")	;AltuFaltu-e

	$y += 23
		$g_hChkSmartSwitch = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ChkSmartSwitch", "Smart switch"), $x, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ChkSmartSwitch_Info_01", "Switch to account with the shortest remain training time"))
		GUICtrlSetState(-1, $GUI_UNCHECKED)
		GUICtrlSetOnEvent(-1, "chkSmartSwitch")

		$g_hChkDonateLikeCrazy = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "DonateLikeCrazy", "Donate like Crazy"), $x + 100, $y, -1, -1)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "DonateLikeCrazy_Info_01", "Enable it allows account switching in the order: Donate - Shortest Active - Donate - Shortest Active  - Donate...!"))
		GUICtrlSetOnEvent(-1, "chkSmartSwitch")

		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "CmbTrainTime", "Skip switch if train time") & " <", $x + 220, $y + 4, -1, -1)
		$g_hCmbTrainTimeToSkip = GUICtrlCreateCombo("", $x + 345, $y - 1, 77, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		GUICtrlSetData(-1, "0 minute|1 minute|2 minutes|3 minutes|4 minutes|5 minutes|6 minutes|7 minutes|8 minutes|9 minutes", "1 minute")

	$y += 23
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Description", _
			"Using Switch Accounts requires that not more Google Accounts are registered in Android than configured here. " & _
			"Maximum of 8 Google/CoC Accounts is supported."), $x, $y, $g_iSizeWGrpTab2 - 20, 42, $SS_CENTER)

	$y += 29
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_01", "Accounts"), $x - 5, $y, 60, -1, $SS_CENTER)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_02", "Profile name"), $x + 82, $y, 70, -1, $SS_CENTER)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_03", "Donate only"), $x + 170, $y, 60, -1, $SS_CENTER)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_04", "SwitchAcc log"), $x + 285, $y, -1, -1, $SS_CENTER)

	$y += 14
		GUICtrlCreateGraphic($x, $y, 422, 1, $SS_GRAYRECT)

	$y += 7
		For $i = 0 To UBound($g_ahChkAccount) - 1
			$g_ahChkAccount[$i] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "ChkAccount", "Acc ") & $i + 1 & ".", $x, $y + ($i) * 25, -1, -1)
			GUICtrlSetOnEvent(-1, "chkAccountX")
			$g_ahCmbProfile[$i] = GUICtrlCreateCombo("", $x + 65, $y + ($i) * 25, 110, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "cmbSwitchAccProfileX")
			GUICtrlSetData(-1, _GUICtrlComboBox_GetList($g_hCmbProfile))
			$g_ahChkDonate[$i] = GUICtrlCreateCheckbox("", $x + 190, $y + ($i) * 25 - 3, -1, 25)
		Next

EndFunc   ;==>CreateSwitchAccount
#EndRegion

#Region Farming Schedule tab
Func CreateFarmSchedule()

	Local $x = 10, $y = 30
	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_10", "Account"), $x - 5, $y, 60, -1, $SS_CENTER)
	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_11", "Farm Schedule 1"), $x + 80, $y, 150, -1, $SS_CENTER)
	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Label_12", "Farm Schedule 2"), $x + 260, $y, 150, -1, $SS_CENTER)

	$y += 18
	GUICtrlCreateGraphic($x, $y, 425, 1, $SS_GRAYRECT)

	$y += 8
	For $i = 0 To 7
		$x = 10
		$g_ahChkSetFarm[$i] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "SetFarm", "Acc ") & $i + 1 & ".", $x, $y + $i * 30, -1, -1)
			GUICtrlSetOnEvent(-1, "chkSetFarmSchedule")
		$g_ahCmbAction1[$i] = GUICtrlCreateCombo(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Action1", "Turn..."), $x + 60, $y + $i * 30, 58, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, "Idle|Donate|Active")
			GUICtrlSetBkColor(-1, $COLOR_WHITE)
		$g_ahCmbCriteria1[$i] = GUICtrlCreateCombo(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Criteria1", "when..."), $x + 123, $y + $i * 30, 62, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, "Gold >|Elixir >|DarkE >|Trop. >|Time:")
			GUICtrlSetBkColor(-1, $COLOR_WHITE)
			GUICtrlSetOnEvent(-1, "cmbCriteria1")
		$g_ahTxtResource1[$i] = GUICtrlCreateInput("", $x + 187, $y + $i * 30, 50, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		$g_ahCmbTime1[$i] = GUICtrlCreateCombo("", $x + 187, $y + $i * 30, 50, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, 	"0 am|1 am|2 am|3 am|4 am|5 am|6 am|7 am|8 am|9 am|10am|11am|" & _
								"12pm|1 pm|2 pm|3 pm|4 pm|5 pm|6 pm|7 pm|8 pm|9 pm|10pm|11pm")
			GUICtrlSetState(-1, $GUI_HIDE)

		$x = 248 + 10 - 60
		$g_ahCmbAction2[$i] = GUICtrlCreateCombo(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Action2", "Turn..."), $x + 60, $y + $i * 30, 58, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, "Idle|Donate|Active")
			GUICtrlSetBkColor(-1, $COLOR_WHITE)
		$g_ahCmbCriteria2[$i] = GUICtrlCreateCombo(GetTranslatedFileIni("MBR GUI Design Child Bot - Profiles", "Criteria2", "when..."), $x + 123, $y + $i * 30, 62, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, "Gold <|Elixir <|DarkE <|Trop. <|Time:")
			GUICtrlSetBkColor(-1, $COLOR_WHITE)
			GUICtrlSetOnEvent(-1, "cmbCriteria2")
		$g_ahTxtResource2[$i] = GUICtrlCreateInput("", $x + 187, $y + $i * 30, 50, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		$g_ahCmbTime2[$i] = GUICtrlCreateCombo("", $x + 187, $y + $i * 30, 50, -1, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, 	"0 am|1 am|2 am|3 am|4 am|5 am|6 am|7 am|8 am|9 am|10am|11am|" & _
								"12pm|1 pm|2 pm|3 pm|4 pm|5 pm|6 pm|7 pm|8 pm|9 pm|10pm|11pm")
			GUICtrlSetState(-1, $GUI_HIDE)
	Next

EndFunc   ;==>CreateFarmSchedule
#EndRegion

#Region Switch Account log
Func CreateBotSwitchAccLog()

	Local $x = 0, $y = 0
	Local $activeHWnD1 = WinGetHandle("") ; RichEdit Controls tamper with active window
	$g_hTxtSALog = _GUICtrlRichEdit_Create($g_hGUI_LOG_SA, "", $x, $y, 205, 200, BitOR($ES_MULTILINE, $ES_READONLY, $WS_VSCROLL, $WS_HSCROLL, $ES_UPPERCASE, $ES_AUTOHSCROLL, $ES_AUTOVSCROLL, $ES_NUMBER, 0x200), $WS_EX_STATICEDGE)
	WinActivate($activeHWnD1) ; restore current active window

EndFunc   ;==>CreateBotSwitchAccLog
#EndRegion
