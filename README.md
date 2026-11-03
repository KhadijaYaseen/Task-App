# Task-App (Company Project & Milestone Task Manager)

A modern, high-contrast, offline-ready **Company Task & Milestone Management Mobile Application** built with **Flutter & Dart**, styled using Hallmark's authentic **Cobalt (Modern Minimal)** design system.

---

## 📖 Documentation & Guides
* **Comprehensive User & Admin Guide:** [USER_GUIDE.md](USER_GUIDE.md)
* **Company Repository:** [https://github.com/khawajaalabs/Task-App](https://github.com/khawajaalabs/Task-App)

---

## 📱 Core Features & Architecture

### 1. Role-Based Authentication (RBAC)
* **Tech Lead / Admin Mode (Saleem):**
  * Secure sign-in using Admin ID (`admin` / `saleem`) and Password (`admin123` / `saleem123`).
  * Privileges: Full rights to dynamically register employees, create milestones, and assign tasks.
* **Team Member Mode (Khadija Yaseen, Hamza Khan, Zain Ahmed):**
  * One-tap authenticated profile selection.
  * Privileges: Track personal deliverables, update status (`In Progress` ⇄ `Completed`), and browse the company team directory.
  * **Admin Security Guard:** Prompts for Tech Lead credentials if unauthorized members attempt administrative operations.

### 2. Company Team Roster (Dynamic Member Management)
* Dynamic employee directory enabling the Tech Lead to add team members with Full Name, Role, and Company Email.
* Newly registered members immediately become eligible assignees across task creation forms and profile logins.

### 3. Milestone Task Assignment & Single-Assignee Exclusivity
* Milestone creation with Priority levels (**URGENT**, **HIGH**, **MEDIUM**, **LOW**).
* **Single-Assignee Exclusivity:** Guarantees that deliverables cannot be duplicated or ambiguously assigned across multiple members.

### 4. Hallmark "Cobalt" Modern Minimalist Design System
* **Tactile 3D Keycaps:** Physical button depression (`.key`, `.key--primary`) with solid border shadows.
* **Jump Search Bar (`⌘ K`):** Quick real-time filtering across active projects and task titles.
* **Executive Metric Ledger:** Instant overview of Active, In Progress, and Completed milestones.
* **Color Palette:** Pure paper `#FAFBFC`, Deep slate ink `#0F172A`, Crisp borders `#CBD5E1`, and Electric Cobalt `#1D4ED8`.

---

## 🚀 Getting Started

### Installing via Pre-built APK
A standalone, production-optimized APK is available in the root:
```bash
adb install -r TaskApp.apk
```

### Running from Source
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run automated tests (100% green)
flutter test

# 3. Launch application on emulator or connected device
flutter run
```

---

## 🧪 Automated Testing
```bash
flutter test
```
All unit and widget test suites pass with 0 errors.

---
*© 2026 Khawaja Labs. Engineered for internal operations and team excellence.*
