;Convertify v1.4 Beta 3
;An audio converter designed with Asterisk compatibility in mind
;JamesR

;Changelog:
;A complete rewrite from v1.3 and before!
;Finally working multiple file input support!
;Finally working arbitrary output folder support!
;Ini support!

;Bugs Fixed:
;Spawning the process for Convertify.exe would sometimes randomly fail
;In specific circumstances it was possible to create an infinite load loop.
;Fixed outputting of files with manual mode ignoring the user selection
;Fixed outputting of files with manual mode creating empty files
;Fixed outputting of files with manual mode just doing nothing


;Known Bugs:
;Exiting out of the select a file screen will still proceed with trying to convert...something
;Ini support is kinda broken so it's mostly disabled in this build


;Please report all new bugs as either issues or directly to James via Teams!

;~~~~~~~~~~~~~~~~~~~~~
;Vars and GUI
;~~~~~~~~~~~~~~~~~~~~~

global convertEnabled = 0 ; 0 - user hasn't selected a file yet, 1 = User has selected file
global selectionMode = 0 ;0 = Multiple File mode, 1 = Folder mode, 9 = No files have been selected yet
global fileManage = 1 ; 0 = Auto manage disabled, 1 = Auto Manage Enabled

global inputPath = A_ScriptDir
global outputPath = A_ScriptDir

global appVersion="1.4-beta3"
global buildNumber="build48"

global iniMissing=0

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;This lets our two file dialogs and the convert function play nice and share data.
global sourceFile = ""
global destinationFile= ""
global filePath = ""
global destinationPath = ""

IniLoad()

doesLogFileExist() ;checks for log
logAddBootSuccessful()

;~~~~~~~~~~~~~~~~~~~~~
;GUI Creation
;~~~~~~~~~~~~~~~~~~~~~

Gui,Add,Button,x75 y9 w120 h23,Convert!
Gui,Add,Text,x10 y31 w250 h13,_________________________________________________________________
Gui,Add,StatusBar,,defaultTextString
logAddInfo("BOOT - frontend GUI opened.")
SB_SetText("Welcome to Convertify " . appVersion . "! There be dragons!")
Gui,Show,w270 h140,Convertify %appVersion%
Gui,Add,Text,x30 y80 w250 h13,Automatic output will create an /out/ directory
Gui,Add,Text,x55 y95 w250 h13,in the same directory as the script.
if (fileManage = 1)
{
Gui,Add,Checkbox,x50 y55 w180 h13 gOutputModeChange vManageOutput Checked,Automatically Manage Output Files
return
}
if (fileManage = 0)
{
Gui,Add,Checkbox,x50 y55 w180 h13 gOutputModeChange vManageOutput ,Automatically Manage Output Files
return
}
else
{
	return
}
;~~~~~~~~~~~~~~~~~~~~~
;GUI Actions
;~~~~~~~~~~~~~~~~~~~~~

ButtonConvert!:
{
IniLoad()
SB_SetText("Selecting input file/folder...")
loadFile()
	if (fileManage = 0)
	{
	selectSavePath()
	convertStartAuto()
	return
	}
	else
	{
	convertStartAuto()
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
			logAddInfo("GUI - Checkbox for Automatic File Manage was set to on, output files will go to the script directory!")
			SB_SetText("Automatic Manage Output Files is ENABLED!")
		}
	else
		{
			fileManage = 0
			logAddInfo("GUI - Checkbox for Automatic File Manage was set to off, the user will now specify output directories!")
            SB_SetText("Automatic Manage Output Files is DISABLED!")
		}
	}
return

;~~~~~~~~~~~~~~~~~~~~~
;File I/O Functions
;~~~~~~~~~~~~~~~~~~~~~

loadFile()
{
logAddInfo("opening file select dialog")
		FileSelectFile, sourceFile, M3, , Open audio file, Audio (*.mp3; *.wav; *.ogg; *.m4a)
		if (sourceFile = "")
			{
				logAddInfo("File selection was canceled, closing program.")
				logAddClose()
				;ExitApp, [ ExitCode]
				return
			}
		else
			{
				logAddInfo("The user selected the following: " . sourceFile)
				return
			}
}


selectSavePath()
{
	;if (iniMissing = 1)
	;{
    logAddInfo("opening file save dialog")
	FileSelectFolder, outputPath, , 3
	return
	;}
	;else
	;{
	;logAddInfo("Using already set file path")
	;return
	;}
}

;~~~~~~~~~~~~~~~~~~~~~
;Conversion Functions
;~~~~~~~~~~~~~~~~~~~~~

convertStartManual()
{
		Loop, parse, sourceFile, `n
			{
				if (A_Index = 1)
					{
						logAddInfo("Selected files directory is " . A_LoopField)
					}
				else
					{
						logAddInfo("Loop iteration has begun on the files selected.")
						logAddInfo("current file is " . A_LoopField)
						inputPath = %A_LoopField%

					    destinationPath=%outputPath%\%inputPath%_converted.wav
						StringReplace, destinationPath, destinationPath,  `r`n,
						StringReplace, outputPathFixed, outputPath,  `r`n,
						Msgbox %outputPathFixed%
						inputFile = %outputPathFixed%\%inputPath%
						StringReplace, outputPath, outputPathFixed,  `r`n,
						logAddInfo("destinationPath is " . A_LoopField)
						logAddInfo("inputFile is " . A_LoopField)

						logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
						Run %A_ScriptDir%\bin\convertify.exe -i "%outputPath%\%inputPath%" -ar 8000 -ac 1 "%destinationPath%"
						logAddInfo( inputFile . " should be converted!")
						SB_SetText( inputFile . " should be converted!")
					}
			}
		SB_SetText("All conversions have finished - Check the Input folder!")
		return
}

convertStartAuto()
{
		Loop, parse, sourceFile, `n
			{
				if (A_Index = 1)
					{
						logAddInfo("Selected files directory is " . A_LoopField)
						if (fileManage = 0)
						{
							inputFilePath = %A_LoopField%
						}
						else
						{
							outputPath = %A_LoopField%
						}

					}
				else
					{
						logAddInfo("Loop iteration has begun on the files selected.")
						logAddInfo("current file is " . A_LoopField)
						inputPath = %A_LoopField%

						if (fileManage = 0)
						{


							destinationPath=%outputPath%\%inputPath%_converted.wav
							inputFile = %inputFilePath%\%inputPath%

						}
						else
						{
							destinationPath=%outputPath%\out\%inputPath%_converted.wav
							inputFile = %outputPath%\%inputPath%
					    }

						logAddInfo("destinationPath is " . A_LoopField)
						logAddInfo("inputFile is " . A_LoopField)

						logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
						RunWait "%A_ScriptDir%\bin\convertify.exe" -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y
						logAddInfo( inputFile . " should be converted!")
						SB_SetText( inputFile . " should be converted!")
					}
			}
		SB_SetText("All conversions have finished - Check the Input folder!")
		;inputPath = ""
		;outputPath = ""
		return
}


;~~~~~~~~~~~~~~~~~~~~~
;Ini Functions
;~~~~~~~~~~~~~~~~~~~~~

IniLoad()
{


if FileExist("convertify.ini")
{
IniRead, fileManage, Convertify.ini, Settings, fileManage
;IniRead, inputPath, Convertify.ini, Settings, inputPath
;IniRead, outputPath, Convertify.ini, Settings, outputPath
return
}
else
{
	logAddInfo("INI file missing, using defaults")
	iniMissing = 1
}



}

;~~~~~~~~~~~~~~~~~~~~~
;Logging Functions
;~~~~~~~~~~~~~~~~~~~~~

;Check if log exists in current working directory, if not create it.
doesLogFileExist()
{

	if FileExist("log-%appVersion%-%buildNumber%.txt")
	{
	logAddInfo("I/O - Log file exists!")
	return
	}

	if !FileExist("log-%appVersion%-%buildNumber%.txt")
	{
	logAddError("I/O - Log file does not exist, creating new log.")
	return
	}

}

;Log application startup.
logAddBootSuccessful()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application boot successful. `n
		), %A_ScriptDir%\log-%appVersion%-%buildNumber%.txt
	return
}

;Log an application error (I want this to be similar to how ProjectContingency logs)
logAddError(logErrorString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [ERROR] %logErrorString% `n
		), %A_ScriptDir%\log-%appVersion%-%buildNumber%.txt
	return
}

;Log app close
logAddClose()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application close requested. `n
		), %A_ScriptDir%\log-%appVersion%-%buildNumber%.txt
	return
}

;Log app info. Can pass string to it via logAddInfo("this is a string")
logAddInfo(logInfoString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] %logInfoString% `n
		), %A_ScriptDir%\log-%appVersion%-%buildNumber%.txt
	return
}