# 💪 Fitness & Gym Tracker App

A simple, offline-first mobile app to record workouts, track exercises, weights, reps, and sets, and view progress over time.

## 🎯 Goal

Create a simple mobile app to:
- Record workouts per session
- Track exercises, weights, reps, and sets
- View progress over time
- Include built-in exercises
- Allow custom exercises

## 👤 Target User

- Gym-goers who want simple logging, not social media or coaching
- Users who prefer offline-first, privacy-focused apps

## ✅ Core Features (MUST-HAVE)

### 1. Workout Session
- Start new workout
- Select exercises
- Add: Weight, Reps, Sets
- Save session with date/time

### 2. Exercise Library
- **Preloaded exercises** by muscle group:
  - Chest
  - Back
  - Legs
  - Shoulders
  - Arms
  - Core
- **Custom exercises**:
  - Add with name and muscle group
  - Edit / delete custom exercises

### 3. Progress Tracking
- History of workouts
- See last weight/reps for an exercise
- Simple charts (optional v1)

## ❌ Explicit Non-Goals

- No social features
- No AI coaching
- No diet tracking
- No wearable integration
- No cloud sync (local storage only in v1)

## 🛠️ Technology Stack

| Component | Technology |
|-----------|------------|
| Platform | Cross-platform (Android + iOS) |
| Framework | Flutter |
| Database | SQLite (sqflite package) |
| State Management | Provider |
| Backend | None (offline-first) |

## 📱 App Structure

### Screens
1. **Home** - Workout History
2. **New Workout** - Create and log workout
3. **Exercise Selection** - Pick exercises for workout
4. **Add/Edit Exercise** - Manage custom exercises
5. **Progress View** - View historical data
6. **Settings** - App configuration

### Data Models
```dart
Exercise {
  id, name, muscleGroup, isCustom, iconName
}

Workout {
  id, startTime, endTime, notes
}

WorkoutSet {
  id, workoutId, exerciseId, setNumber, weight, reps, isCompleted
}
```

---

## 🏁 Implementation Milestones

### ✅ Milestone 1: Basic App Skeleton
- [x] Flutter project setup
- [x] App navigation (bottom nav + routing)
- [x] Empty screens structure
- [x] Local database setup (SharedPreferences for Web/Mobile)
- [x] Theme and styling

### ✅ Milestone 2: Exercise Library
- [x] Preloaded exercises (seeded database - 30+ items)
- [x] View exercises by muscle group
- [x] Add custom exercises
- [x] Edit/delete custom exercises

### ✅ Milestone 3: Workout Logging
- [x] Create new workout session
- [x] Add exercises to workout
- [x] Record sets, reps, weight for each exercise
- [x] Save completed workout

### ✅ Milestone 4: History & Progress
- [x] Workout list by date
- [x] Workout detail view
- [x] Last performance per exercise
- [x] Training volume charts & breakdown

### ✅ Milestone 5: Polish
- [x] Hero animations & smooth transitions
- [x] Integrated Rest Timer
- [x] Weight unit selection (kg/lbs)
- [x] Data management (Clear all data)
- [x] UI cleanup and branding

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio / VS Code with Flutter extension
- Android Emulator or iOS Simulator (or physical device)

### Installation

1. **Clone/Navigate to the project:**
   ```bash
   cd "gym app antygraviti/fitness_tracker"
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Build for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 📁 Project Structure

```
fitness_tracker/
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # App configuration
│   ├── theme/                 # App theming
│   │   └── app_theme.dart
│   ├── models/                # Data models
│   │   ├── exercise.dart
│   │   ├── workout.dart
│   │   └── workout_set.dart
│   ├── database/              # SQLite database
│   │   └── database_helper.dart
│   ├── providers/             # State management
│   │   ├── exercise_provider.dart
│   │   └── workout_provider.dart
│   ├── screens/               # UI screens
│   │   ├── home/
│   │   ├── workout/
│   │   ├── exercises/
│   │   ├── progress/
│   │   └── settings/
│   └── widgets/               # Reusable widgets
│       └── common/
├── assets/                    # Images, fonts, etc.
├── pubspec.yaml              # Dependencies
└── README.md
```

---

## 📝 Development Log

### Day 1 - Milestone 1
- Created Flutter project
- Set up navigation structure
- Implemented SQLite database
- Created base screens

---

## 📄 License

This project is for personal use.

---

**Built with ❤️ using Flutter**
