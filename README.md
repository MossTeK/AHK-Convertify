# AHK-Convertify
An AHK script designed to convert files with Asterisk compatibility in mind.

Run the .ahk script, and a dialog will pop open asking how many files you need to convert. The script will then iterate through the existing framework, ie. selecting the file, selecting the output folder and filename, then opening an instance of FFMPEG and processing that one file, until the loop is finished iterating.

Future versions of this will rework file selection and output. This is a "quck and dirty" implementation just to get something working, then we can go back and improve on it later.