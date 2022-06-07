;Convertify v1.3 Beta 1 
;An audio converter designed with Asterisk compatibility in mind
;JamesR

;Changelog:
;Code cleanup - lots of old, unused code was removed.
;New GUI - This one's actually finished!
;Multi File mode! This will let you select multiple files by holding shift or ctrl.
;Folder mode - convert all files in a folder at once!
;Automatic file management - Now you can disable or enable this! Disabling lets you select an output folder.
;Logs are much more verbose and detailed now!

;Bugs Fixed:
;Fixed an oversight where logging was using WorkingDir instead of ScriptDir, resulting in a moving log file


;No new ones were introduced as far as I know.

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
;Vars and GUI
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

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
global inputPath= 
global outputPath=
global outputPathManual= 

Gui,Add,Button,x75 y9 w120 h23,Input Files
Gui,Add,Text,x10 y57 w250 h13,_________________________________________________________________
Gui,Add,Button,x75 y130 w120 h23,Convert!
;Gui,Add,Text,x30 y105 w215 h13,Note - Blank GUI spots are for future releases
Gui,Add,StatusBar,,defaultTextString
logAddInfo("frontend GUI opened.")
SB_SetText("Welcome to Convertify v1.3 Beta 1! There be dragons!")
Gui,Show,w270 h190,Convertify v1.3

; Disabling of some features that aren't in 1.2
; NOTE - enabling these won't magically make them function :)
Gui,Add,Button, x75 y35 w120 h23 Disabled,Output Files
;Gui,Add,Radio,x10 y75 w75 h13 vModeSelect1,Folder Mode
;Gui,Add,Radio,x192 y75 w75 h13 vModeSelect2,Files Mode
Gui,Add,Checkbox,x50 y102 w180 h13 gOutputModeChange vManageOutput Checked,Automatically Manage Output Files
Gui,Add,Checkbox,x50 y75 w180 h13 gFileModeChange vFileInputMode,Input button selects entire folder

;Msgbox fileManage is currently %fileManage%
logAddInfo("BOOT - fileManage is currently " . fileManage)
;Msgbox selectionMode is currently %selectionMode%
logAddInfo("BOOT - selectionMode is currently " . selectionMode)

return

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
;GUI Actions
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ButtonInputFiles:
SB_SetText("Selecting input file/folder...")
logAddInfo("Selecting input file/folder...")
loadFile()
return

ButtonOutputFiles:
SB_SetText("Selecting output file/folder...")
logAddInfo("Selecting output file/folder...")
selectSavePath()
return

ButtonConvert!:
SB_SetText("Invoking Convertify and converting the selected file(s)...")
convertStartNew()
return

GuiClose:
logAddClose()
ExitApp

GuiEscape:
logAddInfo("Escape button pressed. Terminating program.")
logAddClose()
ExitApp

OutputModeChange:
Loop, 1 
{
    GuiControlGet, CheckBoxState,, ManageOutput
	if (CheckBoxState = 0) 
		{
			GuiControl, Enable, Button3
			fileManage = 0
			logAddInfo("Checkbox for Automatic File Manage was set to off, feature is DISABLED!")
            SB_SetText("Automatic Manage Output Files is DISABLED!")
		}
	Else
		{
			GuiControl, Disable, Button3
			fileManage = 1
			logAddInfo("Checkbox for Automatic File Manage was set to on, feature is ENABLED!")
			SB_SetText("Automatic Manage Output Files is ENABLED!")
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
			selectionMode = 2
			logAddInfo("Checkbox for File Input Mode was set to off, running in Files mode!")
		}
	Else
		{
			selectionMode = 1
			logAddInfo("Checkbox for File Input Mode was set to on, running in Folder mode!")
		}
	}		
return
	
;~~~~~~~~~~~~~~~~~~~~~
;File I/O Functions
;~~~~~~~~~~~~~~~~~~~~~
	
loadFile()
{
logAddInfo("Opening input file selection dialog")

if (selectionMode = 0)	
	{
		FileSelectFile, sourceFile, M3, RootDir\Filename, Open audio file, Audio (*.mp3; *.wav; *.ogg; *.m4a)
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
				convertEnabled = 1
				logAddInfo("convertEnabled = " . convertEnabled)
				return
			}
    }	

if (selectionMode = 1)	
	{
	logAddInfo("Selection mode is currently 1 - Folder Mode")
		FileSelectFolder, sourceFile
		logAddInfo("The user selected the following: " . sourceFile)
		SetWorkingDir %sourceFile%
		logAddInfo("A_WorkingDir is now " . A_WorkingDir)
		convertEnabled = 1
		logAddInfo("convertEnabled = " . convertEnabled)
		return
	}		
else 
	{
	logAddInfo("Selection mode is currently out of range, Terminating")
	Msgbox uh oh you somehow selected an option that put selectionMode out of range
	ExitApp
	return
	}
	
	}

selectSavePath()
{
    logAddInfo("Opening file save dialog")
	if (fileManage = 0)
		{
			logAddInfo("fileManage mode is 0 - Automatic Management of files disabled")
			FileSelectFolder, outputPathManual, , 3
			return
		}
	if (fileManage = 1)
		{
		    logAddInfo("Selection mode is currently 1 - Automatic Management of files is enabled (this message should never actually be printed to log!!!")
			Msgbox you somehow managed to get fileManage into a state where the button is active but the setting is not. Terminating.
			logAddClose()
			ExitApp
		}
	else
		{
			Msgbox you somehow managed to get fileManage into an unknown state. Terminating.
			logAddClose()
			ExitApp
		}
}

;~~~~~~~~~~~~~~~~~~~~~
;Conversion Functions
;~~~~~~~~~~~~~~~~~~~~~

convertStart()
{
logAddInfo("convertStart is called")
	if (selectionMode = 0)	; Files Mode
		{
		Loop, parse, sourceFile, `n
			{
				if (A_Index = 1)
					{
						logAddInfo("Selected files directory is " . inputPath)
						outputPath = %A_LoopField%
					}
				else
					{
						logAddInfo("Loop iteration has begun on the files selected.")
						logAddInfo("current file is " . A_LoopField)
						inputPath = %A_LoopField%

					    destinationPath=%folderPath%\%inputPath%_converted.wav
						inputFile = %folderPath%\%inputPath%
						logAddInfo("destinationPath is " . A_LoopField)
						logAddInfo("inputFile is " . A_LoopField)

						logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
						Run %A_ScriptDir%\bin\convertify.exe -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y 
						logAddInfo( inputFile . " should be converted!")
						SB_SetText( inputFile . " should be converted!")
					}
			}


	if (selectionMode = 1)	; Folders Mode
		{
		Loop, parse, sourceFile, `n
			{
				if (A_Index = 1)
					{
						logAddInfo("Selected files directory is " . A_LoopField)
						outputPath = %A_LoopField%
					}
				else
					{
						logAddInfo("Loop iteration has begun on the files selected.")
						logAddInfo("current file is " . A_LoopField)
						inputPath = %A_LoopField%

					    destinationPath=%inputPath%\%inputPath%_converted.wav
						inputFile = %outputPath%\%inputPath%
						logAddInfo("destinationPath is " . A_LoopField)
						logAddInfo("inputFile is " . A_LoopField)

						logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
						Run %A_ScriptDir%\bin\convertify.exe -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y 
						logAddInfo( inputFile . " should be converted!")
						SB_SetText( inputFile . " should be converted!")
					}
			}
		SB_SetText("All conversions have finished - Check the Input folder!")
		return
		}
	}
}
return

ConvertStartNew()
{

if convertEnabled = 0
{
			logAddInfo("User tried to convert files before selecting any")
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
							logAddInfo("Selected files directory is " . A_LoopField)
							if (fileManage = 1)
							{
							logAddInfo("Automatic output managing is enabled.")
							outputPath = inputPath
							}
							if (fileManage = 0)
							{
							logAddInfo("Automatic output managing is disabled.")
							}
						}
					else
						{
							logAddInfo("Loop iteration has begun on the files selected.")
							logAddInfo("current file is " . A_LoopField)
							inputPath = %A_LoopField%

							destinationPath=%outputPath%\%inputPath%_converted.wav
							inputFile = %outputPath%\%inputPath%
							logAddInfo("destinationPath is " . A_LoopField)
							logAddInfo("inputFile is " . A_LoopField)

							logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
							Run %A_ScriptDir%\bin\convertify.exe -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y 
							logAddInfo( inputFile . " should be converted!")
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

						logAddInfo("FOLDER MODE CONVERSION STARTED")
						logAddInfo("Selected files directory is " . A_WorkingDir)
						Loop %A_WorkingDir%\*.*
							{
							files = %A_LoopFileName%
							;Msgbox %files%
							;logAddInfo("Files selected are: ")
							;logAddInfo(files)
							logAddInfo("Loop iteration has begun on the files selected.")
							logAddInfo("current file is " . files)
							inputPath = %filePath%
							if (fileManage = 1)
								{
								logAddInfo("Automatic output managing is enabled.")
								destinationPath=%A_WorkingDir%\%files%_converted.wav
								}
							if (fileManage = 0)
								{
								logAddInfo("Automatic output managing is disabled.")
								logAddInfo("OutputPathManual is " . outputPathManual)
								destinationPath=%outputPathManual%\%files%_converted.wav
								}
							;destinationPath=%A_WorkingDir%\%files%_converted.wav
							inputFile = %A_WorkingDir%\%files%
							logAddInfo("destinationPath is " . destinationPath)
							logAddInfo("inputFile is " . A_LoopField)
							logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . inputFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
							Run %A_ScriptDir%\bin\convertify.exe -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y 
							logAddInfo( inputFile . " should be converted!")
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
		logAddInfo("User tried to convert files before selecting any")
		SB_SetText("Please select a file first!")
	}
}

list_files(Directory)
{
	files =
	Loop %Directory%\*.*
	{
		files = %files%`n%A_LoopFileName%
	}
	return files
}
;~~~~~~~~~~~~~~~~~~~~~
;Logging Functions
;~~~~~~~~~~~~~~~~~~~~~

;Check if log exists in current working directory, if not create it.
doesLogFileExist()
{
	
	if FileExist("log-1.3-beta1.txt")
	{
		if (debugMode = 4)
		{
			logAddInfo("succesfully found existing log.")
			ToolTip debugMode = 4 existing log found
			sleep 1000
			ToolTip
		}
	}
	
	if !FileExist("log-1.3-beta1.txt")
	{
		if (debugMode = 4)
		{
			ToolTip debugMode = 4 no log found so creating new
			sleep 1000
			ToolTip
		}

		logAddInfo("Log file does not exist, creating new log.")
	}
	
	return
}

;Log application startup.
logAddBootSuccessful()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application boot successful. `n
		), %A_ScriptDir%\log-1.3-beta1.txt 
	return
}

;Log an application error (I want this to be similar to how ProjectContingency logs)
logAddError(logErrorString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [ERROR] %logErrorString% `n
		), %A_ScriptDir%\log-1.3-beta1.txt
	return
}

;Log app close
logAddClose()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application close requested. `n
		), %A_ScriptDir%\log-1.3-beta1.txt
	return
}

;Log app info. Can pass string to it via logAddInfo("this is a string")
logAddInfo(logInfoString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] %logInfoString% `n
		), %A_ScriptDir%\log-1.3-beta1.txt
	return
}