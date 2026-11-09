# Task-App — Internal Project & Milestone Task Manager

A high-performance, offline-first **Task & Milestone Management Mobile Application** built for **Khawaja Labs** using **Flutter & Dart**, backed by **Supabase PostgreSQL** and styled with the **Cobalt Design System**.

---

## 🌟 Key Highlights

* **Enterprise Role-Based Access Control (RBAC):** Dedicated workflows for **Tech Lead / Admin** and **Team Members**.
* **1-Click Native Gmail Dispatch:** When an Admin adds a new team member, the app utilizes an Android `MethodChannel` to launch the device's native Gmail composer pre-filled with credentials and welcome onboarding instructions.
* **Single-Assignee Exclusivity Guard:** Tasks with identical titles cannot be duplicated within the same project, preventing duplicate effort and overlapping deliverables.
* **Project-Scoped Task Management:** Organize deliverables with priority tags (`Urgent`, `High`, `Medium`, `Low`), target deadlines, and project groupings.
* **Visual Analytics & Reporting:** Real-time metrics including completion rates, overdue vs. upcoming distribution, and team workload summaries.
* **Offline-Resilient Architecture:** Real-time Supabase cloud sync with seamless local fallback to ensure zero downtime during network disruptions.

---

## 🏗️ Architecture & Tech Stack

```
task_app/
├── android/                 # Native Android configuration
│   └── app/src/main/kotlin/ # Custom Kotlin MethodChannel (native mailto intent)
├── lib/
│   ├── models/              # Immutable domain entities (Employee, TaskItem, TaskStatus)
│   ├── screens/             # Feature screens
│   │   ├── login_screen.dart   # Role-based authentication & profile picker
│   │   ├── stats_screen.dart   # Interactive visual analytics & charts
│   │   └── team_screen.dart    # Team roster management & onboarding modal
│   ├── services/            # Supabase REST client with offline fallback
│   ├── theme/               # Cobalt theme tokens, color palettes, and styling
│   ├── widgets/             # Reusable UI components (tactile 3D keys, badges, cards)
│   └── main.dart            # App entrypoint, state management & dashboard
├── test/
│   └── widget_test.dart     # Comprehensive unit & widget test suite (8/8 green)
└── pubspec.yaml             # Project dependencies and asset definitions
```

### Technology Highlights
* **Framework:** Flutter (Channel stable)
* **Language:** Dart 3.x
* **Backend:** Supabase REST API (PostgreSQL)
* **Platform Bridge:** Kotlin `MethodChannel` (`com.khawajaalabs.task_app/email`) for direct Android Intent handling without third-party plugin overhead.

---

## 🔐 Authentication & Roles

### 1. 👑 Tech Lead / Administrator (Saleem)
* **Default Admin ID:** `saleemali001232@gmail.com` *(or `admin` / `saleem`)*
* **Default Password:** `admin123` *(or `saleem123`)*
* **Privileges:**
  * Add, manage, and delete team members.
  * Create, edit, reassign, and delete project tasks.
  * Set initial passwords and dispatch credentials via Gmail.
  * Full access to organizational analytics and team workload.

### 2. 🚀 Team Member
* **Privileges:**
  * View assigned deliverables across projects.
  * Update personal task progress (`In Progress` ⇄ `Completed`).
  * Browse the team directory.
  * Read-only protection: Non-admin members cannot delete or alter other members' deliverables.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK `^3.5.0` or later
* Android SDK (API 34+ recommended)
* Physical Android device or Android Emulator

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/khawajaalabs/Task-App.git
   cd Task-App
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run automated tests:**
   ```bash
   flutter test
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

5. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```
   The compiled APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🧪 Automated Testing

The test suite covers full user journeys, edge cases, RBAC guards, and search filters:

```bash
flutter test
```

### Test Suite Coverage:
| Test Case | Scope |
| :--- | :--- |
| **Login & Dashboard Flow** | Company identity render, Admin authentication, Dashboard navigation |
| **Admin Login Validation** | Rejection of invalid credentials with clear feedback |
| **Team Member Sign-in** | Single-tap profile selection and personal deliverable sync |
| **Task Lifecycle (CRUD)** | Task creation with due dates, in-place edit, and delete confirmation |
| **Analytics Dashboard** | Metric summaries, completion status, and chart distribution |
| **RBAC Task Guard** | Non-admins cannot edit/delete deliverables and cannot toggle peer tasks |
| **Duplicate Exclusivity** | Project-scoped title collision prevention |
| **Smart Search Filter** | Multi-keyword search across titles, assignees, and `"my task"` |

All 8 tests pass with **0 errors**.

---

## 📄 License & Attribution

Internal software developed for **Khawaja Labs**. Designed and maintained for production operational workflow.
