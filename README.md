# 🦊 Meerkat – Fast, Private Local File Sharing

Meerkat is an open-source Flutter app for **fast, secure, and offline file sharing** across devices — redesigned with a clean UI and modern experience.

🧩 **Based on [LocalSend](https://github.com/localsend/localsend)**  
Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

---

## ✨ Features
- 📡 Local file sharing without the Internet  
- 🔒 Fully offline & secure  
- 💡 Clean, fast, and open-source  
- 🎨 Redesigned user interface  

---

## 🧠 Attribution
Original project © [LocalSend Contributors](https://github.com/localsend/localsend)  
Modifications & UI enhancements © 2025 Chethan Krishna

---

## ⚖️ License
This project is licensed under the [Apache License 2.0](LICENSE).

---

## 🚀 Getting Started

To compile Meerkat from the source code, follow these steps:

1. Install Flutter [directly](https://flutter.dev) or using [fvm](https://fvm.app) (see [version required](app/.fvmrc))
2. Install [Rust](https://www.rust-lang.org/tools/install)
3. Clone the `Meerkat` repository
4. Run `cd app` to enter the app directory
5. Run `flutter pub get` to download dependencies
6. Run `flutter run` to start the app

> [!NOTE]
> Meerkat currently requires an older Flutter version (specified in [app/.fvmrc](app/.fvmrc))
> and thus build issues may be caused by a mismatch between the required and the (system-wide) installed Flutter version.  
> To make development more consistent, Meerkat uses [fvm](https://fvm.app) to manage the project Flutter version.
> After installing `fvm`, run `fvm flutter` instead of `flutter`.

---

## 🛠️ Building

### Android

Traditional APK

```bash
flutter build apk
```

AppBundle for Google Play

```bash
flutter build appbundle
```

---

## 📱 About the Original Project

This project is based on **LocalSend**, a cross-platform app that enables secure communication between devices using a REST API and HTTPS encryption. Unlike other messaging apps that rely on external servers, it doesn't require an internet connection or third-party servers, making it a fast and reliable solution for local communication.

For more information on the LocalSend Protocol, see the [documentation](https://github.com/localsend/protocol).

---

## 🤝 Contributing

We welcome contributions! If you'd like to improve Meerkat, feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

---

## 📧 Contact

**Developer:** Chethan Krishna  
**GitHub:** [Chethan616/Meerkat](https://github.com/Chethan616/Meerkat)
