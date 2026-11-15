# 🚀 Free Public Deployment Guide – Nursing Adventure

**Nursing Adventure** is a production-ready, mobile-first web game built with Flutter Web and Web Audio API synthesis. Nursing students anywhere can open the website link directly in **Google Chrome** (on Android, iPhone, iPad, tablets, or desktop) and play immediately without downloading an APK or registering.

---

## ⚡ Option 1: Cloudflare Pages (Recommended – 100% Free Forever)

Cloudflare Pages provides free high-speed global CDN hosting, automatic HTTPS, unlimited bandwidth, and instant deployment.

### Method A: Direct Upload (No CLI or Git required – 30 Seconds!)
1. Go to [https://pages.cloudflare.com/](https://pages.cloudflare.com/) and create a free account.
2. In the dashboard, click **"Create an application"** > **"Pages"** > **"Upload assets"**.
3. Enter a project name (e.g., `nursing-adventure`).
4. Drag and drop the entire contents of the **`build/web`** folder into Cloudflare Pages.
5. Click **"Deploy site"**.
6. Cloudflare will instantly provide your free public HTTPS link:
   ```
   https://nursing-adventure.pages.dev
   ```
   Share this link with your nursing students!

---

### Method B: Wrangler CLI (One Command Deployment)
If you have `npx` / Node installed:
```bash
npx wrangler pages deploy build/web --project-name nursing-adventure
```
Wrangler will upload your assets and return your live public URL immediately.

---

### Method C: Git Integration (Automatic Continuous Deployment)
1. Push this project folder to your GitHub or GitLab repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Nursing Adventure"
   git remote add origin https://github.com/<your-username>/nursing-adventure.git
   git push -u origin main
   ```
2. In Cloudflare Pages dashboard, select **"Connect to Git"**.
3. Choose your repository.
4. Set build settings:
   - **Framework preset:** `None`
   - **Build command:** `flutter build web --release`
   - **Build output directory:** `build/web`
5. Click **Save and Deploy**. Every future `git push` will automatically update the live site!

---

## 🌐 Option 2: GitHub Pages (100% Free with GitHub Actions)

An automated GitHub Actions workflow is already pre-configured in `.github/workflows/deploy.yml`:

1. Push this project to a GitHub repository:
   ```bash
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin main
   ```
2. In your repository on GitHub:
   - Go to **Settings** > **Pages**.
   - Under **Build and deployment** > **Source**, select **GitHub Actions**.
3. The workflow will automatically test and build your release bundle.
4. Your free public URL will be live at:
   ```
   https://<your-username>.github.io/<repository-name>/
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
