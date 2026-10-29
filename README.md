# Task-App (Company Project & Task Manager)

A modern, high-contrast, offline-ready **Project & Task Management Mobile Application** built with **Flutter & Dart**, styled using Hallmark's **Cobalt (Modern Minimal)** design system.

---

## 📱 Core Features & Architecture (Module 1)

### 1. Executive Metric Summary
* **Active Tasks Counter:** Real-time visibility into open company work items.
* **In-Progress Workload:** Tracks active engineering sprint items.
* **Completed Milestones:** Velocity metrics on closed deliverables.

### 2. Projects Hub & Progress Tracking
* Horizontal carousel displaying active company projects.
* Real-time milestone progress bar (`15/20 Tasks • 75%`).
* Project Health Status indicators (🟢 *On Track*, 🟡 *At Risk*, 🔴 *Delayed*).

### 3. Smart Filtering & Employee Assignment
* **One-Tap Filters:** `All Tasks`, `My Tasks (Khadija)`, `In Progress`, `High Priority`.
* **Assignee Avatars & Badges:** Instant team member ownership (Saleem, Khadija, Hamza, Zain).
* **Priority Engine:** High-contrast Urgent, High, Medium, and Low indicators.

---

## 🎨 Design System: Hallmark "Cobalt"
* **Tokens:** Strict separation of design tokens in `lib/theme/cobalt_theme.dart`.
* **Palette:** Deep Slate 900 (`#0F172A`), Pure White cards, and Electric Cobalt Accent (`#2563EB`).
* **Micro-Interactions:** Subtle elevation, geometric border radii, and accessible high-contrast typography.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.47+ recommended)
* Dart SDK (v3.13+)
* Android Emulator or physical device

### Running the App
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run automated tests
flutter test

# 3. Launch application on emulator
flutter run
```

---

## 🧪 Automated Tests
```bash
flutter test
```
All unit and widget test suites pass with 0 errors.
