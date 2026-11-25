import 'package:flutter/material.dart';

class GastroBossInfo {
  final String name;
  final String title;
  final String description;
  final Color auraColor;
  final IconData icon;
  final String dangerLevel;

  const GastroBossInfo({
    required this.name,
    required this.title,
    required this.description,
    required this.auraColor,
    required this.icon,
    this.dangerLevel = 'ÉLEVÉ',
  });
}

class GastroWorld {
  final int id; // 1-7
  final String name;
  final String subtitle;
  final String theme; // 'anatomy', 'symptoms', 'treatment', 'exams', 'family', 'nursing', 'revision'
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final List<int> questionIds; // which of the 27 official question IDs belong here
  final String bossName;
  final String bossDescription;
  final String bossDangerLevel;
  final String environmentDescription;
  bool isUnlocked;
  bool isCompleted;
  int starsEarned; // 0-3

  // Visuals and progression
  final IconData icon;
  final String guideWelcome;
  final Color? tunnelDeepColorCustom;
  final Color? tunnelWallColorCustom;
  final Color? tunnelFringeColorCustom;
  final String? unlockedWeaponNameCustom;

  GastroWorld({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.theme,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.questionIds,
    required this.bossName,
    required this.bossDescription,
    required this.environmentDescription,
    this.bossDangerLevel = 'MODÉRÉ',
    this.isUnlocked = false,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.icon = Icons.biotech_rounded,
    this.guideWelcome = '',
    this.tunnelDeepColorCustom,
    this.tunnelWallColorCustom,
    this.tunnelFringeColorCustom,
    this.unlockedWeaponNameCustom,
  });

  // Backward compatibility getters
  String get title => name;
  int get startLevel => questionIds.isNotEmpty ? questionIds.first : 1;
  int get endLevel => questionIds.isNotEmpty ? questionIds.last : 27;
  int get questionCount => questionIds.length;
  Color get accentColor => secondaryColor;
  Color get tunnelDeepColor => tunnelDeepColorCustom ?? primaryColor.withValues(alpha: 0.25);
  Color get tunnelWallColor => tunnelWallColorCustom ?? primaryColor;
  Color get tunnelFringeColor => tunnelFringeColorCustom ?? secondaryColor;
  String get unlockedWeaponName => unlockedWeaponNameCustom ?? 'Arme Niveau $id';

  GastroBossInfo get boss => GastroBossInfo(
        name: bossName,
        title: bossDescription.split('.').first,
        description: bossDescription,
        auraColor: primaryColor,
        icon: icon,
        dangerLevel: bossDangerLevel,
      );

  static List<GastroWorld> worlds = [
    // -------------------------------------------------------------
    // MONDE 1 : Estomac & Muqueuse — Anatomie & Lésions (Q1-Q4)
    // -------------------------------------------------------------
    GastroWorld(
      id: 1,
      name: 'ESTOMAC & MUQUEUSE',
      subtitle: 'Anatomie, Physiologie et Lésions',
      theme: 'anatomy',
      description: 'Explorez l\'anatomie du tube digestif, les villosités et le mécanisme des fistules.',
      primaryColor: const Color(0xFFFB7185), // Corail lumineux
      secondaryColor: const Color(0xFFFDBA74), // Pêche dorée
      questionIds: const [1, 2, 3, 4],
      bossName: 'Helicobacter Rex',
      bossDescription: 'Fléau Flagellé de la Muqueuse. Colonise la paroi gastrique et libère des enzymes corrosives.',
      bossDangerLevel: 'MODÉRÉ',
      environmentDescription: 'Parois corail lumineuses, villosités ondulantes et lumière gastrique rosée.',
      isUnlocked: true,
      icon: Icons.biotech_rounded,
      guideWelcome: 'Bienvenue dans l\'Estomac ! Maîtrisons l\'anatomie et la physiologie digestive.',
      tunnelDeepColorCustom: const Color(0xFF541F35),
      tunnelWallColorCustom: const Color(0xFFBE4B65),
      tunnelFringeColorCustom: const Color(0xFFFDA4AF),
      unlockedWeaponNameCustom: 'Double Laser Océan',
    ),

    // -------------------------------------------------------------
    // MONDE 2 : Intestin Grêle — Symptômes & Manifestations (Q5-Q9)
    // -------------------------------------------------------------
    GastroWorld(
      id: 2,
      name: 'INTESTIN GRÊLE',
      subtitle: 'Symptômes et Manifestations MICI',
      theme: 'symptoms',
      description: 'Déchiffrez les symptômes cardinaux, la rémission et les atteintes articulaires.',
      primaryColor: const Color(0xFFFB923C), // Orange chaleureux
      secondaryColor: const Color(0xFF38BDF8), // Bleu océan
      questionIds: const [5, 6, 7, 8, 9],
      bossName: 'Colossus Inflammatio',
      bossDescription: 'Titan des Poussées Aiguës. Projette des salves de cytokines inflammatoires.',
      bossDangerLevel: 'MODÉRÉ +',
      environmentDescription: 'Corridor océan-ambre baigné de replis absorbants et de foyers inflammatoires.',
      icon: Icons.medical_services_rounded,
      guideWelcome: 'Cap sur l\'Intestin Grêle pour identifier la sémiologie des MICI.',
      tunnelDeepColorCustom: const Color(0xFF153E5C),
      tunnelWallColorCustom: const Color(0xFF0E7490),
      tunnelFringeColorCustom: const Color(0xFFFDBA74),
      unlockedWeaponNameCustom: 'Canon Antibactérien',
    ),

    // -------------------------------------------------------------
    // MONDE 3 : Iléon Terminal — Traitements & Observance (Q10-Q12)
    // -------------------------------------------------------------
    GastroWorld(
      id: 3,
      name: 'ILÉON TERMINAL',
      subtitle: 'Traitements et Observance',
      theme: 'treatment',
      description: 'Maîtrisez les biothérapies anti-TNF, immunosuppresseurs et l\'importance de l\'observance.',
      primaryColor: const Color(0xFF14B8A6), // Turquoise médicinal
      secondaryColor: const Color(0xFF34D399), // Vert menthe
      questionIds: const [10, 11, 12],
      bossName: 'Auto-Immuno Titan',
      bossDescription: 'Golem des Anticorps Dissidents. Bloque l\'action des thérapies biologiques.',
      bossDangerLevel: 'ÉLEVÉ',
      environmentDescription: 'Flux turquoise apaisant enrichi de molécules thérapeutiques et plaques immunitaires.',
      icon: Icons.medication_rounded,
      guideWelcome: 'Bienvenue dans l\'Iléon Terminal ! Place à la pharmacologie anti-TNF.',
      tunnelDeepColorCustom: const Color(0xFF0D444A),
      tunnelWallColorCustom: const Color(0xFF0F766E),
      tunnelFringeColorCustom: const Color(0xFF5EEAD4),
      unlockedWeaponNameCustom: 'Projectiles Thérapeutiques',
    ),

    // -------------------------------------------------------------
    // MONDE 4 : Côlon Transverse — Examens & Nutrition (Q13-Q17)
    // -------------------------------------------------------------
    GastroWorld(
      id: 4,
      name: 'CÔLON TRANSVERSE',
      subtitle: 'Examens, Dépistage et Nutrition',
      theme: 'exams',
      description: 'Interprétez CRP, plaquettes, dépistage coloscopique et nutrition entérale.',
      primaryColor: const Color(0xFF0EA5E9), // Bleu ciel vif
      secondaryColor: const Color(0xFF34D399), // Vert menthe
      questionIds: const [13, 14, 15, 16, 17],
      bossName: 'Calprotectin Behemoth',
      bossDescription: 'Sentinelle des Biomarqueurs. Protégé par une carapace d\'enzymes leucocytaires.',
      bossDangerLevel: 'ÉLEVÉ',
      environmentDescription: 'Lumière colique azur claire ponctuée de marqueurs biochimiques et flore probiotique.',
      icon: Icons.science_rounded,
      guideWelcome: 'Analysons les marqueurs biologiques et la surveillance endoscopique du côlon.',
      tunnelDeepColorCustom: const Color(0xFF103763),
      tunnelWallColorCustom: const Color(0xFF0284C7),
      tunnelFringeColorCustom: const Color(0xFF6EE7B7),
      unlockedWeaponNameCustom: 'Onde Anti-Inflammatoire',
    ),

    // -------------------------------------------------------------
    // MONDE 5 : Zone Vasculaire — Hérédité & Grossesse (Q18-Q24)
    // -------------------------------------------------------------
    GastroWorld(
      id: 5,
      name: 'ZONE VASCULAIRE',
      subtitle: 'Hérédité, Grossesse et Allaitement',
      theme: 'family',
      description: 'Accompagnez les patientes : fertilité, grossesse sous contrôle et allaitement sécurisé.',
      primaryColor: const Color(0xFFA78BFA), // Violet doux
      secondaryColor: const Color(0xFFFB7185), // Corail rose
      questionIds: const [18, 19, 20, 21, 22, 23, 24],
      bossName: 'Chromosoma Prime',
      bossDescription: 'Archonte Périnatal. Déclenche des vagues circulaires autour des membranes cellulaires.',
      bossDangerLevel: 'TRÈS ÉLEVÉ',
      environmentDescription: 'Chambre vasculaire lavande et corail douce avec vésicules génétiques luminescentes.',
      icon: Icons.favorite_rounded,
      guideWelcome: 'Sept questions essentielles sur la conception, la grossesse et l\'allaitement !',
      tunnelDeepColorCustom: const Color(0xFF33215E),
      tunnelWallColorCustom: const Color(0xFF7C3AED),
      tunnelFringeColorCustom: const Color(0xFFFDA4AF),
      unlockedWeaponNameCustom: 'Bouclier Déflecteur Pulsé',
    ),

    // -------------------------------------------------------------
    // MONDE 6 : Soins Intensifs — Rôle Infirmier & Urgences (Q25-Q27)
    // -------------------------------------------------------------
    GastroWorld(
      id: 6,
      name: 'SECTEUR SOINS AIGUS',
      subtitle: 'Rôle Infirmier et Colite Aiguë Grave',
      theme: 'nursing',
      description: 'Repérez l\'urgence vitale (CAG), surveillez l\'azathioprine et assurez la thromboprophylaxie.',
      primaryColor: const Color(0xFF38BDF8), // Bleu monitoring lumineux
      secondaryColor: const Color(0xFFFBBF24), // Or d'alerte clinique
      questionIds: const [25, 26, 27],
      bossName: 'Thrombosis Hydra',
      bossDescription: 'Hydre des Complications Aiguës. Multiplie les projectiles rapides et zones critiques.',
      bossDangerLevel: 'CRITIQUE',
      environmentDescription: 'Corridor clinique haute précision avec rétrécissements intestinaux et signaux vitaux.',
      icon: Icons.health_and_safety_rounded,
      guideWelcome: 'Votre expertise infirmière fait la différence face aux situations aiguës !',
      tunnelDeepColorCustom: const Color(0xFF103159),
      tunnelWallColorCustom: const Color(0xFF1D4ED8),
      tunnelFringeColorCustom: const Color(0xFFFCD34D),
      unlockedWeaponNameCustom: 'Plasma Bio-Émeraude',
    ),

    // -------------------------------------------------------------
    // MONDE 7 : Sanctuaire Final — Révision & Maîtrise PFE
    // -------------------------------------------------------------
    GastroWorld(
      id: 7,
      name: 'SANCTUAIRE FINAL',
      subtitle: 'Révision Active & Maîtrise Totale',
      theme: 'revision',
      description: 'Consolidez vos points à revoir ou triomphez de l\'épreuve ultime de certification ISSIT.',
      primaryColor: const Color(0xFFFBBF24), // Or radieux
      secondaryColor: const Color(0xFF22D3EE), // Cyan lumineux
      questionIds: const [], // Dynamiquement alimenté par progress.revisionQueue
      bossName: 'Alpha-Cure Prime',
      bossDescription: 'Gardien Suprême de la Rémission. Test ultime combinant agilité, bouclier et puissance.',
      bossDangerLevel: 'ULTIME',
      environmentDescription: 'Sanctuaire doré et turquoise baigné d\'aurores thérapeutiques apaisantes.',
      icon: Icons.workspace_premium_rounded,
      guideWelcome: 'L\'épreuve finale ! Transformez vos connaissances cliniques en puissance de guérison !',
      tunnelDeepColorCustom: const Color(0xFF134154),
      tunnelWallColorCustom: const Color(0xFF0E7490),
      tunnelFringeColorCustom: const Color(0xFFFDE047),
      unlockedWeaponNameCustom: 'Rayon Thérapeutique Ultime',
    ),
  ];

  static GastroWorld getWorldForLevel(int level) {
    if (level >= 1 && level <= worlds.length) {
      return worlds[level - 1];
    }
    return worlds.first;
  }

  static GastroWorld getWorldForQuestionId(int questionId) {
    for (final world in worlds) {
      if (world.questionIds.contains(questionId)) {
        return world;
      }
    }
    return worlds.first;
  }
}

List<GastroWorld> get allGastroWorlds => GastroWorld.worlds;
