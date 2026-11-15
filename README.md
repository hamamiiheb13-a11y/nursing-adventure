# ⚓ NURSING ADVENTURE – Anime Educational Web Game

> **LEARN • PLAY • CHALLENGE**  
> An educational **Snakes and Ladders** web game designed specifically for nursing students. Built with **Flutter Web** and a client-side **Web Audio API synthesizer**, featuring an original **One Piece-inspired nautical anime adventure aesthetic**.

---

## 📋 Table of Contents
1. [Project Overview](#-project-overview)
2. [Game Features & Rules](#-game-features--rules)
3. [The Medical Crew](#-the-medical-crew)
4. [File Structure & Architecture](#-file-structure--architecture)
5. [How to Open the Project](#-how-to-open-the-project)
6. [How to Modify the Game (Customization Guide)](#-how-to-modify-the-game-customization-guide)
   - [Changing Characters & Attributes](#1-changing-characters--attributes)
   - [Customizing Character Artwork & Avatars](#2-customizing-character-artwork--avatars)
   - [Modifying Ladders & Snakes](#3-modifying-ladders--snakes)
   - [Changing Backgrounds & Particles](#4-changing-backgrounds--particles)
   - [Adjusting Colors & Palette](#5-adjusting-colors--palette)
   - [Replacing & Tuning Audio / Music](#6-replacing--tuning-audio--music)
   - [Modifying Dice Physics & Animations](#7-modifying-dice-physics--animations)
   - [Adding New Game Features](#8-adding-new-game-features)
7. [Testing & Quality Verification](#-testing--quality-verification)
8. [Rebuilding the Production Website](#-rebuilding-the-production-website)
9. [Publishing Updates to Cloudflare Pages](#-publishing-updates-to-cloudflare-pages)
10. [Security & Best Practices](#-security--best-practices)

---

## 🌟 Project Overview

**Nursing Adventure** combines classic snakes-and-ladders race mechanics with clinical education. Nursing students race across a 100-square boustrophedon board, surging upward on **Golden Rescue Ladders** (clinical breakthroughs like CPR and Rapid Triage) and sliding down **Hazard Red Snakes** (medical pitfalls like medication dosage errors and needlestick risks).

- **Zero Install:** Runs directly in Google Chrome on mobile phones (Android & iPhone), tablets, and desktop browsers.
- **Offline & Zero Latency:** Audio and graphics are 100% vector and Web Audio API synthesized—no external MP3 or image download lag.
- **Multiple Modes:** Solo vs AI ("Dr. Bot") or 2–4 Player Pass & Play on a single device.

---

## 🎮 Game Features & Rules

1. **Board Layout:** 100 numbered squares in a 10x10 boustrophedon zigzag order:
   - Row 1: `1 ➔ 10` (left to right)
   - Row 2: `20 ➔ 11` (right to left)
   - Row 3: `21 ➔ 30` (left to right)
   - Row 4: `40 ➔ 31` (right to left)
   - ...up to Row 10: `100 ➔ 91` (right to left, finishing at Square 100).
2. **Turn Order:**
   - Players roll the 3D die on their turn.
   - The token hops square-by-square with bounce physics and footstep sounds.
3. **Golden Rescue Ladders (7 Ladders):**
   - Landing on a ladder base triggers an ascending golden particle chime and moves the player upward:
     - `Sq 4 ➔ 14`: **Rapid Triage** – Quick acuity assessment secures priority beds.
     - `Sq 9 ➔ 31`: **IV Hydration Surge** – Fluid replacement prevents hypovolemic shock.
     - `Sq 21 ➔ 42`: **High-Quality CPR** – 100–120 compressions/min restores spontaneous circulation.
     - `Sq 28 ➔ 84`: **Defibrillator Surge** – Early shock in VFib triples survival rates.
     - `Sq 51 ➔ 67`: **5 Rights of Meds** – Right Patient, Drug, Dose, Route & Time prevent error.
     - `Sq 72 ➔ 91`: **Early Sepsis Protocol** – Lactate, cultures, and antibiotics within 1 hour.
     - `Sq 80 ➔ 99`: **ICU Full Recovery** – Critical stabilization leads to patient discharge.
4. **Hazard Red Snakes (8 Snakes):**
   - Landing on a snake head triggers an ominous hiss and slides the player backward:
     - `Sq 17 ➔ 7`: **Medication Mixup** – Always verify patient wristband and two identifiers.
     - `Sq 54 ➔ 34`: **Needlestick Hazard** – Never recap needles by hand; use safety sharps devices.
     - `Sq 62 ➔ 19`: **Sepsis Shock Cascade** – Missed early tachycardia and hypotension caused septic drop.
     - `Sq 64 ➔ 60`: **Documentation Gap** – If it wasn't documented, clinically it wasn't done.
     - `Sq 87 ➔ 36`: **Burnout Breakdown** – Prioritize self-care and structured crew handoffs.
     - `Sq 93 ➔ 73`: **Nosocomial Infection** – Break in aseptic technique; hand hygiene first.
     - `Sq 95 ➔ 75`: **Anaphylaxis Alert** – Verify allergy bands before administering antibiotics.
     - `Sq 98 ➔ 79`: **Unverified Dosage Miss** – Decimal point error; always double-check calculations.
5. **Winning:** The first player to reach Square 100 triggers the victory fanfare, celebratory confetti, and the clinical stats award.

---

## 👩‍⚕️ The Medical Crew

| Character | Role & Specialty | Palette | Motto |
| :--- | :--- | :--- | :--- |
| **Captain Lyra** | Trauma Fleet Commander (ER / ICU) | Navy Blue (`#0B2545`) & Gold (`#FFD166`) | *"Steady hands through any storm!"* |
| **Kai Swift** | Surgical Ninja Medic (OR / Sterile Field) | Turquoise (`#006D77`) & Cyan (`#00F5D4`) | *"Zero delay, sterile precision!"* |
| **Aria Blossom**| Pediatric Navigator (Peds / Oncology) | Rose Coral (`#8B1E3F`) & Pink (`#FF99C8`) | *"Kindness is the strongest medicine!"* |
| **Doc Jin** | Pharmacology Sage (Toxicology / Rx) | Deep Violet (`#3C096C`) & Neon Lilac (`#E0AAFF`) | *"Every milligram determines the outcome!"* |

---

## 🏗️ File Structure & Architecture

```
site jeu/
├── lib/
│   ├── main.dart                      # App entry point, MaterialApp theme & orientation
│   ├── audio/
│   │   ├── audio_interface.dart       # Abstract audio contract
│   │   ├── audio_stub.dart            # Safe stub for desktop/tests
│   │   ├── audio_web.dart             # dart:js_interop bridge for Web Audio
│   │   └── audio_service.dart         # Singleton Audio Service
│   ├── models/
│   │   ├── board_tile.dart            # 100 tiles, ladder/snake coordinates, tips
│   │   ├── character.dart             # 4 Anime character profiles, stats, badges
│   │   ├── game_event.dart            # Match event log entry model
│   │   └── player.dart                # Active player state, AI flag, match stats
│   ├── screens/
│   │   ├── intro_screen.dart          # Entry hero screen with animated logo & "PLAY NOW"
│   │   ├── main_menu_screen.dart      # Solo vs AI, 2P/4P Pass & Play, lore & settings
│   │   ├── character_select_screen.dart # Character picker, custom names, attribute bars
│   │   └── game_screen.dart           # Central board, HUD, turn manager & scoreboard
│   └── widgets/
│       ├── action_banner.dart         # Live match status banner with clinical pearls
│       ├── anime_avatar.dart          # Vector CustomPainter anime avatars (resolution-independent)
│       ├── anime_background.dart      # Ambient nautical particle canvas animation
│       ├── board_painter.dart         # CustomPainter for golden ladders and red snakes
│       ├── board_widget.dart          # Responsive 10x10 grid with pawn tokens
│       ├── dice_widget.dart           # 3D tumbling animated dice and roll button
│       ├── instructions_dialog.dart   # Visual rules & clinical connections modal
│       ├── player_token.dart          # Animated bouncing pawn tokens
│       ├── settings_dialog.dart       # Audio toggles and animation speed controls
│       └── victory_dialog.dart        # Confetti celebration, trophy & stats
├── web/
│   ├── audio_synth.js                 # Web Audio API Synthesizer (BGM + SFX)
│   ├── index.html                     # Mobile viewport, PWA manifest, animated loader
│   └── _headers                       # Cloudflare Pages security & caching headers
├── test/
│   ├── widget_test.dart               # App smoke test
│   └── game_logic_test.dart           # Boustrophedon 100-tile geometry, ladder/snake tests
├── build/web/                         # Compiled production web release
├── DEPLOYMENT.md                      # Free public hosting instructions
└── wrangler.toml                      # Cloudflare Pages deployment configuration
```

---

## 💻 How to Open the Project

1. **Prerequisites:**
   - Flutter SDK (version 3.24 or newer).
   - Any modern web browser (Google Chrome, Microsoft Edge, Safari, Firefox).
   - Code editor of choice (VS Code, Cursor, Android Studio, or IntelliJ).

2. **Open in Editor:**
   Open the `site jeu` folder in your editor.

3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run Locally in Google Chrome:**
   ```bash
   flutter run -d chrome
   ```
   Or use the built-in static server for testing:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\serve_web.ps1 -port 8080
   ```
   Then open `http://localhost:8080` in Google Chrome.

---

## 🎨 How to Modify the Game (Customization Guide)

### 1. Changing Characters & Attributes
Edit [`lib/models/character.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/models/character.dart):
- To rename a character, modify `name: 'Captain Lyra'`.
- To change their clinical title or specialty, edit `title:` or `specialty:`.
- To edit their quote, modify `motto:`.
- To change their clinical attributes, adjust the values in `stats: {'Care': 95, 'Speed': 88, 'Focus': 92, 'Wisdom': 90}`.

### 2. Customizing Character Artwork & Avatars
Avatars are rendered in vector graphics using Flutter `CustomPainter` inside [`lib/widgets/anime_avatar.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/widgets/anime_avatar.dart):
- Each character has a dedicated drawing routine (`_drawCaptainLyra`, `_drawKai`, `_drawAria`, `_drawDocJin`).
- You can change hair color, hat styles, epaulets, and facial expressions by adjusting the `Color(...)` values and paths.
- To use PNG/JPEG images instead, simply replace the `CustomPaint` child with `Image.asset('assets/images/your_character.png')`.

### 3. Modifying Ladders & Snakes
Edit [`lib/models/board_tile.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/models/board_tile.dart):
- In `BoardDefinition.ladders`, you can change any ladder start square, destination square, name, or medical tip:
  ```dart
  4: {'to': 14, 'name': 'Rapid Triage', 'tip': 'Quick acuity assessment secures priority patient beds!'},
  ```
- In `BoardDefinition.snakes`, you can adjust snake heads, tails, names, or clinical complication warnings:
  ```dart
  17: {'to': 7, 'name': 'Medication Mixup', 'tip': 'Always scan patient wristband before IV administration!'},
  ```
- Ladders and snakes will automatically recalculate their Bézier curves and 3D visual coordinates on the board!

### 4. Changing Backgrounds & Particles
Edit [`lib/widgets/anime_background.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/widgets/anime_background.dart):
- To change the ocean gradient, modify the `LinearGradient` colors in `build`:
  ```dart
  Color(0xFF040D1A), // Deep navy abyss
  Color(0xFF0A1F38), // Oceanic medical blue
  Color(0xFF082D4F), // Coastal cyan navy
  ```
- To change floating particle density, adjust the loop count in `initState` (`for (int i = 0; i < 28; i++)`).
- Particle shapes include crosses (`✚`), stars, circles, diamonds, and pulsing medical rings.

### 5. Adjusting Colors & Palette
- Primary theme colors are set in [`lib/main.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/main.dart) (`ThemeData.colorScheme`).
- Board cell colors are configured in [`lib/widgets/board_widget.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/widgets/board_widget.dart) in `_buildTileCell`.
- Snake colors are configured in [`lib/widgets/board_painter.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/widgets/board_painter.dart) (`Color(0xFFEF233C)` crimson body, `#FFFF9E00` belly line, `#CCFF00` glowing eyes).
- Golden ladder colors are defined in `_drawRescueLadder` (`#FFD166` gold with `#BB3E03` metallic shading).

### 6. Replacing & Tuning Audio / Music
Audio synthesis code is located in [`web/audio_synth.js`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/web/audio_synth.js):
- **Sound Effects:**
  - `playDice`: Modify `clicks` count and frequencies.
  - `playStep`: Change `baseFreq` or pitch increment.
  - `playLadder`: Edit the notes array (`[523.25, 659.25, 783.99, 987.77, 1046.50]`) to change the ascending arpeggio.
  - `playSnake`: Adjust oscillator sweep and the noise burst buffer.
  - `playVictory`: Edit the melody array for the victory fanfare.
- **Background Music (BGM):**
  - Notes, durations, and tempo are defined in the `BGM.notes` array in `audio_synth.js`.
  - To load an external MP3 file instead, simply replace `audio_synth.js` calls with standard HTML5 `<audio>` elements or the `audioplayers` package.

### 7. Modifying Dice Physics & Animations
- Dice tumble rotation, face perspective, and pip layout are in [`lib/widgets/dice_widget.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/widgets/dice_widget.dart).
- Rolling speed and hop delay are in [`lib/screens/game_screen.dart`](file:///c:/Users/hamam/OneDrive/Bureau/site%20jeu/lib/screens/game_screen.dart):
  ```dart
  final hopDelay = _isFastSpeed ? 140 : 250; // milliseconds per square
  ```

### 8. Adding New Game Features
The project follows clean separation of concerns:
- **New Screen:** Add a widget under `lib/screens/` and push it using `Navigator.of(context).push(...)`.
- **New Game Event:** Add an enum value to `GameEventType` in `lib/models/game_event.dart`.
- **New Game Sound:** Declare the method in `audio_interface.dart`, implement it in `audio_web.dart` and `audio_stub.dart`, and add the Web Audio oscillator logic in `web/audio_synth.js`.

---

## 🧪 Testing & Quality Verification

To verify that your modifications compile cleanly and pass all automated tests:

```bash
# 1. Run static analysis (0 errors, 0 warnings)
dart analyze

# 2. Run automated test suite (geometry, ladders, snakes, victory conditions)
flutter test
```

---

## 📦 Rebuilding the Production Website

Whenever you make any changes to code or design, compile the production release:

```bash
flutter build web --release
```

This compiles optimized JavaScript, wasm, and tree-shaken font assets into the **`build/web/`** directory.

---

## 🚀 Publishing Updates to Cloudflare Pages

### Option A: Automatic Git Integration (Recommended)
1. Push your changes to your GitHub repository:
   ```bash
   git add .
   git commit -m "Update game: added new clinical tips"
   git push origin main
   ```
2. Cloudflare Pages automatically detects the push, runs `flutter build web --release`, and updates your live website at the exact same public URL within 60 seconds!

### Option B: Direct Drag-and-Drop (No Git Required)
1. Go to [Cloudflare Pages Dashboard](https://pages.cloudflare.com/).
2. Select your `nursing-adventure` project.
3. Click **Create new deployment** > Drag and drop the updated **`build/web`** folder.
4. The same public link is updated immediately.

---

## 🔒 Security & Best Practices

- **Zero API Keys in Repository:** The game runs 100% client-side without storing private secrets or credentials.
- **HTTPS Enforced:** Cloudflare Pages provides free automatic SSL certificates.
- **No Third-Party Tracking:** Fully student-safe; no cookies or student registration required.
- **License:** Open educational use for nursing students, educators, and medical trainees.
