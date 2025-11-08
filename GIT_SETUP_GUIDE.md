# 🚀 Git Setup and Publishing Commands

## 📁 Initialize Git Repository

Run these commands in PowerShell from the project root:

```powershell
# Navigate to project folder (if not already there)
cd "C:\Users\ChethanKrishna\Downloads\Meerkat\Meerkat"

# Initialize Git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial release: Meerkat - Based on LocalSend"

# Create GitHub repository first (via web), then:
git remote add origin https://github.com/Chethan616/Meerkat.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## 🏷️ Creating Releases

After making changes:

```powershell
# Add changes
git add .

# Commit with message
git commit -m "Your commit message here"

# Push to GitHub
git push origin main

# Create a tag for release (e.g., v1.0.0)
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## 📦 Before First Push - Important Files to Check

### Files Already Modified ✅
- `app/pubspec.yaml` → Changed to `meerkat`
- `app/android/app/src/main/AndroidManifest.xml` → Package: `com.chethan616.meerkat`
- `app/android/app/src/debug/AndroidManifest.xml` → Updated
- `app/android/app/src/profile/AndroidManifest.xml` → Updated
- `app/android/app/build.gradle` → Application ID updated
- `LICENSE` → Added your modifications notice
- `README.md` → New branded version with attribution
- `NOTICE` → Created with proper attribution

### Optional: Files You Might Want to Update
- `.github/workflows/*.yml` → Remove or update CI/CD (optional)
- `CONTRIBUTING.md` → Update with your info (optional)
- `CHANGELOG.md` → Start fresh or keep original

---

## 🔒 .gitignore Recommendations

Make sure your `.gitignore` includes:

```
# Flutter
.dart_tool/
.packages
.pub-cache/
.pub/
build/

# Android
*.jks
*.keystore
key.properties
local.properties

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# macOS
.DS_Store
```

---

## 🎯 GitHub Repository Setup

1. Go to https://github.com/new
2. **Repository name:** Meerkat
3. **Description:** Fast, private local file sharing app based on LocalSend
4. **Visibility:** Public
5. **Initialize:** Leave unchecked (we already have files)
6. Click "Create repository"

Then follow the commands above to push your code!

---

## 📝 Recommended First GitHub Release

After your first push, create a release on GitHub:

1. Go to your repo → Releases → "Create a new release"
2. **Tag:** v1.0.0
3. **Title:** Meerkat v1.0.0 - Initial Release
4. **Description:**
   ```
   # 🦊 Meerkat v1.0.0 - Initial Release
   
   Fast, private, open-source local file sharing app based on LocalSend.
   
   ## ✨ Features
   - Local file sharing without internet
   - Fully offline & secure
   - Cross-platform support
   - Modern UI
   
   ## 📥 Downloads
   - APK: [Attach your APK file]
   - Google Play: [Link once published]
   
   ## 🧠 Attribution
   Based on LocalSend (https://github.com/localsend/localsend)
   Licensed under Apache 2.0
   ```
5. Attach your built APK file
6. Publish release!

---

## 🎨 Next Steps

1. Build your app:
   ```powershell
   cd app
   flutter pub get
   flutter build apk --release
   ```

2. Test the APK on your device

3. Customize UI/colors if desired

4. Push to GitHub using commands above

5. Build AAB for Play Store:
   ```powershell
   flutter build appbundle --release
   ```

6. Upload to Google Play Console

---

Good luck! 🚀
