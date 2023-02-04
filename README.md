# Buttonsweeper

![Capture](https://user-images.githubusercontent.com/88516542/216791102-dc8b20ae-856e-4d54-b3d5-38e5a7b20c41.JPG)


A mine game, in PowerShell.
File must be saved as 'UTF-8 with BOM' in order for emoji faces to appear correctly (open in notepad and save-as).

Buttonsweeper is a version of the game Minesweeper, written in PowerShell, taking advantage of .NET with System.Windows.Forms and System.Windows.Drawing.

There are 4 modes; Easy, Medium, Hard, and Extreme.  A Custom game mode is included, though performance may vary depending on the values entered.

The first time Buttonsweeper.ps1 is run, a CSV file will be created in the same directory named scores.csv, if one does not exist.  This file must remain in the same directory for the highscore portion of the script to function.  Make sure to run the script from a directory where creating a file is allowed, or you will recieve errors when the script is run, though the game will still run.  The 'Name' property of highscores is taken from the user profile of whoever ran the script.
