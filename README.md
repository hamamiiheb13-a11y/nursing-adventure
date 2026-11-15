# 🩺 NURSING ADVENTURE – Anime Educational Web Game

> **LEARN • PLAY • CHALLENGE**
> An adventurous, anime-inspired educational Snakes & Ladders web game designed specifically for nursing and medical students to play directly in Google Chrome on mobile devices and desktop.

---

## 🌟 Highlights & Features

- **📱 Mobile-First Responsive Design:** Runs directly in Google Chrome on Android, iPhone, iPad, tablets, and desktop. No APK installation or app store required.
- **⚓ Grand Medical Fleet Aesthetic:** One Piece-inspired anime adventure atmosphere featuring original characters wearing stylized nursing uniforms, navigational compass flourishes, and oceanic clinical themes.
- **🎲 3D-Styled Animated Dice & Smooth Pawn Hopping:** Dice rolls with dynamic 3D tumbling physics and rattle sound effects. Player tokens bounce square-by-square across the board with footstep chimes.
- **🪜 Golden Rescue Ladders:** Represents critical clinical breakthroughs (e.g., *Rapid Triage*, *IV Hydration Surge*, *High-Quality CPR*, *Defibrillator Surge*, *5 Rights of Meds*, *Early Sepsis Protocol*, *ICU Full Recovery*).
- **🐍 Hazard Red Snakes:** Scary crimson serpents representing medical pitfalls and complications (e.g., *Medication Mixup*, *Needlestick Hazard*, *Sepsis Shock Cascade*, *Documentation Gap*, *Burnout Breakdown*, *Anaphylaxis Alert*).
- **🎵 Real-Time Web Audio Synthesizer:** 100% client-side Web Audio API audio synthesis producing rich pirate anime background melodies and realistic SFX without requiring 50MB of audio downloads.
- **👥 Flexible Game Modes:**
  - **Solo Adventure:** Play against AI "Dr. Bot" for solo training.
  - **Crew Duel:** 2-Player Pass-and-Play on a single smartphone or tablet.
  - **Study Squad Tournament:** 3 to 4 players for group study sessions.
- **🏆 Victory Celebration:** Confetti bursts, golden trophy awards, and match statistics (dice rolls, ladders climbed, snakes avoided).

---

## 🧑‍⚕️ Meet the Medical Crew

1. **Captain Lyra** – *Trauma Fleet Commander*
   - **Specialty:** Emergency & Critical Care
   - **Motto:** *"Steady hands through any storm!"*
   - **Palette:** Medical Royal Navy (`#0B2545`) & Golden Epaulets (`#FFD166`).
2. **Kai Swift** – *Surgical Ninja Medic*
   - **Specialty:** OR & Sterile Field Mastery
   - **Motto:** *"Zero delay, sterile precision!"*
   - **Palette:** Turquoise Scrubs (`#006D77`) & Electric Cyan (`#00F5D4`).
3. **Aria Blossom** – *Pediatric Navigator*
   - **Specialty:** Pediatrics & Oncology
   - **Motto:** *"Kindness is the strongest medicine!"*
   - **Palette:** Rose Coral (`#8B1E3F`) & Pastel Pink (`#FF99C8`).
4. **Doc Jin** – *Pharmacology Sage*
   - **Specialty:** Pharmacotherapy & Toxicology
   - **Motto:** *"Every milligram determines the outcome!"*
   - **Palette:** Royal Violet (`#3C096C`) & Neon Lavender (`#E0AAFF`).

---

## 📂 Project Architecture

```
site jeu/
├── lib/
│   ├── main.dart                      # Application entry point & theme
│   ├── audio/
│   │   ├── audio_interface.dart       # Abstract audio service contract
│   │   ├── audio_stub.dart            # Stub for tests & desktop
│   │   ├── audio_web.dart             # JS interop with Web Audio API
│   │   └── audio_service.dart         # Singleton Audio Service
│   ├── models/
│   │   ├── board_tile.dart            # 100 tiles, 7 ladders, 8 snakes & tips
│   │   ├── character.dart             # 4 Anime character profiles & stats
│   │   ├── game_event.dart            # Match event log structure
│   │   └── player.dart                # Active player state & match stats
│   ├── screens/
│   │   ├── intro_screen.dart          # Hero entrance screen with animated logo
│   │   ├── main_menu_screen.dart      # Game mode selection & crew lore
│   │   ├── character_select_screen.dart # Interactive character & name picker
│   │   └── game_screen.dart           # Central board, HUD, dice & turn loop
│   └── widgets/
│       ├── action_banner.dart         # Turn and event notification banner
│       ├── anime_avatar.dart          # Vector CustomPainter anime avatars
│       ├── anime_background.dart      # Oceanic floating ambient particle canvas
│       ├── board_painter.dart         # High-perf painter for ladders & snakes
│       ├── board_widget.dart          # Responsive 10x10 grid with pawn tokens
│       ├── dice_widget.dart           # 3D tumbling animated dice & roll button
│       ├── instructions_dialog.dart   # Visual rules & clinical connections modal
│       ├── player_token.dart          # Animated bouncing pawn tokens
│       ├── settings_dialog.dart       # SFX/BGM toggles & speed settings
│       └── victory_dialog.dart        # Confetti celebration & match stats
├── web/
│   ├── audio_synth.js                 # Web Audio API Synthesizer & BGM engine
│   ├── index.html                     # Mobile viewport, PWA & loading screen
│   └── _headers                       # Cloudflare Pages security & caching headers
├── test/
│   ├── widget_test.dart               # Smoke test
│   └── game_logic_test.dart           # 100-tile geometry, ladder & snake tests
├── build/web/                         # Compiled production web bundle
├── DEPLOYMENT.md                      # Free public hosting instructions
└── wrangler.toml                      # Cloudflare Pages configuration
```

---

## 🛠️ Development & Build Commands

### Run Locally:
```bash
flutter run -d chrome
```

### Run Tests:
```bash
flutter test
```

### Build Production Release:
```bash
flutter build web --release
```

The production release is located in **`build/web/`** and can be deployed for free directly to **Cloudflare Pages** or **GitHub Pages**.
