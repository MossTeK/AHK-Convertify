# AHK-Convertify
An AHK script designed to convert files with Asterisk compatibility in mind. 

The GUI is very straightforward, and has two major features - the Convert button and the Advanced Options button.

![image](https://user-images.githubusercontent.com/5680448/183481708-7100e94a-0471-490e-8e56-51d3bad17277.png)

The advanced options button will bring you to a new menu, which will save your selected options every time the menu is closed.

![image](https://user-images.githubusercontent.com/5680448/183481846-5262e7f5-bc80-46dd-b0fa-16ef80a3e53a.png)

Run the .ahk script, and the above GUI will pop open that will let you choose input files. This will open a Windows-native file selection dialog that supports Ctrl and Shift to select multiple files at once.

v1.4 is a overhaul of how I was structuring the project and a minor rewrite. 1.3 was getting out of hand with a ton of undocumented changes everywhere just desperately trying to get everything to work, so 1.4 is a return to form and a overhaul under the hood.

Folder mode has been removed due to being largely redundant with the normal file selection mode, plus it would require extra work on my side to filter out unsupported files, as well as implementaiton being a bit of a headache. This new method is extremely streamlined and is very easy to use.

# Changelog

A complete rewrite from v1.3 and before! Now starring a much more robust and way less complicated core conversion logic. Conversion flow has been overhauled and is vastly less complicated, and as a result is now much less fragile and is way more battle-hardened.

Finally working multiple file input support!

Finally working arbitrary output folder support!

Ini support! The Advanced Menu will automatcally save your selections to convertify.ini in the script directory.

Advanced Menu! This works with the INI support and will save to disk any changes you make here.

Folder mode has been removed as it was largely redundant with multiple file selection.

Automatic File Management - Now reads your preference from the INI! Disabling lets you select an output folder. Enabling it will output files to /out/ in the script directory.

Force Output Directory - you can set a force override so all you need to do is select your input files and Convertify can now output to the same manual directory without asking every time!

There are now three main conversion modes, as follows:

1 - Automatic Output - Will automatically output all files to ScriptDirectory/out/ 

2 - Manual Output - Will let you specify input and output files each time

3 - Force Output - Will let you manually specify the output folder once, and it will use that folder every time while only asking for input files.

# Bugs Fixed

Spawning the process for Convertify.exe would sometimes randomly fail

In specific circumstances it was possible to create an infinite load loop.

Fixed outputting of files with manual mode ignoring the user selection

Fixed outputting of files with manual mode creating empty files

Fixed outputting of files with manual mode just doing nothing

Fixed automatic output trying to create the new file in the location of the file, instead of the script directory

Advanced Settings screen does not visualy refresh when you select a new force path, but still works

Automatically Manage Output Files being checked will now disable Force Output checkbox and OutputFolder button.

Awesomeness Detection now properly detects awesomeness.

Opening the app would sometimes immediately launch the conversion process

Exiting out of the select a file screen will still proceed with trying to convert...something

Converting files with spaces in the name will fail

**As well as most bugs from v1.3 that were fixed:**

Fixed an oversight where logging was using WorkingDir instead of ScriptDir, resulting in a moving log file

Fixed an issue where ancient file selection code set a variable to 2, which is out of range in modern code - thanks Jacob!

Fixed a bug where unchecking and rechecking "Automatically Manage Output Files" caused the checkbox to disable

Fixed a bug where the file enumeration loop wouldn't properly step through all files in Folder mode, forcing you to run it many times

Fixed all instances of Error logs erroniously reporting they were [INFO] and not [ERROR]

Fixed a bug where you could start converting files before you selected files to convert

# Known Bugs

Checking if Log Exists on boot always fails, but only visually - https://github.com/JamesR-cB/AHK-Convertify/issues/5 
