# Build Flutter app
cd app
flutter build windows --release
cd ..

# Create MSI installer
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\scripts\build_msi_installer.ps1