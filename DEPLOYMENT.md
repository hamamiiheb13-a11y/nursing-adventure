# 🚀 Guide de Déploiement Public Gratuit – Gastro Quest

**Gastro Quest** est une application web médicale interactive et mobile-first construite avec Flutter Web et un synthétiseur Web Audio API. Les étudiants en médecine et gastro-entérologie peuvent ouvrir le lien directement dans **Google Chrome** (sur smartphone Android, iPhone, iPad ou ordinateur) et jouer immédiatement sans aucune installation d'application ni téléchargement d'APK.

---

## ⚡ Option 1: GitHub Pages (Déploiement Automatisé via GitHub Actions)

Un workflow GitHub Actions automatisé est déjà pré-configuré dans `.github/workflows/deploy.yml` :

1. À chaque `git push` sur la branche `main`, GitHub Actions compile automatiquement la version Web Release et déploie le site.
2. Votre lien public officiel gratuit :
   ```
   https://hamamiiheb13-a11y.github.io/nursing-adventure/
   ```
3. Si nécessaire, vérifiez dans votre dépôt GitHub : **Settings** > **Pages** > **Build and deployment** > Source : **GitHub Actions**.

---

## ⚡ Option 2: Cloudflare Pages (Optionnel)

Lien Cloudflare Pages :
```
https://nursing-adventure.pages.dev
```

---

## 🛡️ Production Optimizations Included

1. **Security & Performance Headers (`_headers`):**
   - Configured with `X-Frame-Options`, `X-Content-Type-Options`, and `Permissions-Policy`.
   - Immutable 1-year caching for WebAssembly (`.wasm`) and CanvasKit assets.
2. **Web Audio API Engine (`audio_synth.js`):**
   - 100% browser-synthesized audio effects and pirate-themed anime background music.
   - Zero external audio file requests, eliminating 404s, CORS blocks, and buffering lag.
3. **Mobile-First PWA Manifest (`manifest.json`):**
   - Can be added to a smartphone home screen as a standalone mobile app icon directly from Chrome!
