# Release Notes — Task-App v1.2.0

> **Khawaja Labs Engineering Release**  
> **Release Tag:** `v1.2.0`  
> **Date:** November 17, 2026  
> **Target Platform:** Android (API Level 26–34+)  
> **Binary Name:** `TaskApp-v1.2.0-release.apk` (51.8 MB)  
> **Architecture Support:** `armeabi-v7a`, `arm64-v8a`, `x86_64`  

---

## 🚀 Highlights of Release 1.2.0

### 1. 🕒 Live Attendance Engine & Dynamic Punch Card
* **Interactive Hero Card:** Features real-time `HH:mm:ss` counter with dynamic ticker, active `CLOCKED IN` badge (emerald green), and `OFFLINE` badge (slate).
* **Shift Timing & Target Integration:** Seamlessly reads per-employee shift configurations (`8:00 PM – 12:00 AM`, `4h 00m` daily target).
* **Dynamic Target Parsing:** Robust regex parsing handles varying formats (`4h 00m`, `5h 00m`) without fallback degradation.

### 2. ✏️ In-App Shift Schedule Customization
* **On-the-Fly Editing:** Tapping the pencil icon (`✏️`) on the Hero Card opens an intuitive edit dialog.
* **Instant Recalculation:** Adjust shift start time, end time, and target hours; active shift badges and overtime counters update instantly in-memory without restarting.

### 3. 🛡️ Role-Based Attendance Privacy Barrier
* **Team Member Privacy:** Engineers (e.g. Khadija Yaseen) are restricted to viewing only their own verified attendance logs.
* **Tech Lead Audit Controls:** Tech Lead Saleem has administrative access to an All-Roster selector with horizontal filter chips to audit and review company attendance.

### 4. 🎨 Cobalt Design System & UI Refinements
* **Tactile Purple Tasks Pill:** The top-right keycap dynamically renders as a high-contrast purple primary keycap on secondary tabs.
* **Constraint Layout Hardening:** Wrapped hero card column elements in `Flexible` containers with ellipsis overflow styling, permanently resolving the `0.753px right overflow` issue on high-density displays.
* **Refined Task Hover Micro-Interactions:** Replaced permanent borders with interactive, hover-only purple glow borders.

### 5. 📧 Native Android Gmail Onboarding Bridge
* Zero-dependency native Kotlin `MethodChannel` (`com.khawajaalabs.task_app/email`) directly dispatches onboarding credentials via Android `Intent.ACTION_SENDTO`.

### 6. 🧪 100% Automated Test Suite (10/10 Passing)
* Automated integration test suite fully updated and verified green (`10/10 passed`).
* Static analysis clean with zero errors and zero warnings (`dart analyze`).

---

## 📦 Distribution & Installation

### Android APK Direct Download
The production release APK is pre-compiled and ready for deployment:
* **Release Artifact:** `TaskApp-v1.2.0-release.apk`
* **Local Location:** `C:\Users\Hp\Desktop\TaskApp-v1.2.0-release.apk`
* **Project Root:** `D:\projects\task_app\TaskApp-v1.2.0-release.apk`

### Installation via Android Debug Bridge (ADB)
```powershell
adb install -r TaskApp-v1.2.0-release.apk
```

### Installation on Physical Device
1. Transfer `TaskApp-v1.2.0-release.apk` to your Android device via USB, Google Drive, or Slack.
2. Open your device's **Files** or **Downloads** app.
3. Tap on `TaskApp-v1.2.0-release.apk` and select **Install** (allow installation from this source if prompted).
4. Launch **Task-App** and log in.

---

## 🔑 Default Credentials Summary

| Role | Name | Email / ID | Password | Access Level |
|:---|:---|:---|:---|:---|
| **Tech Lead / Admin** | Saleem | `saleemali001232@gmail.com` *(or `admin`)* | `password123` *(or `admin123`)* | Full Admin (Tasks, Team, All-Roster Attendance) |
| **Mobile Engineer** | Khadija Yaseen | `khadijayaseen36@gmail.com` | `password123` | Team Member (Own Tasks, Private Attendance) |
| **UI/UX Designer** | Hamza Khan | `hamza@khawajalabs.com` | `password123` | Team Member |
| **Backend Developer**| Zain Ahmed | `zain@khawajalabs.com` | `password123` | Team Member |
