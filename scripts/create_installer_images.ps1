# Create Professional MSI Installer Images for Meerkat
# Creates banner (493x58) and dialog (493x312) BMP images

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Banner Image (493x58 pixels) - Top banner in installer
$bannerWidth = 493
$bannerHeight = 58
$banner = New-Object System.Drawing.Bitmap($bannerWidth, $bannerHeight)
$graphics = [System.Drawing.Graphics]::FromImage($banner)

# Professional gradient background (Blue theme)
$rect = New-Object System.Drawing.Rectangle(0, 0, $bannerWidth, $bannerHeight)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(41, 128, 185),  # Deep blue
    [System.Drawing.Color]::FromArgb(52, 152, 219),  # Light blue
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$graphics.FillRectangle($brush, $rect)

# Add text
$font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$graphics.DrawString("Meerkat", $font, $textBrush, 20, 12)

$subtitleFont = New-Object System.Drawing.Font("Segoe UI", 10)
$graphics.DrawString("Secure File Sharing", $subtitleFont, $textBrush, 180, 28)

# Save banner
$banner.Save("$scriptDir\meerkat_banner.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
Write-Host "Created: meerkat_banner.bmp (493x58)" -ForegroundColor Green

$graphics.Dispose()
$banner.Dispose()

# Dialog Image (493x312 pixels) - Side image in installer
$dialogWidth = 493
$dialogHeight = 312
$dialog = New-Object System.Drawing.Bitmap($dialogWidth, $dialogHeight)
$graphics = [System.Drawing.Graphics]::FromImage($dialog)

# Professional gradient background
$rect = New-Object System.Drawing.Rectangle(0, 0, $dialogWidth, $dialogHeight)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(41, 128, 185),   # Deep blue
    [System.Drawing.Color]::FromArgb(142, 68, 173),   # Purple accent
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillRectangle($brush, $rect)

# Add branding
$titleFont = New-Object System.Drawing.Font("Segoe UI", 36, [System.Drawing.FontStyle]::Bold)
$graphics.DrawString("Meerkat", $titleFont, $textBrush, 30, 100)

$descFont = New-Object System.Drawing.Font("Segoe UI", 14)
$graphics.DrawString("Secure File Sharing", $descFont, $textBrush, 30, 160)
$graphics.DrawString("Share files safely across devices", $descFont, $textBrush, 30, 190)
$graphics.DrawString("on your local network", $descFont, $textBrush, 30, 220)

# Add version
$versionFont = New-Object System.Drawing.Font("Segoe UI", 10)
$graphics.DrawString("Version 1.0.0", $versionFont, $textBrush, 30, 270)

# Save dialog
$dialog.Save("$scriptDir\meerkat_dialog.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
Write-Host "Created: meerkat_dialog.bmp (493x312)" -ForegroundColor Green

$graphics.Dispose()
$dialog.Dispose()

Write-Host ""
Write-Host "Professional installer images created successfully!" -ForegroundColor Cyan
Write-Host "These will be used in your MSI installer for a polished look." -ForegroundColor Cyan
