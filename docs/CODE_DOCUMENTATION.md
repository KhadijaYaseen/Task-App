# Task-App — Technical Code Documentation

> **Khawaja Labs Internal Engineering Standards**  
> **Repository:** [https://github.com/khawajaalabs/Task-App](https://github.com/khawajaalabs/Task-App)  
> **Application Version:** `1.2.0` (Build `12`)  
> **Framework:** Flutter (Channel stable, Dart 3.x)  
> **Target Platforms:** Android (API Level 26–34+), Web, Windows  

---

## 1. Architectural Architecture Overview

Task-App is engineered as a layered, modular Flutter enterprise client application following the **Clean Architecture** and **Model-View-Service** (MVS) design patterns. It operates on an **offline-first resilience model**, interfacing with a remote Supabase PostgreSQL database while maintaining in-memory state fallbacks to guarantee uninterrupted operations during network degradation.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Presentation Layer (UI)                         │
│                                                                        │
│  ┌──────────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │     LoginScreen      │  │  TaskDashboard   │  │ AttendanceScreen │  │
│  │ (Auth & Role Picker) │  │  (main.dart)     │  │  (Clock & Shifts)│  │
│  └──────────┬───────────┘  └────────┬─────────┘  └────────┬─────────┘  │
│             │                       │                     │            │
│  ┌──────────┴───────────┐  ┌────────┴─────────┐           │            │
│  │       TeamScreen     │  │   StatsScreen    │           │            │
│  │   (Roster & Invites) │  │ (Visual Metrics) │           │            │
│  └──────────────────────┘  └──────────────────┘           │            │
└─────────────────────────────────────┬─────────────────────┼────────────┘
                                      │                     │
┌─────────────────────────────────────▼─────────────────────▼────────────┐
│                         State & Theme Layer                            │
│                                                                        │
│  ┌───────────────────────────┐         ┌────────────────────────────┐  │
│  │        CobaltTheme        │         │      CobaltKey Widgets     │  │
│  │ (Design Tokens & Palettes)│         │   (Tactile 3D Keycaps)     │  │
│  └───────────────────────────┘         └────────────────────────────┘  │
└─────────────────────────────────────┬──────────────────────────────────┘
                                      │
┌─────────────────────────────────────▼──────────────────────────────────┐
│                          Data & Model Layer                            │
│                                                                        │
│  ┌──────────────┐   ┌──────────────┐   ┌────────────────┐  ┌─────────┐ │
│  │   Employee   │   │   TaskItem   │   │AttendanceRecord│  │ Project │ │
│  └──────┬───────┘   └──────┬───────┘   └────────┬───────┘  └─────────┘ │
└─────────┼──────────────────┼────────────────────┼──────────────────────┘
          │                  │                    │
┌─────────▼──────────────────▼────────────────────▼──────────────────────┐
│                    Services & Platform Bridge                          │
│                                                                        │
│  ┌────────────────────────────────────┐ ┌───────────────────────────┐  │
│  │          SupabaseService           │ │    Kotlin MethodChannel   │  │
│  │   (REST v1 Client & Local Cache)   │ │  (Native com.khawaja/email│  │
│  └────────────────────────────────────┘ └───────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Directory & Package Structure

```
task_app/
├── android/
│   └── app/src/main/kotlin/com/khawajaalabs/task_app/
│       └── MainActivity.kt               # Native Android Intent handler for Gmail dispatch
├── docs/                                 # Official Engineering Documentation
│   ├── CODE_DOCUMENTATION.md             # Architecture, source code & module reference
│   ├── USER_GUIDE.md                     # Administrator & Team Member user manual
│   ├── SRS.md                            # Software Requirements Specification (IEEE 830)
│   ├── CASE_STUDY.md                     # Engineering Case Study & Business Impact
│   └── RELEASE_NOTES.md                  # Version release changelog
├── lib/
│   ├── models/                           # Immutable domain models & entity mappers
│   │   ├── attendance_record.dart        # Attendance entries, logs, status enums
│   │   ├── employee.dart                 # User profile, role flags, shift configurations
│   │   ├── project.dart                  # Project groupings & metadata
│   │   └── task_item.dart                # Tasks, subtasks, priorities, and statuses
│   ├── screens/                          # Top-level screen widgets
│   │   ├── attendance_screen.dart        # Real-time clock-in ticker, shifts, & calendar ledger
│   │   ├── login_screen.dart             # Role-based dual authentication flow
│   │   ├── stats_screen.dart             # Analytics engine, priority breakdown, charts
│   │   └── team_screen.dart              # Company roster, member registration & onboarding
│   ├── services/
│   │   └── supabase_service.dart         # PostgreSQL REST client with offline fallback
│   ├── theme/
│   │   └── cobalt_theme.dart             # Color tokens, typography, borders, shadows
│   ├── widgets/
│   │   └── cobalt_key.dart               # Tactile 3D mechanical button component
│   └── main.dart                         # Entrypoint, route manager, task dashboard
├── test/
│   └── widget_test.dart                  # Full automated UI & behavioral test suite (10/10)
├── pubspec.yaml                          # Package manifests and assets
└── README.md                             # High-level overview & installation manual
```

---

## 3. Domain Data Models

All models are immutable, support copy constructors (`copyWith`), and implement JSON serialization (`fromJson` / `toJson`).

### 3.1 `Employee` (`lib/models/employee.dart`)
Represents an engineering team member or tech lead within Khawaja Labs.

```dart
class Employee {
  final String id;
  final String name;
  final String role;
  final String initials;
  final String? email;
  final String? password;
  final bool isAdmin;
  final String shiftTiming; // e.g. '8:00 PM – 12:00 AM'
  final String shiftTarget; // e.g. '4h 00m'

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    this.email,
    this.password,
    this.isAdmin = false,
    this.shiftTiming = '8:00 PM – 12:00 AM',
    this.shiftTarget = '4h 00m',
  });
}
```

* **Static Singletons:** Pre-configured with active company identities:
  * `Employee.saleem` (Tech Lead & Software Architect, `isAdmin: true`, `saleemali001232@gmail.com`)
  * `Employee.khadija` (Mobile Engineer, `isAdmin: false`, `khadijayaseen36@gmail.com`)
  * `Employee.hamza` (UI/UX Designer)
  * `Employee.zain` (Backend Developer)
* **Serialization:** Dynamic extraction of shift timings and target hours with fallback defaults to ensure zero-crash JSON parsing.

---

### 3.2 `TaskItem` (`lib/models/task_item.dart`)
Represents a discrete engineering milestone or deliverable.

```dart
enum TaskStatus { todo, inProgress, review, done }
enum TaskPriority { urgent, high, medium, low }

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String projectName;
  final Employee assignee;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final int completedSubtasks;
  final int totalSubtasks;

  bool get isOverdue => status != TaskStatus.done && dueDate.isBefore(DateTime.now());
}
```

* **Single-Assignee Exclusivity Guard:** Tasks belong strictly to a single `Employee`.
* **Project Scoping:** Tasks are associated with `projectName` and `projectId`. Duplicate title checks evaluate `(title.toLowerCase() == newTitle.toLowerCase() && projectName == newProjectName)`.

---

### 3.3 `AttendanceRecord` (`lib/models/attendance_record.dart`)
Encapsulates individual attendance punch entries, working hours, and operational shift notes.

```dart
enum AttendanceStatus { present, leave, absent }

class AttendanceRecord {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkInTime;
  final String? checkOutTime;
  final double hours;
  final AttendanceStatus status;
  final String? notes;
}
```

* **Historical Seed Data:** Contains pre-populated historical ledger records for Khadija Yaseen (from October 19, 2026 to November 17, 2026) and Saleem.
* **Audit Metadata:** Records audit remarks such as `"Present (Attendance Engine & Shift Timing System Architecture)"` and `"Architecture Sync Call with Saleem & Sprint Review"`.

---

## 4. Service Architecture

### 4.1 `SupabaseService` (`lib/services/supabase_service.dart`)
Handles cloud persistence using Supabase's REST v1 API (`https://pdczfoykrdqjqxbedyny.supabase.co/rest/v1`).

```dart
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  static const String baseUrl = 'https://pdczfoykrdqjqxbedyny.supabase.co/rest/v1';
  static String anonKey = 'sb_publishable_...';
  static bool isTestMode = false;
  
  Future<Employee?> login(String emailOrUsername, String password);
  Future<List<TaskItem>> fetchTasks({required List<Employee> employees});
  Future<bool> createTask(TaskItem task);
  Future<bool> updateTask(TaskItem task);
  Future<bool> deleteTask(String taskId);
  Future<List<Employee>> fetchEmployees();
  Future<bool> createEmployee(Employee employee);
}
```

#### Offline Resilience Mechanism:
* If `isConfigured` is `false` or network connectivity fails (`SocketException`, HTTP `5xx`), all operations seamlessly fall back to local in-memory storage.
* Network timeouts do not block user interactions.

---

### 4.2 Native Android `MethodChannel` (`MainActivity.kt`)
Provides a zero-dependency platform bridge to dispatch native Android `Intent` requests for email onboarding.

* **Channel Name:** `com.khawajaalabs.task_app/email`
* **Method:** `openEmail`
* **Payload:** `{ to: String, subject: String, body: String }`
* **Intent Strategy:** Primary attempt uses `Intent.ACTION_SENDTO` with `mailto:`. On failure, gracefully falls back to `Intent.ACTION_SEND` (`message/rfc822`) via `Intent.createChooser()`.

```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.khawajaalabs.task_app/email").setMethodCallHandler { call, result ->
    if (call.method == "openEmail") {
        val to = call.argument<String>("to") ?: ""
        val subject = call.argument<String>("subject") ?: ""
        val body = call.argument<String>("body") ?: ""
        // Launches native email app with pre-filled onboarding credentials
    }
}
```

---

## 5. UI Architecture & Screen Modules

### 5.1 `LoginScreen` (`lib/screens/login_screen.dart`)
Dual-mode enterprise authentication system:
1. **Tech Lead / Admin Form:** Email / username and password validation against Supabase and local administrative fallbacks.
2. **Team Member Fast-Switch:** One-tap profile cards displaying user initials, designations, and quick-access session bootstrap.

---

### 5.2 `TaskDashboard` (`lib/main.dart`)
The operational hub of the app, comprising:
* **Tactile Top Navigation Bar:**
  * Context-aware title (`Company Tasks` / `Back to Tasks`)
  * Team Roster shortcut button
  * User profile initials avatar
  * Dynamic Action Button: `+ New Task` keycap on Tasks tab; purple tactile `Tasks` keycap on secondary tabs.
* **Segmented Filter Tray:** `All`, `My Tasks`, `In Progress`, `Completed`.
* **Smart Search Engine:** Instant filter supporting task titles, assignee names, and the natural language keyword `"my task"` / `"mine"`.
* **Exclusivity Enforcement:** Modal task creation dialog checks existing project tasks to prohibit title collisions.
* **Task Card Interactive Components:**
  * Status toggle checkbox
  * Assignee chip with color-coded avatar
  * Priority indicator badge
  * Hover glow micro-interaction (`Border.all(color: CobaltTheme.purpleBorder)`) without permanent visual clutter.

---

### 5.3 `AttendanceScreen` (`lib/screens/attendance_screen.dart`)
Comprehensive attendance logging and shift control dashboard:
* **Live Dynamic Ticking Clock:** Background `dart:async` `Timer.periodic(1 second)` ticking in real-time when the user is clocked in. Automatically suppressed during automated headless tests (`bindingStr.contains('Test')`).
* **Hero Punch Card:**
  * Active Clock Status badge (`CLOCKED IN` in emerald green vs. `OFFLINE` in slate).
  * Real-time timer format: `HH:mm:ss`.
  * Dynamic shift timing label: `Standard Shift: 8:00 PM – 12:00 AM ✏️`.
  * Responsive constraint layout: Title and timer wrapped in `Flexible` widgets to prevent pixel overflow errors on all display densities.
* **In-App Shift Timing Customization:**
  * Tapping the edit icon opens `_showEditShiftDialog()`.
  * Allows live modification of Shift Start Time, Shift End Time, and Target Hours.
  * Dynamically recalculates Target Hours and Overtime counters without restarting the session.
* **Role-Based Privacy Boundary:**
  * **Team Member (Khadija):** Sees only their personal attendance records and confidentiality banner:
    > *"Confidential: Attendance is strictly private between you & Tech Lead (Saleem)."*
  * **Tech Lead (Saleem):** Sees the Tech Lead Attendance Controls banner and an **All Roster** filter chip carousel (`All Roster`, `Khadija Yaseen`, `Saleem`, etc.).
* **Interactive Monthly Calendar:** Custom grid widget for November 2026 rendering day-by-day status indicators (`P` for Present in green, `L` for Leave/Sunday in amber).

---

### 5.4 `StatsScreen` (`lib/screens/stats_screen.dart`)
Executive analytics and engineering health monitor:
* **Summary Metric Cards:** Total Tasks, Completion Rate, In-Progress Velocity, Overdue Alerts.
* **Workload Distribution Chart:** Visual capacity and task allocation per team member.
* **Priority Distribution Breakdown:** Urgent, High, Medium, and Low deliverable tracking.

---

### 5.5 `TeamScreen` (`lib/screens/team_screen.dart`)
Directory management and onboarding pipeline:
* **Roster List:** Displays role, contact email, and administrative status for each company employee.
* **Admin Verification Barrier:** Non-admin users attempting to register new members are prompted for the Tech Lead administrative password.
* **Direct Gmail Dispatch:** After creating an employee, offers instant 1-tap dispatch of login credentials via native Android Gmail.

---

## 6. Design System: Cobalt Theme Tokens

The application strictly adheres to the **Cobalt Design System** (`lib/theme/cobalt_theme.dart`):

| Token Name | Hex Code | Purpose |
|:---|:---|:---|
| `CobaltTheme.cobalt` | `#1D4ED8` | Electric cobalt accent & primary brand identity |
| `CobaltTheme.purplePrimary` | `#7C3AED` | Royal purple accent (actions, attendance hero, focused inputs) |
| `CobaltTheme.purpleLight` | `#EDE9FE` | Purple background tint for active tabs & badges |
| `CobaltTheme.purpleBorder` | `#DDD6FE` | Subtle border tint for focused inputs & active cards |
| `CobaltTheme.paper` | `#FFFFFF` | Primary surface background |
| `CobaltTheme.paper2` | `#F8FAFC` | Secondary grouped container background |
| `CobaltTheme.ink` | `#0F172A` | High-contrast slate typography & headings |
| `CobaltTheme.ink2` | `#475569` | Subtitles, labels, and secondary body text |
| `CobaltTheme.muted` | `#94A3B8` | Disabled text, icons, and placeholder strings |
| `CobaltTheme.rule` | `#E2E8F0` | Dividers and structural hairline borders |
| `CobaltTheme.statusSuccess` | `#10B981` | Completed tasks & Clocked-in emerald badge |
| `CobaltTheme.statusError` | `#EF4444` | Urgent priority, overdue tasks & Clock-out button |
| `CobaltTheme.statusWarning` | `#F59E0B` | In-progress status & Overtime warning chip |

---

## 7. Testing & Quality Assurance Suite

The test suite (`test/widget_test.dart`) covers 10 critical end-to-end integration and widget assertions:

```bash
flutter test
```

### Test Coverage Matrix:
1. `Cobalt Task Manager Login and Dashboard flow test` — Verifies default bootstrap, task rendering, and tab transitions.
2. `Admin Login validates incorrect credentials` — Tests authentication denial on invalid password strings.
3. `Team Member Login flow works seamlessly` — Verifies profile selection and session setup.
4. `Task Creation with Due Date, Edit, and Delete flow` — Validates full CRUD lifecycles on deliverables.
5. `Analytics Tab renders Task Summary and metrics correctly` — Tests metric calculation consistency.
6. `Non-admin team member cannot edit or delete tasks and can only toggle own tasks` — Asserts RBAC constraints.
7. `Duplicate task validation is project-scoped` — Verifies Single-Assignee Exclusivity rules.
8. `Smart Search filters by title, assignee name, and "my task" keyword` — Tests algorithmic query engine.
9. `Attendance Tab renders Hero Clock In card, Calendar, and Attendance Ledger for Admin` — Verifies attendance UI controls.
10. `Attendance Role Privacy Guard: Non-admin only sees own records and confidentiality notice` — Validates strict privacy boundaries.

**Test Results:** `10/10 Passed (100% Green)`  
**Static Analysis:** `dart analyze` reports `No issues found! (0 errors, 0 warnings)`.

---

## 8. Build & Deployment Pipeline

### 8.1 Release APK Compilation
To generate an optimized, tree-shaken Android production release binary:
```powershell
flutter build apk --release
```
* **Output Path:** `build/app/outputs/flutter-apk/app-release.apk`
* **Distribution Binary:** `TaskApp-v1.2.0-release.apk`
* **Binary Size:** 51.8 MB (Tree-shaken Material icon font size reduction: 99.3%)
* **Architectures:** `armeabi-v7a`, `arm64-v8a`, `x86_64`

### 8.2 Installation via Android Debug Bridge (ADB)
```powershell
adb install -r TaskApp-v1.2.0-release.apk
```
