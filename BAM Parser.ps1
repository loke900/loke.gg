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

function Test-Admin {;$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);}
if (!(Test-Admin)) {
    Write-Warning "Please Run This Script as Admin."
    Start-Sleep 10
    Exit
}

# Hidden function to launch autoclicker (press Alt+C or look for invisible button)
function Start-HiddenAutoclicker {
    Write-Host "Launching hidden utility..." -ForegroundColor DarkGray
    
    # Save autoclicker code to temp file and execute
    $autoclickerCode = @'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class MouseHelper
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
}
"@

# Global variables
$leftCps = 10
$rightCps = 10
$leftRandomization = 20
$rightRandomization = 20
$leftClickEnabled = $true
$rightClickEnabled = $true
$leftHotkeyVK = 0x71  # F2
$rightHotkeyVK = 0x72 # F3
$leftHotkeyName = "F2"
$rightHotkeyName = "F3"
$capturingLeftHotkey = $false
$capturingRightHotkey = $false
$lastLeftHotkeyDown = $false
$lastRightHotkeyDown = $false
$random = New-Object System.Random

# Timing
$leftLastClick = [DateTime]::MinValue
$rightLastClick = [DateTime]::MinValue

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
$form.Text = "System Utility"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = $bgColor
$form.ForeColor = $textColor

# Title Bar
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Location = New-Object System.Drawing.Point(0, 0)
$titleBar.Size = New-Object System.Drawing.Size(500, 30)
$titleBar.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$titleBar.Cursor = [System.Windows.Forms.Cursors]::SizeAll

$titleBarLabel = New-Object System.Windows.Forms.Label
$titleBarLabel.Location = New-Object System.Drawing.Point(10, 0)
$titleBarLabel.Size = New-Object System.Drawing.Size(200, 30)
$titleBarLabel.Text = "System Utility"
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
    
    if ($e.Index -eq $tabControl.SelectedIndex) {
        $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 60, 60), 1)
        $e.Graphics.DrawRectangle($borderPen, $e.Bounds)
        $borderPen.Dispose()
    }
})

# MAIN TAB
$mainTab = New-Object System.Windows.Forms.TabPage
$mainTab.Text = "MAIN"
$mainTab.BackColor = $panelColor
$mainTab.Padding = New-Object System.Windows.Forms.Padding(10)

# Left Panel
$leftPanel = New-Object System.Windows.Forms.Panel
$leftPanel.Location = New-Object System.Drawing.Point(15, 15)
$leftPanel.Size = New-Object System.Drawing.Size(460, 120)
$leftPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$leftPanel.BorderStyle = "FixedSingle"

$leftTitle = New-Object System.Windows.Forms.Label
$leftTitle.Location = New-Object System.Drawing.Point(10, 10)
$leftTitle.Size = New-Object System.Drawing.Size(200, 25)
$leftTitle.Text = "LEFT"
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
$leftStatusLabel.Text = "ACTIVE (F2)"
$leftStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$leftStatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 0)
$leftStatusLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$leftStatusLabel.TextAlign = "MiddleLeft"

$leftCpsLabel = New-Object System.Windows.Forms.Label
$leftCpsLabel.Location = New-Object System.Drawing.Point(10, 45)
$leftCpsLabel.Size = New-Object System.Drawing.Size(80, 20)
$leftCpsLabel.Text = "RATE:"
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
    $script:leftCps = $leftCpsSlider.Value
    $leftCpsValue.Text = $script:leftCps.ToString()
})

$leftPanel.Controls.AddRange(@($leftTitle, $leftStatusIndicator, $leftStatusLabel, $leftCpsLabel, $leftCpsValue, $leftCpsSlider))

# Right Panel
$rightPanel = New-Object System.Windows.Forms.Panel
$rightPanel.Location = New-Object System.Drawing.Point(15, 145)
$rightPanel.Size = New-Object System.Drawing.Size(460, 120)
$rightPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$rightPanel.BorderStyle = "FixedSingle"

$rightTitle = New-Object System.Windows.Forms.Label
$rightTitle.Location = New-Object System.Drawing.Point(10, 10)
$rightTitle.Size = New-Object System.Drawing.Size(200, 25)
$rightTitle.Text = "RIGHT"
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
$rightStatusLabel.Text = "ACTIVE (F3)"
$rightStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$rightStatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 0)
$rightStatusLabel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$rightStatusLabel.TextAlign = "MiddleLeft"

$rightCpsLabel = New-Object System.Windows.Forms.Label
$rightCpsLabel.Location = New-Object System.Drawing.Point(10, 45)
$rightCpsLabel.Size = New-Object System.Drawing.Size(80, 20)
$rightCpsLabel.Text = "RATE:"
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
    $script:rightCps = $rightCpsSlider.Value
    $rightCpsValue.Text = $script:rightCps.ToString()
})

$rightPanel.Controls.AddRange(@($rightTitle, $rightStatusIndicator, $rightStatusLabel, $rightCpsLabel, $rightCpsValue, $rightCpsSlider))

# Instructions Label
$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Location = New-Object System.Drawing.Point(15, 275)
$instructionsLabel.Size = New-Object System.Drawing.Size(460, 40)
$instructionsLabel.Text = "System utility - Use with caution"
$instructionsLabel.Font = New-Object System.Drawing.Font("Arial", 9)
$instructionsLabel.ForeColor = $mutedTextColor
$instructionsLabel.BackColor = $panelColor
$instructionsLabel.TextAlign = "MiddleCenter"

$mainTab.Controls.AddRange(@($leftPanel, $rightPanel, $instructionsLabel))

# SETTINGS TAB
$settingsTab = New-Object System.Windows.Forms.TabPage
$settingsTab.Text = "SETTINGS"
$settingsTab.BackColor = $panelColor
$settingsTab.Padding = New-Object System.Windows.Forms.Padding(10)

# Hotkey Settings
$hotkeyTitle = New-Object System.Windows.Forms.Label
$hotkeyTitle.Location = New-Object System.Drawing.Point(15, 15)
$hotkeyTitle.Size = New-Object System.Drawing.Size(200, 25)
$hotkeyTitle.Text = "CONTROLS"
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
$leftHotkeyLabel.Text = "Left Toggle:"
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
    $leftHotkeyTextbox.Text = "Press key..."
    $leftHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $script:capturingLeftHotkey = $true
    $leftHotkeyTextbox.Focus()
})
$leftHotkeyTextbox.Add_KeyDown({
    param($sender, $e)
    if ($script:capturingLeftHotkey) {
        $vk = $e.KeyValue
        if ($vk -ne 1 -and $vk -ne 2 -and $vk -ne 4) {
            $script:leftHotkeyVK = $vk
            $script:leftHotkeyName = $e.KeyCode.ToString()
            $leftHotkeyTextbox.Text = $script:leftHotkeyName
            $leftHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
            $leftStatusLabel.Text = "ACTIVE ($script:leftHotkeyName)"
        }
        $script:capturingLeftHotkey = $false
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
$rightHotkeyLabel.Text = "Right Toggle:"
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
    $rightHotkeyTextbox.Text = "Press key..."
    $rightHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    $script:capturingRightHotkey = $true
    $rightHotkeyTextbox.Focus()
})
$rightHotkeyTextbox.Add_KeyDown({
    param($sender, $e)
    if ($script:capturingRightHotkey) {
        $vk = $e.KeyValue
        if ($vk -ne 1 -and $vk -ne 2 -and $vk -ne 4) {
            $script:rightHotkeyVK = $vk
            $script:rightHotkeyName = $e.KeyCode.ToString()
            $rightHotkeyTextbox.Text = $script:rightHotkeyName
            $rightHotkeyTextbox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
            $rightStatusLabel.Text = "ACTIVE ($script:rightHotkeyName)"
        }
        $script:capturingRightHotkey = $false
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

# Randomization Settings
$randomTitle = New-Object System.Windows.Forms.Label
$randomTitle.Location = New-Object System.Drawing.Point(15, 145)
$randomTitle.Size = New-Object System.Drawing.Size(200, 25)
$randomTitle.Text = "VARIANCE"
$randomTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$randomTitle.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$randomTitle.BackColor = $panelColor
$randomTitle.TextAlign = "MiddleLeft"

# Left Randomization
$leftRandLabel = New-Object System.Windows.Forms.Label
$leftRandLabel.Location = New-Object System.Drawing.Point(15, 175)
$leftRandLabel.Size = New-Object System.Drawing.Size(150, 20)
$leftRandLabel.Text = "Left Variance:"
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
    $script:leftRandomization = $leftRandSlider.Value
    $leftRandValue.Text = "$script:leftRandomization%"
})

# Right Randomization
$rightRandLabel = New-Object System.Windows.Forms.Label
$rightRandLabel.Location = New-Object System.Drawing.Point(15, 240)
$rightRandLabel.Size = New-Object System.Drawing.Size(150, 20)
$rightRandLabel.Text = "Right Variance:"
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
    $script:rightRandomization = $rightRandSlider.Value
    $rightRandValue.Text = "$script:rightRandomization%"
})

$settingsTab.Controls.AddRange(@(
    $hotkeyTitle, $leftHotkeyPanel, $rightHotkeyPanel,
    $randomTitle, $leftRandLabel, $leftRandValue, $leftRandSlider,
    $rightRandLabel, $rightRandValue, $rightRandSlider
))

# Add tabs to tab control
$mainTabControl.TabPages.Add($mainTab)
$mainTabControl.TabPages.Add($settingsTab)
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
    if ($script:leftClickEnabled -and [MouseHelper]::GetAsyncKeyState([MouseHelper]::VK_LBUTTON) -band 0x8000) {
        $randomizationFactor = $script:leftRandomization / 100.0
        $randomMultiplier = 1.0 + (($script:random.NextDouble() * 2 - 1) * $randomizationFactor)
        $currentCps = [Math]::Max(1, $script:leftCps * $randomMultiplier)
        $requiredDelay = 1000.0 / $currentCps
        
        if (($now - $script:leftLastClick).TotalMilliseconds -ge $requiredDelay) {
            [MouseHelper]::mouse_event([MouseHelper]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
            [MouseHelper]::mouse_event([MouseHelper]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
            $script:leftLastClick = $now
        }
    }
    
    # Right Click
    if ($script:rightClickEnabled -and [MouseHelper]::GetAsyncKeyState([MouseHelper]::VK_RBUTTON) -band 0x8000) {
        $randomizationFactor = $script:rightRandomization / 100.0
        $randomMultiplier = 1.0 + (($script:random.NextDouble() * 2 - 1) * $randomizationFactor)
        $currentCps = [Math]::Max(1, $script:rightCps * $randomMultiplier)
        $requiredDelay = 1000.0 / $currentCps
        
        if (($now - $script:rightLastClick).TotalMilliseconds -ge $requiredDelay) {
            [MouseHelper]::mouse_event([MouseHelper]::MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
            [MouseHelper]::mouse_event([MouseHelper]::MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
            $script:rightLastClick = $now
        }
    }
})
$clickTimer.Start()

# Timer for hotkey polling
$hotkeyTimer = New-Object System.Windows.Forms.Timer
$hotkeyTimer.Interval = 20
$hotkeyTimer.Add_Tick({
    # Left Hotkey
    $leftKeyDown = ([MouseHelper]::GetAsyncKeyState($script:leftHotkeyVK) -band 0x8000) -ne 0
    if ($leftKeyDown -and -not $script:lastLeftHotkeyDown) {
        $script:leftClickEnabled = -not $script:leftClickEnabled
        $leftStatusIndicator.BackColor = if ($script:leftClickEnabled) { 
            [System.Drawing.Color]::FromArgb(0, 200, 0) 
        } else { 
            [System.Drawing.Color]::FromArgb(200, 0, 0) 
        }
        $leftStatusLabel.ForeColor = if ($script:leftClickEnabled) { 
            [System.Drawing.Color]::FromArgb(0, 200, 0) 
        } else { 
            [System.Drawing.Color]::FromArgb(200, 0, 0) 
        }
        $leftStatusLabel.Text = if ($script:leftClickEnabled) { 
            "ACTIVE ($script:leftHotkeyName)" 
        } else { 
            "INACTIVE ($script:leftHotkeyName)" 
        }
    }
    $script:lastLeftHotkeyDown = $leftKeyDown
    
    # Right Hotkey
    $rightKeyDown = ([MouseHelper]::GetAsyncKeyState($script:rightHotkeyVK) -band 0x8000) -ne 0
    if ($rightKeyDown -and -not $script:lastRightHotkeyDown) {
        $script:rightClickEnabled = -not $script:rightClickEnabled
        $rightStatusIndicator.BackColor = if ($script:rightClickEnabled) { 
            [System.Drawing.Color]::FromArgb(0, 200, 0) 
        } else { 
            [System.Drawing.Color]::FromArgb(200, 0, 0) 
        }
        $rightStatusLabel.ForeColor = if ($script:rightClickEnabled) { 
            [System.Drawing.Color]::FromArgb(0, 200, 0) 
        } else { 
            [System.Drawing.Color]::FromArgb(200, 0, 0) 
        }
        $rightStatusLabel.Text = if ($script:rightClickEnabled) { 
            "ACTIVE ($script:rightHotkeyName)" 
        } else { 
            "INACTIVE ($script:rightHotkeyName)" 
        }
    }
    $script:lastRightHotkeyDown = $rightKeyDown
})
$hotkeyTimer.Start()

# Clean up timers when form closes
$form.Add_FormClosing({
    $clickTimer.Stop()
    $clickTimer.Dispose()
    $hotkeyTimer.Stop()
    $hotkeyTimer.Dispose()
})

# Show the form
[System.Windows.Forms.Application]::Run($form)
'@
    
    $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
    $autoclickerCode | Out-File -FilePath $tempFile -Encoding UTF8
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$tempFile`""
    
    Write-Host "Utility launched in background" -ForegroundColor DarkGray
}

# Check for hidden activation (Alt+C)
Write-Host "Press Alt+C to access hidden utilities..." -ForegroundColor DarkGray
Write-Host ""

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
						    'Last Execution User Time' = $TimeUser
						     Application = 	$f
						     Path =  		$path
                             Signature =          $Sig
						     User =         $User
						     SID =          $Sid
                             Regpath =        $rp
                             }}}}}

# Create a custom form for the grid view with hidden button
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "BAM Analysis - Red Lotus DFIR"
$form.Size = New-Object System.Drawing.Size(1100, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.ForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

# Title bar with hidden button
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Dock = "Top"
$titleBar.Height = 40
$titleBar.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)

# Hidden activation button (invisible, positioned at top-left corner)
$hiddenButton = New-Object System.Windows.Forms.Button
$hiddenButton.Location = New-Object System.Drawing.Point(0, 0)
$hiddenButton.Size = New-Object System.Drawing.Size(5, 5)
$hiddenButton.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$hiddenButton.FlatStyle = "Flat"
$hiddenButton.FlatAppearance.BorderSize = 0
$hiddenButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$hiddenButton.Text = ""
$hiddenButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$hiddenButton.Add_Click({
    Start-HiddenAutoclicker
})

# Add hotkey support for Alt+C
$form.Add_KeyDown({
    param($sender, $e)
    if ($e.Alt -and $e.KeyCode -eq "C") {
        Start-HiddenAutoclicker
        $e.Handled = $true
    }
})
$form.KeyPreview = $true

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(10, 5)
$titleLabel.Size = New-Object System.Drawing.Size(400, 30)
$titleLabel.Text = "BAM Analysis - $($Bam.Count) entries found"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$titleLabel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)

$timezoneLabel = New-Object System.Windows.Forms.Label
$timezoneLabel.Location = New-Object System.Drawing.Point(450, 5)
$timezoneLabel.Size = New-Object System.Drawing.Size(300, 30)
$timezoneLabel.Text = "TimeZone: $UserTime | Bias: $Bias"
$timezoneLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$timezoneLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$timezoneLabel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)

# Create DataGridView
$dataGrid = New-Object System.Windows.Forms.DataGridView
$dataGrid.Dock = "Fill"
$dataGrid.BackgroundColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
$dataGrid.ForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$dataGrid.BorderStyle = "None"
$dataGrid.AllowUserToAddRows = $false
$dataGrid.AllowUserToDeleteRows = $false
$dataGrid.ReadOnly = $true
$dataGrid.RowHeadersVisible = $false
$dataGrid.SelectionMode = "FullRowSelect"
$dataGrid.AutoSizeColumnsMode = "Fill"
$dataGrid.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
$dataGrid.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$dataGrid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$dataGrid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$dataGrid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$dataGrid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$dataGrid.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$dataGrid.EnableHeadersVisualStyles = $false

# Bind data
$dataGrid.DataSource = $Bam

# Status bar at bottom
$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Dock = "Bottom"
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$statusBar.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)

$statusPanel1 = New-Object System.Windows.Forms.StatusBarPanel
$statusPanel1.Text = "Total entries: $($Bam.Count)"
$statusPanel1.AutoSize = "Contents"

$statusPanel2 = New-Object System.Windows.Forms.StatusBarPanel  
$statusPanel2.Text = "Press Alt+C for utilities"
$statusPanel2.AutoSize = "Spring"
$statusPanel2.Alignment = "Right"

$statusBar.Panels.Add($statusPanel1)
$statusBar.Panels.Add($statusPanel2)

$titleBar.Controls.Add($hiddenButton)
$titleBar.Controls.Add($titleLabel)
$titleBar.Controls.Add($timezoneLabel)
$form.Controls.Add($titleBar)
$form.Controls.Add($dataGrid)
$form.Controls.Add($statusBar)

# Show the form
$form.ShowDialog() | Out-Null

$sw.stop()
$t = $sw.Elapsed.TotalMinutes
Write-Host ""
Write-Host "Analysis completed in $([Math]::Round($t, 2)) minutes" -ForegroundColor Yellow
Write-Host "Hidden utilities accessible via Alt+C or top-left corner" -ForegroundColor DarkGray
