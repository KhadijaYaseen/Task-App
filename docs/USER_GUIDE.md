# Khawaja Labs — Task-App User & Administrator Guide

> **Author:** Mobile Engineering Team (Khawaja Labs)  
> **Target Audience:** Tech Lead (Saleem), Project Managers, and Engineering Team Members (Khadija Yaseen, Hamza Khan, Zain Ahmed)  
> **App Version:** `1.2.0`  

---

## 1. Executive Overview

Task-App is the unified **Internal Engineering Operations & Attendance Platform** built specifically for **Khawaja Labs**. It streamlines milestone delivery, eliminates task ambiguity through single-assignee exclusivity, and provides an integrated, confidential attendance engine.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Khawaja Labs Task-App                           │
│                                                                        │
│   👑 Tech Lead (Saleem)                  🚀 Team Member (Khadija)      │
│   • Assign & Manage Tasks                • View Personal Deliverables  │
│   • Register Employees & Gmail Invite    • Execute & Complete Tasks    │
│   • Audit All-Roster Attendance          • Punch In / Clock Out Shift  │
│   • Organization-wide Analytics          • Private Attendance History  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Authentication & Credentials Reference

The application features role-based access control (RBAC). Pre-configured accounts are listed below:

### 👑 Tech Lead / Administrator Account
* **Primary Admin:** Saleem (Software Architect & Tech Lead)
* **Email / ID:** `saleemali001232@gmail.com` *(or username: `admin` / `saleem`)*
* **Password:** `password123` *(or `admin123`)*
* **Permissions:** Full administrative control, team registration, all-roster attendance audit, deliverable creation and deletion.

### 🚀 Team Member Accounts
* **Engineer 1:** Khadija Yaseen (`khadijayaseen36@gmail.com`) — *Mobile Engineer*
* **Engineer 2:** Hamza Khan (`hamza@khawajalabs.com`) — *UI/UX Designer*
* **Engineer 3:** Zain Ahmed (`zain@khawajalabs.com`) — *Backend Developer*
* **Default Password:** `password123`
* **Permissions:** Personal task execution, personal attendance tracking, directory browsing.

---

## 3. Tech Lead & Administrator Operations (Saleem)

### 3.1 Logging in as Tech Lead
1. Open Task-App on your device or emulator.
2. Select the **Admin / Lead** tab.
3. Enter `saleemali001232@gmail.com` (or `admin`) and password `password123`.
4. Tap **`Login as Tech Lead (Saleem)`**.
5. The dashboard initializes with full administrative privileges.

---

### 3.2 Registering a New Employee & 1-Click Gmail Onboarding
1. Tap the **Team Directory** icon (`👥`) in the top navigation bar.
2. Tap the **`+ Add Member`** button.
3. Fill in the employee registration form:
   * **Full Name** (e.g. `Hamza Khan`)
   * **Designation / Role** (e.g. `UI/UX Designer`)
   * **Company Email** (e.g. `hamza@khawajalabs.com`)
   * **Initial Password** (default: `password123`)
   * Checkbox: **Grant Tech Lead Privileges** (Leave unchecked for standard engineers).
4. Tap **`✓ Save & Register Employee`**.
5. **Instant Gmail Dispatch:** A prompt appears asking if you want to dispatch login credentials. Tap **`Send via Gmail`** — the app automatically opens your native Gmail client with a pre-filled welcome email containing login credentials, app links, and security instructions.

---

### 3.3 Assigning Project Tasks (Single-Assignee Exclusivity)
1. On the Tasks dashboard, tap the purple **`+ New Task`** button in the top right.
2. Complete the deliverable details:
   * **Task Title:** Concise deliverable summary (e.g., *Integrate Supabase Auth*).
   * **Project Name:** Active project tag (e.g., *Task-App*).
   * **Assignee:** Select a registered team member from the dynamic dropdown.
   * **Priority Chip:** Choose **Urgent**, **High**, **Medium**, or **Low**.
   * **Target Due Date:** Select the deadline date.
3. Tap **`Assign Task`**.
4. **Collision Guard:** If an identical task title already exists in the same project, Task-App prevents duplicate assignment and displays:
   > *"Task is already assigned to [Assignee]. Each task is exclusively assigned to one team member."*

---

### 3.4 Tech Lead Attendance Audit & Roster Monitoring
1. Tap the **`Attendance`** tab in the segmented navigation bar.
2. As Tech Lead, you will see the **Tech Lead Attendance Controls** banner.
3. Use the horizontal **Filter Chips** carousel:
   * **`All Roster`**: Displays complete organizational logs.
   * **`Khadija Yaseen`**: Filters directly to Khadija's verified punch history.
   * **`Saleem`**: Filters directly to Tech Lead logs.
4. **Attendance Ledger:** Review exact Check-In times, Check-Out times, total hours worked, and operational remarks (e.g., *"Architecture Sync Call with Saleem & Sprint Review"*).

---

### 3.5 Organizational Analytics & Workload Distribution
1. Tap the **`Analytics`** tab in the top navigation bar.
2. Review real-time metrics:
   * **Completion Rate:** Percentage of finished vs. active deliverables.
   * **Team Workload Breakdown:** Visual allocation chart displaying task counts per team member.
   * **Priority Distribution:** High-contrast charts highlighting urgent bottlenecks.

---

## 4. Team Member Operations (Khadija Yaseen)

### 4.1 Logging in as a Team Member
1. Open Task-App.
2. Select the **Team Member** tab.
3. Tap your user card (e.g. **Khadija Yaseen**).
4. Tap **`Continue as Khadija Yaseen`** (or enter your password `password123` if prompted).
5. The dashboard opens configured to your personalized workspace.

---

### 4.2 Managing & Executing Assigned Deliverables
1. **Filtering Your Work:** Tap the **`My Tasks`** chip on the task dashboard to filter out other team members' tasks and view solely your assigned deliverables.
2. **Smart Search:** Type `"my task"`, `"mine"`, or deliverable keywords in the search bar.
3. **Updating Status:** Tap the square checkbox on your task card to toggle between **In Progress** and **Completed**. The dashboard counters update dynamically.
4. **Security Protection:** Non-admin members cannot delete company tasks or reassign deliverables to other team members without Tech Lead authentication.

---

### 4.3 Attendance Engine: Clocking In & Out
1. Tap the **`Attendance`** tab in the top navigation bar.
2. **Clocking In:** Tap the **`Clock In`** button on the purple Hero Card.
   * The status badge immediately switches to **`● CLOCKED IN`** in emerald green.
   * The live ticking clock begins counting your hours in real-time (`00:00:01`, `00:00:02`...).
   * Your clock-in time (e.g. `8:44 PM`) is recorded in the **CLOCK IN** metric pill.
3. **Clocking Out:** When your shift concludes, tap **`Clock Out`**.
   * The timer pauses, and exact hours logged are calculated.
   * A confirmation notification displays:  
     > *"Clocked out successfully at [Time]. Logged [X]h today!"*

---

### 4.4 In-App Shift Timing Customization (✏️ Edit Feature)
If your working hours or shift schedule change (e.g., from `8:00 PM – 12:00 AM` to `9:00 PM – 2:00 AM`):
1. On the purple Hero Attendance Card, locate the text:
   `Standard Shift: 8:00 PM – 12:00 AM ✏️`
2. Tap on the shift text or the **pencil icon** (`✏️`).
3. An **Edit Shift Timing** dialog appears:
   * **Shift Start:** Enter your start time (e.g., `8:00 PM` or `9:00 PM`).
   * **Shift End:** Enter your end time (e.g., `12:00 AM` or `2:00 AM`).
   * **Target Hours:** Enter your daily target (e.g., `4` or `5`).
4. Tap **`Save`**.
5. The shift badge, Shift Target metric pill, and Overtime calculator immediately adapt to your new schedule without requiring an app restart!

---

### 4.5 Confidentiality & Attendance History Calendar
* **Strict Privacy Rule:** Your attendance data is strictly confidential. Only you and Tech Lead Saleem can view your records. The app displays:
  > *"Confidential: Attendance is strictly private between you & Tech Lead (Saleem)."*
* **Calendar View:** The November 2026 calendar displays color-coded badges:
  * **`P` (Green):** Verified present day with recorded hours.
  * **`L` (Amber):** Approved leave or scheduled Sunday rest day.
* **Date Inspector:** Tap any calendar day to inspect check-in/out stamps and task remarks for that date.

---

## 5. Troubleshooting & FAQ

### Q1: What does "Right overflowed by X pixels" with yellow-black stripes mean?
* **Answer:** This is a Flutter responsive layout warning indicating that screen elements exceeded available horizontal width. In Version `1.2.0`, this has been permanently fixed by wrapping text columns in flexible constraint wrappers.

### Q2: Can a team member see another engineer's attendance?
* **Answer:** **No.** Non-admin members are strictly scoped to their own records. Only Tech Lead Saleem has administrative access to the All-Roster selector.

### Q3: What happens if internet connectivity drops?
* **Answer:** Task-App utilizes an offline-first architecture. If Supabase cannot be reached, the application seamlessly switches to local memory mode, allowing uninterrupted task toggling and attendance tracking.

### Q4: How do I share the APK with another team member?
* **Answer:** The release binary `TaskApp-v1.2.0-release.apk` is available in the GitHub Releases section and can be installed directly using Android package installer or via ADB:
  ```powershell
  adb install -r TaskApp-v1.2.0-release.apk
  ```
