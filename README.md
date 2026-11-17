# Task-App — Internal Project & Milestone Task Manager

> **Khawaja Labs Engineering Ecosystem**  
> **Production Release:** `v1.2.0`  
> **Framework:** Flutter (Dart 3.x) & Android Kotlin Native Bridge  
> **Backend:** Supabase PostgreSQL with Offline Fallback  
> **Design System:** Hallmark Cobalt (Modern Minimal)  

---

## 📚 Official Documentation Suite

Comprehensive technical, functional, and operational documentation is available in the [`docs/`](docs/) directory:

| Document | File Link | Description |
|:---|:---|:---|
| **Code Documentation** | [**`docs/CODE_DOCUMENTATION.md`**](docs/CODE_DOCUMENTATION.md) | Architectural diagrams, data models (`Employee`, `TaskItem`, `AttendanceRecord`), services, Kotlin `MethodChannel`, and build pipelines. |
| **User & Admin Guide** | [**`docs/USER_GUIDE.md`**](docs/USER_GUIDE.md) | Complete operational manual for Tech Lead (Saleem) and Team Members (Khadija Yaseen), covering tasks, Gmail invites, attendance clocking, and shift edits. |
| **Software Requirements (SRS)** | [**`docs/SRS.md`**](docs/SRS.md) | Formal IEEE 830 specification defining all functional requirements (FR-1 through FR-10), non-functional constraints, and acceptance criteria. |
| **Engineering Case Study** | [**`docs/CASE_STUDY.md`**](docs/CASE_STUDY.md) | Detailed case study highlighting operational challenges, architectural solutions, single-assignee exclusivity, and business impact metrics. |
| **Release Notes v1.2.0** | [**`docs/RELEASE_NOTES.md`**](docs/RELEASE_NOTES.md) | Changelog, distribution binary artifacts, installation procedures, and credential reference. |

---

## 🌟 Key Application Features

* **Enterprise Role-Based Access Control (RBAC):** Tailored operational modes for **Tech Lead / Admin (Saleem)** and **Team Members (Khadija Yaseen, Hamza Khan, Zain Ahmed)**.
* **Single-Assignee Exclusivity Engine:** Tasks cannot be duplicated or ambiguously shared within a project, completely eliminating task collisions.
* **Real-Time Attendance Engine:** Interactive hero card with a live dynamic ticking clock (`HH:mm:ss`), punch-in/out stamps, and exact hours logged calculation.
* **In-App Shift Schedule Customization:** Engineers can adjust shift timings (`8:00 PM – 12:00 AM` or `9:00 PM – 2:00 AM`) and target hours on-the-fly using the ✏️ edit tool without requiring app redeployment.
* **Attendance Confidentiality Guard:** Strict architectural privacy barrier ensuring team members view only their personal records while granting the Tech Lead an All-Roster audit view.
* **1-Click Native Gmail Dispatch:** Android `MethodChannel` (`com.khawajaalabs.task_app/email`) launches the native Gmail composer pre-filled with credentials upon adding a new team member.
* **Visual Engineering Analytics:** Real-time metrics including completion velocity, workload capacity charts, and priority breakdowns.
* **Offline-Resilient Architecture:** Real-time Supabase PostgreSQL sync with seamless in-memory fallback during network drops.

---

## 🔑 Access Credentials

| Role | Name | Email / ID | Password | Access Level |
|:---|:---|:---|:---|:---|
| **Tech Lead / Admin** | Saleem | `saleemali001232@gmail.com` *(or `admin`)* | `password123` *(or `admin123`)* | Full Admin (Tasks, Team, All-Roster Attendance) |
| **Mobile Engineer** | Khadija Yaseen | `khadijayaseen36@gmail.com` | `password123` | Team Member (Own Tasks, Private Attendance) |
| **UI/UX Designer** | Hamza Khan | `hamza@khawajalabs.com` | `password123` | Team Member |
| **Backend Developer**| Zain Ahmed | `zain@khawajalabs.com` | `password123` | Team Member |

---

## 🏗️ Technical Architecture

```
task_app/
├── android/app/src/main/kotlin/com/khawajaalabs/task_app/
│   └── MainActivity.kt               # Native Kotlin MethodChannel (Gmail Intent)
├── docs/                             # Engineering Documentation
│   ├── CODE_DOCUMENTATION.md         # Full code & architecture reference
│   ├── USER_GUIDE.md                 # Complete User & Admin manual
│   ├── SRS.md                        # IEEE 830 Software Requirements Specification
│   ├── CASE_STUDY.md                 # Project Case Study & Impact
│   └── RELEASE_NOTES.md              # v1.2.0 Release Notes
├── lib/
│   ├── models/                       # Domain entities (Employee, TaskItem, AttendanceRecord)
│   ├── screens/                      # Screens (Login, Dashboard, Attendance, Stats, Team)
│   ├── services/                     # Supabase REST client with offline fallback
│   ├── theme/                        # Cobalt design tokens & palettes
│   ├── widgets/                      # Tactile 3D CobaltKey buttons
│   └── main.dart                     # App entrypoint, state management & dashboard
├── test/
│   └── widget_test.dart              # Automated widget & unit test suite (10/10 green)
└── pubspec.yaml                      # Dependencies and asset definitions
```

---

## 🚀 Installation & Release Artifacts

### 1. Download Release Binary (APK)
The production-optimized release binary is available:
* **Release File:** `TaskApp-v1.2.0-release.apk` (Size: 51.8 MB)
* **Local Path:** `C:\Users\Hp\Desktop\TaskApp-v1.2.0-release.apk`
* **Direct Install via ADB:**
  ```powershell
  adb install -r TaskApp-v1.2.0-release.apk
  ```

### 2. Development Setup
```bash
# Clone the repository
git clone https://github.com/khawajaalabs/Task-App.git
cd Task-App

# Install packages
flutter pub get

# Run static analysis
dart analyze

# Run automated tests
flutter test

# Run application
flutter run
```

---

## 🧪 Quality Assurance & Test Verification

```
00:05 +10: All tests passed!
Analyzing task_app...
No issues found!
```
* **Test Suite:** `10 / 10 Passing (100% Green)`
* **Static Analysis:** `0 Warnings, 0 Errors`
* **Performance:** Sub-1.8s startup, 60fps animations, 99.3% Material icon tree-shaking reduction.
