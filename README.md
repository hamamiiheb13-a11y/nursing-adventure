# 🚀 CAPSULE WARRIORS : THE STOMACH MISSION

> **EXPÉDITION MÉDICALE 2D DANS LE TRACTUS GASTRIQUE • ISSIT PFE**  
> Un véritable jeu vidéo Web 2D Arcade en mode paysage conçu pour les étudiants en gastro-entérologie et en soins infirmiers, dédié aux **Maladies Inflammatoires Chroniques de l'Intestin (MICI)** : Maladie de Crohn et Rectocolite Hémorragique (RCH).  
> Développé avec **Flutter Web** à 60 FPS, Canvas API et moteur audio Web Audio API.

---

## 🌟 Vue d'ensemble du Projet

**CAPSULE WARRIORS** transforme l'apprentissage clinique des MICI en une expérience de jeu d'arcade 2D immersive :

- **Expérience Arcade 2D en mode paysage (Landscape) :** Gameplay horizontal plein écran avec parallaxe multi-couches, physique de capsule fluide, obstacles biologiques et ennemis animés.
- **Les 33 Questions Pédagogiques ISSIT :** Intégration fidèle des 33 questions issues du document original de l'Institut Supérieur des Sciences Infirmières de Tunis (PFE).
- **7 Stages Thématiques :**
  1. *Anatomie, Physiologie et Lésions Intestinales* (Q1 à Q4)
  2. *Généralités, Symptômes et Manifestations de la Maladie* (Q5 à Q9)
  3. *Traitements Médicamenteux et Observance* (Q10 à Q14)
  4. *Examens, Marqueurs Biologiques et Dépistage* (Q15 à Q18)
  5. *Mode de Vie, Alimentation et Voyages* (Q19 à Q22)
  6. *Hérédité, Fertilité, Grossesse et Allaitement* (Q23 à Q30)
  7. *Rôle Infirmier & Urgences MICI* (Q31 à Q33)
- **Contrôles Complets & Hybrides :**
  - **PC :** Souris pour viser et tirer (clic gauche), touches `WASD` / Flèches pour naviguer, `ESPACE` pour tir/propulsion, `E`/`Shift` pour le bouclier, `Échap` pour pause.
  - **Mobile :** Joystick tactile analogique virtuel à gauche, grands boutons néon de tir et de bouclier à droite, overlay de guidage rotation paysage.
- **Arsenal Progressif :** Laser Médical MK-I, Double Laser, Plasma Shot, Bouclier d'Énergie, Electric Wave, Ultimate Pulse.
- **Ennemis & Boss de Fin de Stage :** 5 espèces destructibles (HelicoBacterium, CytokineCloud, SpikeVirion, AcidDroplet, ToxicSpore) et Boss colossal à terrasser grâce aux réponses cliniques.
- **Répétition Intelligente des Erreurs :** En cas d'erreur, explication détaillée bienveillante, perte d'un cœur et insertion dans la file de révision jusqu'à maîtrise complète.
- **Sauvegarde Automatique :** Sauvegarde via `SharedPreferences` de la progression, des scores, des armes et des statistiques.

---

## 🎮 Navigation & Écrans

- **Accueil Arcade :** Décor gastrique animé, capsule en lévitation avec propulsion lumineuse, boutons `JOUER`, `REPRENDRE`, `COMMENT JOUER`, `PARAMÈTRES`.
- **Cinématique d'Introduction :** Séquence animée avec option `SKIP`.
- **Sélection des 7 Stages :** Cartes panoramiques avec vignettes dessinées sur Canvas, évaluation en étoiles (★) et états débloqués/verrouillés.
- **Briefing de Mission :** Aperçu du thème, des ennemis et de l'armement équipé.
- **HUD Arcade :** Jauge de 3 cœurs, score, progression %, XP, badge d'arme.
- **Centre de Révision :** Consultation des 33 questions avec filtres et corrigés détaillés.
- **Écran Final :** Certificat médical, score total, taux de précision et révision guidée.

---

## 🛠️ Technologies
- **Framework :** Flutter Web (SDK 3.x)
- **Rendu Graphique :** CustomPainter & CanvasKit 60 FPS
- **Audio :** Synthétiseur Web Audio API dynamique
- **Polices :** Google Fonts (`Orbitron`, `Inter`)
- **Déploiement :** GitHub Pages & Cloudflare Pages compatibles
