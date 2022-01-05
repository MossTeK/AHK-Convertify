﻿;Convertify v1.2
;An audio converter designed with Asterisk compatibility in mind
;JamesR

;Changelog:
;Batch converts! Added a new GUI menu that asks how many files you want to convert.
;Convertify.exe moved to bin folder
;Log files incremented to log-1.1.txt

;Bugs:
;No new ones were introduced as far as I know.
;v1 - File save dialog does not automaitcally append .wav like it should, so I hardcode it, causing .wav.wav if you manually type .wav.

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;debugMode lets you set what level of debugging you need. 0 is off, 4 is near pedantic verbosity with lossa tools. Note: this does not affect logging
;this is unused
global debugMode = 0


;This lets our two file dialogs and the convert function play nice and share data.
global sourceFile = ""
global destinationFile= ""

doesLogFileExist() ;checks for log

;if the program doesnt crash, this logs a good boot
logAddBootSuccessful()


;debug 
selectionMode = 0 ;0 - Single File 1 - Multiple File 2 - Folder
inputPath= 
outputPath= 

Gui,Add,Button,x215 y11 w43 h23,Select Input
Gui,Add,Edit,x110 y12 w100 h21,%inputPath%
Gui,Add,Text,x10 y15 w88 h13,Input File(s)/Folder
Gui,Add,Button,x215 y41 w43 h23,Select Output
Gui,Add,Edit,x110 y42 w100 h21,%outputPath%
Gui,Add,Text,x10 y45 w96 h13,Output File(s)/Folder
Gui,Add,Radio,x11 y75 w75 h13,Folder Mode
Gui,Add,Radio,x11 y95 w70 h13,Files Mode
Gui,Add,Radio,x11 y115 w100 h13,Single File Mode
Gui,Add,Checkbox,x11 y135 w180 h13,Automatically Name Output Files
Gui,Add,Button,x82 y152 w100 h38,Convert!
Gui,Add,Text,x38 y194 w200 h13,Pre Release Build - For Evaluation Only
Gui,Show,w270 h220,Convertify v1.2 Pre-Release
logAddInfo("Multi-Select GUI opened.")
return

ButtonSelectInput:
loadFile()
return

ButtonSelectOutput:
selectSavePath()
return

ButtonConvert!:
convertStart()
return

;InputBox, LoopCount, Convertify v1.1, Please enter the number of files you are converting., , 330, 130

if ErrorLevel
	;MsgBox, Conversion canceled. Convertify will now close.
	logAddInfo("Multi-Select GUI closed with no selection. App terminated.")
If LoopCount is not digit
    {
    MsgBox, A valid number was not entered.
	logAddInfo("User entered a non valid string into the Multi-Select GUI. App terminated.")
	logAddInfo("String entered: " . LoopCount)
	}
else
{
logAddInfo("Entering interate loop with LoopCount set to: " . LoopCount)
Loop, %LoopCount%,
	{
	    logAddInfo("Loop Iteration: " . A_Index)
		;File load dialog
		loadFile()

		;File save dialog
		selectSavePath()

		;invokes Convertify and passes the variables to it
		convertStart()
	}
logAddInfo("Loop exiting successfully!")
logAddClose()
ExitApp
}

;return

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

if (selectionMode = 0)
	{
		FileSelectFile, sourceFile, 3, RootDir\Filename, Open audio file, Audio (*.mp3; *.wav; *.ogg; *.m4a)
		if (sourceFile = "")
			{
				logAddInfo("File selection was canceled, closing program.")
				logAddClose()
				;ExitApp, [ ExitCode]
			}
		else
			{
				logAddInfo("The user selected the following:" . sourceFile)
			}
	}
	
if (selectionMode = 1)	
	{
		FileSelectFile, sourceFile, M3, RootDir\Filename, Open audio file, Audio (*.mp3; *.wav; *.ogg; *.m4a)
		if (sourceFile = "")
			{
				logAddInfo("File selection was canceled, closing program.")
				logAddClose()
				;ExitApp, [ ExitCode]
			}
		else
			{
				logAddInfo("The user selected the following:" . sourceFile)
			}
	}
	
if (selectionMode = 2)	
	{
		FileSelectFolder, inputPath
	}
	
else 
	{
	Msgbox This is not implemented yet
	}
}

selectSavePath()
{
    logAddInfo("opening file save dialog")
	
	;debug 
	selectionMode = 0
	
	if (selectionMode = 0)
		{
			FileSelectFile, destinationFile, S, RootDir\Filename, Save audio file, Audio (*.wav)
			if (destinationFile = "")
				{
					logAddInfo("File selection was canceled, closing program.")
					logAddClose()
					;ExitApp, [ ExitCode]
				}
			else
				{
					logAddInfo("The user selected the following:" . destinationFile)
				}
		}
	else
	{
	Msgbox This is not implemented yet
	}
}

convertStart()
{
	if (selectionMode = 0)	
		{
			SplitPath, sourceFile, sourceName

			sourcePath=%A_ScriptDir%\%sourceFile%
			destinationPath=%destinationFile%.wav ;bugfix - save directory doesnt seem to save the .wav even though im explicitly telling it too and this makes me sad

			logAddInfo("sourceFile is set to " . sourceFile)
			logAddInfo("destinationPath is set to " . destinationPath)

			logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")

			;this tells Convertify where the source file is, the type of conversion we want to happen, 
			;bitrate, sets it to mono, and saves it to the path the user specified earlier.
			Run %A_ScriptDir%\bin\convertify.exe -i "%sourceFile%" -ar 8000 -ac 1 "%destinationPath%" -y 

			logAddInfo("File should be converted!")
			Return
		}
	
	if (selectionMode = 1)	
		{
			;SplitPath, sourceFile, sourceName

			;sourcePath=%A_ScriptDir%\%sourceFile%
			;destinationPath=%destinationFile%.wav ;bugfix - save directory doesnt seem to save the .wav even though im explicitly telling it too and this makes me sad

			;logAddInfo("sourceFile is set to " . sourceFile)
			;logAddInfo("destinationPath is set to " . destinationPath)

			;logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")

			;this tells Convertify where the source file is, the type of conversion we want to happen, 
			;bitrate, sets it to mono, and saves it to the path the user specified earlier.
			;Run %A_ScriptDir%\bin\convertify.exe -i "%sourceFile%" -ar 8000 -ac 1 "%destinationPath%" -y 

			;logAddInfo("File should be converted!")
			Msgbox This is not implemented yet
			return
		}
	else
		{
			Msgbox This is not implemented yet
			return
		}
}
;~~~~~~~~~~~~~~~~~~~~~
;Logging Functions
;~~~~~~~~~~~~~~~~~~~~~

;Taken from CLib - use it like you would Contingency's logging syntax

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