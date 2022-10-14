Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.drawing

$WelcomeText = "
This is Buttonsweeper!
"

$PlayedSec = 0

function Process-Button($ButtonObj) {
    $ButtonObj.visible = $false
    Write-Host $ButtonObj.Location
    Write-Host $ButtonObj.Name
    Write-Host "This is a test of the Process-Button function"
    $SurroundingButtons = @($ButtonObj)
    foreach($Button in $Buttons){
        #above and below
        if((($ButtonObj.Location.X -eq $Button.Location.X) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y +20))) -or
            (($ButtonObj.Location.X -eq $Button.Location.X) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y -20)))
            ) {$SurroundingButtons = $SurroundingButtons + ($Button)}
        #left and right
        if((($ButtonObj.Location.Y -eq $Button.Location.Y) -and ($ButtonObj.Location.X -eq ($Button.Location.X +20))) -or
            (($ButtonObj.Location.Y -eq $Button.Location.Y) -and ($ButtonObj.Location.X -eq ($Button.Location.X -20)))
            ) {$SurroundingButtons = $SurroundingButtons + ($Button)}
        #right diagonals
        if((($ButtonObj.Location.X -eq ($Button.Location.X + 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y +20))) -or
            (($ButtonObj.Location.X -eq ($Button.Location.X + 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y -20)))
            ) {$SurroundingButtons = $SurroundingButtons + ($Button)}
        #left diagonals
        if((($ButtonObj.Location.X -eq ($Button.Location.X - 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y +20))) -or
            (($ButtonObj.Location.X -eq ($Button.Location.X - 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y -20)))
            ) {$SurroundingButtons = $SurroundingButtons + ($Button)}     
        foreach($Button in $SurroundingButtons){
            if(!($MineLocs -contains $Button)){
                $Button.Visible = $false
                $SurroundingMines = @()
                $MineCount = 0
                #above and below
                if((($ButtonObj.Location.X -eq $Button.Location.X) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y +20))) -or
                    (($ButtonObj.Location.X -eq $Button.Location.X) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y -20)))
                    ) {$MineCount = ($MineCount + 1)}
                #left and right
                if((($ButtonObj.Location.Y -eq $Button.Location.Y) -and ($ButtonObj.Location.X -eq ($Button.Location.X +20))) -or
                    (($ButtonObj.Location.Y -eq $Button.Location.Y) -and ($ButtonObj.Location.X -eq ($Button.Location.X -20)))
                    ) {$MineCount = ($MineCount + 1)}
                #right diagonals
                if((($ButtonObj.Location.X -eq ($Button.Location.X + 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y +20))) -or
                    (($ButtonObj.Location.X -eq ($Button.Location.X + 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y -20)))
                    ) {$MineCount = ($MineCount + 1)}
                #left diagonals
                if((($ButtonObj.Location.X -eq ($Button.Location.X - 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y +20))) -or
                    (($ButtonObj.Location.X -eq ($Button.Location.X - 20)) -and ($ButtonObj.Location.Y -eq ($Button.Location.Y -20)))
                    ) {$MineCount = ($MineCount + 1)}
                }
            }
        #Write-Host $MineCount
        }
    }

function New-Game {
    $Multiplier = 1
    #Form Parameter
    $form2 = New-Object System.Windows.Forms.Form
    $form2.Text = "New Game"
    $form2.Name = "NewGame"
    $form2.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 150
    $System_Drawing_Size.Width = 300
    $form2.FormBorderStyle = 'Fixed3D'
    $form2.MaximizeBox = $false
    $form2.ClientSize = $System_Drawing_Size

    $WelcomeLabel = New-Object System.Windows.Forms.Label
    $WelcomeLabel.Text = $WelcomeText
    $WelcomeLabel.Location = New-Object System.Drawing.Point(90,20)
    $WelcomeLabel.Autosize = $true
    $form2.Controls.Add($WelcomeLabel)

    $EasyButton = New-Object System.Windows.Forms.Button
    $EasyButton.Text = "10x10"
    $EasyButton.Location = New-Object System.Drawing.Point(15, 80)
    $EasyButton.Size = New-Object System.Drawing.Size(80,20)
    $EasyButton.Add_Click({($Multiplier = $Multiplier * 0.5), ($Script:PlayedSec = 0), ($form2.Dispose()), (Generate-Game)})
    $form2.Controls.Add($EasyButton)

    $MediumButton = New-Object System.Windows.Forms.Button
    $MediumButton.Text = "15x15"
    $MediumButton.Location = New-Object System.Drawing.Point(110, 80)
    $MediumButton.Size = New-Object System.Drawing.Size(80,20)
    $MediumButton.Add_Click({($Multiplier = $Multiplier * 1), ($Script:PlayedSec = 0), ($form2.Dispose()), (Generate-Game)})
    $form2.Controls.Add($MediumButton)

    $HardButton = New-Object System.Windows.Forms.Button
    $HardButton.Text = "30x30"
    $HardButton.Location = New-Object System.Drawing.Point(205, 80)
    $HardButton.Size = New-Object System.Drawing.Size(80,20)
    $HardButton.Add_Click({($Multiplier = $Multiplier * 1.5), ($Script:PlayedSec = 0),($form2.Dispose()), (Generate-Game)})
    $form2.Controls.Add($HardButton)

    $ScoreButton = New-Object System.Windows.Forms.Button
    $ScoreButton.Text = "High Scores"
    $ScoreButton.Location = New-Object System.Drawing.Point(110, 115)
    $ScoreButton.Size = New-Object System.Drawing.Size(80,20)
    $ScoreButton.Add_Click({})
    $form2.Controls.Add($ScoreButton)

    #Save the initial state of the form
    $InitialFormWindowState = $form2.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $form2.add_Load($OnLoadForm_StateCorrection)
    #Show the Form
    $form2.ShowDialog()| Out-Null
    }

function Generate-Game{
    try{$form1.Dispose(), $timer.stop(), $Playing = $false}catch{}    
    $Script:Playing = $true
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.add_tick({($Script:PlayedSec = ($Script:PlayedSec + 1)), $TimerListBox.Items.Clear(), $TimerListBox.Items.Add($Script:PlayedSec)}) #(Get-Date -Format "hh:mm:ss tt")

    #Form Parameter
    $form1 = New-Object System.Windows.Forms.Form
    $form1.Text = "Button Sweeper"
    $form1.Name = "form1"
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 40 + (400 * $Multiplier)
    $System_Drawing_Size.Width = 20 + (400 * $Multiplier)
    $form1.FormBorderStyle = 'Fixed3D'
    $form1.MaximizeBox = $false
    $form1.ClientSize = $System_Drawing_Size
    $form1.add_Closing({$timer.Stop()})

    #Form Parameter
#    $form2 = New-Object System.Windows.Forms.Form
#    $form2.Text = "New Game"
#    $form2.Name = "NewGame"
#    $form2.DataBindings.DefaultDataSourceUpdateMode = 0
#    $System_Drawing_Size = New-Object System.Drawing.Size
#    $System_Drawing_Size.Height = 40 + (400 * $Multiplier)
#    $System_Drawing_Size.Width = 20 + (400 * $Multiplier)
#    $form2.FormBorderStyle = 'Fixed3D'
#    $form2.MaximizeBox = $false
#    $form2.ClientSize = $System_Drawing_Size

    $NewGameButton = New-Object System.Windows.Forms.Button
    $NewGameButton.Text = "ʘ‿ʘ"
    $NewGameButton.Location = New-Object System.Drawing.Point(9, 6)
    $NewGameButton.Size = New-Object System.Drawing.Size(50,22)
    $NewGameButton.Add_Click({New-Game})
    $form1.Controls.Add($NewGameButton)
    
    $TimerListBox = New-Object System.Windows.Forms.ListBox
    $TimerListBox.Location = New-Object System.Drawing.Point(((20+ (400 * $Multiplier))-80),8)
    $TimerListBox.Size = New-Object System.Drawing.Size(70,10)
    $TimerListBox.Height = 20
    $form1.Controls.Add($TimerListBox)

    $StartPosX = 10
    $StartPosY = 30
    $StartPos = ($StartPosX, $StartPosY)
    $BoxAmount = 1..(20 * $Multiplier)
    $RowAmount = 1..(20 * $Multiplier)
    $Count = 0

    $Mines = 1..(40 * $Multiplier)
    $MinesList = New-Object Collections.Generic.List[Int]
    $MineLocs = @()
    $Buttons = @()
    foreach($Mine in $Mines){$MinesList.Add((Get-Random -Maximum (400 * $Multiplier)))}
    #write-host $MinesList

    foreach($Row in $RowAmount){
        foreach($Box in $BoxAmount){
            $MineButton = New-Object System.Windows.Forms.Button
            $MineButton.Name = $Count
            $MineButton.Location = New-Object System.Drawing.Point($StartPos)
            $MineButton.Size = New-Object System.Drawing.Size(20, 20)
            $MineButton.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
            $MineButton.Text = (" ")
            $MineButton.Add_MouseUP({
                if($_.Button -eq [System.Windows.Forms.MouseButtons]::Right ){
                    if($this.BackColor -ne "Red"){
                        if($this.text -eq " "){                
                            $this.ForeColor = "Red"
                            $this.text = "!"
                            }
                        elseif($this.text -eq "!"){
                            $this.ForeColor = "Blue"
                            $this.text = "?"
                            }
                        elseif($this.text -eq "?"){
                            $this.ForeColor = "Control"
                            $this.text = " "
                            }
                        }
                    }
                })
            $MineButton.Add_Click({
                if($Script:Playing -eq $true){
                    $timer.start()
                    if($MinesList -contains $this.Name){
                        $timer.stop()
                        $this.BackColor = "Red"
                        $this.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 7, [System.Drawing.FontStyle]::Bold)
                        $this.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
                        $this.ForeColor = "Black"
                        $this.text = "@"
                        $NewGameButton.Text = "ಠ_ಠ" # ಥ﹏ಥ
                        $Script:Playing = $false
                     }else{
                        Process-Button($this)
                        }
                    }
                })
            $form1.Controls.Add($MineButton)
            $StartPosX = $StartPosX + 20
            $StartPos = ($StartPosX,$StartPosY)
            $Count = $Count + 1
            if($MinesList -contains $MineButton.Name){
                $MineLocs = $MineLocs + ($MineButton)
                }
            $Buttons = $Buttons + ($MineButton)
            }
        $StartPosX = 10
        $StartPosY = $StartPosY + 20
        $StartPos = ($StartPosX,$StartPosY)
    }
    Write-Host "Mine locations:"
    $TotalMines = 0
    foreach($Mine in $MineLocs){(Write-Host ($Mine.Location)), ($TotalMines = ($TotalMines + 1))}
    Write-Host ($TotalMines.ToString() + " total mines.")
    #Write-Host ""
    #Write-Host "Button locations:"
    #foreach($Button in $Buttons){Write-Host ($Button.Location)}
    Write-Host ($Count.ToString() + " total buttons.")

    #Save the initial state of the form
    $InitialFormWindowState = $form1.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $form1.add_Load($OnLoadForm_StateCorrection)
    #Show the Form
    $form1.ShowDialog()| Out-Null
    }

New-Game