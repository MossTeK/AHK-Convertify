﻿;Convertify v1.3 Beta 1 
;An audio converter designed with Asterisk compatibility in mind
;JamesR

;Changelog:
;Code cleanup - lots of old, unused code was removed. Most code was touched/changed in this release, if at least minorly.
;New GUI - This one's actually finished!
;Multi File mode! This will let you select multiple files by holding shift or ctrl.
;Folder mode - convert all files in a folder at once!
;Automatic file management - Now you can disable or enable this! Disabling lets you select an output folder.
;Logs are much more verbose and detailed now!

;Bugs Fixed:
;Fixed an oversight where logging was using WorkingDir instead of ScriptDir, resulting in a moving log file
;Fixed AHK melting if you use a carrot in file paths
;Fixed an issue where ancient file selection code set a variable to 2, which is out of range in modern code
;Fixed an issue where fixing carrots also broke newlines on log output
;Fixed a bug where unchecking and rechecking "Automatically Manage Output Files" caused the checkbox to disable
;Fixed a bug where the file enumeration loop wouldn't properly step through all files in Folder mode, causing you to run it many times
;Fixed all instances of Error logs erroniously reporting they were [INFO] and not [ERROR]

;Please report all new bugs as either issues or directly to James via Teams!

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
;Vars and GUI
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#include %A_ScriptDir%\bin\ini.ahk

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#EscapeChar | ; thanks Jacob for being you and somehow managing to break AHK itself

;This lets our two file dialogs and the convert function play nice and share data.
global sourceFile = ""
global destinationFile= ""
global filePath = ""
global destinationPath = ""

doesLogFileExist() ;checks for log
logAddBootSuccessful()

global convertEnabled = 0 ; 0 - user hasn't selected a file yet, 1 = User has selected file
global selectionMode = 0 ;0 = Multiple File mode, 1 = Folder mode, 9 = No files have been selected yet
global fileManage = 1 ; 0 = Auto manage disabled, 1 = Auto Manage Enabled
global inputPath=A_ScriptDir
global outputPath=A_ScriptDir
global outputPathManual=A_ScriptDir

doesIniExist() ; You want to do this later in the file or else empty variables galore!

Gui,Add,Button,x75 y9 w120 h23,Input Files
Gui,Add,Text,x10 y31 w250 h13,_________________________________________________________________
Gui,Add,Button,x75 y113 w120 h23,Convert!
Gui,Add,StatusBar,,defaultTextString
logAddInfo("BOOT - frontend GUI opened.")
SB_SetText("Welcome to Convertify v1.3 Beta 2! There be dragons!")
Gui,Show,w270 h170,Convertify v1.3
Gui,Add,Checkbox,x50 y85 w180 h13 gOutputModeChange vManageOutput Checked,Automatically Manage Output Files
Gui,Add,Checkbox,x50 y55 w180 h13 gFileModeChange vFileInputMode,Input button selects entire folder

logAddInfo("BOOT - fileManage is currently " . fileManage)
logAddInfo("BOOT - selectionMode is currently " . selectionMode)

return

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
;GUI Actions
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ButtonInputFiles:
SB_SetText("Selecting input file/folder...")
logAddInfo("I/O - Selecting input file/folder...")
loadFile()
return

ButtonOutputFiles:
SB_SetText("Selecting output file/folder...")
logAddInfo("I/O - Selecting output file/folder...")
selectSavePath()
return

ButtonConvert!:
{
	if fileManage = 1
		{
			SB_SetText("Invoking Convertify and converting the selected file(s)...")
			convertStartNew()
			return
		}
	if fileManage = 0
		{
			SB_SetText("Invoking Convertify and converting the selected file(s)...")
			selectSavePath()
			convertStartNew()
			return
		}
	else
	{
	SB_SetText("fileManage is broken, try again")
	return
	}
}
GuiClose:
logAddClose()
ExitApp

GuiEscape:
logAddInfo("GUI - Escape button pressed. Terminating program.")
logAddClose()
ExitApp

OutputModeChange:
Loop, 1 
{
    GuiControlGet, CheckBoxState,, ManageOutput
	if (CheckBoxState = 1)	
		{
			fileManage = 1
			logAddInfo("GUI - Checkbox for Automatic File Manage was set to on, feature is ENABLED!")
			SB_SetText("Automatic Manage Output Files is ENABLED!")
		}
	else
		{
			fileManage = 0
			logAddInfo("GUI - Checkbox for Automatic File Manage was set to off, feature is DISABLED!")
            SB_SetText("Automatic Manage Output Files is DISABLED!")
		}
	}		
return	

FileModeChange:
Loop, 1 
{
    GuiControlGet, CheckBoxState,, FileInputMode
	if (CheckBoxState = 0) 
		{
			;GuiControl, Enable, Button3
			selectionMode = 0
			logAddInfo("GUI - Checkbox for File Input Mode was set to off, running in Files mode!")
		}
	Else
		{
			selectionMode = 1
			logAddInfo("GUI - Checkbox for File Input Mode was set to on, running in Folder mode!")
		}
	}		
return
	
;~~~~~~~~~~~~~~~~~~~~~
;File I/O Functions
;~~~~~~~~~~~~~~~~~~~~~
	
loadFile()
{
logAddInfo("I/O - Opening input file selection dialog")

if (selectionMode = 0)	
	{
		FileSelectFile, sourceFile, M3, RootDir\Filename, Open audio file, Audio (*.mp3; *.wav; *.ogg; *.m4a)
		if (sourceFile = "")
			{
				logAddInfo("I/O - File selection was canceled, closing menu.")
				logAddClose()
				
				return
			}
		else
			{
				logAddInfo("I/O - The user selected the following: " . sourceFile)
				convertEnabled = 1
				logAddInfo("I/O - variable convertEnabled = " . convertEnabled)
				return
			}
    }	

if (selectionMode = 1)	
	{
	logAddInfo("I/O - Selection mode is currently 1 - Folder Mode")
		FileSelectFolder, sourceFile
		logAddInfo("I/O - The user selected the following: " . sourceFile)
		SetWorkingDir %sourceFile%
		logAddInfo("I/O - A_WorkingDir is now " . A_WorkingDir)
		convertEnabled = 1
		logAddInfo("I/O - variable convertEnabled = " . convertEnabled)
		return
	}		
else 
	{
	logAddError("I/O - Selection mode is currently out of range, Terminating")
	Msgbox uh oh you somehow selected an option that put selectionMode out of range
	ExitApp
	return
	}
}

selectSavePath()
{
    logAddInfo("I/O - Opening file save dialog")
	if (fileManage = 0)
		{
			logAddInfo("I/O - fileManage mode is 0 - Automatic Management of files disabled")
			FileSelectFolder, outputPathManual, , 3
			return
		}
	if (fileManage = 1)
		{
		    logAddError("CRITICAL - you somehow managed to get fileManage into a state where the button is active but the setting is not. Terminating.")
			Msgbox you somehow managed to get fileManage into a state where the button is active but the setting is not. Terminating.
			logAddClose()
			ExitApp
		}
	else
		{
			Msgbox you somehow managed to get fileManage into an unknown state. Terminating.
			logAddError("CRITICAL - you somehow managed to get fileManage into an unknown state. Terminating.")
			logAddClose()
			ExitApp
		}
}

;~~~~~~~~~~~~~~~~~~~~~
;Conversion Functions
;~~~~~~~~~~~~~~~~~~~~~

ConvertStartNew()
{

if convertEnabled = 0
{
			logAddError("ERROR - User tried to convert files before selecting any.")
            SB_SetText("Please select a file first!")
}

if convertEnabled = 1
	{
		if selectionMode = 0
			{	
				Loop, parse, sourceFile, `n
					{
					if (A_Index = 1)
						{
							logAddInfo("CONVERT - File(s) mode is selected!")
							logAddInfo("CONVERT - Selected files directory is " . A_LoopField)
							if (fileManage = 1)
							{
							logAddInfo("CONVERT - Automatic output managing is enabled.")
							outputPath = inputPath
							}
							if (fileManage = 0)
							{
							logAddInfo("CONVERT - Automatic output managing is disabled.")
							}
						}
					else
						{
							logAddInfo("CONVERT - Loop iteration has begun on the files selected.")
							logAddInfo("CONVERT - current file is " . A_LoopField)
							inputPath = %A_LoopField%

							destinationPath=%outputPath%\%inputPath%_converted.wav
							inputFile = %outputPath%\%inputPath%
							logAddInfo("CONVERT - destinationPath is " . A_LoopField)
							logAddInfo("CONVERT - inputFile is " . A_LoopField)

							logAddInfo("CONVERT - Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
							Run %A_ScriptDir%\bin\convertify.exe -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y 
							logAddInfo("CONVERT - " . inputFile . " should be converted!")
							SB_SetText( inputFile . " should be converted!")
						}
					}
			SB_SetText("All conversions have finished - Check the Input folder!")
			return
			}	
	
		if selectionMode = 1
			{
				Loop, parse, sourceFile, `n		
					{

						logAddInfo("CONVERT - Folder mode is selected!")
						logAddInfo("CONVERT - Selected files directory is " . A_WorkingDir)
						Loop %A_WorkingDir%\*.*
							{
							files = %A_LoopFileName%
							logAddInfo("CONVERT - Loop iteration has begun on the files selected.")
							logAddInfo("CONVERT - current file is " . files)
							inputPath = %filePath%
							if (fileManage = 1)
								{
								logAddInfo("CONVERT - Automatic output managing is enabled.")
								destinationPath=%A_WorkingDir%\%files%_converted.wav
								}
							if (fileManage = 0)
								{
								logAddInfo("CONVERT - Automatic output managing is disabled.")
								logAddInfo("CONVERT - OutputPathManual is " . outputPathManual)
								destinationPath=%outputPathManual%\%files%_converted.wav
								}
							inputFile = %A_WorkingDir%\%files%
							logAddInfo("CONVERT - destinationPath is " . destinationPath)
							logAddInfo("CONVERT - inputFile is " . A_LoopField)
							logAddInfo("CONVERT - Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . inputFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
							Run %A_ScriptDir%\bin\convertify.exe -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y 
							logAddInfo("CONVERT - " . inputFile . " should be converted!")
							SB_SetText( inputFile . " should be converted!")
							}
					}

				SB_SetText("All conversions have finished - Check the Input folder!")		
			}

	convertEnabled = 0
	return
	}
else
	{
		logAddError("GUI - User tried to convert files before selecting any")
		SB_SetText("Please select a file first!")
	}
}

;~~~~~~~~~~~~~~~~~~~~~
;Ini Functions
;~~~~~~~~~~~~~~~~~~~~~

;Check if ini exists, if not create it.
doesIniExist()
{
	
	if FileExist("convertify.ini")
	{
	ini := new Ini(A_ScriptDir . "\convertify.ini")
	ini.Get("convertEnabled", "Settings", default_value = "0")
	ini.Get("selectionMode", "Settings", default_value = "0")
	ini.Get("fileManage", "Settings", default_value = "1")
	ini.Get("inputPath", "Settings", default_value = "A_ScriptDir")
	ini.Get("outputPathManual", "Settings", default_value = "outputPathManual")
	ini.Get("testParm", "Debug", default_value = "NEVER GONNA GIVE U UP")
	ini.Save()
	;Msgbox %default_value%
	sleep 100
	}
	
	if !FileExist("convertify.ini")
	{
	logAddInfo("BOOT - Ini file missing, generating new one.")
	FileAppend,
	(
	[Settings]
	), %A_ScriptDir%\convertify.ini 
	ini := new Ini(A_ScriptDir . "\convertify.ini")
	ini.Set("convertEnabled", "Settings", convertEnabled)
	ini.Set("selectionMode", "Settings", selectionMode)
	ini.Set("fileManage", "Settings", fileManage)
	ini.Set("inputPath", "Settings", inputPath)
	ini.Set("outputPathManual", "Settings", outputPathManual)
	
	ini.Save()
	sleep 100
	logAddInfo("BOOT - Ini generation complete!")
	}
	
	return
}

;~~~~~~~~~~~~~~~~~~~~~
;Logging Functions
;~~~~~~~~~~~~~~~~~~~~~

;Check if log exists in current working directory, if not create it.
doesLogFileExist()
{
	
	if FileExist("log-1.3-beta2.txt")
	{
		if (debugMode = 4)
		{
			logAddInfo("LOG - succesfully found existing log.")
			ToolTip debugMode = 4 existing log found
			sleep 1000
			ToolTip
		}
	}
	
	if !FileExist("log-1.3-beta2.txt")
	{
		if (debugMode = 4)
		{
			ToolTip debugMode = 4 no log found so creating new
			sleep 1000
			ToolTip
		}

		logAddError("I/O - Log file does not exist, creating new log.")
	}
	
	return
}

;Log application startup.
logAddBootSuccessful()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application boot successful. |n
		), %A_ScriptDir%\log-1.3-beta2.txt 
	return
}

;Log an application error (I want this to be similar to how ProjectContingency logs)
logAddError(logErrorString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [ERROR] %logErrorString% |n
		), %A_ScriptDir%\log-1.3-beta2.txt
	return
}

;Log app close
logAddClose()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application close requested. |n
		), %A_ScriptDir%\log-1.3-beta2.txt
	return
}

;Log app info. Can pass string to it via logAddInfo("this is a string")
logAddInfo(logInfoString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] %logInfoString% |n
		), %A_ScriptDir%\log-1.3-beta2.txt
	return
}