Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.drawing

## new game window
function New-Game {

    $NewGameForm = New-Object System.Windows.Forms.Form
    $NewGameForm.Text = "New Game"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 150
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
    $WelcomeLabel.Location = New-Object System.Drawing.Point(46,30)
    $WelcomeLabel.Autosize = $true
    $NewGameForm.Controls.Add($WelcomeLabel)

    $EasyButton = New-Object System.Windows.Forms.Button
    $EasyButton.Text = "Easy"
    $EasyButton.Location = New-Object System.Drawing.Point(15, 80)
    $EasyButton.Size = New-Object System.Drawing.Size(80,20)
    $EasyButton.Add_Click({($Multiplier = 1), ($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (New-GameBoard($Multiplier))})
    $NewGameForm.Controls.Add($EasyButton)

    $MediumButton = New-Object System.Windows.Forms.Button
    $MediumButton.Text = "Medium"
    $MediumButton.Location = New-Object System.Drawing.Point(110, 80)
    $MediumButton.Size = New-Object System.Drawing.Size(80,20)
    $MediumButton.Add_Click({($Multiplier = 2), ($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (New-GameBoard($Multiplier))})
    $NewGameForm.Controls.Add($MediumButton)

    $HardButton = New-Object System.Windows.Forms.Button
    $HardButton.Text = "Hard"
    $HardButton.Location = New-Object System.Drawing.Point(205, 80)
    $HardButton.Size = New-Object System.Drawing.Size(80,20)
    $HardButton.Add_Click({($Multiplier = 3), ($Script:PlayedSec = 0),($NewGameForm.Dispose()), (New-GameBoard($Multiplier))})
    $NewGameForm.Controls.Add($HardButton)

    $ScoreButton = New-Object System.Windows.Forms.Button
    $ScoreButton.Text = "Wikipedia"
    $ScoreButton.Location = New-Object System.Drawing.Point(110, 115)
    $ScoreButton.Size = New-Object System.Drawing.Size(80,20)
    $ScoreButton.Add_Click({Start-Process 'https://en.wikipedia.org/wiki/Minesweeper_(video_game)'})
    $NewGameForm.Controls.Add($ScoreButton)

    $NewGameForm.ShowDialog() | Out-Null
    }

## generate game window
function New-GameBoard($Size) {

    try{$GameForm.Dispose(), $timer.Stop()}catch{}

    $Script:Playing = $false
    $Script:Started = $false
    $PlayedSec = 0

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.add_tick({($Script:PlayedSec = ($Script:PlayedSec + 1)),$TimerListBox.Items.Clear(), $TimerListBox.Items.Add($Script:PlayedSec)})

    $GameForm = New-Object System.Windows.Forms.Form
    $GameForm.Text = "Buttonsweeper"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 40 + (200 * $Size)
    $System_Drawing_Size.Width = 20 + (200 * $Size)
    $GameForm.FormBorderStyle = 'Fixed3D'
    $GameForm.MaximizeBox = $false
    $GameForm.ClientSize = $System_Drawing_Size
    $GameForm.StartPosition = 'CenterScreen'
    $GameForm.TopMost = $true
    $GameForm.add_Closing({$timer.Stop(), $GameForm.Dispose()})

    $NewGameButton = New-Object System.Windows.Forms.Button
    $NewGameButton.Text = "ʘ‿ʘ" # ʘ‿ʘ # = ) # the more complicated face requires UTF-8 with BOM
    $NewGameButton.Location = New-Object System.Drawing.Point(((100 * $Size)-20), 4)
    $NewGameButton.Size = New-Object System.Drawing.Size(60,24)
    $NewGameButton.Add_Click({New-Game})
    $GameForm.Controls.Add($NewGameButton)
    
    $TimerListBox = New-Object System.Windows.Forms.ListBox
    $TimerListBox.Location = New-Object System.Drawing.Point(((15+ (200 * $Size))-40),8)
    $TimerListBox.Size = New-Object System.Drawing.Size(34,10)
    $TimerListBox.Height = 20
    $GameForm.Controls.Add($TimerListBox)
    $TimerListBox.Items.Add($PlayedSec)

    $RemainderListBox = New-Object System.Windows.Forms.ListBox
    $RemainderListBox.Location = New-Object System.Drawing.Point(11, 8)
    $RemainderListBox.Size = New-Object System.Drawing.Size(34, 10)
    $RemainderListBox.Height = 20
    $GameForm.Controls.Add($RemainderListBox)

    ## button generation

    $StartPosX = 10
    $StartPosY = 30
    $StartPos = ($StartPosX, $StartPosY)
    $BoxAmount = 1..(10 * $Size)
    $RowAmount = 1..(10 * $Size)
    $Count = 1
    
    switch($Size){
        (1) {$Script:MineAmount = 10} # easy number of mines
        (2) {$Script:MineAmount = 40} # medium number of mines
        (3) {$Script:MineAmount = 99} # hard number of mines
        }

    $RemainderListBox.Items.Add($Script:MineAmount)
    
    $Buttons = @()
    $MineButtons = @()
    $NotMineButtons = @()
    $MineNeighbors = @()   

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

    ## mine counter text / label generation

    foreach($Button in $Buttons){

        $SurroundingMineCount = 0
        $SurroundingMines = $MineButtons | Where-Object {
            
            (($_.Location.X -eq $Button.Location.X) -and ($_.Location.Y -eq ($Button.Location.Y + 20))) -or # above
            (($_.Location.X -eq $Button.Location.X) -and ($_.Location.Y -eq ($Button.Location.Y - 20))) -or # below
            (($_.Location.X -eq ($Button.Location.X + 20)) -and ($_.Location.Y -eq $Button.Location.Y)) -or # left
            (($_.Location.X -eq ($Button.Location.X - 20)) -and ($_.Location.Y -eq $Button.Location.Y)) -or # right
            (($_.Location.X -eq ($Button.Location.X - 20)) -and ($_.Location.Y -eq ($Button.Location.Y -20))) -or # up left
            (($_.Location.X -eq ($Button.Location.X + 20)) -and ($_.Location.Y -eq ($Button.Location.Y -20))) -or # up right
            (($_.Location.X -eq ($Button.Location.X - 20)) -and ($_.Location.Y -eq ($Button.Location.Y +20))) -or # down left
            (($_.Location.X -eq ($Button.Location.X + 20)) -and ($_.Location.Y -eq ($Button.Location.Y +20))) # down right
            
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
            
            #### # show button clicked, and coordinates of mines
            #Write-Host 'Button clicked: ' $ButtonObject.Name, $ButtonObject.Location
            #Write-Host 'Mine locations: '
            #foreach($Mine in $MineButtons){Write-Host $Mine.Name $Mine.Location}

            if($MineButtons -contains $ButtonObject){
                $Script:Playing = $false
                $timer.stop()
                $ButtonObject.BackColor = "Red"
                $ButtonObject.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 7, [System.Drawing.FontStyle]::Bold)
                $ButtonObject.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
                $ButtonObject.ForeColor = "Black"
                $ButtonObject.text = "@"
                $NewGameButton.Text = "ಠ_ಠ" # ಠ_ಠ # = ( # more complicated face requires UTF-8 with BOM
                foreach($MineButton in $MineButtons){
                    $MineButton.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 7, [System.Drawing.FontStyle]::Bold)
                    $MineButton.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
                    $MineButton.ForeColor = "Black"
                    $MineButton.Text = "@"
                    }
            }else{
                
                $ButtonObject.Visible = $false
                    
                Find-Surrounding($ButtonObject)
                
                Test-IfWon 
                }
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
            
            $SurroundingButtons = $Buttons | Where-Object {
        
                (($_.Location.X -eq $Button.Location.X) -and ($_.Location.Y -eq ($Button.Location.Y + 20))) -or # above
                (($_.Location.X -eq $Button.Location.X) -and ($_.Location.Y -eq ($Button.Location.Y - 20))) -or # below
                (($_.Location.X -eq ($Button.Location.X + 20)) -and ($_.Location.Y -eq $Button.Location.Y)) -or # left
                (($_.Location.X -eq ($Button.Location.X - 20)) -and ($_.Location.Y -eq $Button.Location.Y)) -or # right
                (($_.Location.X -eq ($Button.Location.X - 20)) -and ($_.Location.Y -eq ($Button.Location.Y -20))) -or # up left
                (($_.Location.X -eq ($Button.Location.X + 20)) -and ($_.Location.Y -eq ($Button.Location.Y -20))) -or # up right
                (($_.Location.X -eq ($Button.Location.X - 20)) -and ($_.Location.Y -eq ($Button.Location.Y +20))) -or # down left
                (($_.Location.X -eq ($Button.Location.X + 20)) -and ($_.Location.Y -eq ($Button.Location.Y +20))) # down right
    
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
        $Script:Playing = $false
        $timer.Stop()
        switch($Size){
        (1) {$GameMode = 'Easy'} # easy number of mines
        (2) {$GameMode = 'Medium'} # medium number of mines
        (3) {$GameMode = 'Hard'} # hard number of mines
            }
        $NewGameButton.Text = "(╯°□°）╯" # (╯°□°）╯ # = D # more complicated face requires UTF-8 with BOM
        [System.Windows.Forms.MessageBox]::Show(('YOU WON!!! ... You beat ') + $GameMode  + (' mode in ') + $TimerListBox.Items + (' seconds.'))
        }
    }

## start the game
New-Game