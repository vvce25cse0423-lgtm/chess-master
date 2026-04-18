# ♟ Chess Master — Full-Stack Flutter App

A beautiful, feature-complete chess application built with Flutter.

![Chess Master](https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

| Feature | Details |
|---|---|
| 🎮 **Game Modes** | Player vs Player • Player vs AI |
| 🤖 **AI Levels** | Easy / Medium / Hard (Minimax + Alpha-Beta) |
| ⏱ **Time Controls** | 1 / 3 / 5 / 10 / 15 / 30 minute games |
| ♟ **Full Chess Rules** | Castling • En passant • Pawn promotion • Check/Checkmate/Stalemate |
| 📜 **Move History** | Algebraic notation with full move log |
| ⚖ **Material Count** | Live captured pieces + material advantage |
| 🎨 **Beautiful UI** | Dark theme with gold accents, animations, Cinzel typography |
| 🔄 **Board Flip** | Flip for local two-player on same device |
| 📱 **Responsive** | Portrait & landscape layouts |
| 🔊 **Sound Ready** | Sound toggle (add your own .mp3 assets) |
| 📊 **Session Stats** | Win/loss/draw tracking across games |

---

## 📋 Step-by-Step Setup

### Prerequisites

Make sure you have these installed before starting:

```
✅ Flutter SDK 3.24+ → https://docs.flutter.dev/get-started/install
✅ Android Studio or VS Code
✅ Git → https://git-scm.com
✅ GitHub account → https://github.com
```

---

## 🚀 STEP 1 — Install Flutter

### Windows
```powershell
# Option A: winget
winget install Google.Flutter

# Option B: Manual
# 1. Download from https://docs.flutter.dev/get-started/install/windows
# 2. Extract to C:\flutter
# 3. Add C:\flutter\bin to PATH in System Environment Variables
```

### macOS
```bash
# Option A: Homebrew
brew install --cask flutter

# Option B: Manual
# Download from https://docs.flutter.dev/get-started/install/macos
```

### Linux
```bash
sudo snap install flutter --classic
# OR
# Download and extract, then add to PATH
```

### Verify Installation
```bash
flutter doctor
# All green checkmarks needed (Android toolchain is most important)
```

---

## 🚀 STEP 2 — Clone and Run Locally

```bash
# Clone the repo (after you push it — see Step 4)
git clone https://github.com/YOUR_USERNAME/chess-master.git
cd chess-master

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run in release mode
flutter run --release
```

---

## 🚀 STEP 3 — Project Structure

```
chess_master/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   ├── chess_piece.dart      # Piece types, colors, unicode
│   │   ├── chess_move.dart       # Move model + algebraic notation
│   │   ├── chess_game.dart       # Full chess engine (all rules)
│   │   └── chess_ai.dart         # AI engine (Minimax + Alpha-Beta)
│   ├── providers/
│   │   └── game_provider.dart    # State management (Provider)
│   ├── screens/
│   │   ├── home_screen.dart      # Main menu
│   │   ├── game_screen.dart      # Game view
│   │   └── settings_screen.dart  # Settings
│   ├── widgets/
│   │   ├── chess_board.dart      # Board rendering
│   │   ├── player_info_bar.dart  # Player timer + captured pieces
│   │   ├── move_history.dart     # Scrollable move log
│   │   ├── captured_pieces.dart  # Captured pieces display
│   │   ├── promotion_dialog.dart # Pawn promotion picker
│   │   └── game_over_dialog.dart # End game popup
│   └── theme/
│       └── app_theme.dart        # Colors, typography, theme
├── android/                      # Android native project
├── .github/
│   └── workflows/
│       └── build_apk.yml         # GitHub Actions CI/CD
├── pubspec.yaml                  # Dependencies
└── README.md
```

---

## 🚀 STEP 4 — Push to GitHub

### 4a. Create GitHub Repository

1. Go to **https://github.com/new**
2. Name it: `chess-master`
3. Set to **Public** (required for free GitHub Actions minutes)
4. Do **NOT** initialize with README (we already have one)
5. Click **Create repository**

### 4b. Initialize and Push

```bash
# Navigate to your project folder
cd chess_master

# Initialize git
git init

# Add all files
git add .

# First commit
git commit -m "🎮 Initial commit: Chess Master Flutter app"

# Add your GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/chess-master.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 4c. Verify Push
- Go to `https://github.com/YOUR_USERNAME/chess-master`
- You should see all your files ✅

---

## 🚀 STEP 5 — Build APK with GitHub Actions

### 5a. Enable GitHub Actions
GitHub Actions is **automatically enabled** on public repositories.
No setup needed — the workflow file is already in `.github/workflows/build_apk.yml`.

### 5b. Trigger a Build
The build triggers automatically when you push to `main`. To trigger manually:

1. Go to your GitHub repo
2. Click **Actions** tab
3. Click **Build APK** workflow (left sidebar)
4. Click **Run workflow** → **Run workflow** (green button)

### 5c. Monitor the Build
1. Click on the running workflow
2. Click the **build** job
3. Watch each step expand in real time
4. Total build time: ~8–12 minutes first run (Flutter is cached after)

### 5d. Download Your APK
**Option A — GitHub Artifacts (every build):**
1. Go to **Actions** → click your completed build
2. Scroll to **Artifacts** section at the bottom
3. Click **ChessMaster-APKs** to download a ZIP containing all APK variants

**Option B — GitHub Releases (auto-created on push to main):**
1. Go to your repo **Releases** section (right sidebar)
2. Click the latest release (e.g., `v1`)
3. Download directly from the **Assets** section

---

## 🚀 STEP 6 — Install APK on Android

```
1. Transfer APK to your phone (USB, email, Google Drive, etc.)
2. On Android phone: Settings → Security → "Install unknown apps"
   → Enable for your file manager or browser
3. Open the APK file → Install
4. Find "Chess Master" in your app drawer and play! ♟
```

**Which APK to use?**
- `*_arm64.apk` → Most modern Android phones (2018+) ← **Recommended**
- `*_arm32.apk` → Older Android phones
- `*_x86_64.apk` → Android emulators / Chromebooks
- `*_universal.apk` → Works on everything but larger file size

---

## 🚀 STEP 7 — Make Changes and Rebuild

```bash
# Make your code changes...

# Stage and commit
git add .
git commit -m "✨ Add new feature"

# Push — this automatically triggers a new APK build!
git push

# Check progress at:
# https://github.com/YOUR_USERNAME/chess-master/actions
```

---

## 🛠 Build Locally (No GitHub Required)

```bash
# Debug APK (fast, for testing)
flutter build apk --debug

# Release APK (optimized)
flutter build apk --release

# Split APKs (smaller per architecture)
flutter build apk --split-per-abi --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎮 How to Play

| Action | How |
|---|---|
| **Select piece** | Tap a piece of your color |
| **Move piece** | Tap a highlighted green square |
| **Cancel selection** | Tap empty square or different piece |
| **Pawn promotion** | Move pawn to last rank → pick piece |
| **Castling** | Move king 2 squares left/right (if eligible) |
| **En passant** | Capture diagonally on highlighted square |
| **Resign** | Tap the flag 🏳 icon in top-right |
| **Flip board** | Tap the flip 🔄 icon |
| **New game** | Go back to menu → choose game mode |

---

## ⚙️ Customization

### Change Board Colors
Edit `lib/theme/app_theme.dart`:
```dart
static const Color lightSquare = Color(0xFFF0D9B5); // Cream
static const Color darkSquare  = Color(0xFFB58863); // Brown
```

Popular alternatives:
```dart
// Green felt (classic)
lightSquare = Color(0xFFEEEED2);
darkSquare  = Color(0xFF769656);

// Blue ocean
lightSquare = Color(0xFFDEE3E6);
darkSquare  = Color(0xFF8CA2AD);

// Purple
lightSquare = Color(0xFFE8D0E8);
darkSquare  = Color(0xFF9370AB);
```

### Add Sound Effects
1. Add `.mp3` files to `assets/sounds/`
2. Update `pubspec.yaml` assets section
3. Use `audioplayers` package (already in pubspec) in `game_provider.dart`

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `flutter_animate` | Smooth animations |
| `google_fonts` | Cinzel + Rajdhani fonts |
| `animate_do` | Entry animations |
| `shared_preferences` | Settings persistence |
| `audioplayers` | Sound effects |
| `sqflite` | Local game history database |
| `confetti` | Win celebration |

---

## 🤖 AI Engine

The AI uses **Minimax algorithm with Alpha-Beta pruning**:

| Difficulty | Search Depth | Avg Move Time |
|---|---|---|
| Easy | 1 ply | Instant (random-ish) |
| Medium | 3 ply | < 1 second |
| Hard | 4 ply | 1–3 seconds |

Evaluation factors:
- Material value (pawn=1, knight/bishop=3, rook=5, queen=9)
- Piece-square tables (positional bonuses)
- Checkmate detection
- Stalemate avoidance

---

## 🔧 Troubleshooting

**`flutter doctor` shows issues:**
```bash
# Accept Android licenses
flutter doctor --android-licenses
# Then press 'y' for each
```

**Build fails with Gradle error:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

**GitHub Actions fails:**
- Check the **Actions** tab for error details
- Common fix: ensure `pubspec.yaml` has no syntax errors
- Verify all files are committed and pushed

**APK won't install:**
- Enable "Install from unknown sources" for your file manager app
- Make sure you're using the right architecture APK for your device

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

*Built with ♟ and Flutter*
