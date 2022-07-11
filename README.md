# AHK-Convertify
An AHK script designed to convert files with Asterisk compatibility in mind. Now with a new GUI!

The GUI is now mostly complete and it looks like:

![image](https://user-images.githubusercontent.com/5680448/178305026-2f059306-ba77-46c5-9bd2-e84730e2619d.png)

Run the .ahk script, and the above GUI will pop open that will let you choose input files. This will open a Windows-native file selection dialog that supports Ctrl and Shift to select multiple files at once.

v1.4 is a overhaul of how I was structuring the project and a minor rewrite. 1.3 was getting out of hand with a ton of undocumented changes everywhere just desperately trying to get everything to work. 

Folder mode has been removed due to being largely redundant with the normal file selection mode, plus it would require extra work on my side to filter out unsupported files, as well as implementaiton being a bit of a headache.

# Changelog

Slight revamp to project flow to make it easier to understand and follow.

Ini support! (This is still experimental as of beta3 and is mostly disabled as a result)

Folder mode has been removed as it was largely redundant with multiple file selection.

Automatic file management - Now reads your preference from the INI! Disabling lets you select an output folder. Enabling it will output files to /out/ in the script directory.

Ini loading is currently working somewhat. If you want to experiment, an example INI files is attached. Renmove the .txt on the end so it reads "convertify.ini" and place it in the script directory.

[convertify.ini.txt](https://github.com/JamesR-cB/AHK-Convertify/files/9085663/convertify.ini.txt)

# Bugs Fixed

All bugs from v1.3 that were fixed:

Fixed an oversight where logging was using WorkingDir instead of ScriptDir, resulting in a moving log file

Fixed AHK melting if you use a carrot in file paths - thanks Jacob!

Fixed an issue where ancient file selection code set a variable to 2, which is out of range in modern code - thanks Jacob!

Fixed an issue where fixing carrots also broke newlines on log output

Fixed a bug where unchecking and rechecking "Automatically Manage Output Files" caused the checkbox to disable

Fixed a bug where the file enumeration loop wouldn't properly step through all files in Folder mode, forcing you to run it many times

Fixed all instances of Error logs erroniously reporting they were [INFO] and not [ERROR]

Fixed a bug where you could start converting files before you selected files to convert

All bugs from 1.4 that were fixed:

Spawning the process for Convertify.exe would sometimes randomly fail

In specific circumstances it was possible to create an infinite load loop.

Fixed outputting of files with manual mode ignoring the user selection

Fixed outputting of files with manual mode creating empty files

Fixed outputting of files with manual mode just doing nothing

# Known Bugs

There is a nasty race condition with folder select that if you output to the same directory as the source files, and had too many files in there or a slow enough PC, the loop would see new conversions and re-convert them endlessly.

Solution: Don't output files to the same directory as the source files :)
