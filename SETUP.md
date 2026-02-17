# Dopamine - Morning Routine Habit Tracker

An iOS app with interactive Lock Screen and Home Screen widgets that put your daily habits front and center the moment you pick up your phone.

## What It Does

- **Interactive Home Screen Widget** — A checklist of your morning habits displayed as a widget. Tap the circle to check off a habit, tap the arrow to open the associated app directly.
- **Lock Screen Widget** — Shows your progress (e.g., "2/4 habits done") right on the lock screen.
- **One-Tap App Launch** — Each habit links to an external app (Noom, Headspace, Notion, Spotify, etc.) via URL schemes. Tapping opens the app immediately.
- **Daily Reset** — The checklist resets at midnight automatically.
- **Customizable** — Add, remove, and reorder habits from the main app. Quick presets included for popular apps.

## Architecture

```
Dopamine/
├── Shared/                    # Shared between app + widget
│   ├── HabitModel.swift       # Data model, persistence (UserDefaults via App Groups)
│   └── AppIntents.swift       # Interactive widget intents (toggle habit, open app)
├── Dopamine/                  # Main iOS app
│   ├── DopamineApp.swift      # App entry point, deep link handler
│   ├── ViewModels/
│   │   └── HabitViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift      # Main habit list screen
│   │   ├── HabitCardView.swift    # Individual habit card
│   │   ├── ProgressRingView.swift # Animated progress ring
│   │   └── AddHabitView.swift     # Add/edit habit sheet
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── Dopamine.entitlements
├── DopamineWidget/            # WidgetKit extension
│   ├── DopamineWidget.swift   # All widget views + timeline provider
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── DopamineWidget.entitlements
├── project.yml                # XcodeGen project spec
└── generate_xcodeproj.sh      # Script to generate .xcodeproj
```

## Setup

### Prerequisites

- macOS with Xcode 15+ installed
- iOS 17+ device or simulator
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

### Steps

1. **Install XcodeGen** (if you don't have it):
   ```bash
   brew install xcodegen
   ```

2. **Generate the Xcode project**:
   ```bash
   cd Dopamine
   ./generate_xcodeproj.sh
   ```

3. **Open in Xcode**:
   ```bash
   open Dopamine.xcodeproj
   ```

4. **Configure signing**:
   - Select the Dopamine target → Signing & Capabilities
   - Choose your development team
   - Do the same for the DopamineWidgetExtension target

5. **Verify App Groups**:
   - Both targets should have `group.com.dopamine.habits` in their App Groups capability
   - If not, add it manually in Signing & Capabilities

6. **Build and run** on a device or simulator (iOS 17+)

### Adding the Widget

After installing the app:

1. Long-press your Home Screen → tap the "+" button
2. Search for "Dopamine" or "Morning Routine"
3. Choose Medium (checklist) or Large (detailed) size
4. For Lock Screen: long-press lock screen → Customize → add widget

## How It Works

### Data Flow
- Habits and completion state are stored in **UserDefaults** using a shared **App Group** (`group.com.dopamine.habits`)
- Both the main app and widget read/write to the same store
- When the widget's toggle button is pressed, an **AppIntent** fires that updates the store and reloads the widget timeline

### URL Scheme Deep Links
- Each habit has an associated app URL scheme (e.g., `spotify://`, `headspace://`)
- The widget uses `dopamine://open?scheme=X&fallback=Y` links
- The main app intercepts these and opens the target app, falling back to the App Store if not installed

### Widget Types
| Widget | Family | Description |
|--------|--------|-------------|
| Morning Routine | `systemMedium` | Checklist with toggle buttons and app launch links |
| Morning Routine | `systemLarge` | Full checklist with progress ring and "Open" buttons |
| Habits Progress | `accessoryCircular` | Lock screen circle showing X/Y count |
| Habits Progress | `accessoryInline` | Lock screen inline text |

## Default Habits

The app ships with 4 default habits:
- ⚖️ **Log Weight** → Noom
- 🧘 **Meditate** → Headspace
- 🎯 **Vision Board** → Notion
- 🎧 **Podcast** → Spotify

You can customize these or add your own from the app.
