# Build Meerkat MSI Installer using WiX Toolset
# Prerequisites: Install WiX Toolset from https://wixtoolset.org/releases/

Write-Host "Building Meerkat MSI Installer..." -ForegroundColor Green

# Set paths
$buildDir = ".\app\build\windows\x64\runner\Release"
$outputDir = ".\installer-output"
$wixDir = ".\scripts"
$sourceDir = Join-Path $PSScriptRoot "..\app\build\windows\x64\runner\Release"

# Check if WiX is installed (v4+ uses 'wix' command, v3 uses 'candle' and 'light')
$wix = Get-Command "wix.exe" -ErrorAction SilentlyContinue
$candle = Get-Command "candle.exe" -ErrorAction SilentlyContinue

if (-not $wix -and -not $candle) {
    Write-Host "ERROR: WiX Toolset not found!" -ForegroundColor Red
    Write-Host "Please install WiX Toolset from: https://wixtoolset.org/releases/" -ForegroundColor Yellow
    Write-Host "Or install via: dotnet tool install --global wix" -ForegroundColor Yellow
    Write-Host "After installing, restart PowerShell and try again." -ForegroundColor Yellow
    exit 1
}

# Determine WiX version
$useWixV4 = $null -ne $wix

# Create output directory
if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Create a simple License.rtf if it doesn't exist
$licenseFile = Join-Path $sourceDir "License.rtf"
if (-not (Test-Path $licenseFile)) {
    @"
{\rtf1\ansi\ansicpg1252\deff0\nouicompat{\fonttbl{\f0\fnil\fcharset0 Calibri;}}
{\*\generator Riched20 10.0.19041}\viewkind4\uc1 
\pard\sa200\sl276\slmult1\f0\fs22\lang9 Apache License 2.0\par
This software is licensed under the Apache License, Version 2.0.\par
See LICENSE file for details.\par
}
"@ | Out-File -FilePath $licenseFile -Encoding ASCII
}

Write-Host "Compiling WiX source..." -ForegroundColor Cyan

if ($useWixV4) {
    # WiX v4+ (modern command)
    Write-Host "Using WiX v4+ toolset..." -ForegroundColor Yellow
    
    wix.exe extension add WixToolset.Util.wixext 2>$null
    wix.exe extension add WixToolset.UI.wixext 2>$null
    
    wix.exe build "$wixDir\meerkat_installer_v2.wxs" `
        -out "$outputDir\Meerkat-1.0.0-windows-x64.msi" `
        -d SourceDir="$sourceDir" `
        -d ProjectDir="$wixDir" `
        -arch x64 `
        -ext WixToolset.Util.wixext `
        -ext WixToolset.UI.wixext
        
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: WiX build failed!" -ForegroundColor Red
        exit 1
    }
} else {
    # WiX v3 (legacy commands)
    Write-Host "Using WiX v3 toolset..." -ForegroundColor Yellow
    
    # Compile .wxs to .wixobj
    candle.exe "$wixDir\meerkat_installer.wxs" `
        -out "$outputDir\meerkat_installer.wixobj" `
        -dSourceDir="$sourceDir" `
        -arch x64

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: WiX compilation failed!" -ForegroundColor Red
        exit 1
    }

    Write-Host "Linking MSI package..." -ForegroundColor Cyan

    # Link .wixobj to create .msi
    light.exe "$outputDir\meerkat_installer.wixobj" `
        -out "$outputDir\Meerkat-1.0.0-windows-x64.msi" `
        -ext WixUIExtension `
        -cultures:en-us

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: MSI linking failed!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "SUCCESS! MSI installer created:" -ForegroundColor Green
Write-Host "$outputDir\Meerkat-1.0.0-windows-x64.msi" -ForegroundColor Yellow
Write-Host ""
Write-Host "You can now distribute this MSI file!" -ForegroundColor Green
