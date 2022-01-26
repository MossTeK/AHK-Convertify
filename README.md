# AHK-Convertify
An AHK script designed to convert files with Asterisk compatibility in mind. Now with a new GUI! The GUI has gone under a series of modifications and is designed for a lot of future options - currently only the options relevant to 1.2 are enabled and working.

The eventual full GUI will look like this:

![image](https://user-images.githubusercontent.com/5680448/151085037-6d255d3f-8c14-4bd6-9653-c311edcf8c1f.png)


The current UI looks like this:

![image](https://user-images.githubusercontent.com/5680448/151085062-49aa0fd0-fe14-464d-bc98-b6e3fd409526.png)

Run the .ahk script, and the above GUI will pop open that will let you choose input files. This will open a Windows-native file selection dialog that supports Ctrl and Shift to select multiple files at once.

This build also has a new feature - Automatic handling of output files! This will put the converted files into the source directory (aka, right beside the original files) with a "_converted.wav" on the end.

Future builds will enable a checkbox to let the program automatically manage your outputs, or to let you select your own.

Future builds will also enable folder selection mode for both input and output - meaning you can select a folder and the program will automatically select all compatible files and convert them for you.
