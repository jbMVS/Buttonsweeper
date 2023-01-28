# Buttonsweeper
A mine game, in PowerShell.
File must be saved as 'UTF-8 with BOM' in order for emoji faces to appear correctly (open in notepad and save-as).

Buttonsweeper is a version of the game Minesweeper, written in PowerShell, taking advantage of .NET and System.Windows.Forms and System.Windows.Drawing.

There are 4 modes; Easy, Medium, Hard, and Extreme.  A Custom game mode is included, though performance may vary depending on the values entered.

The first time Buttonsweeper.ps1 is run, a CSV file will be created in the same directory named scores.csv for storing scores, if one does not exist.  This file must remain in the same directory as the script in order to function.  Make sure to run the script from a directory where creating a file is allowed, or you will recieve errors when the script is run.  However, the game will still run, just without functioning highscores.
