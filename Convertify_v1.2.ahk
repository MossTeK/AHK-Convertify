;Convertify v1.2 Final
;An audio converter designed with Asterisk compatibility in mind
;JamesR

;Changelog:
;New GUI - most of this is empty, more features will come in v1.3
;Multi File mode! This will let you select multiple files by holding shift or ctrl.
;Automatic file management - this will output the converted files to the same directory, and append _converted.wav to the end.
;Single file mode that existed in pre-release is now officially depracated and has been removed/stubbed out.

;Bugs:
;No new ones were introduced as far as I know.

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;this is unused
global debugMode = 0

;dividerText = ""

;This lets our two file dialogs and the convert function play nice and share data.
global sourceFile = ""
global destinationFile= ""
global filePath = ""
global destinationPath = ""

doesLogFileExist() ;checks for log
logAddBootSuccessful()

global selectionMode = 2 ;2 - Multiple File 1 - Folder
global inputPath= 
global outputPath= 

;Gui,Add,Button,x215 y11 w43 h23,Select Input
;Gui,Add,Edit,x110 y12 w100 h21,%inputPath%
;Gui,Add,Text,x10 y15 w88 h13,Input File(s)/Folder
;Gui,Add,Radio, gFileMode vselectionMode Checked x11 y95 w70 h13,Files Mode
;Gui,Add,Button,x82 y152 w100 h38,Convert!
;Gui,Show,w270 h250,Convertify v1.2 Final
;logAddInfo("frontend GUI opened.")
;SB_SetText("Welcome to Convertify v1.2!")

Gui,Add,Button,x75 y9 w120 h23,Input Files
Gui,Add,Text,x10 y57 w250 h13,_________________________________________________________________
Gui,Add,Button,x75 y130 w120 h23,Convert!
Gui,Add,Text,x30 y105 w215 h13,Note - Blank GUI spots are for future releases
Gui,Add,StatusBar,,defaultTextString
logAddInfo("frontend GUI opened.")
SB_SetText("Welcome to Convertify v1.2!")
Gui,Show,w270 h190,Convertify v1.2

; Disabling of some features that aren't in 1.2
; NOTE - enabling these won't magically make them function :)
;Gui,Add,Button,x75 y35 w120 h23,Output Files
;Gui,Add,Radio,x10 y75 w75 h13,Folder Mode
;Gui,Add,Radio,x192 y75 w75 h13,Files Mode
;Gui,Add,Checkbox,x50 y102 w180 h13,Automatically Name Output Files

return

ButtonInputFiles:
SB_SetText("Selecting input file/folder...")
loadFile()
return

ButtonOutputFiles:
SB_SetText("Selecting output file/folder...")
Msgbox This feature has not been implemented yet. Check back in Convertify v1.3!
return

ButtonConvert!:
SB_SetText("Invoking Convertify and converting the selected file(s)...")
convertStart()
return

GuiClose:
logAddClose()
ExitApp

GuiEscape:
logAddInfo("Escape button pressed. Terminating program.")
logAddClose()
ExitApp

loadFile()
{
logAddInfo("opening file select dialog")

if (selectionMode = 2)	
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
				return
			}
    }	
else 
	{
		Msgbox This is not implemented yet
		return
	}
}

selectSavePath()
{
    logAddInfo("opening file save dialog")
	if (selectionMode = 2)
		{
			FileSelectFolder, outputPath, , 3
			return
		}
	else
		{
			Msgbox This is not implemented yet
		}
}

convertStart()
{
	if (selectionMode = 2)	
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
}
;~~~~~~~~~~~~~~~~~~~~~
;Logging Functions
;~~~~~~~~~~~~~~~~~~~~~

;Check if log exists in current working directory, if not create it.
doesLogFileExist()
{
	
	if FileExist("log-1.2.txt")
	{
		if (debugMode = 4)
		{
			logAddInfo("succesfully found existing log.")
			ToolTip debugMode = 4 existing log found
			sleep 1000
			ToolTip
		}
	}
	
	if !FileExist("log-1.2.txt")
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
		), %A_WorkingDir%\log-1.2.txt 
	return
}

;Log an application error (I want this to be similar to how ProjectContingency logs)
logAddError(logErrorString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [ERROR] %logErrorString% `n
		), %A_WorkingDir%\log-1.2.txt
	return
}

;Log app close
logAddClose()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application close requested. `n
		), %A_WorkingDir%\log-1.2.txt
	return
}

;Log app info. Can pass string to it via logAddInfo("this is a string")
logAddInfo(logInfoString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] %logInfoString% `n
		), %A_WorkingDir%\log-1.2.txt
	return
}