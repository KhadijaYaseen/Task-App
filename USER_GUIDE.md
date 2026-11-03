# Khawaja Labs — Task-App User & Administrator Guide

A modern, high-contrast, offline-ready **Company Task & Project Management Mobile Application** built in Flutter & Dart, engineered strictly following Hallmark's **Cobalt (Modern Minimal)** design system.

---

## 📱 Executive Overview

Task-App is designed for internal engineering and project management at **Khawaja Labs**. It bridges the gap between project planning and milestone execution through:
* **Role-Based Access Control (RBAC):** Strict boundaries between Tech Lead administration and Team Member deliverable execution.
* **Single-Assignee Exclusivity:** Guarantees that deliverables cannot be duplicated or ambiguously owned across team members.
* **Authentic Hallmark Cobalt Design:** Tactile 3D keycaps (`.key`, `.key--primary`), high-contrast slate ink typography, crisp 8px cards, and electric cobalt `#1D4ED8` accents.

---

## 🔑 Login & Access Credentials

The application provides two tailored sign-in modes on launch:

### 1. 👑 Tech Lead / Administrator (Saleem)
* **Access Level:** Full administrative privileges (Assign tasks, add team members, full directory access).
* **Admin ID:** `admin` *(or `saleem` / `saleem@khawajalabs.com`)*
* **Password:** `admin123` *(or `saleem123`)*

### 2. 🚀 Team Member (Khadija Yaseen, Hamza Khan, Zain Ahmed)
* **Access Level:** View assigned deliverables, track progress, toggle status (`In Progress` ⇄ `Completed`), and browse the team directory.
* **Authentication:** One-tap profile selection.
* **Security Guard:** If a team member attempts an administrative action (e.g. creating milestones or adding employees), the app dynamically prompts for the Tech Lead verification pass.

---

## 🧭 Step-by-Step Feature Walkthrough

### 1. Authentication & Session Initialization
1. Launch the app on your Android device.
2. Under the **`👑 Admin / Lead`** tab, enter `admin` and `admin123`, then tap **`Login as Tech Lead (Saleem)`**.
3. To test the team member experience, tap **`Switch`** in the top session banner, navigate to **`🚀 Team Member`**, select **`Khadija Yaseen`**, and tap **`Continue as Khadija Yaseen`**.

---

### 2. Team Directory & Dynamic Member Registration (Lead Only)
1. Tap the **Team Icon** (`👥`) in the top navigation bar to open the **Company Team Roster**.
2. Tap **`+ Add Member`** to register a new employee.
3. Fill in:
   * **Full Name** (e.g., *Farhan Akhtar*)
   * **Designation / Role** (e.g., *QA Automation Engineer*)
   * **Company Email** (Optional)
   * Checkbox: *Grant Tech Lead / Admin Privileges* (if applicable)
4. Tap **`✓ Save & Register Employee`**.
5. The new member is immediately registered in memory and becomes available across:
   * The **Assignee Picker** when creating new tasks.
   * The **Team Member Sign-in** screen.
   * The active company roster.

---

### 3. Assigning Milestone Deliverables (Lead Only)
1. From the Dashboard, tap the tactile **`+ New Task`** keycap in the top right.
2. Enter:
   * **Task Title:** Clean deliverable name (e.g., *Setup SQLite Local Cache*).
   * **Project Name:** Company project (e.g., *Task-App* or *Mobile Starter Template*).
   * **Assignee:** Choose an employee from the dynamic dropdown (pre-populated with all registered company members).
   * **Priority:** Tap one of the high-contrast priority chips (**URGENT**, **HIGH**, **MEDIUM**, **LOW**).
3. Tap **`Assign Task`**.
4. **Exclusivity Enforcement:** If an active task with the same title already exists, the app rejects duplicate collision and displays:  
   > *"Task is already assigned to [Assignee Name]. Each task is exclusively assigned to one team member."*

---

### 4. Tracking & Completing Deliverables (Team Member View)
1. Switch session to a team member (e.g. **Khadija Yaseen**).
2. The Dashboard displays:
   * **Session Banner:** Confirming active member identity.
   * **Executive Metric Ledger:** Real-time counters for **Active**, **In Progress**, and **Completed** tasks.
   * **`My Tasks` Filter:** Tap the `My Tasks` tab in the segmented tray to instantly filter down to deliverables assigned specifically to your profile.
3. **Updating Task Status:** Tap the square checkbox on any task card to toggle between **In Progress** and **Completed**. The metric counters and strike-through styling update reactively.
4. **Jump Search Bar (`⌘ K`):** Type in the jump bar to filter tasks by title or project name on the fly.

---

## 📊 Role-Based Access Control (RBAC) Matrix

| Capability | Tech Lead (Saleem) | Team Member (Khadija / Team) |
| :--- | :---: | :---: |
| **Login via Admin ID & Password** | ✅ | ❌ |
| **One-Tap Profile Sign-in** | ❌ | ✅ |
| **View Company Deliverables** | ✅ | ✅ |
| **Filter by Personal Workload (`My Tasks`)** | ✅ | ✅ |
| **Update Task Status (`In Progress` / `Done`)** | ✅ | ✅ |
| **Create & Assign Milestone Deliverables** | ✅ | 🔒 (Requires Admin Pass) |
| **Register New Employees (`+ Add Member`)** | ✅ | 🔒 (Requires Admin Pass) |
| **Delete Deliverables** | ✅ | ✅ |

---

## 🛠️ Build & Installation Reference

### Installing via APK
The pre-compiled Android Application Package (APK) can be installed directly on any Android 8.0+ device or emulator:
```bash
adb install -r TaskApp.apk
```

### Running from Source
```bash
# Fetch dependencies
flutter pub get

# Run automated test suites (All pass green)
flutter test

# Launch on connected device/emulator
flutter run
```

---
*© 2026 Khawaja Labs. Engineered for internal operations and team excellence.*
