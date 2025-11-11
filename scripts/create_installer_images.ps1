# Create Professional MSI Installer Images for Meerkat
# Creates banner (493x58) and dialog (493x312) BMP images

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Banner Image (493x58 pixels) - Top banner in installer
$bannerWidth = 493
$bannerHeight = 58
$banner = New-Object System.Drawing.Bitmap($bannerWidth, $bannerHeight)
$graphics = [System.Drawing.Graphics]::FromImage($banner)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Professional gradient background (Blue theme)
$rect = New-Object System.Drawing.Rectangle(0, 0, $bannerWidth, $bannerHeight)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(41, 128, 185),  # Deep blue
    [System.Drawing.Color]::FromArgb(52, 152, 219),  # Light blue
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal
)
$graphics.FillRectangle($brush, $rect)

# Add text with proper spacing
$font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$graphics.DrawString("Meerkat Setup", $font, $textBrush, 20, 15)

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
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Clean gradient background (Blue theme)
$rect = New-Object System.Drawing.Rectangle(0, 0, $dialogWidth, $dialogHeight)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(41, 128, 185),   # Deep blue
    [System.Drawing.Color]::FromArgb(52, 152, 219),   # Lighter blue (not purple)
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillRectangle($brush, $rect)

# Add subtle overlay for better text contrast
$overlayBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 0, 0, 0))
$graphics.FillRectangle($overlayBrush, $rect)

# Professional branding with proper spacing
$titleFont = New-Object System.Drawing.Font("Segoe UI", 42, [System.Drawing.FontStyle]::Bold)
$graphics.DrawString("Meerkat", $titleFont, $textBrush, 40, 80)

$descFont = New-Object System.Drawing.Font("Segoe UI", 16)
$graphics.DrawString("Secure Local File Sharing", $descFont, $textBrush, 40, 155)

# Feature highlights with proper spacing
$featureFont = New-Object System.Drawing.Font("Segoe UI", 12)
$graphics.DrawString("• Cross-platform file transfers", $featureFont, $textBrush, 40, 200)
$graphics.DrawString("• No internet required", $featureFont, $textBrush, 40, 225)
$graphics.DrawString("• Fast and private", $featureFont, $textBrush, 40, 250)

# Save dialog
$dialog.Save("$scriptDir\meerkat_dialog.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
Write-Host "Created: meerkat_dialog.bmp (493x312)" -ForegroundColor Green

$graphics.Dispose()
$dialog.Dispose()

Write-Host ""
Write-Host "Professional installer images created successfully!" -ForegroundColor Cyan
Write-Host "These will be used in your MSI installer for a polished look." -ForegroundColor Cyan
