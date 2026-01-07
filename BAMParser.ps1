$ErrorActionPreference = "SilentlyContinue"

function Get-Signature {

    [CmdletBinding()]
     param (
        [string[]]$FilePath
    )

    $Existence = Test-Path -PathType "Leaf" -Path $FilePath
    $Authenticode = (Get-AuthenticodeSignature -FilePath $FilePath -ErrorAction SilentlyContinue).Status
    $Signature = "Invalid Signature (UnknownError)"

    if ($Existence) {
        if ($Authenticode -eq "Valid") {
            $Signature = "Valid Signature"
        }
        elseif ($Authenticode -eq "NotSigned") {
            $Signature = "Invalid Signature (NotSigned)"
        }
        elseif ($Authenticode -eq "HashMismatch") {
            $Signature = "Invalid Signature (HashMismatch)"
        }
        elseif ($Authenticode -eq "NotTrusted") {
            $Signature = "Invalid Signature (NotTrusted)"
        }
        elseif ($Authenticode -eq "UnknownError") {
            $Signature = "Invalid Signature (UnknownError)"
        }
        return $Signature
    } else {
        $Signature = "File Was Not Found"
        return $Signature
    }
}

# Autoclicker hotkey detection and GUI function
function Initialize-Autoclicker {
    # Add Windows Forms assemblies for hotkey detection
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class KeyboardHook
{
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
    
    [DllImport("user32.dll")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
    
    public const int MOUSEEVENTF_LEFTDOWN = 0x02;
    public const int MOUSEEVENTF_LEFTUP = 0x04;
    public const int MOUSEEVENTF_RIGHTDOWN = 0x08;
    public const int MOUSEEVENTF_RIGHTUP = 0x10;
    
    public const int VK_LBUTTON = 0x01;
    public const int VK_RBUTTON = 0x02;
    public const int VK_CONTROL = 0x11;
    public const int VK_MENU = 0x12; // ALT key
    public const int VK_C = 0x43;
}
"@

    # Global autoclicker variables
    $global:autoclickerEnabled = $false
    $global:clickerForm = $null
    $global:clickTimer = $null
    $global:hotkeyTimer = $null
    
    # Clicker settings
    $global:leftCps = 10
    $global:rightCps = 10
    $global:leftRandomization = 20
    $global:rightRandomization = 20
    $global:leftClickEnabled = $true
    $global:rightClickEnabled = $true
    $global:leftHotkeyVK = 0x71  # F2
    $global:rightHotkeyVK = 0x72 # F3
    $global:leftHotkeyName = "F2"
    $global:rightHotkeyName = "F3"
    $global:capturingLeftHotkey = $false
    $global:capturingRightHotkey = $false
    $global:lastLeftHotkeyDown = $false
    $global:lastRightHotkeyDown = $false
    $global:random = New-Object System.Random
    
    # Timing
    $global:leftLastClick = [DateTime]::MinValue
    $global:rightLastClick = [DateTime]::MinValue
    
    # Hotkey check timer
    $global:altCTimer = New-Object System.Timers.Timer
    $global:altCTimer.Interval = 100  # Check every 100ms
    $global:altCTimer.AutoReset = $true
    $global:altCTimer.Enabled = $true
    
    $global:altCTimer.Add_Elapsed({
        $altPressed = ([KeyboardHook]::GetAsyncKeyState([KeyboardHook]::VK_MENU) -band 0x8000) -ne 0
        $cPressed = ([KeyboardHook]::GetAsyncKeyState([KeyboardHook]::VK_C) -band 0x8000) -ne 0
        
        if ($altPressed -and $cPressed -and -not $global:autoclickerEnabled) {
            $global:autoclickerEnabled = $true
            Show-AutoclickerGUI
        }
    })
    
    # Start the hotkey monitoring timer
    $global:altCTimer.Start()
}

function Show-AutoclickerGUI {
    # Load Windows Forms assemblies
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Colors
    $bgColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
    $panelColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
    $tabColor = [System.Drawing.Color]::FromArgb(28, 28, 28)
    $accentColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
    $textColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $mutedTextColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
    $borderColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    
    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "CClicker"
    $form.Size = New-Object System.Drawing.Size(500, 400)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "None"
    $form.BackColor = $bgColor
    $form.ForeColor = $textColor
    $form.TopMost = $true
    
    # Title Bar
    $titleBar = New-Object System.Windows.Forms.Panel
    $titleBar.Location = New-Object System.Drawing.Point(0, 0)
    $titleBar.Size = New-Object System.Drawing.Size(500, 30)
    $titleBar.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $titleBar.Cursor = [System.Windows.Forms.Cursors]::SizeAll
    
    $titleBarLabel = New-Object System.Windows.Forms.Label
    $titleBarLabel.Location = New-Object System.Drawing.Point(10, 0)
    $titleBarLabel.Size = New-Object System.Drawing.Size(200, 30)
    $titleBarLabel.Text = "CClicker"
    $titleBarLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $titleBarLabel.ForeColor = $accentColor
    $titleBarLabel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $titleBarLabel.TextAlign = "MiddleLeft"
    $titleBarLabel.Cursor = [System.Windows.Forms.Cursors]::SizeAll
    
    # Minimize button
    $minimizeButton = New-Object System.Windows.Forms.Button
    $minimizeButton.Location = New-Object System.Drawing.Point(430, 0)
    $minimizeButton.Size = New-Object System.Drawing.Size(30, 30)
    $minimizeButton.Text = "_"
    $minimizeButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $minimizeButton.ForeColor = $mutedTextColor
    $minimizeButton.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $minimizeButton.FlatStyle = "Flat"
    $minimizeButton.FlatAppearance.BorderSize = 0
    $minimizeButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $minimizeButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $minimizeButton.Add_Click({
        $form.WindowState = "Minimized"
    })
    
    # Close button
    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Location = New-Object System.Drawing.Point(460, 0)
    $closeButton.Size = New-Object System.Drawing.Size(30, 30)
    $closeButton.Text = "X"
    $closeButton.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $closeButton.ForeColor = $mutedTextColor
    $closeButton.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $closeButton.FlatStyle = "Flat"
    $closeButton.FlatAppearance.BorderSize = 0
    $closeButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $closeButton.Cursor = [System.Windows.Forms.Cursors]::Hand
    $closeButton.Add_Click({
        $global:autoclickerEnabled = $false
        if ($global:clickTimer -ne $null) {
            $global:clickTimer.Stop()
            $global:clickTimer.Dispose()
        }
        if ($global:hotkeyTimer -ne $null) {
            $global:hotkeyTimer.Stop()
            $global:hotkeyTimer.Dispose()
        }
        $form.Close()
    })
    $closeButton.Add_MouseEnter({
        $closeButton.BackColor = [System.Drawing.Color]::FromArgb(200, 50, 50)
    })
    $closeButton.Add_MouseLeave({
        $closeButton.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    })
    
    $titleBar.Controls.Add($titleBarLabel)
    $titleBar.Controls.Add($minimizeButton)
    $titleBar.Controls.Add($closeButton)
    $form.Controls.Add($titleBar)
    
    # Create Tab Control
    $mainTabControl = New-Object System.Windows.Forms.TabControl
    $mainTabControl.Location = New-Object System.Drawing.Point(0, 30)
    $mainTabControl.Size = New-Object System.Drawing.Size(500, 370)
    $mainTabControl.Appearance = "FlatButtons"
    $mainTabControl.ItemSize = New-Object System.Drawing.Size(80, 30)
    $mainTabControl.SizeMode = "Fixed"
    $mainTabControl.SelectedIndex = 0
    $mainTabControl.BackColor = $tabColor
    $mainTabControl.ForeColor = $textColor
    
    # Custom drawing for tabs
    $mainTabControl.DrawMode = "OwnerDrawFixed"
    $mainTabControl.Add_DrawItem({
        param($sender, $e)
        
        $tabControl = $sender
        $tabPage = $tabControl.TabPages[$e.Index]
        
        # Draw background
        if ($e.Index -eq $tabControl.SelectedIndex) {
            $e.Graphics.FillRectangle(
                (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(45, 45, 45))), 
                $e.Bounds
            )
        } else {
            $e.Graphics.FillRectangle(
                (New-Object System.Drawing.SolidBrush($tabColor)), 
                $e.Bounds
            )
        }
        
        # Draw tab text
        $stringFormat = New-Object System.Drawing.StringFormat
        $stringFormat.Alignment = "Center"
        $stringFormat.LineAlignment = "Center"
        
        $textColor = if ($e.Index -eq $tabControl.SelectedIndex) { $accentColor } else { $textColor }
        $textFont = if ($e.Index -eq $tabControl.SelectedIndex) { 
            New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold) 
        } else { 
            New-Object System.Drawing.Font("Arial", 9) 
        }
        
        $e.Graphics.DrawString($tabPage.Text, $textFont, 
            (New-Object System.Drawing.SolidBrush($textColor)), $e.Bounds, $stringFormat)
        
        # Draw border around selected tab
        if ($e.Index -eq $tabControl.SelectedIndex) {
            $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 60, 60), 1)
            $e.Graphics.DrawRectangle($borderPen, $e.Bounds)
            $borderPen.Dispose()
        }
    })
    
    # CLICKER TAB
    $clickerTab = New-Object System.Windows.Forms.TabPage
    $clickerTab.Text = "CLICKER"
    $clickerTab.BackColor = $panelColor
    $clickerTab.Padding = New-Object System.Windows.Forms.Padding(10)
    
    # Left Click Panel
    $leftPanel = New-Object System.Windows.Forms.Panel
    $leftPanel.Location = New-Object System.Drawing.Point(15, 15)
    $leftPanel.Size = New-Object System.Drawing.Size(460, 120)
    $leftPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftPanel.BorderStyle = "FixedSingle"
    
    $leftTitle = New-Object System.Windows.Forms.Label
    $leftTitle.Location = New-Object System.Drawing.Point(10, 10)
    $leftTitle.Size = New-Object System.Drawing.Size(200, 25)
    $leftTitle.Text = "LEFT CLICK"
    $leftTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $leftTitle.ForeColor = $accentColor
    $leftTitle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftTitle.TextAlign = "MiddleLeft"
    
    $leftStatusIndicator = New-Object System.Windows.Forms.Panel
    $leftStatusIndicator.Location = New-Object System.Drawing.Point(220, 13)
    $leftStatusIndicator.Size = New-Object System.Drawing.Size(12, 12)
    $leftStatusIndicator.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 0)
    
    $leftStatusLabel = New-Object System.Windows.Forms.Label
    $leftStatusLabel.Location = New-Object System.Drawing.Point(240, 10)
    $leftStatusLabel.Size = New-Object System.Drawing.Size(150, 20)
    $leftStatusLabel.Text = "ENABLED (F2)"
    $leftStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $leftStatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 0)
    $leftStatusLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftStatusLabel.TextAlign = "MiddleLeft"
    
    $leftCpsLabel = New-Object System.Windows.Forms.Label
    $leftCpsLabel.Location = New-Object System.Drawing.Point(10, 45)
    $leftCpsLabel.Size = New-Object System.Drawing.Size(80, 20)
    $leftCpsLabel.Text = "CPS:"
    $leftCpsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $leftCpsLabel.ForeColor = $mutedTextColor
    $leftCpsLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftCpsLabel.TextAlign = "MiddleLeft"
    
    $leftCpsValue = New-Object System.Windows.Forms.Label
    $leftCpsValue.Location = New-Object System.Drawing.Point(380, 45)
    $leftCpsValue.Size = New-Object System.Drawing.Size(70, 20)
    $leftCpsValue.Text = "10"
    $leftCpsValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $leftCpsValue.ForeColor = $accentColor
    $leftCpsValue.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftCpsValue.TextAlign = "MiddleRight"
    
    $leftCpsSlider = New-Object System.Windows.Forms.TrackBar
    $leftCpsSlider.Location = New-Object System.Drawing.Point(10, 70)
    $leftCpsSlider.Size = New-Object System.Drawing.Size(440, 40)
    $leftCpsSlider.Minimum = 1
    $leftCpsSlider.Maximum = 50
    $leftCpsSlider.Value = 10
    $leftCpsSlider.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftCpsSlider.ForeColor = $accentColor
    $leftCpsSlider.TickStyle = "None"
    $leftCpsSlider.Add_Scroll({
        $global:leftCps = $leftCpsSlider.Value
        $leftCpsValue.Text = $global:leftCps.ToString()
    })
    
    $leftPanel.Controls.AddRange(@($leftTitle, $leftStatusIndicator, $leftStatusLabel, $leftCpsLabel, $leftCpsValue, $leftCpsSlider))
    
    # Right Click Panel
    $rightPanel = New-Object System.Windows.Forms.Panel
    $rightPanel.Location = New-Object System.Drawing.Point(15, 145)
    $rightPanel.Size = New-Object System.Drawing.Size(460, 120)
    $rightPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightPanel.BorderStyle = "FixedSingle"
    
    $rightTitle = New-Object System.Windows.Forms.Label
    $rightTitle.Location = New-Object System.Drawing.Point(10, 10)
    $rightTitle.Size = New-Object System.Drawing.Size(200, 25)
    $rightTitle.Text = "RIGHT CLICK"
    $rightTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $rightTitle.ForeColor = $accentColor
    $rightTitle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightTitle.TextAlign = "MiddleLeft"
    
    $rightStatusIndicator = New-Object System.Windows.Forms.Panel
    $rightStatusIndicator.Location = New-Object System.Drawing.Point(220, 13)
    $rightStatusIndicator.Size = New-Object System.Drawing.Size(12, 12)
    $rightStatusIndicator.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 0)
    
    $rightStatusLabel = New-Object System.Windows.Forms.Label
    $rightStatusLabel.Location = New-Object System.Drawing.Point(240, 10)
    $rightStatusLabel.Size = New-Object System.Drawing.Size(150, 20)
    $rightStatusLabel.Text = "ENABLED (F3)"
    $rightStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $rightStatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 0)
    $rightStatusLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightStatusLabel.TextAlign = "MiddleLeft"
    
    $rightCpsLabel = New-Object System.Windows.Forms.Label
    $rightCpsLabel.Location = New-Object System.Drawing.Point(10, 45)
    $rightCpsLabel.Size = New-Object System.Drawing.Size(80, 20)
    $rightCpsLabel.Text = "CPS:"
    $rightCpsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $rightCpsLabel.ForeColor = $mutedTextColor
    $rightCpsLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightCpsLabel.TextAlign = "MiddleLeft"
    
    $rightCpsValue = New-Object System.Windows.Forms.Label
    $rightCpsValue.Location = New-Object System.Drawing.Point(380, 45)
    $rightCpsValue.Size = New-Object System.Drawing.Size(70, 20)
    $rightCpsValue.Text = "10"
    $rightCpsValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $rightCpsValue.ForeColor = $accentColor
    $rightCpsValue.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightCpsValue.TextAlign = "MiddleRight"
    
    $rightCpsSlider = New-Object System.Windows.Forms.TrackBar
    $rightCpsSlider.Location = New-Object System.Drawing.Point(10, 70)
    $rightCpsSlider.Size = New-Object System.Drawing.Size(440, 40)
    $rightCpsSlider.Minimum = 1
    $rightCpsSlider.Maximum = 50
    $rightCpsSlider.Value = 10
    $rightCpsSlider.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightCpsSlider.ForeColor = $accentColor
    $rightCpsSlider.TickStyle = "None"
    $rightCpsSlider.Add_Scroll({
        $global:rightCps = $rightCpsSlider.Value
        $rightCpsValue.Text = $global:rightCps.ToString()
    })
    
    $rightPanel.Controls.AddRange(@($rightTitle, $rightStatusIndicator, $rightStatusLabel, $rightCpsLabel, $rightCpsValue, $rightCpsSlider))
    
    # Instructions Label
    $instructionsLabel = New-Object System.Windows.Forms.Label
    $instructionsLabel.Location = New-Object System.Drawing.Point(15, 275)
    $instructionsLabel.Size = New-Object System.Drawing.Size(460, 40)
    $instructionsLabel.Text = "Use Hotkey's to toggle Clicker • Toggle with Hotkeys in 'OTHER' Tab"
    $instructionsLabel.Font = New-Object System.Drawing.Font("Arial", 9)
    $instructionsLabel.ForeColor = $mutedTextColor
    $instructionsLabel.BackColor = $panelColor
    $instructionsLabel.TextAlign = "MiddleCenter"
    
    $clickerTab.Controls.AddRange(@($leftPanel, $rightPanel, $instructionsLabel))
    
    # OTHER TAB
    $otherTab = New-Object System.Windows.Forms.TabPage
    $otherTab.Text = "OTHER"
    $otherTab.BackColor = $panelColor
    $otherTab.Padding = New-Object System.Windows.Forms.Padding(10)
    
    # Hotkey Settings Title
    $hotkeyTitle = New-Object System.Windows.Forms.Label
    $hotkeyTitle.Location = New-Object System.Drawing.Point(15, 15)
    $hotkeyTitle.Size = New-Object System.Drawing.Size(200, 25)
    $hotkeyTitle.Text = "HOTKEY SETTINGS"
    $hotkeyTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $hotkeyTitle.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
    $hotkeyTitle.BackColor = $panelColor
    $hotkeyTitle.TextAlign = "MiddleLeft"
    
    # Left Hotkey Panel
    $leftHotkeyPanel = New-Object System.Windows.Forms.Panel
    $leftHotkeyPanel.Location = New-Object System.Drawing.Point(15, 45)
    $leftHotkeyPanel.Size = New-Object System.Drawing.Size(460, 40)
    $leftHotkeyPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftHotkeyPanel.BorderStyle = "FixedSingle"
    
    $leftHotkeyLabel = New-Object System.Windows.Forms.Label
    $leftHotkeyLabel.Location = New-Object System.Drawing.Point(10, 10)
    $leftHotkeyLabel.Size = New-Object System.Drawing.Size(200, 20)
    $leftHotkeyLabel.Text = "Left Click Toggle:"
    $leftHotkeyLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $leftHotkeyLabel.ForeColor = $mutedTextColor
    $leftHotkeyLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftHotkeyLabel.TextAlign = "MiddleLeft"
    
    $leftHotkeyTextbox = New-Object System.Windows.Forms.TextBox
    $leftHotkeyTextbox.Location = New-Object System.Drawing.Point(220, 8)
    $leftHotkeyTextbox.Size = New-Object System.Drawing.Size(120, 24)
    $leftHotkeyTextbox.Text = "F2"
    $leftHotkeyTextbox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $leftHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $leftHotkeyTextbox.ForeColor = $accentColor
    $leftHotkeyTextbox.BorderStyle = "FixedSingle"
    $leftHotkeyTextbox.ReadOnly = $true
    $leftHotkeyTextbox.TextAlign = "Center"
    $leftHotkeyTextbox.Cursor = [System.Windows.Forms.Cursors]::Hand
    $leftHotkeyTextbox.Add_Click({
        $leftHotkeyTextbox.Text = "Set a bind..."
        $leftHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
        $global:capturingLeftHotkey = $true
        $leftHotkeyTextbox.Focus()
    })
    $leftHotkeyTextbox.Add_KeyDown({
        param($sender, $e)
        if ($global:capturingLeftHotkey) {
            $vk = $e.KeyValue
            if ($vk -ne 1 -and $vk -ne 2 -and $vk -ne 4) {
                $global:leftHotkeyVK = $vk
                $global:leftHotkeyName = $e.KeyCode.ToString()
                $leftHotkeyTextbox.Text = $global:leftHotkeyName
                $leftHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
                $leftStatusLabel.Text = "ENABLED ($global:leftHotkeyName)"
            }
            $global:capturingLeftHotkey = $false
            $e.SuppressKeyPress = $true
        }
    })
    
    $leftHotkeyInfo = New-Object System.Windows.Forms.Label
    $leftHotkeyInfo.Location = New-Object System.Drawing.Point(350, 10)
    $leftHotkeyInfo.Size = New-Object System.Drawing.Size(100, 20)
    $leftHotkeyInfo.Text = "Click to set"
    $leftHotkeyInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $leftHotkeyInfo.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $leftHotkeyInfo.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $leftHotkeyInfo.TextAlign = "MiddleRight"
    
    $leftHotkeyPanel.Controls.AddRange(@($leftHotkeyLabel, $leftHotkeyTextbox, $leftHotkeyInfo))
    
    # Right Hotkey Panel
    $rightHotkeyPanel = New-Object System.Windows.Forms.Panel
    $rightHotkeyPanel.Location = New-Object System.Drawing.Point(15, 90)
    $rightHotkeyPanel.Size = New-Object System.Drawing.Size(460, 40)
    $rightHotkeyPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightHotkeyPanel.BorderStyle = "FixedSingle"
    
    $rightHotkeyLabel = New-Object System.Windows.Forms.Label
    $rightHotkeyLabel.Location = New-Object System.Drawing.Point(10, 10)
    $rightHotkeyLabel.Size = New-Object System.Drawing.Size(200, 20)
    $rightHotkeyLabel.Text = "Right Click Toggle:"
    $rightHotkeyLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $rightHotkeyLabel.ForeColor = $mutedTextColor
    $rightHotkeyLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightHotkeyLabel.TextAlign = "MiddleLeft"
    
    $rightHotkeyTextbox = New-Object System.Windows.Forms.TextBox
    $rightHotkeyTextbox.Location = New-Object System.Drawing.Point(220, 8)
    $rightHotkeyTextbox.Size = New-Object System.Drawing.Size(120, 24)
    $rightHotkeyTextbox.Text = "F3"
    $rightHotkeyTextbox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $rightHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    $rightHotkeyTextbox.ForeColor = $accentColor
    $rightHotkeyTextbox.BorderStyle = "FixedSingle"
    $rightHotkeyTextbox.ReadOnly = $true
    $rightHotkeyTextbox.TextAlign = "Center"
    $rightHotkeyTextbox.Cursor = [System.Windows.Forms.Cursors]::Hand
    $rightHotkeyTextbox.Add_Click({
        $rightHotkeyTextbox.Text = "Set Bind..."
        $rightHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
        $global:capturingRightHotkey = $true
        $rightHotkeyTextbox.Focus()
    })
    $rightHotkeyTextbox.Add_KeyDown({
        param($sender, $e)
        if ($global:capturingRightHotkey) {
            $vk = $e.KeyValue
            if ($vk -ne 1 -and $vk -ne 2 -and $vk -ne 4) {
                $global:rightHotkeyVK = $vk
                $global:rightHotkeyName = $e.KeyCode.ToString()
                $rightHotkeyTextbox.Text = $global:rightHotkeyName
                $rightHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
                $rightStatusLabel.Text = "ENABLED ($global:rightHotkeyName)"
            }
            $global:capturingRightHotkey = $false
            $e.SuppressKeyPress = $true
        }
    })
    
    $rightHotkeyInfo = New-Object System.Windows.Forms.Label
    $rightHotkeyInfo.Location = New-Object System.Drawing.Point(350, 10)
    $rightHotkeyInfo.Size = New-Object System.Drawing.Size(100, 20)
    $rightHotkeyInfo.Text = "Click to set"
    $rightHotkeyInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $rightHotkeyInfo.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $rightHotkeyInfo.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $rightHotkeyInfo.TextAlign = "MiddleRight"
    
    $rightHotkeyPanel.Controls.AddRange(@($rightHotkeyLabel, $rightHotkeyTextbox, $rightHotkeyInfo))
    
    # Randomization Title
    $randomTitle = New-Object System.Windows.Forms.Label
    $randomTitle.Location = New-Object System.Drawing.Point(15, 145)
    $randomTitle.Size = New-Object System.Drawing.Size(200, 25)
    $randomTitle.Text = "RANDOMIZATION"
    $randomTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $randomTitle.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
    $randomTitle.BackColor = $panelColor
    $randomTitle.TextAlign = "MiddleLeft"
    
    # Left Randomization
    $leftRandLabel = New-Object System.Windows.Forms.Label
    $leftRandLabel.Location = New-Object System.Drawing.Point(15, 175)
    $leftRandLabel.Size = New-Object System.Drawing.Size(150, 20)
    $leftRandLabel.Text = "Left Randomization:"
    $leftRandLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $leftRandLabel.ForeColor = $accentColor
    $leftRandLabel.BackColor = $panelColor
    $leftRandLabel.TextAlign = "MiddleLeft"
    
    $leftRandValue = New-Object System.Windows.Forms.Label
    $leftRandValue.Location = New-Object System.Drawing.Point(345, 175)
    $leftRandValue.Size = New-Object System.Drawing.Size(60, 20)
    $leftRandValue.Text = "20%"
    $leftRandValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $leftRandValue.ForeColor = $accentColor
    $leftRandValue.BackColor = $panelColor
    $leftRandValue.TextAlign = "MiddleRight"
    
    $leftRandSlider = New-Object System.Windows.Forms.TrackBar
    $leftRandSlider.Location = New-Object System.Drawing.Point(15, 200)
    $leftRandSlider.Size = New-Object System.Drawing.Size(380, 30)
    $leftRandSlider.Minimum = 0
    $leftRandSlider.Maximum = 100
    $leftRandSlider.Value = 20
    $leftRandSlider.BackColor = $panelColor
    $leftRandSlider.ForeColor = $accentColor
    $leftRandSlider.TickStyle = "None"
    $leftRandSlider.Add_Scroll({
        $global:leftRandomization = $leftRandSlider.Value
        $leftRandValue.Text = "$global:leftRandomization%"
        $leftRandValue.ForeColor = $accentColor
    })
    
    # Right Randomization
    $rightRandLabel = New-Object System.Windows.Forms.Label
    $rightRandLabel.Location = New-Object System.Drawing.Point(15, 240)
    $rightRandLabel.Size = New-Object System.Drawing.Size(150, 20)
    $rightRandLabel.Text = "Right Randomization:"
    $rightRandLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $rightRandLabel.ForeColor = $accentColor
    $rightRandLabel.BackColor = $panelColor
    $rightRandLabel.TextAlign = "MiddleLeft"
    
    $rightRandValue = New-Object System.Windows.Forms.Label
    $rightRandValue.Location = New-Object System.Drawing.Point(345, 240)
    $rightRandValue.Size = New-Object System.Drawing.Size(60, 20)
    $rightRandValue.Text = "20%"
    $rightRandValue.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $rightRandValue.ForeColor = $accentColor
    $rightRandValue.BackColor = $panelColor
    $rightRandValue.TextAlign = "MiddleRight"
    
    $rightRandSlider = New-Object System.Windows.Forms.TrackBar
    $rightRandSlider.Location = New-Object System.Drawing.Point(15, 265)
    $rightRandSlider.Size = New-Object System.Drawing.Size(380, 30)
    $rightRandSlider.Minimum = 0
    $rightRandSlider.Maximum = 100
    $rightRandSlider.Value = 20
    $rightRandSlider.BackColor = $panelColor
    $rightRandSlider.ForeColor = $accentColor
    $rightRandSlider.TickStyle = "None"
    $rightRandSlider.Add_Scroll({
        $global:rightRandomization = $rightRandSlider.Value
        $rightRandValue.Text = "$global:rightRandomization%"
        $rightRandValue.ForeColor = $accentColor
    })
    
    # Info Label
    $otherInfoLabel = New-Object System.Windows.Forms.Label
    $otherInfoLabel.Location = New-Object System.Drawing.Point(15, 305)
    $otherInfoLabel.Size = New-Object System.Drawing.Size(460, 40)
    $otherInfoLabel.Text = "Randomization for Left + Right CPS`nExample: 20 CPS with 20% randomization = 16-24 CPS"
    $otherInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $otherInfoLabel.ForeColor = $mutedTextColor
    $otherInfoLabel.BackColor = $panelColor
    $otherInfoLabel.TextAlign = "MiddleCenter"
    
    $otherTab.Controls.AddRange(@(
        $hotkeyTitle, $leftHotkeyPanel, $rightHotkeyPanel,
        $randomTitle, $leftRandLabel, $leftRandValue, $leftRandSlider,
        $rightRandLabel, $rightRandValue, $rightRandSlider,
        $otherInfoLabel
    ))
    
    # Add tabs to tab control
    $mainTabControl.TabPages.Add($clickerTab)
    $mainTabControl.TabPages.Add($otherTab)
    $form.Controls.Add($mainTabControl)
    
    # Dragging events
    $titleBar.Add_MouseDown({
        param($sender, $e)
        if ($e.Button -eq "Left") {
            $script:isDragging = $true
            $script:dragStart = $e.Location
        }
    })
    
    $titleBar.Add_MouseMove({
        param($sender, $e)
        if ($script:isDragging) {
            $form.Location = New-Object System.Drawing.Point(
                ($form.Location.X + $e.X - $script:dragStart.X),
                ($form.Location.Y + $e.Y - $script:dragStart.Y)
            )
        }
    })
    
    $titleBar.Add_MouseUp({
        param($sender, $e)
        $script:isDragging = $false
    })
    
    $titleBarLabel.Add_MouseDown({
        param($sender, $e)
        if ($e.Button -eq "Left") {
            $script:isDragging = $true
            $script:dragStart = New-Object System.Drawing.Point(
                ($e.X + $titleBarLabel.Location.X),
                $e.Y
            )
        }
    })
    
    $titleBarLabel.Add_MouseMove({
        param($sender, $e)
        if ($script:isDragging) {
            $form.Location = New-Object System.Drawing.Point(
                ($form.Location.X + $e.X - $script:dragStart.X + $titleBarLabel.Location.X),
                ($form.Location.Y + $e.Y - $script:dragStart.Y)
            )
        }
    })
    
    $titleBarLabel.Add_MouseUp({
        param($sender, $e)
        $script:isDragging = $false
    })
    
    # Timer for clicking
    $clickTimer = New-Object System.Windows.Forms.Timer
    $clickTimer.Interval = 1
    $clickTimer.Add_Tick({
        $now = [DateTime]::Now
        
        # Left Click
        if ($global:leftClickEnabled -and [KeyboardHook]::GetAsyncKeyState([KeyboardHook]::VK_LBUTTON) -band 0x8000) {
            $randomizationFactor = $global:leftRandomization / 100.0
            $randomMultiplier = 1.0 + (($global:random.NextDouble() * 2 - 1) * $randomizationFactor)
            $currentCps = [Math]::Max(1, $global:leftCps * $randomMultiplier)
            $requiredDelay = 1000.0 / $currentCps
            
            if (($now - $global:leftLastClick).TotalMilliseconds -ge $requiredDelay) {
                [KeyboardHook]::mouse_event([KeyboardHook]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
                [KeyboardHook]::mouse_event([KeyboardHook]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
                $global:leftLastClick = $now
            }
        }
        
        # Right Click
        if ($global:rightClickEnabled -and [KeyboardHook]::GetAsyncKeyState([KeyboardHook]::VK_RBUTTON) -band 0x8000) {
            $randomizationFactor = $global:rightRandomization / 100.0
            $randomMultiplier = 1.0 + (($global:random.NextDouble() * 2 - 1) * $randomizationFactor)
            $currentCps = [Math]::Max(1, $global:rightCps * $randomMultiplier)
            $requiredDelay = 1000.0 / $currentCps
            
            if (($now - $global:rightLastClick).TotalMilliseconds -ge $requiredDelay) {
                [KeyboardHook]::mouse_event([KeyboardHook]::MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
                [KeyboardHook]::mouse_event([KeyboardHook]::MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
                $global:rightLastClick = $now
            }
        }
    })
    $global:clickTimer = $clickTimer
    $clickTimer.Start()
    
    # Timer for hotkey polling
    $hotkeyTimer = New-Object System.Windows.Forms.Timer
    $hotkeyTimer.Interval = 20
    $hotkeyTimer.Add_Tick({
        # Left Hotkey
        $leftKeyDown = ([KeyboardHook]::GetAsyncKeyState($global:leftHotkeyVK) -band 0x8000) -ne 0
        if ($leftKeyDown -and -not $global:lastLeftHotkeyDown) {
            $global:leftClickEnabled = -not $global:leftClickEnabled
            $leftStatusIndicator.BackColor = if ($global:leftClickEnabled) { 
                [System.Drawing.Color]::FromArgb(0, 200, 0) 
            } else { 
                [System.Drawing.Color]::FromArgb(200, 0, 0) 
            }
            $leftStatusLabel.ForeColor = if ($global:leftClickEnabled) { 
                [System.Drawing.Color]::FromArgb(0, 200, 0) 
            } else { 
                [System.Drawing.Color]::FromArgb(200, 0, 0) 
            }
            $leftStatusLabel.Text = if ($global:leftClickEnabled) { 
                "ENABLED ($global:leftHotkeyName)" 
            } else { 
                "DISABLED ($global:leftHotkeyName)" 
            }
        }
        $global:lastLeftHotkeyDown = $leftKeyDown
        
        # Right Hotkey
        $rightKeyDown = ([KeyboardHook]::GetAsyncKeyState($global:rightHotkeyVK) -band 0x8000) -ne 0
        if ($rightKeyDown -and -not $global:lastRightHotkeyDown) {
            $global:rightClickEnabled = -not $global:rightClickEnabled
            $rightStatusIndicator.BackColor = if ($global:rightClickEnabled) { 
                [System.Drawing.Color]::FromArgb(0, 200, 0) 
            } else { 
                [System.Drawing.Color]::FromArgb(200, 0, 0) 
            }
            $rightStatusLabel.ForeColor = if ($global:rightClickEnabled) { 
                [System.Drawing.Color]::FromArgb(0, 200, 0) 
            } else { 
                [System.Drawing.Color]::FromArgb(200, 0, 0) 
            }
            $rightStatusLabel.Text = if ($global:rightClickEnabled) { 
                "ENABLED ($global:rightHotkeyName)" 
            } else { 
                "DISABLED ($global:rightHotkeyName)" 
            }
        }
        $global:lastRightHotkeyDown = $rightKeyDown
    })
    $global:hotkeyTimer = $hotkeyTimer
    $hotkeyTimer.Start()
    
    # Clean up timers when form closes
    $form.Add_FormClosing({
        $global:autoclickerEnabled = $false
        if ($global:clickTimer -ne $null) {
            $global:clickTimer.Stop()
            $global:clickTimer.Dispose()
        }
        if ($global:hotkeyTimer -ne $null) {
            $global:hotkeyTimer.Stop()
            $global:hotkeyTimer.Dispose()
        }
    })
    
    # Show the form
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog()
}

# Initialize the autoclicker hotkey listener
Initialize-Autoclicker

# Original BAM script continues here
Clear-Host

Write-Host "";
Write-Host "";
Write-Host -ForegroundColor Red "   ██████╗ ███████╗██████╗     ██╗      ██████╗ ████████╗██╗   ██╗███████╗    ██████╗  █████╗ ███╗   ███╗";
Write-Host -ForegroundColor Red "   ██╔══██╗██╔════╝██╔══██╗    ██║     ██╔═══██╗╚══██╔══╝██║   ██║██╔════╝    ██╔══██╗██╔══██╗████╗ ████║";
Write-Host -ForegroundColor Red "   ██████╔╝█████╗  ██║  ██║    ██║     ██║   ██║   ██║   ██║   ██║███████╗    ██████╔╝███████║██╔████╔██║";
Write-Host -ForegroundColor Red "   ██╔══██╗██╔══╝  ██║  ██║    ██║     ██║   ██║   ██║   ██║   ██║╚════██║    ██╔══██╗██╔══██║██║╚██╔╝██║";
Write-Host -ForegroundColor Red "   ██║  ██║███████╗██████╔╝    ███████╗╚██████╔╝   ██║   ╚██████╔╝███████║    ██████╔╝██║  ██║██║ ╚═╝ ██║";
Write-Host -ForegroundColor Red "   ╚═╝  ╚═╝╚══════╝╚═════╝     ╚══════╝ ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝    ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝";
Write-Host "";
Write-Host -ForegroundColor Blue "   Made By PureIntent (Shitty ScreenSharer) For Red Lotus ScreenSharing and DFIR - " -NoNewLine
Write-Host -ForegroundColor Red "discord.gg/redlotus";
Write-Host "";
Write-Host -ForegroundColor Yellow "   Autoclicker: Press ALT+C to open the clicker GUI"
Write-Host "";

function Test-Admin {;$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);}
if (!(Test-Admin)) {
    Write-Warning "Please Run This Script as Admin."
    Start-Sleep 10
    Exit
}

$sw = [Diagnostics.Stopwatch]::StartNew()

if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try{New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE}
    Catch{Write-Warning "Error Mounting HKEY_Local_Machine"}
}
$bv = ("bam", "bam\State")
Try{$Users = foreach($ii in $bv){Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($ii)\UserSettings\" | Select-Object -ExpandProperty PSChildName}}
Catch{
    Write-Warning "Error Parsing BAM Key. Likely unsupported Windows Version"
    Exit
}
$rpath = @("HKLM:\SYSTEM\CurrentControlSet\Services\bam\","HKLM:\SYSTEM\CurrentControlSet\Services\bam\state\")

$UserTime = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").TimeZoneKeyName
$UserBias = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").ActiveTimeBias
$UserDay = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").DaylightBias

$Bam = Foreach ($Sid in $Users){$u++
            
        foreach($rp in $rpath){
           $BamItems = Get-Item -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
           Write-Host -ForegroundColor Red "Extracting " -NoNewLine
           Write-Host -ForegroundColor Blue "$($rp)UserSettings\$SID"
           $bi = 0 

            Try{
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid)
            $User = $objSID.Translate( [System.Security.Principal.NTAccount]) 
            $User = $User.Value
            }
            Catch{$User=""}
            $i=0
            ForEach ($Item in $BamItems){$i++
		    $Key = Get-ItemProperty -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue| Select-Object -ExpandProperty $Item
	
            If($key.length -eq 24){
                $Hex=[System.BitConverter]::ToString($key[7..0]) -replace "-",""
                $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
			    $TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
			    $Bias = -([convert]::ToInt32([Convert]::ToString($UserBias,2),2))
			    $Day = -([convert]::ToInt32([Convert]::ToString($UserDay,2),2)) 
			    $Biasd = $Bias/60
			    $Dayd = $Day/60
			    $TImeUser = (Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))).addminutes($Bias) -Format "yyyy-MM-dd HH:mm:ss") 
			    $d = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {((split-path -path $item).Remove(23)).trimstart("\Device\HarddiskVolume")} else {$d = ""}
			    $f = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {Split-path -leaf ($item).TrimStart()} else {$item}	
			    $cp = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {($item).Remove(1,23)} else {$cp = ""}
			    $path = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {Join-Path -Path "C:" -ChildPath $cp} else {$path = ""}			
			    $sig = if((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3)-match '\d{1}')
			    {Get-Signature -FilePath $path} else {$sig = ""}				
                [PSCustomObject]@{
                            'Examiner Time' = $TimeLocal
						    'Last Execution Time (UTC)'= $TimeUTC
						    'Last Execution User Time' = $TImeUser
						     Application = 	$f
						     Path =  		$path
                             Signature =          $Sig
						     User =         $User
						     SID =          $Sid
                             Regpath =        $rp
                             }}}}}

$Bam | Out-GridView -PassThru -Title "BAM key entries $($Bam.count)  - User TimeZone: ($UserTime) -> ActiveBias: ( $Bias) - DayLightTime: ($Day)"

$sw.stop()
$t = $sw.Elapsed.TotalMinutes
Write-Host ""
Write-Host "Elapsed Time $t Minutes" -ForegroundColor Yellow
Write-Host "Note: Autoclicker hotkey listener is running in background (ALT+C to open)"
