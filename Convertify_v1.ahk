;Convertify v1
;An audio converter designed with Asterisk compatibility in mind
;JamesR, with input from Mike in Onbaording and Khris from Night Krew

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;debugMode lets you set what level of debugging you need. 0 is off, 4 is near pedantic verbosity with lossa tools. Note: this does not affect logging
global debugMode = 0 ; 0, 1, 2, 3, 4

;This lets our two file dialogs and the convert function play nice and share data.
global sourceFile = ""
global destinationFile= ""

doesLogFileExist() ;checks for log

;if the program doesnt crash, this logs a good boot
logAddBootSuccessful()

;File load dialog
loadFile()

;File save dialog
selectSavePath()

;invokes Convertify and passes the variables to it
convertStart()

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

logAddInfo("Invoking Convertify with the parameters: " . A_ScriptDir . "\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")


;this tells Convertify where the source file is, the type of conversion we want to happen, 
;bitrate, sets it to mono, and saves it to the path the user specified earlier.
Run %A_ScriptDir%\convertify.exe -i "%sourceFile%" -ar 8000 -ac 1 "%destinationPath%" -y 

logAddInfo("File should be converted!") 

logAddClose()
ExitApp

;this should never be called because of the Exit above
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
		), %A_WorkingDir%\log.txt 
	return
}

;Log an application error (I want this to be similar to how ProjectContingency logs)
logAddError(logErrorString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [ERROR] %logErrorString% `n
		), %A_WorkingDir%\log.txt
	return
}

;Log app close
logAddClose()
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] Application close requested. `n
		), %A_WorkingDir%\log.txt
	return
}

;Log app info. Can pass string to it via logAddInfo("this is a string")
logAddInfo(logInfoString="")
{
	FormatTime, currentTime, A_now, d-MMM-yyyy hh:mm:ss tt
	FileAppend,
		(
		%currentTime% [INFO] %logInfoString% `n
		), %A_WorkingDir%\log.txt
	return
}