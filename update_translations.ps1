# Update all translation files to change LocalSend to Meerkat
$translationDir = "C:\Users\ChethanKrishna\Downloads\Meerkat\Meerkat\app\assets\i18n"
$files = Get-ChildItem -Path $translationDir -Filter "*.json" -Exclude "_*"

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        if ($content -match '"appName":\s*"LocalSend"') {
            $content = $content -replace '"appName":\s*"LocalSend"', '"appName": "Meerkat"'
            Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
            Write-Host "Updated: $($file.Name)"
        } else {
            Write-Host "Already updated or no match: $($file.Name)"
        }
    } catch {
        Write-Host "Error updating $($file.Name): $_"
    }
}

Write-Host "`nDone! All translation files processed."
