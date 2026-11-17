# Software Requirements Specification (SRS)
## For Task-App: Internal Task & Attendance Management Ecosystem

> **Organization:** Khawaja Labs  
> **Prepared by:** Mobile Engineering Team (Lead: Saleem, Mobile Engineer: Khadija Yaseen)  
> **Standard:** Conforming to IEEE Std 830-1998  
> **Version:** `1.2.0`  
> **Date:** November 17, 2026  
> **Status:** Approved for Production Release  

---

## Table of Contents
1. [Introduction](#1-introduction)  
   1.1 Purpose  
   1.2 Document Conventions  
   1.3 Intended Audience  
   1.4 Project Scope  
   1.5 References  
2. [Overall Description](#2-overall-description)  
   2.1 Product Perspective  
   2.2 Product Features  
   2.3 User Classes and Characteristics  
   2.4 Operating Environment  
   2.5 Design and Implementation Constraints  
   2.6 Assumptions and Dependencies  
3. [External Interface Requirements](#3-external-interface-requirements)  
   3.1 User Interfaces  
   3.2 Hardware Interfaces  
   3.3 Software Interfaces  
   3.4 Communications Interfaces  
4. [System Features & Functional Requirements](#4-system-features--functional-requirements)  
   4.1 Authentication & Session Management (FR-1)  
   4.2 Milestone & Task Management (FR-2)  
   4.3 Single-Assignee Exclusivity Guard (FR-3)  
   4.4 Team Directory & Employee Registration (FR-4)  
   4.5 1-Click Native Email Onboarding Bridge (FR-5)  
   4.6 Real-Time Attendance Engine & Punch Card (FR-6)  
   4.7 Dynamic Shift Configuration & In-App Customization (FR-7)  
   4.8 Attendance Privacy & Role Scoping (FR-8)  
   4.9 Visual Engineering Analytics (FR-9)  
   4.10 Cloud Synchronization & Offline Fallback (FR-10)  
5. [Non-Functional Requirements](#5-non-functional-requirements)  
   5.1 Performance Requirements  
   5.2 Security & Confidentiality Requirements  
   5.3 Reliability & Fault Tolerance  
   5.4 Usability & Accessibility  
   5.5 Maintainability & Portability  
6. [Verification Matrix & Acceptance Criteria](#6-verification-matrix--acceptance-criteria)  

---

## 1. Introduction

### 1.1 Purpose
This Software Requirements Specification (SRS) establishes the complete functional and non-functional requirements for **Task-App**, an enterprise mobile application designed for internal project coordination, milestone tracking, and verified attendance logging at **Khawaja Labs**.

### 1.2 Document Conventions
* **SHALL / MUST:** Indicates mandatory requirements binding on software release.
* **SHOULD:** Indicates high-priority recommendations.
* **MAY:** Indicates optional or extensible future capabilities.
* Identifiers follow the format `FR-[Module]-[Index]` for functional requirements and `NFR-[Category]-[Index]` for non-functional requirements.

### 1.3 Intended Audience
This document serves as the formal specification for software engineers, QA automation specialists, project managers, and executive leadership (Software Architect & Tech Lead Saleem) responsible for deployment, audit, and verification.

### 1.4 Project Scope
Task-App replaces fragmented messaging channels and ad-hoc spreadsheets by consolidating:
* **Deliverable Ownership:** Enforcing single-assignee responsibility to prevent duplicate work.
* **Attendance & Shift Verification:** Replacing manual attendance sheets with a real-time ticking clock, verified timestamps, and role-based privacy guarantees.
* **Onboarding Automation:** Seamlessly registering employees and dispatching credentials via native Android Gmail intents.

### 1.5 References
* IEEE Std 830-1998: *Recommended Practice for Software Requirements Specifications*.
* Hallmark Design Systems: *Cobalt (Modern Minimal) UI Specification*.
* Flutter Architecture Guidelines: *State Management & Platform Interoperability*.

---

## 2. Overall Description

### 2.1 Product Perspective
Task-App is a standalone client-server mobile application communicating with a Supabase PostgreSQL backend via REST APIs, featuring an embedded offline caching engine and platform-specific native Kotlin MethodChannels for Android system integration.

```
┌────────────────────────────────────────────────────────┐
│                   Android OS (API 26+)                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │               Task-App Client Engine             │  │
│  │  ┌───────────────┐ ┌───────────────┐ ┌────────┐  │  │
│  │  │ Cobalt UI Kit │ │ Attend Engine │ │ Cache  │  │  │
│  │  └───────┬───────┘ └───────┬───────┘ └───┬────┘  │  │
│  └──────────┼─────────────────┼─────────────┼───────┘  │
│             │ MethodChannel   │ HTTPS REST  │          │
│             ▼                 ▼             ▼          │
│     Native Mail App       Supabase DB   Local RAM      │
└────────────────────────────────────────────────────────┘
```

### 2.2 Product Features
* **Role-Based Dual Access:** Tailored interfaces for Tech Lead (Administration) and Team Members (Execution).
* **Collision-Free Task Engine:** Automatic prevention of duplicate task titles within a single project.
* **Smart Search:** Instant indexing across titles, projects, assignees, and natural language filters (`"my task"`).
* **Live Punch Clock:** Dynamic second-by-second ticker tracking logged shift duration.
* **In-App Shift Configuration:** On-the-fly adjustment of shift start, shift end, and daily target hours without app compilation.
* **Strict Attendance Confidentiality:** Hard architectural barriers preventing cross-employee attendance inspection.
* **Zero-Dependency Native Intent Bridge:** Direct Android Intent dispatch to Gmail without external third-party SDK bloat.

### 2.3 User Classes and Characteristics
1. **Tech Lead / Administrator (Saleem):**
   * High technical proficiency.
   * Requires total administrative visibility, task delegation authority, all-roster attendance auditing, and employee management capabilities.
2. **Team Member / Engineer (Khadija Yaseen, Hamza Khan, Zain Ahmed):**
   * Technical engineering contributors.
   * Requires focused personal task visibility (`My Tasks`), frictionless attendance clocking, and absolute privacy regarding personal hours.

### 2.4 Operating Environment
* **Mobile Platform:** Android 8.0 (API Level 26) through Android 15 (API Level 35).
* **Screen Densities:** `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi` across mobile and tablet form factors.
* **Secondary Platforms:** Flutter Web and Windows Desktop (supported via cross-compilation).

### 2.5 Design and Implementation Constraints
* **Design Identity:** Must strictly implement the Cobalt Design System (`CobaltTheme`).
* **Storage Footprint:** Release APK binary size must remain under 60 MB.
* **Network Independence:** Core task toggling and attendance clocking must operate even when offline.

---

## 3. External Interface Requirements

### 3.1 User Interfaces
* **Color Palette:** Primary Cobalt (`#1D4ED8`), Accent Purple (`#7C3AED`), Slate Ink (`#0F172A`), Paper White (`#FFFFFF`).
* **Controls:** 3D tactile mechanical keycaps (`CobaltKey`) with pressed elevation physics.
* **Responsive Layout:** All hero cards and row layouts must incorporate `Flexible` and `Expanded` wrappers to eliminate layout overflow boundaries on all screen aspect ratios.

### 3.2 Software Interfaces
* **Flutter Engine:** Stable Channel Dart 3.x runtime.
* **Database:** Supabase PostgreSQL instance exposed via PostgREST v1 API.
* **Platform Bridge:** Android Native `MethodChannel` (`com.khawajaalabs.task_app/email`).

### 3.3 Communications Interfaces
* **Protocol:** HTTPS (TLS 1.3) using JSON serialization for all network payloads.
* **Headers:** `apikey`, `Authorization: Bearer <token>`, `Content-Type: application/json`.

---

## 4. System Features & Functional Requirements

### 4.1 Authentication & Session Management (FR-1)
* **FR-1.1:** The system SHALL offer dual sign-in modes: Credential-based Admin Login and One-Tap Team Member Fast-Switch.
* **FR-1.2:** The system SHALL authenticate Tech Lead credentials (`saleemali001232@gmail.com` / `admin` with `password123` or `admin123`).
* **FR-1.3:** The system SHALL protect administrative features (Task Creation, Member Registration) with an administrative verification modal when accessed from non-admin accounts.

### 4.2 Milestone & Task Management (FR-2)
* **FR-2.1:** The system SHALL support creating tasks with Title, Description, Project Name, Assignee, Priority (`Urgent`, `High`, `Medium`, `Low`), and Target Due Date.
* **FR-2.2:** The system SHALL provide filter views for `All Tasks`, `My Tasks`, `In Progress`, and `Completed`.
* **FR-2.3:** The system SHALL allow assignees to toggle status between `inProgress` and `done` with a single tap.

### 4.3 Single-Assignee Exclusivity Guard (FR-3)
* **FR-3.1:** The system SHALL enforce that a task belongs to exactly one `Employee`.
* **FR-3.2:** The system SHALL check for title uniqueness within the same project. If a conflict occurs, the system SHALL reject creation and display an informative error identifying the current owner.

### 4.4 Team Directory & Employee Registration (FR-4)
* **FR-4.1:** The system SHALL allow the Tech Lead to register new company employees with Name, Role, Email, and Password.
* **FR-4.2:** Newly registered employees SHALL immediately populate across all task assignment dropdowns and directory views.

### 4.5 1-Click Native Email Onboarding Bridge (FR-5)
* **FR-5.1:** Upon employee creation, the system SHALL prompt to dispatch credentials via Android `MethodChannel`.
* **FR-5.2:** The system SHALL launch the device's native Gmail client pre-populated with recipient email, subject line, and onboarding instructions.

### 4.6 Real-Time Attendance Engine & Punch Card (FR-6)
* **FR-6.1:** The system SHALL provide an interactive Hero Clock In / Clock Out card on the Attendance screen.
* **FR-6.2:** When clocked in, a background timer SHALL tick every 1000 milliseconds, formatting elapsed time as `HH:mm:ss`.
* **FR-6.3:** The system SHALL record the precise Clock-In and Clock-Out timestamps and compute total hours worked.
* **FR-6.4:** Headless automated tests SHALL automatically suppress live timers to prevent race conditions during UI verification.

### 4.7 Dynamic Shift Configuration & In-App Customization (FR-7)
* **FR-7.1:** The system SHALL support customizable employee shift timings (default: `8:00 PM – 12:00 AM`) and target hours (default: `4h 00m`).
* **FR-7.2:** The system SHALL provide an in-app ✏️ edit button on the shift banner opening an `Edit Shift Timing` dialog.
* **FR-7.3:** Changes made via the shift dialog SHALL immediately update the active hero card, Shift Target metric pill, and Overtime calculations without restarting the application.

### 4.8 Attendance Privacy & Role Scoping (FR-8)
* **FR-8.1:** Non-admin team members SHALL strictly view only their own personal attendance records.
* **FR-8.2:** The system SHALL display a privacy assurance notice:  
  *"Confidential: Attendance is strictly private between you & Tech Lead (Saleem)."*
* **FR-8.3:** The Tech Lead SHALL have access to an `All Roster` selector and individual employee filter chips to audit team-wide attendance.

### 4.9 Visual Engineering Analytics (FR-9)
* **FR-9.1:** The system SHALL compute real-time completion velocity, overdue deliverable counts, and priority distribution.
* **FR-9.2:** The system SHALL render workload capacity charts indicating individual task distributions across the engineering team.

### 4.10 Cloud Synchronization & Offline Fallback (FR-10)
* **FR-10.1:** The system SHALL sync tasks and employees with Supabase PostgreSQL when network connectivity is available.
* **FR-10.2:** If network connectivity fails, the system SHALL operate seamlessly in local in-memory fallback mode with zero crash rate.

---

## 5. Non-Functional Requirements

### 5.1 Performance Requirements
* **Startup Time:** Cold launch to interactive dashboard SHALL complete in `< 1.8 seconds` on standard Android hardware.
* **UI Smoothness:** All scroll views, transitions, and tab switches SHALL maintain `60 frames per second (fps)`.
* **Search Latency:** In-memory smart search filtering SHALL execute in `< 16 milliseconds` per keystroke.

### 5.2 Security & Confidentiality Requirements
* **Data Isolation:** Cross-user attendance data leakage is strictly prohibited at the UI widget layer.
* **Credential Protection:** Passwords SHALL NOT be displayed in plain text within logcat or console outputs.
* **Administrative Safeguard:** Critical deletion and onboarding actions require administrative password verification.

### 5.3 Reliability & Fault Tolerance
* **Crash-Free Rate:** The application SHALL achieve a `99.9%` crash-free session rate.
* **Layout Resilience:** Zero pixel overflow exceptions across portrait screen widths ranging from `320px` to `800px+`.

### 5.4 Usability & Accessibility
* **Contrast Compliance:** All text and keycap elements SHALL meet WCAG AA contrast ratios against their respective backgrounds.
* **Tactile Feedback:** Keycaps and buttons SHALL provide immediate visual state transitions upon touch down.

### 5.5 Maintainability & Portability
* **Code Standards:** 100% compliance with `dart analyze` linter rules.
* **Modularity:** Separation of models, screens, services, and theme tokens into distinct packages.

---

## 6. Verification Matrix & Acceptance Criteria

| Requirement ID | Verification Method | Acceptance Criteria | Status |
|:---|:---|:---|:---:|
| **FR-1 (Auth & RBAC)** | Automated Widget Test | Admin login succeeds; invalid credentials rejected; team fast-switch operates. | ✅ PASS |
| **FR-2 (Task CRUD)** | Automated Widget Test | Task creates, lists, edits status, and deletes cleanly. | ✅ PASS |
| **FR-3 (Exclusivity)** | Automated Widget Test | Duplicate task title within same project is blocked. | ✅ PASS |
| **FR-4 (Team Roster)** | Automated Widget Test | Add member registers employee and updates dropdowns. | ✅ PASS |
| **FR-5 (Gmail Bridge)** | Manual Verification | Native Android Gmail opens with pre-filled recipient and body. | ✅ PASS |
| **FR-6 (Clock Engine)** | Automated Widget Test | Clock In starts timer; Clock Out calculates total duration. | ✅ PASS |
| **FR-7 (Shift Config)** | Manual Verification | In-app ✏️ edit updates timing string, target pill, and overtime. | ✅ PASS |
| **FR-8 (Privacy Guard)**| Automated Widget Test | Non-admin view hides other employee records; admin sees All Roster. | ✅ PASS |
| **FR-9 (Analytics)** | Automated Widget Test | Metrics, completion percentages, and priority counts reflect data. | ✅ PASS |
| **FR-10 (Offline)** | Automated Unit Test | App operates without Supabase network connection. | ✅ PASS |

**Final Quality Sign-off:**  
*Automated Test Result:* **10 / 10 Tests Passing (100%)**  
*Static Analysis:* **0 Warnings, 0 Errors**
