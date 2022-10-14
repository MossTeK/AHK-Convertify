;Convertify v1.4 Final
;An audio converter designed with Asterisk compatibility in mind
;JamesR

;Changelog:
;A complete rewrite from v1.3 and before! Now starring a much more robust and way less complicated core conversion logic.
;Finally working multiple file input support!
;Finally working arbitrary output folder support!
;Ini support!
;Advanced Preferences Menu! This works with the INI support and will save to disk any changes you make here.
;Force Output Directory - you can set a force override so all you need to do is select your input files and Convertify can now output to the same manual directory without asking every time!
;There are now three main conversion modes, as follows:
;1 - Automatic Output - Will automatically output all files to ScriptDirectory/out/ 
;2 - Manual Output - Will let you specify input and output files each time
;3 - Force Output - Will let you manually specify the output folder once, and it will use that folder every time while only asking for input files.

;Bugs Fixed:
;Spawning the process for Convertify.exe would sometimes randomly fail
;In specific circumstances it was possible to create an infinite load loop.
;Fixed outputting of files with manual mode ignoring the user selection
;Fixed outputting of files with manual mode creating empty files
;Fixed outputting of files with manual mode just doing nothing
;Fixed automatic output trying to create the new file in the location of the file, instead of the script directory
;Advanced Settings screen does not visualy refresh when you select a new force path, but still works
;Automatically Manage Output Files being checked will now disable Force Output checkbox and OutputFolder button.
;Awesomeness Detection now properly detects awesomeness.
;Opening the app would sometimes immediately launch the conversion process
;Exiting out of the select a file screen will still proceed with trying to convert...something
;Converting files with spaces in the name will fail

;Known Bugs:
;Log checking on boot will claim it's always generating a new log file

;Please report all new bugs as either issues or directly to James via Teams!

;~~~~~~~~~~~~~~~~~~~~~
;Vars and GUI
;~~~~~~~~~~~~~~~~~~~~~

global convertEnabled = 0 ; 0 - user hasn't selected a file yet, 1 = User has selected file
global selectionMode = 0 ;0 = Multiple File mode, 1 = Folder mode, 9 = No files have been selected yet
global fileManage = 1 ; 0 = Auto manage disabled, 1 = Auto Manage Enabled
global forceOutput = 0 ; Force output to always use same pre-selected folder.
global awesomeness = 0 ; Awesomeness Detection!
global TJMode = ; TJ Mode!

global inputPath = A_ScriptDir
global outputPath = A_ScriptDir

global appVersion="1.4-release"
global buildNumber="build96"

global iniMissing=0

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;This lets our two file dialogs and the convert function play nice and share data.
global sourceFile = ""
global destinationFile= ""
global filePath = ""
global destinationPath = ""
global pathStatic = ""

IniLoad()

doesLogFileExist() ;checks for log
logAddBootSuccessful()

if awesomeness = 1
{
logAddInfo("Awesomeness was detected!")
}

;~~~~~~~~~~~~~~~~~~~~~
;GUI Creation
;~~~~~~~~~~~~~~~~~~~~~

Gui,Add,Button,x10 y9 w120 h23,Convert!
Gui,Add,Button,x140 y9 w120 h23,Advanced
Gui,Add,Text,x10 y31 w250 h13,_________________________________________________________________
Gui,Add,StatusBar,,defaultTextString
logAddInfo("BOOT - frontend GUI opened.")
SB_SetText("Welcome to Convertify " . appVersion . "! There be dragons!")
Gui,Add,Text,x30 y50 w250 h13,Thank you for pre-release testing Convertify!
Gui,Add,Text,x55 y65 w250 h13,Please message James on Teams
Gui,Add,Text,x80 y80 w250 h13,if you have problems!
Gui,Show,w270 h120,Convertify %appVersion%

return
;~~~~~~~~~~~~~~~~~~~~~
;GUI Actions
;~~~~~~~~~~~~~~~~~~~~~

ButtonConvert!:
{
IniLoad()
SB_SetText("Selecting input file/folder...")
loadFile()
	if ErrorLevel
		{
			logAddInfo("File load path selection was canceled.")
			SB_SetText("File selection was canceled.")
			return
		}
	if (sourceFile = "")
			{
				logAddInfo("File selection was empty, selection is canceled.")
				SB_SetText("File selection was canceled.")
				return
			}
	if (fileManage = 1)
	{
		if (forceOutput = 0)
			{
			logAddInfo("I/O - loadFile called, forceOutput = 0 and fileManage = 1")
			convertStartAuto()
			}
		if (forceOutput = 1)
			{
			logAddInfo("I/O - loadFile called, forceOutput = 1 and fileManage = 1")
			convertStartAuto()
			}
	return
	}

	else
	{
		if (forceOutput = 0)
			{
			logAddInfo("I/O - loadFile called, forceOutput = 0 and fileManage = 0")
			selectSavePath()
			convertStartAuto()
			}
		if (forceOutput = 1)
			{
			logAddInfo("I/O - loadFile called, forceOutput = 1 and fileManage = 0")
			convertStartAuto()
			}

	return
	}
}

ButtonAdvanced:
{
Gui,2:Add,Button,x5 y97 w120 h23,Output Path
logAddInfo("BOOT - advanced settings GUI opened.")
Gui,2:Add,Text,x215 y100 w650 h25,%outputPath%
Gui,2:Add,Text,x215 y142 w250 h13,Detects how awesome you are.
Gui,2:Add,Text,x215 y50 w650 h15,Check this to force the system to always use the below path
Gui,2:Add,Text,x215 y65 w650 h15,and never ask you for a save path when converting files.
Gui,2:Add,Text,x215 y12 w250 h13,Automatic output will create an /out/ directory
Gui,2:Add,Text,x215 y27 w250 h13,in the same directory as the script.
Gui,2:Add,Text,x5 y250 w637 h13,______________________________________________________________________________________________________________________
Gui,2:Add,Text,x125 y275 w250 h13,Convertify %appVersion%
Gui,2:Add,Text,x125 y300 w250 h13,Converticheck 0.1alpha
Gui,2:Add,Text,x125 y325 w250 h13,Build %buildNumber%
Gui,2:Add,Text,x400 y275 w250 h13,Current environment for the app:
Gui,2:Add,Text,x400 y300 w250 h13,Production/Release
;Gui,2:Add,Text,x400 y300 w250 h13,Development/Debugging/Testing
Gui,2:Add,Checkbox,x5 y185 w170 h23,Empty Option 1
Gui,2:Add,Text,x215 y189 w250 h13,Reserved for future use.
Gui,2:Add,Checkbox,x5 y225 w170 h23,Empty Option 2
Gui,2:Add,Text,x215 y229 w250 h13,Reserved for future use.


; Awesomeness Detection
if (awesomeness = 1)
{
Gui,2:Add,Checkbox,x5 y138 w170 h23 gOutputModeAwesomenessChange vManageAwesomeness Checked,Awesomeness Detection!
}
if (awesomeness = 0)
{
Gui,2:Add,Checkbox,x5 y138 w170 h23 gOutputModeAwesomenessChange vManageAwesomeness,Awesomeness Detection!
}

; Force Output Folder
if (forceOutput = 1)
{
Gui,2:Add,Checkbox,x5 y50 w170 h23 gOutputModeForceChange vManageForcedOutput Checked,Force Specific Outbound Folder
}
if (forceOutput = 0)
{
Gui,2:Add,Checkbox,x5 y50 w170 h23 gOutputModeForceChange vManageForcedOutput,Force Specific Outbound Folder
}

; Automatically Manage Output Files
if (fileManage = 1)
{
Gui,2:Add,Checkbox,x5 y15 w180 h13 gOutputModeChange vManageOutput Checked,Automatically Manage Output Files
GuiControl,2:Disable,Output Path
GuiControl,2:Disable,ManageForcedOutput
}
if (fileManage = 0)
{
Gui,2:Add,Checkbox,x5 y15 w180 h13 gOutputModeChange vManageOutput ,Automatically Manage Output Files
GuiControl,2:Enable,Output Path
GuiControl,2:Enable,ManageForcedOutput
}

Gui,2:Show,w650 h350,Advanced Settings for Convertify %appVersion%
return
}

GuiClose:
logAddClose()
ExitApp

2GuiEscape:
2GuiClose:
Gui,2:Destroy
logAddInfo("GUI - secondary menu should be destroyed")
IniWrite, %fileManage%, Convertify.ini, Settings, fileManage
IniWrite, %forceOutput%, Convertify.ini, Settings, forceOutput
;IniWrite, %inputPath%, Convertify.ini, Settings, inputPath
IniWrite, %outputPath%, Convertify.ini, Settings, outputPath
return

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
			forceOutput = 0
			Gui,2:Destroy
			Gosub ButtonAdvanced
		}
	else
		{
			fileManage = 0
			logAddInfo("GUI - Checkbox for Automatic File Manage was set to off, the user will now specify output directories!")
            SB_SetText("Automatic Manage Output Files is DISABLED!")
			Gui,2:Destroy
			Gosub ButtonAdvanced
		}
	}
return

OutputModeAwesomenessChange:
Loop, 1
{
    GuiControlGet, CheckBoxState,, ManageAwesomeness
	if (CheckBoxState = 1)
		{
			awesomeness = 1
			logAddInfo("GUI - Checkbox for Awesomeness Detection was set to on!")
			SB_SetText("Awesomeness Detection is ENABLED!")
		}
	else
		{
			awesomeness = 0
			logAddInfo("GUI - Checkbox for Awesomeness Detection was set to off!")
            SB_SetText("Automatic Manage Output Files is DISABLED!")
		}
	}
return

OutputModeForceChange:
Loop, 1
{
    GuiControlGet, CheckBoxState,, ManageForcedOutput
	if (CheckBoxState = 1)
		{
			forceOutput = 1
			logAddInfo("GUI - Checkbox for Force Specific Outbound Folder was set to on, output files will go to the specified directory!")
			SB_SetText("Force Specific Outbound Folder is ENABLED!")
		}
	else
		{
			forceOutput = 0
			logAddInfo("GUI - Checkbox for Force Specific Outbound Folder was set to off, the user can now choose output!")
            SB_SetText("Force Specific Outbound Folder is DISABLED!")
		}
	}
return

2ButtonOutputPath:
{
selectSavePath()
Gui,2:Destroy
Gosub ButtonAdvanced
return
}

2ForceSpecificOutboundFolder:
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
logAddInfo("I/O - opening file select dialog")
		FileSelectFile, sourceFile, M3, , Open audio file, Audio (*.mp3; *.wav; *.ogg; *.m4a)
		if (sourceFile = "")
			{
				logAddInfo("File selection was canceled, closing program.")
				logAddClose()
				;ExitApp, [ ExitCode]
				return
			}
		if ErrorLevel
		{
			logAddInfo("File load path selection was canceled.")
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
    logAddInfo("I/O - opening file save dialog")
	FileSelectFolder, outputPath, , 3
	if ErrorLevel
		{
			logAddInfo("File save path selection was canceled.")
			outputPath = %A_ScriptDir%
			return
		}
	return
}

;~~~~~~~~~~~~~~~~~~~~~
;Conversion Functions
;~~~~~~~~~~~~~~~~~~~~~

convertStartAuto()
{
		Loop, parse, sourceFile, `n
			{
				if (A_Index = 1)
					{
						logAddInfo("CONVERT - Selected files directory is " . A_LoopField)
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
						logAddInfo("CONVERT - Loop iteration has begun on the files selected.")
						logAddInfo("CONVERT - current file is " . A_LoopField)
						inputPath = %A_LoopField%

						if (fileManage = 0)
						{

							destinationPath=%outputPath%\%inputPath%_converted.wav
							inputFile = %inputFilePath%\%inputPath%

						}
						else
						{
							destinationPath=%A_ScriptDir%\out\%inputPath%_converted.wav
							inputFile = %outputPath%\%inputPath%
					    }

						logAddInfo("CONVERT - destinationPath is " . A_LoopField)
						logAddInfo("CONVERT - inputFile is " . A_LoopField)

						logAddInfo("CONVERT - Invoking Convertify with the parameters: " . A_ScriptDir . "\bin\convertify.exe -i " . sourceFile . " -ar 8000 -ac 1 " . destinationPath . " -y")
						RunWait "%A_ScriptDir%\bin\convertify.exe" -i "%inputFile%" -ar 8000 -ac 1 "%destinationPath%" -y
						logAddInfo("CONVERT - " . inputFile . " should be converted!")
						SB_SetText(inputFile . " should be converted!")
					}
			}
		SB_SetText("All conversions have finished - Check the output folder!")
		logAddInfo("All conversions have finished - Check the output folder!" . A_LoopField)
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
IniRead, forceOutput, Convertify.ini, Settings, forceOutput
;IniRead, inputPath, Convertify.ini, Settings, inputPath
IniRead, outputPath, Convertify.ini, Settings, outputPath
return
}
else
{
	logAddInfo("I/O - Ini file missing, using defaults")
	iniMissing = 1
}



}

;~~~~~~~~~~~~~~~~~~~~~
;Logging Functions
;~~~~~~~~~~~~~~~~~~~~~

;Check if log exists in current working directory, if not create it.
doesLogFileExist(){
logFileName = %A_ScriptDir%/log-%appVersion%-%buildNUmber%.txt ; The string wont enumerate when called in the FileExsists funciton so we have to declare the filepath as a vairiable. This is the only way I could get this working I suspect this is an AHK issue.
	if FileExist(logFileName){
	logAddInfo("I/O - Log file exists!")
	return
	}
	
	if !FileExist(logFileName){
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
	FileAppend, %currentTime% [INFO] %logInfoString% `n, %A_ScriptDir%\log-%appVersion%-%buildNumber%.txt
	return
}
