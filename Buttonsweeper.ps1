Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.drawing


function New-Game {

    $Multiplier = 1
    $NewGameForm = New-Object System.Windows.Forms.Form
    $NewGameForm.Text = "New Game"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 150
    $System_Drawing_Size.Width = 300
    $NewGameForm.FormBorderStyle = 'Fixed3D'
    $NewGameForm.MaximizeBox = $false
    $NewGameForm.ClientSize = $System_Drawing_Size
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
    $EasyButton.Add_Click({($Multiplier = $Multiplier * 0.5), ($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (Generate-Game($Multiplier))})
    $NewGameForm.Controls.Add($EasyButton)

    $MediumButton = New-Object System.Windows.Forms.Button
    $MediumButton.Text = "Medium"
    $MediumButton.Location = New-Object System.Drawing.Point(110, 80)
    $MediumButton.Size = New-Object System.Drawing.Size(80,20)
    $MediumButton.Add_Click({($Multiplier = $Multiplier * 1), ($Script:PlayedSec = 0), ($NewGameForm.Dispose()), (Generate-Game($Multiplier))})
    $NewGameForm.Controls.Add($MediumButton)

    $HardButton = New-Object System.Windows.Forms.Button
    $HardButton.Text = "Hard"
    $HardButton.Location = New-Object System.Drawing.Point(205, 80)
    $HardButton.Size = New-Object System.Drawing.Size(80,20)
    $HardButton.Add_Click({($Multiplier = $Multiplier * 1.5), ($Script:PlayedSec = 0),($NewGameForm.Dispose()), (Generate-Game($Multiplier))})
    $NewGameForm.Controls.Add($HardButton)

    $ScoreButton = New-Object System.Windows.Forms.Button
    $ScoreButton.Text = "High Scores"
    $ScoreButton.Location = New-Object System.Drawing.Point(110, 115)
    $ScoreButton.Size = New-Object System.Drawing.Size(80,20)
    $ScoreButton.Add_Click({})
    $NewGameForm.Controls.Add($ScoreButton)

    $NewGameForm.ShowDialog() | Out-Null

    }


function Generate-Game($Size) {

    try{$GameForm.Dispose(), $timer.Stop()}catch{}

    $Script:Playing = $false
    $Script:Started = $false
    $Script:PlayedSec = 0

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.add_tick({($Script:PlayedSec = ($Script:PlayedSec + 1)),$TimerListBox.Items.Clear(), $TimerListBox.Items.Add($Script:PlayedSec)})

    $GameForm = New-Object System.Windows.Forms.Form
    $GameForm.Text = "Buttonsweeper"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 40 + (400 * $Size)
    $System_Drawing_Size.Width = 20 + (400 * $Size)
    $GameForm.FormBorderStyle = 'Fixed3D'
    $GameForm.MaximizeBox = $false
    $GameForm.ClientSize = $System_Drawing_Size
    $GameForm.add_Closing({$timer.Stop(), $GameForm.Dispose()})

    $NewGameButton = New-Object System.Windows.Forms.Button
    $NewGameButton.Text = "ʘ‿ʘ"
    $NewGameButton.Location = New-Object System.Drawing.Point(((200 * $Size)-15), 6)
    $NewGameButton.Size = New-Object System.Drawing.Size(50,22)
    $NewGameButton.Add_Click({New-Game})
    $GameForm.Controls.Add($NewGameButton)
    
    $TimerListBox = New-Object System.Windows.Forms.ListBox
    $TimerListBox.Location = New-Object System.Drawing.Point(((15+ (400 * $Size))-40),8)
    $TimerListBox.Size = New-Object System.Drawing.Size(34,10)
    $TimerListBox.Height = 20
    $GameForm.Controls.Add($TimerListBox)
    $TimerListBox.Items.Add($PlayedSec)

    $RemainderListBox = New-Object System.Windows.Forms.ListBox
    $RemainderListBox.Location = New-Object System.Drawing.Point(10, 8)
    $RemainderListBox.Size = New-Object System.Drawing.Size(34, 10)
    $RemainderListBox.Height = 20
    $GameForm.Controls.Add($RemainderListBox)

    # button generation

    $StartPosX = 10
    $StartPosY = 30
    $StartPos = ($StartPosX, $StartPosY)
    $BoxAmount = 1..(20 * $Size)
    $RowAmount = 1..(20 * $Size)
    $Count = 1
    
    switch($Size){
        "0.5" {$Script:MineAmount = 10}
        "1" {$Script:MineAmount = 40}
        "1.5" {$Script:MineAmount = 99}
        }

    $RemainderListBox.Items.Add($Script:MineAmount)
    
    $Buttons = @()
    $MineButtons = @()   

    foreach($Row in $RowAmount){
        foreach($Box in $BoxAmount){
            $GridButton = New-Object System.Windows.Forms.Button
            $GridButton.Name = $Count
            $GridButton.Location = New-Object System.Drawing.Point($StartPos)
            $GridButton.Size = New-Object System.Drawing.Size(20, 20)
            $GridButton.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
            $GridButton.Text = (" ")
            $GridButton.Add_MouseUP({
                if($_.Button -eq [System.Windows.Forms.MouseButtons]::Right ){
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
                Process-Button($this)
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
    $MineButtons = $Buttons | Get-Random -Count ($MineAmount)

    # surrounding-mine counter generation

    foreach($Button in $Buttons){
        $Script:SurroundingMines = 0
        foreach($MineButton in $MineButtons){
            
            if(($Button.Location.X -eq $MineButton.Location.X) -and ($Button.Location.Y -eq ($MineButton.Location.Y + 20))){ # mine below
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            if(($Button.Location.X -eq ($MineButton.Location.X - 20)) -and ($Button.Location.Y -eq ($MineButton.Location.Y + 20))){ # mine below left
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            if(($Button.Location.X -eq ($MineButton.Location.X + 20)) -and ($Button.Location.Y -eq ($MineButton.Location.Y + 20))){ # mine below right
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            if(($Button.Location.X -eq $MineButton.Location.X) -and ($Button.Location.Y -eq ($MineButton.Location.Y - 20))){ # mine above
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            if(($Button.Location.X -eq ($MineButton.Location.X - 20)) -and ($Button.Location.Y -eq ($MineButton.Location.Y - 20))){ # mine above left
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            if(($Button.Location.X -eq ($MineButton.Location.X + 20)) -and ($Button.Location.Y -eq ($MineButton.Location.Y - 20))){ # mine above right
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            if(($Button.Location.X -eq ($MineButton.Location.X +20)) -and ($Button.Location.Y -eq $MineButton.Location.Y)){ # mine to the right
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            if(($Button.Location.X -eq ($MineButton.Location.X -20)) -and ($Button.Location.Y -eq $MineButton.Location.Y)){ # mine to the left
                $Script:SurroundingMines = $Script:SurroundingMines + 1
                }
            
            }
        if($Script:SurroundingMines -ne 0){
            $ThisLabel = New-Object System.Windows.Forms.Label
            $ThisLabel.Name = ($Button.Name + 'Label')
            $ThisLabel.Text = $SurroundingMines
            $ThisLabel.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
            $ThisLabel.Location = New-Object System.Drawing.Point(($Button.Location.X  + 4), ($Button.Location.Y + 2))
            $ThisLabel.Autosize = $true
            $GameForm.Controls.Add($ThisLabel)
            $Script:SurroundingMines = 0
            }
        }

    $GameForm.ShowDialog()| Out-Null
    }


function Process-Button($ButtonObject) {
    if($Script:Playing -eq $false -and $Script:Started -eq $false){
        $Script:Playing = $true
        $Script:Started = $true
        $timer.Start()
        if(!($MineButtons -contains $ButtonObject)){
            Opening-Clear($ButtonObject)
            }
        }
    if($Script:Playing -eq $true){
        if($ButtonObject.Text -ne '!'){
            
            #debug{
            #Write-Host 'Button clicked: ' $ButtonObject.Name, $ButtonObject.Location
            #Write-Host 'Mine locations: '
            #foreach($Mine in $MineButtons){Write-Host $Mine.Name $Mine.Location}
            #}

            if($MineButtons -contains $ButtonObject){
                $Script:Playing = $false
                $timer.stop()
                $ButtonObject.BackColor = "Red"
                $ButtonObject.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 7, [System.Drawing.FontStyle]::Bold)
                $ButtonObject.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
                $ButtonObject.ForeColor = "Black"
                $ButtonObject.text = "@"
                $NewGameButton.Text = "ಠ_ಠ"
                foreach($MineButton in $MineButtons){
                    $MineButton.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 7, [System.Drawing.FontStyle]::Bold)
                    $MineButton.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
                    $MineButton.ForeColor = "Black"
                    $MineButton.Text = "@"
                    }
            }else{
                $ButtonObject.Visible = $false
                Opening-Clear($ButtonObject)
                
                # Win state?

                Check-IfWon
                                            
                }           
            }
        }
    }


function Opening-Clear($ButtonObj){

    Find-Surrounding($ButtonObj)

    # clears the surrounding buttons

    foreach($Button in $Script:SurroundingButtons){
        if(!($MineButtons -contains $Button)){
            $Button.Visible = $false
            #
            }
        }
    }


function Find-Surrounding($ButtonObj){
    
    # finds the surrounding buttons 

    $Script:SurroundingButtons = $Buttons | Where-Object {
        
        (($_.Location.X -eq $ButtonObj.Location.X) -and ($_.Location.Y -eq ($ButtonObj.Location.Y + 20))) -or # above
        (($_.Location.X -eq $ButtonObj.Location.X) -and ($_.Location.Y -eq ($ButtonObj.Location.Y - 20))) -or # below
        (($_.Location.X -eq ($ButtonObj.Location.X + 20)) -and ($_.Location.Y -eq $ButtonObj.Location.Y)) -or # left
        (($_.Location.X -eq ($ButtonObj.Location.X - 20)) -and ($_.Location.Y -eq $ButtonObj.Location.Y)) -or # right
        (($_.Location.X -eq ($ButtonObj.Location.X - 20)) -and ($_.Location.Y -eq ($ButtonObj.Location.Y -20))) -or # up left
        (($_.Location.X -eq ($ButtonObj.Location.X + 20)) -and ($_.Location.Y -eq ($ButtonObj.Location.Y -20))) -or # up right
        (($_.Location.X -eq ($ButtonObj.Location.X - 20)) -and ($_.Location.Y -eq ($ButtonObj.Location.Y +20))) -or # down left
        (($_.Location.X -eq ($ButtonObj.Location.X + 20)) -and ($_.Location.Y -eq ($ButtonObj.Location.Y +20))) # down right
        
        }
    }


function Check-IfWon{
    
#    foreach($Button in $Buttons){
#        if(($Button.Visible -eq $true) -and ($Script:MineButtons -notcontains $Button)){
#            Write-Host $Button.Name
#            }
#        }

    }


New-Game