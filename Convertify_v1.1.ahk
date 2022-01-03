﻿;Convertify v1.1
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

InputBox, LoopCount, Convertify v1.1, Please enter the number of files you are converting., , 330, 130
logAddInfo("Multi-Select GUI opened.")
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

return

loadFile()
{
logAddInfo("opening file select dialog")
FileSelectFile, sourceFile, 3, RootDir\Filename, Open audio file, Audio (*.mp3; *.wav; *.ogg; *.m4a)
if (sourceFile = "")
    {
    logAddInfo("File selection was canceled, closing program.")
    logAddClose()
    ExitApp, [ ExitCode]
    }
else
    {
    logAddInfo("The user selected the following:" . sourceFile)
    }
}

selectSavePath()
{
    logAddInfo("opening file save dialog")
FileSelectFile, destinationFile, S, RootDir\Filename, Save audio file, Audio (*.wav)
if (destinationFile = "")
    {
    logAddInfo("File selection was canceled, closing program.")
    logAddClose()
    ExitApp, [ ExitCode]
    }
else
    {
    logAddInfo("The user selected the following:" . destinationFile)
    }
}

convertStart()
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

;~~~~~~~~~~~~~~~~~~~~~
;Logging Functions
;~~~~~~~~~~~~~~~~~~~~~

;Taken from CLib - use it like you would Contingency's logging syntax

;Check if log exists in current working directory, if not create it.
doesLogFileExist()
{
	
	if FileExist("log.txt")
	{
		if (debugMode = 4)
		{
			logAddInfo("succesfully found existing log.")
			ToolTip debugMode = 4 existing log found
			sleep 1000
			ToolTip
		}
	}
	
	if !FileExist("log.txt")
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
		), %A_WorkingDir%\log-1.1.txt 
	return
}

;Log an application error (I want this to be similar to how ProjectContingency logs)
logAddError(logErrorString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [ERROR] %logErrorString% `n
		), %A_WorkingDir%\log-1.1.txt
	return
}

;Log app close
logAddClose()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application close requested. `n
		), %A_WorkingDir%\log-1.1.txt
	return
}

;Log app info. Can pass string to it via logAddInfo("this is a string")
logAddInfo(logInfoString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] %logInfoString% `n
		), %A_WorkingDir%\log-1.1.txt
	return
}