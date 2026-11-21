# 🩺 GASTRO QUEST – Jeu Éducatif Médical MICI

> **APPRENDRE • COMPRENDRE • PROGRESSER**  
> Une refonte complète et professionnelle du jeu éducatif pour les étudiants en gastro-entérologie, dédié aux **Maladies Inflammatoires Chroniques de l'Intestin (MICI)** : Maladie de Crohn et Rectocolite Hémorragique (RCH).  
> Développé avec **Flutter Web** et moteur audio **Web Audio API**.

---

## 🌟 Vue d'ensemble du Projet

**GASTRO QUEST** transforme la formation clinique en une aventure interactive et immersive à travers 30 niveaux et 6 mondes thématiques.

- **Directement intégré au site existant :** Aucun framework superflu, conservation de la structure et déploiement instantané.
- **Strict respect du questionnaire original :** Les 30 questions et l'ensemble de leurs propositions (A, B, C, D, E) sont strictement conformes au mot près au document PDF original.
- **Pédagogie bienveillante :** Chaque question propose une explication médicale détaillée et validée. L'étudiant peut continuer son parcours même après une erreur afin de maximiser l'apprentissage.
- **Direction artistique premium :** Thème médical immersif (Bleu nuit, Turquoise, Vert émeraude, Touches dorées), illustration animée du système digestif avec flux de transit bioluminescent, et personnage guide animé (Dr. Alex).
- **Gamification & Récompenses :** Points XP, 1 à 3 étoiles par niveau, 6 badges de maîtrise des mondes et hauts faits cliniques.
- **Sauvegarde permanente :** Sauvegarde automatique via `SharedPreferences` / localStorage permettant de reprendre instantanément la partie là où l'étudiant s'était arrêté.

---

## 🗺️ Les 6 Mondes & 30 Niveaux

| Monde | Thème Médical | Niveaux | Questions PDF | Ambiance & Palette |
| :--- | :--- | :--- | :--- | :--- |
| **MONDE 1** | **Anatomie, Physiologie et Lésions Intestinales** | 1 à 4 (4 QCM) | Q31, Q32, Q42, Q46 | Turquoise & Cyan (`#00E5FF`) |
| **MONDE 2** | **Généralités, Symptômes et Manifestations** | 5 à 9 (5 QCM) | Q18, Q20, Q30, Q47, Q48 | Indigo & Violet (`#818CF8`) |
| **MONDE 3** | **Traitements Médicamenteux et Observance** | 10 à 14 (5 QCM) | Q5, Q6, Q8, Q10, Q11 | Vert Émeraude (`#10B981`) |
| **MONDE 4** | **Examens, Marqueurs Biologiques et Dépistage** | 15 à 18 (4 QCM) | Q14, Q16, Q33, Q45 | Bleu Azur & Saphir (`#38BDF8`) |
| **MONDE 5** | **Mode de Vie, Alimentation et Voyages** | 19 à 22 (4 QCM) | Q3, Q12, Q23, Q26 | Ambre Chaud (`#F59E0B`) |
| **MONDE 6** | **Hérédité, Fertilité, Grossesse et Allaitement** | 23 à 30 (8 QCM) | Q29, Q38, Q51, Q52, Q60, Q62, Q63, Q65 | Rose & Magenta (`#EC4899`) |

---

## 📱 Fonctionnalités et Parcours Utilisateur

1. **Écran d'Accueil Spectaculaire :**
   - Logo héroïque *GASTRO QUEST* avec reflets lumineux.
   - Modèle anatomique interactif du système digestif avec animation de transit bioluminescent.
   - Avatar du Guide Médical animé (Dr. Alex) avec dialogue d'accueil.
   - Boutons *Commencer l'aventure* et *Reprendre ma partie*.
   - Indicateurs de progression globale (% et X/30 niveaux), Score XP, Étoiles et Badges.
   - Paramètres audio (SFX / BGM) et option de réinitialisation.

2. **Carte d'Aventure (30 Niveaux) :**
   - Tracé sinueux reliant les 30 niveaux.
   - Bannières thématiques pour chacun des 6 mondes avec progression par monde.
   - Nœuds interactifs : validés avec étoiles dorées, niveau en cours avec pulsation dynamique et curseur joueur, niveaux verrouillés avec cadenas.
   - Défilement automatique vers le niveau actuel.

3. **Interface QCM & Mécanique d'Apprentissage :**
   - Énoncé officiel intact issu du PDF original.
   - Cartes de réponses interactives avec sélection visuelle immédiate.
   - Bouton *Valider ma réponse*.
   - Débriefing pédagogique immédiat :
     - Si correct : son de carillon cristallin, confettis, +100 XP, 3 étoiles, félicitations du Dr. Alex.
     - Si erreur : son bienveillant, +30 XP, affichage de la bonne réponse et explication médicale détaillée.
   - Bouton de transition vers le niveau suivant.

4. **Écran de Bilan & Fin de Jeu :**
   - Célébration finale après le niveau 30.
   - Titre honorifique décerné selon le taux de réussite (ex: *Praticien Hospitalier Expert MICI*).
   - Statistiques précises : Bonnes réponses, réponses à réviser, pourcentage de réussite, score total XP.
   - Bouton *Revoir toutes mes réponses* (revue détaillée des 30 questions et explications).
   - Bouton *Rejouer*.

5. **Page Trophées & Récompenses :**
   - Les 6 badges de maîtrise des mondes.
   - Les 5 hauts faits cliniques globaux.

---

## 🚀 Lancement & Test Local

### Exécuter les tests unitaires et d'interface
```powershell
flutter test
```

### Tester l'application Web localement
```powershell
flutter run -d chrome
```
ou avec le script serveur dédié :
```powershell
.\serve_web.ps1 -port 8080
```
Puis ouvrez `http://localhost:8080/` dans votre navigateur.

### Reconstruire la version de production Web
```powershell
flutter build web --release
```
Les fichiers prêts à être déployés sur Cloudflare Pages, Netlify ou tout hébergeur web se trouvent dans le répertoire `build/web/`.
