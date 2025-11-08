# 📱 Play Store Publishing Info

## App Details

**App Name:** Meerkat  
**Package ID:** com.chethan616.meerkat  
**Category:** Tools / Productivity  
**Developer:** Chethan Krishna  

---

## 📝 Play Store Description

### Short Description (80 characters max)
Fast, secure local file sharing without internet. Based on LocalSend.

### Full Description

🦊 **Meerkat** – Fast, Private Local File Sharing

Meerkat is a fast, secure, and open-source app for sharing files and messages with nearby devices over your local network — no internet required!

✨ **Features:**
• 📡 Share files without internet connection
• 🔒 Fully offline & secure with HTTPS encryption
• ⚡ Fast transfers over local network
• 💡 Clean, modern user interface
• 🎨 Redesigned experience
• 🆓 Completely free and open-source

🔐 **Privacy First:**
Unlike other file-sharing apps, Meerkat doesn't require external servers or internet connection. All data stays on your local network, ensuring maximum privacy and security.

🌐 **Cross-Platform:**
Share files between Android, Windows, macOS, Linux, and iOS devices seamlessly.

---

### 📜 About / Credits Section (IMPORTANT!)

This app is based on the open-source project **LocalSend** (https://github.com/localsend/localsend), licensed under the Apache License, Version 2.0.

Modifications and new features © 2025 Chethan Krishna.

Source code: https://github.com/Chethan616/Meerkat

---

## 🎨 Assets Checklist

Before publishing, make sure you have:

- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (at least 2, up to 8)
  - Minimum: 320px
  - Maximum: 3840px
  - 16:9 or 9:16 aspect ratio recommended
- [ ] Privacy Policy URL (if collecting any data)

---

## ⚖️ Legal Compliance

✅ **Apache 2.0 License Compliance:**
- Original LICENSE file kept ✅
- NOTICE file created ✅
- Attribution in README ✅
- Credit in Play Store description ✅

---

## 🚀 Next Steps

1. **Customize UI/Branding**
   - Replace app icon in `app/android/app/src/main/res/mipmap-*/ic_launcher.png`
   - Or edit `app/assets/icon.png` and regenerate
   - Customize colors in Flutter theme files

2. **Build APK/AAB**
   ```bash
   cd app
   flutter pub get
   flutter build appbundle --release
   ```

3. **Test thoroughly** on multiple devices

4. **Create GitHub Repository**
   ```bash
   git init
   git add .
   git commit -m "Initial release based on LocalSend"
   git remote add origin https://github.com/Chethan616/Meerkat.git
   git push -u origin main
   ```

5. **Upload to Play Console**
   - Sign in to [Google Play Console](https://play.google.com/console)
   - Create new app
   - Upload AAB file
   - Fill in all store listing details
   - **Don't forget attribution in the description!**

---

## 📧 Support

For issues and contributions, visit:  
https://github.com/Chethan616/Meerkat

---

**Developer:** Chethan Krishna  
**License:** Apache 2.0  
**Based on:** LocalSend (https://github.com/localsend/localsend)
