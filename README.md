<div align="center">

# 💊 Vitaria

**Smart medication adherence app — never miss a dose, identify pills with AI, and keep your schedule in sync.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Backend](https://img.shields.io/badge/Backend-Python-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)

</div>

---

## Overview

Vitaria is a cross-platform mobile app that helps users stay on top of their medication. It combines smart reminders, AI-driven pill identification, and Google Calendar sync into one straightforward experience. Originally built as a PBL (project-based learning) team project.

## Features

- 🔔 **Smart reminders** — schedule-aware notifications for every dose
- 📷 **AI pill identification** — point your camera at a tablet, get a match
- 📅 **Calendar sync** — medication events appear in Google Calendar
- 🔒 **Secure storage** — sensitive medical data is kept encrypted at rest
- 🩺 **Medical assistant** — ask questions about your meds and adherence

## Repository Layout

```
.
├── Frontend/               # Flutter app (Android + iOS)
│   ├── lib/                # Dart UI and state management
│   ├── Assets/images/      # Logos and illustrations
│   ├── android/            # Android-specific code
│   └── ios/                # iOS-specific code
├── backend/                # API server
├── home.md                 # Landing page copy
├── privacy_policy.md       # Privacy policy
└── terms_of_service.md     # Terms of service
```

## Getting Started

### Frontend (Flutter)

```bash
git clone https://github.com/bhavya-x/Vitaria.git
cd Vitaria/Frontend
flutter pub get
flutter run                          # default device
flutter build apk --release          # Android release build
```

### Backend

```bash
cd Vitaria/backend
pip install -r requirements.txt
# Configure environment variables, then:
python main.py
```

## Team

Vitaria was built collaboratively. Original co-contributors retained in commit history:
- [@Codexghost1711](https://github.com/Codexghost1711)
- [@VaradDurge](https://github.com/VaradDurge)

## Legal

- [Privacy Policy](privacy_policy.md)
- [Terms of Service](terms_of_service.md)
