# Buttonsweeper - A mine game, in PowerShell

# File must be saved as UTF-8 with BOM in order for emoji faces to appear correctly (open in notepad and save-as)
# Running the script will create a scores.csv file in the parent directly, if one is not present
# When getting a high-score, scores.csv will be appended with the username, score, date, and game mode

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.drawing

## new game window
function New-Game {

    $NewGameForm = New-Object System.Windows.Forms.Form
    $NewGameForm.Text = "New Game"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 185
    $System_Drawing_Size.Width = 300
    $NewGameForm.FormBorderStyle = 'Fixed3D'
    $NewGameForm.MaximizeBox = $false
    $NewGameForm.ClientSize = $System_Drawing_Size
    $NewGameForm.StartPosition = 'CenterScreen'
    $NewGameForm.TopMost = $true
    $NewGameForm.add_Closing({$NewGameForm.Dispose()})

    $WelcomeLabel = New-Object System.Windows.Forms.Label
    $WelcomeLabel.Text = 'Welcome to Buttonsweeper!'
    $WelcomeLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Regular)
    $WelcomeLabel.Location = New-Object System.Drawing.Point(48,25)
    $WelcomeLabel.Autosize = $true
    $NewGameForm.Controls.Add($WelcomeLabel)

    $SubtitleLabel = New-Object System.Windows.Forms.Label
    $SubtitleLabel.Text = 'A mine game, in PowerShell'
    $SubtitleLabel.Location = New-Object System.Drawing.Point(80,50)
    $SubtitleLabel.Autosize = $true
    $NewGameForm.Controls.Add($SubtitleLabel)

    $EasyButton = New-Object System.Windows.Forms.Button
    $EasyButton.Text = "Easy"
    $EasyButton.Location = New-Object System.Drawing.Point(15, 80)
    $EasyButton.Size = New-Object System.Drawing.Size(80,20)
    $EasyButton.Add_Click({($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (New-GameBoard 10 10 10 'Easy')})
    $NewGameForm.Controls.Add($EasyButton)

    $MediumButton = New-Object System.Windows.Forms.Button
    $MediumButton.Text = "Medium"
    $MediumButton.Location = New-Object System.Drawing.Point(110, 80)
    $MediumButton.Size = New-Object System.Drawing.Size(80,20)
    $MediumButton.Add_Click({($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (New-GameBoard 20 20 40 'Medium')})
    $NewGameForm.Controls.Add($MediumButton)

    $HardButton = New-Object System.Windows.Forms.Button
    $HardButton.Text = "Hard"
    $HardButton.Location = New-Object System.Drawing.Point(205, 80)
    $HardButton.Size = New-Object System.Drawing.Size(80,20)
    $HardButton.Add_Click({($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (New-GameBoard 30 30 100 'Hard')})
    $NewGameForm.Controls.Add($HardButton)

    $ExtremeButton = New-Object System.Windows.Forms.Button
    $ExtremeButton.Text = "Extreme!"
    $ExtremeButton.Location = New-Object System.Drawing.Point(60, 115)
    $ExtremeButton.Size = New-Object System.Drawing.Size(80,20)
    $ExtremeButton.Add_Click({($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (New-GameBoard 40 40 200 'Extreme')})
    $NewGameForm.Controls.Add($ExtremeButton)

    $CustomButton = New-Object System.Windows.Forms.Button
    $CustomButton.Text = "Custom.."
    $CustomButton.Location = New-Object System.Drawing.Point(160, 115)
    $CustomButton.Size = New-Object System.Drawing.Size(80,20)
    $CustomButton.Add_Click({New-CustomBoard})
    $NewGameForm.Controls.Add($CustomButton)

    $ScoreButton = New-Object System.Windows.Forms.Button
    $ScoreButton.Text = "High Scores"
    $ScoreButton.Location = New-Object System.Drawing.Point(110, 150)
    $ScoreButton.Size = New-Object System.Drawing.Size(80,20)
    $ScoreButton.Add_Click({Get-HighScores})
    $NewGameForm.Controls.Add($ScoreButton)
        
    $NewGameForm.ShowDialog() | Out-Null
    }

# custom board generation window
function New-CustomBoard(){
    $CustomGameForm = New-Object System.Windows.Forms.Form
    $CustomGameForm.Text = "Custom Game"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 185
    $System_Drawing_Size.Width = 300
    $CustomGameForm.FormBorderStyle = 'Fixed3D'
    $CustomGameForm.MaximizeBox = $false
    $CustomGameForm.ClientSize = $System_Drawing_Size
    $CustomGameForm.StartPosition = 'CenterScreen'
    $CustomGameForm.TopMost = $true
    $CustomGameForm.add_Closing({$CustomGameForm.Dispose()})

    $CustomRowLabel = New-Object System.Windows.Forms.Label
    $CustomRowLabel.Location = New-Object System.Drawing.Point(40,60)
    $CustomRowLabel.Text = 'Height' 
    $CustomRowLabel.Autosize = $true
    $CustomGameForm.Controls.Add($CustomRowLabel)

    $CustomRowTextBox = New-Object System.Windows.Forms.TextBox
    $CustomRowTextBox.Location = New-Object System.Drawing.Point(40,80)
    $CustomRowTextBox.Size = New-Object System.Drawing.Size(60,20)
    $CustomGameForm.Controls.Add($CustomRowTextBox)

    $CustomColumnLabel = New-Object System.Windows.Forms.Label
    $CustomColumnLabel.Location = New-Object System.Drawing.Point(120,60)
    $CustomColumnLabel.Text = 'Width' 
    $CustomColumnLabel.Autosize = $true
    $CustomGameForm.Controls.Add($CustomColumnLabel)

    $CustomColumnTextBox = New-Object System.Windows.Forms.TextBox
    $CustomColumnTextBox.Location = New-Object System.Drawing.Point(120,80)
    $CustomColumnTextBox.Size = New-Object System.Drawing.Size(60,20)
    $CustomGameForm.Controls.Add($CustomColumnTextBox)

    $CustomAmountLabel = New-Object System.Windows.Forms.Label
    $CustomAmountLabel.Location = New-Object System.Drawing.Point(200,60)
    $CustomAmountLabel.Text = 'Mines' 
    $CustomAmountLabel.Autosize = $true
    $CustomGameForm.Controls.Add($CustomAmountLabel)

    $CustomAmountTextBox = New-Object System.Windows.Forms.TextBox
    $CustomAmountTextBox.Location = New-Object System.Drawing.Point(200,80)
    $CustomAmountTextBox.Size = New-Object System.Drawing.Size(60,20)
    $CustomGameForm.Controls.Add($CustomAmountTextBox)

    $GenerateCustomButton = New-Object System.Windows.Forms.Button
    $GenerateCustomButton.Text = "Generate.."
    $GenerateCustomButton.Location = New-Object System.Drawing.Point(60, 150)
    $GenerateCustomButton.Size = New-Object System.Drawing.Size(80,20)
    $GenerateCustomButton.Add_Click({
        if($CustomColumnTextBox.Text -ne ""-and 
            $CustomRowTextBox.Text -ne "" -and
            $CustomAmountTextBox.Text -ne "" -and
            $CustomColumnTextBox.Text -match "^\d+$" -and # regex for digit, i think?
            $CustomRowTextBox.Text -match "^\d+$" -and # regex for digit, i think?
            $CustomAmountTextBox.Text -match "^\d+$" -and # regex for digit, i think?
            [int]$CustomColumnTextBox.Text -gt 9 -and [int]$CustomColumnTextBox.Text -lt 76 -and
            [int]$CustomRowTextBox.Text -gt 0 -and [int]$CustomRowTextBox.Text -lt 41 -and
            [int]$CustomAmountTextBox.Text -gt 0
            ){
                if(([int]$CustomColumnTextBox.Text * [int]$CustomRowTextBox.Text) -gt [int]$CustomAmountTextBox.Text){
                    ($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (New-GameBoard $CustomColumnTextBox.Text $CustomRowTextBox.Text $CustomAmountTextBox.Text 'Custom')
                }else{
                    [System.Windows.Forms.MessageBox]::Show(('Mine amount must be less than total button amount.'), $TopMessage)
                }
        }else{
            [System.Windows.Forms.MessageBox]::Show((
                '
        Height must be between 1 - 40

        Width must be between 10 - 75
        
        Mines must be at least 1
                '
                ), $TopMessage)
        }
    })
    $CustomGameForm.Controls.Add($GenerateCustomButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Text = "Cancel"
    $CancelButton.Location = New-Object System.Drawing.Point(160, 150)
    $CancelButton.Size = New-Object System.Drawing.Size(80,20)
    $CancelButton.Add_Click({$CustomGameForm.Dispose()})
    $CustomGameForm.Controls.Add($CancelButton)

    $CustomGameForm.ShowDialog() | Out-Null
}

## generate game window
function New-GameBoard($XSize, $YSize, $Script:MineAmount, $GameMode) {

    try{$GameForm.Dispose(), $timer.Stop()}catch{}

    $CurrentScores = Import-Csv -Path '.\scores.csv'
    $CurrentScores | ForEach-Object {$_.Score = [int]$_.Score}

    $Script:Playing = $false
    $Script:Started = $false
    $Script:FirstClear = $true
    $PlayedSec = 0
    
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.add_tick({($Script:PlayedSec = ($Script:PlayedSec + 1)),$TimerListBox.Items.Clear(), $TimerListBox.Items.Add($Script:PlayedSec)})

    $GameForm = New-Object System.Windows.Forms.Form
    $GameForm.Text = "Buttonsweeper"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 40 + (20 * $YSize)
    $System_Drawing_Size.Width = 20 + (20 * $XSize)
    $GameForm.FormBorderStyle = 'Fixed3D'
    $GameForm.MaximizeBox = $false
    $GameForm.ClientSize = $System_Drawing_Size
    $GameForm.StartPosition = 'CenterScreen'
    $GameForm.TopMost = $true
    $GameForm.add_Closing({$timer.Stop(), $GameForm.Dispose()})

    $NewGameButton = New-Object System.Windows.Forms.Button
    $NewGameButton.Text = "ʘ‿ʘ" # ʘ‿ʘ # = ) # the more complicated face requires UTF-8 with BOM
    $NewGameButton.Location = New-Object System.Drawing.Point(((10 * $XSize)-20), 4)
    $NewGameButton.Size = New-Object System.Drawing.Size(60,24)
    $NewGameButton.Add_Click({New-Game})
    $GameForm.Controls.Add($NewGameButton)
    
    $TimerListBox = New-Object System.Windows.Forms.ListBox
    $TimerListBox.Location = New-Object System.Drawing.Point(((20 * $XSize)-25),8)
    $TimerListBox.Size = New-Object System.Drawing.Size(34,10)
    $TimerListBox.Height = 20
    $GameForm.Controls.Add($TimerListBox)
    $TimerListBox.Items.Add($PlayedSec)

    $TimerLabel = New-Object System.Windows.Forms.Label
    $TimerLabel.Name = ('TimerLabel')
    $TimerLabel.Text = '⏰' 
    $TimerLabel.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)
    $TimerLabel.Location = New-Object System.Drawing.Point(((20 * $XSize)-45),9)
    $TimerLabel.Autosize = $true
    $GameForm.Controls.Add($TimerLabel)

    $RemainderListBox = New-Object System.Windows.Forms.ListBox
    $RemainderListBox.Location = New-Object System.Drawing.Point(11, 8)
    $RemainderListBox.Size = New-Object System.Drawing.Size(34, 10)
    $RemainderListBox.Height = 20
    $GameForm.Controls.Add($RemainderListBox)

    $RemainderLabel = New-Object System.Windows.Forms.Label
    $RemainderLabel.Name = ('TimerLabel')
    $RemainderLabel.Text = '@' 
    $RemainderLabel.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Regular)
    $RemainderLabel.Location = New-Object System.Drawing.Point((46),7)
    $RemainderLabel.Autosize = $true
    $GameForm.Controls.Add($RemainderLabel)

    ## button generation
    $StartPosX = 10
    $StartPosY = 30
    $StartPos = ($StartPosX, $StartPosY)
    $BoxAmount = 1..$XSize #10 * $Size
    $RowAmount = 1..$YSize #10 * $Size
    $Count = 1

    $RemainderListBox.Items.Add($Script:MineAmount)
    
    $Buttons = @() # an array of all buttons
    $MineButtons = @() # an array of just buttons containing mines
    $NotMineButtons = @() # array of just buttons not containing mines
    $MineNeighbors = @() # array of buttons neighboring mines, for processing what to clear

    foreach($Row in $RowAmount){
        foreach($Box in $BoxAmount){
            $GridButton = New-Object System.Windows.Forms.Button
            $GridButton.Name = $Count
            $GridButton.Location = New-Object System.Drawing.Point($StartPos)
            $GridButton.Size = New-Object System.Drawing.Size(20, 20)
            $GridButton.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
            $GridButton.Text = (" ")
            $GridButton.Add_MouseUP({
                if($_.Button -eq [System.Windows.Forms.MouseButtons]::Right -and $Script:Playing -eq $true){
                    if($this.BackColor -ne "Red"){
                        if($this.text -eq " "){                
                            $this.ForeColor = "Red"
                            $this.text = "!"
                            $Script:MineAmount = $Script:MineAmount - 1
                            $RemainderListBox.Items.Clear()
                            $RemainderListBox.Items.Add($Script:MineAmount)
                            }
                        elseif($this.text -eq "!"){
                            $this.ForeColor = "Blue"
                            $this.text = "?"
                            $Script:MineAmount = $Script:MineAmount + 1
                            $RemainderListBox.Items.Clear()
                            $RemainderListBox.Items.Add($Script:MineAmount)
                            }
                        elseif($this.text -eq "?"){
                            $this.ForeColor = "Control"
                            $this.text = " "
                            }
                        }
                    }
                })
            $GridButton.Add_Click({
                Use-Button($this)
                })
            $GameForm.Controls.Add($GridButton)
            $StartPosX = $StartPosX + 20
            $StartPos = ($StartPosX,$StartPosY)
            $Count = $Count + 1
            $Buttons = $Buttons + ($GridButton)
            }
        $StartPosX = 10
        $StartPosY = $StartPosY + 20
        $StartPos = ($StartPosX,$StartPosY)
        }
    
    $MineButtons = $Buttons | Get-Random -Count ($Script:MineAmount) # gets $MineAmount of buttons and makes them minebuttons

    ## debug # color each mine button pink
    #foreach($Button in $MineButtons){$Button.BackColor = 'pink'}

    ## mine counter text / label generation
    foreach($Button in $Buttons){

        $SurroundingMineCount = 0
        
        $SurroundingMines = @()
            
        foreach($CheckButton in $MineButtons){
            if(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y + 20))){$SurroundingMines += $CheckButton}
            if(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y - 20))){$SurroundingMines += $CheckButton}
            if(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingMines += $CheckButton}
            if(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingMines += $CheckButton}
            if(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y -20))){$SurroundingMines += $CheckButton}
            if(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y -20))){$SurroundingMines += $CheckButton}
            if(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y +20))){$SurroundingMines += $CheckButton}
            if(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y +20))){$SurroundingMines += $CheckButton}
        }

        foreach($Mine in $SurroundingMines){
            $SurroundingMineCount = $SurroundingMineCount + 1
            }

        if($MineButtons -notcontains $Button){
            $NotMineButtons = $NotMineButtons + $Button
            }

        if($SurroundingMineCount -ne 0){
            $ThisLabel = New-Object System.Windows.Forms.Label
            $ThisLabel.Name = ($Button.Name + 'Label')
            $ThisLabel.Text = $SurroundingMineCount
            $ThisLabel.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
            $ThisLabel.Location = New-Object System.Drawing.Point(($Button.Location.X  + 4), ($Button.Location.Y + 2))
            $ThisLabel.Autosize = $true
            switch($SurroundingMineCount){
                (1){$ThisLabel.ForeColor = 'blue'}
                (2){$ThisLabel.ForeColor = 'green'}
                (3){$ThisLabel.ForeColor = 'red'}
                (4){$ThisLabel.ForeColor = 'darkblue'}
                (5){$ThisLabel.ForeColor = 'maroon'}
                (6){$ThisLabel.ForeColor = 'darkcyan'}
                (7){$ThisLabel.ForeColor = 'black'}
                (8){$ThisLabel.ForeColor = 'darkgray'}
                }
                 
            $MineNeighbors = $MineNeighbors + $Button           
            
            $GameForm.Controls.Add($ThisLabel)
            }
        }
    $GameForm.ShowDialog()| Out-Null
    }

## what happens when you press a button
function Use-Button($ButtonObject) {

    if($Script:Playing -eq $false -and $Script:Started -eq $false){
        $Script:Playing = $true
        $Script:Started = $true
        $timer.Start()
        }

    if($Script:Playing -eq $true){
        if($ButtonObject.Text -ne '!'){
            
            ## debug # show button clicked, and coordinates of mines
            #Write-Host 'Button clicked: ' $ButtonObject.Name, $ButtonObject.Location
            #Write-Host 'Mine locations: '
            #foreach($Mine in $MineButtons){Write-Host $Mine.Name $Mine.Location}

            if($MineButtons -contains $ButtonObject){
                $Script:Playing = $false
                $timer.stop()
                $ButtonObject.BackColor = "Red"
                $NewGameButton.Text = "ಠ_ಠ" # ಠ_ಠ # = ( # more complicated face requires UTF-8 with BOM
                foreach($MineButton in $MineButtons){
                    $MineButton.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 7, [System.Drawing.FontStyle]::Bold)
                    $MineButton.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
                    $MineButton.ForeColor = "Black"
                    $MineButton.Text = "@"
                    }
            }else{
                $ButtonObject.Visible = $false
                if($MineNeighbors -notcontains $ButtonObject){    
                    Find-Surrounding($ButtonObject)
                }
                Test-IfWon 
                }
            }
        }
    }

function Find-FirstSurrounding($ButtonObj){

    $ButtonsToCheck = New-Object -TypeName 'System.Collections.ArrayList'
    
    $ButtonsToCheck.Add($ButtonObj)

    while($ButtonsToCheck.Count -gt 0){

        $RemoveQueue = @()
        $AddQueue = @()

        foreach($Button in $ButtonsToCheck){
            
            $SurroundingButtons = @()
            
            foreach($CheckButton in $Buttons){
                if(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y + 20))){$SurroundingButtons += $CheckButton}
                elseif(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y - 20))){$SurroundingButtons += $CheckButton}
                elseif(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingButtons += $CheckButton}
                elseif(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingButtons += $CheckButton}
            }
            foreach($SurButton in $SurroundingButtons){
                if($MineButtons -notcontains $SurButton -and $SurButton.Visible -eq $true -and $SurButton.Text -ne '!' -and $SurButton.Text -ne '?'){
                    $SurButton.Visible = $false
                    if($MineNeighbors -notcontains $SurButton){
                        $AddQueue = $AddQueue + $SurButton # queue of buttons to be ADDED to ButtonsToCheck                   
                        }
                    }
                }
            $RemoveQueue = $RemoveQueue + $Button # queue of buttons to be REMOVED from ButtonsToCheck
            }
        foreach($Button in $RemoveQueue){
            $ButtonsToCheck.Remove($Button)
            }
        foreach($Button in $AddQueue){
            $ButtonsToCheck.Add($Button)
            }
        }
    }


## coordinate surrounding buttons
function Find-Surrounding($ButtonObj){

    $ButtonsToCheck = New-Object -TypeName 'System.Collections.ArrayList'
    
    $ButtonsToCheck.Add($ButtonObj)

    while($ButtonsToCheck.Count -gt 0){

        $RemoveQueue = @()
        $AddQueue = @()

        foreach($Button in $ButtonsToCheck){
            
            $SurroundingButtons = @()

            if($Script:FirstClear -eq $True){
                foreach($CheckButton in $Buttons){
                    if(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y + 20))){
                        $SurroundingButtons += $CheckButton
                    }
                    elseif(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y - 20))){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingButtons += $CheckButton}
                }
                $Script:FirstClear = $false
            }else{
                foreach($CheckButton in $Buttons){
                    if(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y + 20))){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq $Button.Location.X) -and ($CheckButton.Location.Y -eq ($Button.Location.Y - 20))){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq $Button.Location.Y)){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y -20))){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y -20))){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X - 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y +20))){$SurroundingButtons += $CheckButton}
                    elseif(($CheckButton.Location.X -eq ($Button.Location.X + 20)) -and ($CheckButton.Location.Y -eq ($Button.Location.Y +20))){$SurroundingButtons += $CheckButton}
                }
            }
            foreach($SurButton in $SurroundingButtons){
                if($MineButtons -notcontains $SurButton -and $SurButton.Visible -eq $true -and $SurButton.Text -ne '!' -and $SurButton.Text -ne '?'){
                    $SurButton.Visible = $false
                    if($MineNeighbors -notcontains $SurButton){
                        $AddQueue = $AddQueue + $SurButton # queue of buttons to be ADDED to ButtonsToCheck                   
                        }
                    }
                }
            $RemoveQueue = $RemoveQueue + $Button # queue of buttons to be REMOVED from ButtonsToCheck
            }
        foreach($Button in $RemoveQueue){
            $ButtonsToCheck.Remove($Button)
            }
        foreach($Button in $AddQueue){
            $ButtonsToCheck.Add($Button)
            }
        }
    }

## calculate remaining visible buttons that are not mines, if game won show complete screen
function Test-IfWon{

    $VisibleButtons = $NotMineButtons | Where-Object {$_.Visible -eq $true}
    
    if($VisibleButtons.Count -eq 0){
        $timer.Stop()
        $Script:Playing = $false
        $TopMessage = ""
        $TopScore = $false
        $NewGameButton.Text = "(╯°□°）╯" # (╯°□°）╯ # = D # more complicated face requires UTF-8 with BOM
        
        ## checks for high score
        $PlayerScore = $TimerListBox.Items
        if($GameMode -ne 'Custom'){
            $ModeScores = $CurrentScores | Where-Object {$_.Mode -eq $GameMode} | Sort-Object Score | Select-Object -First 11
            foreach($Score in $ModeScores){
                if($PlayerScore -lt $Score.Score -or $ModeScores.Count -lt 11){
                    $TopMessage = "HIGH SCORE!"
                    $Today = (Get-Date).ToString('MM/dd/yy')
                    $TopScore = $true
                }
            }
        }
        if($TopScore -eq $true){
            "$env:USERNAME, $PlayerScore, $Today, $GameMode" | Out-File '.\scores.csv' -Append
        }
        [System.Windows.Forms.MessageBox]::Show(('     YOU WON!!!     You beat ') + $GameMode  + (' mode in ') + $TimerListBox.Items + (' seconds.'), $TopMessage)
        if($TopScore -eq $true){Get-HighScores}
        }
    }

## handle high score info
$CurrentScores = Get-ChildItem -Path '.\scores.csv'  -ErrorAction SilentlyContinue

if($null -eq $CurrentScores){
    'Name,Score,Date,Mode' | Out-File '.\scores.csv'
    '0,0,0,Easy','0,0,0,Medium','0,0,0,Hard','0,0,0,Extreme' | Out-File '.\scores.csv' -Append
}else{
    ## append Extreme mode score placeholder, if it's not present 
    $ScoresCheck = Import-Csv $CurrentScores
    $UpdatedScores = $false
    foreach($Score in $ScoresCheck){
        if($Score -like '*Extreme*'){
            $UpdatedScores = $true
        }
    }
    if($UpdatedScores -ne $true){
        '0,0,0,Extreme' | Out-File '.\scores.csv' -Append
    }
    ##
}

## generates the high score window
function Get-HighScores {

    $HighScoresForm = New-Object System.Windows.Forms.Form
    $HighScoresForm.Text = "High Scores"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 740
    $System_Drawing_Size.Width = 340
    $HighScoresForm.FormBorderStyle = 'Fixed3D'
    $HighScoresForm.MaximizeBox = $false
    $HighScoresForm.ClientSize = $System_Drawing_Size
    $HighScoresForm.StartPosition = 'CenterScreen'
    $HighScoresForm.TopMost = $true
    $HighScoresForm.add_Closing({$HighScoresForm.Dispose()})

    $EasyLabel = New-Object System.Windows.Forms.Label
    $EasyLabel.Text = 'Easy'
    $EasyLabel.Location = New-Object System.Drawing.Point(10,17)
    $EasyLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Italic)
    $EasyLabel.Autosize = $true
    $HighScoresForm.Controls.Add($EasyLabel)
    
    $NameListBoxEasy = New-Object System.Windows.Forms.ListBox
    $NameListBoxEasy.Location = New-Object System.Drawing.Point(10,40)
    $NameListBoxEasy.Size = New-Object System.Drawing.Size(100,20)
    $NameListBoxEasy.Height = 140
    $HighScoresForm.Controls.Add($NameListBoxEasy)
    
    $ScoreListBoxEasy = New-Object System.Windows.Forms.ListBox
    $ScoreListBoxEasy.Location = New-Object System.Drawing.Point(120,40)
    $ScoreListBoxEasy.Size = New-Object System.Drawing.Size(100,20)
    $ScoreListBoxEasy.Height = 140
    $HighScoresForm.Controls.Add($ScoreListBoxEasy)
    
    $DateListBoxEasy = New-Object System.Windows.Forms.ListBox
    $DateListBoxEasy.Location = New-Object System.Drawing.Point(230,40)
    $DateListBoxEasy.Size = New-Object System.Drawing.Size(100,20)
    $DateListBoxEasy.Height = 140
    $HighScoresForm.Controls.Add($DateListBoxEasy)

    $MediumLabel = New-Object System.Windows.Forms.Label
    $MediumLabel.Text = 'Medium'
    $MediumLabel.Location = New-Object System.Drawing.Point(10,187)
    $MediumLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Italic)
    $MediumLabel.Autosize = $true
    $HighScoresForm.Controls.Add($MediumLabel)

    $NameListBoxMedium = New-Object System.Windows.Forms.ListBox
    $NameListBoxMedium.Location = New-Object System.Drawing.Point(10,210)
    $NameListBoxMedium.Size = New-Object System.Drawing.Size(100,20)
    $NameListBoxMedium.Height = 140
    $HighScoresForm.Controls.Add($NameListBoxMedium)

    $ScoreListBoxMedium = New-Object System.Windows.Forms.ListBox
    $ScoreListBoxMedium.Location = New-Object System.Drawing.Point(120,210)
    $ScoreListBoxMedium.Size = New-Object System.Drawing.Size(100,20)
    $ScoreListBoxMedium.Height = 140
    $HighScoresForm.Controls.Add($ScoreListBoxMedium)
    
    $DateListBoxMedium = New-Object System.Windows.Forms.ListBox
    $DateListBoxMedium.Location = New-Object System.Drawing.Point(230,210)
    $DateListBoxMedium.Size = New-Object System.Drawing.Size(100,20)
    $DateListBoxMedium.Height = 140
    $HighScoresForm.Controls.Add($DateListBoxMedium)

    $HardLabel = New-Object System.Windows.Forms.Label
    $HardLabel.Text = 'Hard'
    $HardLabel.Location = New-Object System.Drawing.Point(10,357)
    $HardLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Italic)
    $HardLabel.Autosize = $true
    $HighScoresForm.Controls.Add($HardLabel)

    $NameListBoxHard = New-Object System.Windows.Forms.ListBox
    $NameListBoxHard.Location = New-Object System.Drawing.Point(10,380)
    $NameListBoxHard.Size = New-Object System.Drawing.Size(100,20)
    $NameListBoxHard.Height = 140
    $HighScoresForm.Controls.Add($NameListBoxHard)

    $ScoreListBoxHard = New-Object System.Windows.Forms.ListBox
    $ScoreListBoxHard.Location = New-Object System.Drawing.Point(120,380)
    $ScoreListBoxHard.Size = New-Object System.Drawing.Size(100,20)
    $ScoreListBoxHard.Height = 140
    $HighScoresForm.Controls.Add($ScoreListBoxHard)
    
    $DateListBoxHard = New-Object System.Windows.Forms.ListBox
    $DateListBoxHard.Location = New-Object System.Drawing.Point(230,380)
    $DateListBoxHard.Size = New-Object System.Drawing.Size(100,20)
    $DateListBoxHard.Height = 140
    $HighScoresForm.Controls.Add($DateListBoxHard)

    $ExtremeLabel = New-Object System.Windows.Forms.Label
    $ExtremeLabel.Text = 'Extreme!'
    $ExtremeLabel.Location = New-Object System.Drawing.Point(10,527)
    $ExtremeLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Italic)
    $ExtremeLabel.Autosize = $true
    $HighScoresForm.Controls.Add($ExtremeLabel)

    $NameListBoxExtreme = New-Object System.Windows.Forms.ListBox
    $NameListBoxExtreme.Location = New-Object System.Drawing.Point(10,550)
    $NameListBoxExtreme.Size = New-Object System.Drawing.Size(100,20)
    $NameListBoxExtreme.Height = 140
    $HighScoresForm.Controls.Add($NameListBoxExtreme)

    $ScoreListBoxExtreme = New-Object System.Windows.Forms.ListBox
    $ScoreListBoxExtreme.Location = New-Object System.Drawing.Point(120,550)
    $ScoreListBoxExtreme.Size = New-Object System.Drawing.Size(100,20)
    $ScoreListBoxExtreme.Height = 140
    $HighScoresForm.Controls.Add($ScoreListBoxExtreme)
    
    $DateListBoxExtreme = New-Object System.Windows.Forms.ListBox
    $DateListBoxExtreme.Location = New-Object System.Drawing.Point(230,550)
    $DateListBoxExtreme.Size = New-Object System.Drawing.Size(100,20)
    $DateListBoxExtreme.Height = 140
    $HighScoresForm.Controls.Add($DateListBoxExtreme)

    $CloseButton = New-Object System.Windows.Forms.Button
    $CloseButton.Text = "Close"
    $CloseButton.Location = New-Object System.Drawing.Point(130, 700)
    $CloseButton.Size = New-Object System.Drawing.Size(80,20)
    $CloseButton.Add_Click({$HighScoresForm.Dispose()})
    $HighScoresForm.Controls.Add($CloseButton)

    $CurrentScores = Import-Csv -Path '.\scores.csv'
    $CurrentScores | ForEach-Object {$_.Score = [int]$_.Score}

    $EasyScores = @()
    $EasyScores = $EasyScores + ($CurrentScores | Where-Object {$_.Mode -eq 'Easy'} | Sort-Object Score | Select-Object -First 11)
    foreach($Score in $EasyScores){
        if($Score.Score -ne 0){
            $NameListBoxEasy.Items.Add($Score.Name), $ScoreListBoxEasy.Items.Add($Score.Score), $DateListBoxEasy.Items.Add($Score.Date)
        }
    }
    $MediumScores = @()
    $MediumScores = $MediumScores + ($CurrentScores | Where-Object {$_.Mode -eq 'Medium'} | Sort-Object Score | Select-Object -First 11)
    foreach($Score in $MediumScores){
        if($Score.Score -ne 0){
            $NameListBoxMedium.Items.Add($Score.Name), $ScoreListBoxMedium.Items.Add($Score.Score), $DateListBoxMedium.Items.Add($Score.Date)
        }
    }
    $HardScores = @()
    $HardScores = $HardScores + ($CurrentScores | Where-Object {$_.Mode -eq 'Hard'} | Sort-Object Score | Select-Object -First 11)
    foreach($Score in $HardScores){
        if($Score.Score -ne 0){
            $NameListBoxHard.Items.Add($Score.Name), $ScoreListBoxHard.Items.Add($Score.Score), $DateListBoxHard.Items.Add($Score.Date)
        }
    }
    $ExtremeScores = @()
    $ExtremeScores = $ExtremeScores + ($CurrentScores | Where-Object {$_.Mode -eq 'Extreme'} | Sort-Object Score | Select-Object -First 11)
    foreach($Score in $ExtremeScores){
        if($Score.Score -ne 0){
            $NameListBoxExtreme.Items.Add($Score.Name), $ScoreListBoxExtreme.Items.Add($Score.Score), $DateListBoxExtreme.Items.Add($Score.Date)
        }
    }
    $HighScoresForm.ShowDialog() | Out-Null
}

## start the game
New-Game