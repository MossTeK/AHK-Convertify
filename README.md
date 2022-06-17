# AHK-Convertify
An AHK script designed to convert files with Asterisk compatibility in mind. Now with a new GUI!

The GUI is now mostly complete (pretty sure it wont change at least lol) and now looks like:

![image](https://user-images.githubusercontent.com/5680448/172486171-3c90bbfe-a311-4e70-989e-2c52ea0a259a.png)

Run the .ahk script, and the above GUI will pop open that will let you choose input files. This will open a Windows-native file selection dialog that supports Ctrl and Shift to select multiple files at once.

v1.3 Beta 1 has added manual handling of output files back into the mix of modes - Automatic handling of output files still exists and works exactly as it did in v1.2, you just now have the option to have the program automatically spit out into the same input directory or a custom one of your choosing.

v1.3Beta 2 will add config support to remember your preference for output directory and options.

v1.3Beta4 is the current RC and has all features present and working with a "final" GUI.

# Changelog

Code cleanup - lots of old, unused code was removed. Most code was touched/changed in this release, if at least minorly.

New GUI - This one's actually finished!

Multi File mode! This will let you select multiple files by holding shift or ctrl.

Folder mode - convert all files in a folder at once!

Automatic file management - Now you can disable or enable this! Disabling lets you select an output folder.

Logs are much more verbose and detailed now!

# Bugs Fixed

Fixed an oversight where logging was using WorkingDir instead of ScriptDir, resulting in a moving log file

Fixed AHK melting if you use a carrot in file paths - thanks Jacob!

Fixed an issue where ancient file selection code set a variable to 2, which is out of range in modern code - thanks Jacob!

Fixed an issue where fixing carrots also broke newlines on log output

Fixed a bug where unchecking and rechecking "Automatically Manage Output Files" caused the checkbox to disable

Fixed a bug where the file enumeration loop wouldn't properly step through all files in Folder mode, forcing you to run it many times

Fixed all instances of Error logs erroniously reporting they were [INFO] and not [ERROR]

Fixed a bug where you could start converting files before you selected files to convert


# Known Bugs

There is a nasty race condition with folder select that if you output to the same directory as the source files,

and had too many files in there or a slow enough PC, the loop would see new conversions and re-convert them endlessly.

Solution: Don't output files to the same directory as the source files :) (working on a fix but it wont be ready this ver)
