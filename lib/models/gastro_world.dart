import 'package:flutter/material.dart';

class GastroBossInfo {
  final String name;
  final String title;
  final String description;
  final Color auraColor;
  final IconData icon;

  const GastroBossInfo({
    required this.name,
    required this.title,
    required this.description,
    required this.auraColor,
    required this.icon,
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
  final List<int> questionIds; // which of the 27 question IDs belong here
  final String bossName;
  final String bossDescription;
  final String environmentDescription;
  bool isUnlocked;
  bool isCompleted;
  int starsEarned; // 0-3

  // Visuals and audio
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
  Color get tunnelDeepColor => tunnelDeepColorCustom ?? primaryColor.withValues(alpha: 0.15);
  Color get tunnelWallColor => tunnelWallColorCustom ?? primaryColor;
  Color get tunnelFringeColor => tunnelFringeColorCustom ?? secondaryColor;
  String get unlockedWeaponName => unlockedWeaponNameCustom ?? 'Arme Niveau $id';

  GastroBossInfo get boss => GastroBossInfo(
        name: bossName,
        title: bossDescription.split('.').first,
        description: bossDescription,
        auraColor: primaryColor,
        icon: icon,
      );

  static List<GastroWorld> worlds = [
    // -------------------------------------------------------------
    // MONDE 1 : Anatomie, Physiologie et Lésions Intestinales (Q1-Q4)
    // -------------------------------------------------------------
    GastroWorld(
      id: 1,
      name: 'MONDE 1',
      subtitle: 'Anatomie, Physiologie et Lésions',
      theme: 'anatomy',
      description: 'Explorez la structure du tube digestif, les villosités et les mécanismes des lésions digestives.',
      primaryColor: const Color(0xFFD32F2F), // Rouge vif artériel
      secondaryColor: const Color(0xFFFF5252), // Corail néon
      questionIds: const [1, 2, 3, 4],
      bossName: 'Helicobacter Rex',
      bossDescription: 'Le Fléau Flagellé de la Muqueuse. Colonise et détruit la barrière épithéliale gastrique.',
      environmentDescription: 'Vascularisation dense, villosités intestinales mouvantes, paroi gastrique rouge sang avec micro-cryptes.',
      isUnlocked: true,
      icon: Icons.biotech_rounded,
      guideWelcome: 'Bienvenue dans le premier Monde ! Commençons par les fondations : l\'anatomie et la physiologie digestive !',
      tunnelDeepColorCustom: const Color(0xFF200508),
      tunnelWallColorCustom: const Color(0xFF991B1B),
      tunnelFringeColorCustom: const Color(0xFFF87171),
      unlockedWeaponNameCustom: 'Laser Médical MK-I',
    ),

    // -------------------------------------------------------------
    // MONDE 2 : Généralités, Symptômes et Manifestations (Q5-Q9)
    // -------------------------------------------------------------
    GastroWorld(
      id: 2,
      name: 'MONDE 2',
      subtitle: 'Généralités, Symptômes et Manifestations',
      theme: 'symptoms',
      description: 'Déchiffrez la sémiologie des MICI, poussées aiguës, sténoses et manifestations extra-digestives.',
      primaryColor: const Color(0xFF8E24AA), // Pourpre profond
      secondaryColor: const Color(0xFFFF9100), // Orange énergétique
      questionIds: const [5, 6, 7, 8, 9],
      bossName: 'Colossus Inflammatio',
      bossDescription: 'Le Titan des Poussées Aiguës. Projette des décharges de cytokines inflammatoires destructrices.',
      environmentDescription: 'Zone d\'hyperthermie tissulaire, filaments d\'exsudat pourpre, spasmes musculaires et éruptions inflammatoires.',
      icon: Icons.medical_services_rounded,
      guideWelcome: 'Bravo pour votre avancée ! Analysons maintenant la présentation clinique et les symptômes systémiques.',
      tunnelDeepColorCustom: const Color(0xFF1B0726),
      tunnelWallColorCustom: const Color(0xFF6B21A8),
      tunnelFringeColorCustom: const Color(0xFFF59E0B),
      unlockedWeaponNameCustom: 'Double Laser Cyan',
    ),

    // -------------------------------------------------------------
    // MONDE 3 : Traitements Médicamenteux et Observance (Q10-Q12)
    // -------------------------------------------------------------
    GastroWorld(
      id: 3,
      name: 'MONDE 3',
      subtitle: 'Traitements Médicamenteux et Observance',
      theme: 'treatment',
      description: 'Maîtrisez les biothérapies anti-TNF, les immunosuppresseurs, les corticoïdes et l\'observance.',
      primaryColor: const Color(0xFF0D9488), // Émeraude pharmacologique
      secondaryColor: const Color(0xFF00E5FF), // Cyan électrique
      questionIds: const [10, 11, 12],
      bossName: 'Auto-Immuno Titan',
      bossDescription: 'Le Golem des Anticorps Dissidents. Complexe d\'anticorps aberrants réfractaire aux thérapies standards.',
      environmentDescription: 'Canaux pharmacologiques bleu-vert, flux de molécules synthétiques, barrières d\'immunosuppression étincelantes.',
      icon: Icons.medication_rounded,
      guideWelcome: 'Le Monde 3 vous plonge dans la pharmacologie : biothérapies et suivi de sécurité thérapeutique !',
      tunnelDeepColorCustom: const Color(0xFF042021),
      tunnelWallColorCustom: const Color(0xFF0F766E),
      tunnelFringeColorCustom: const Color(0xFF2DD4BF),
      unlockedWeaponNameCustom: 'Plasma Shot Bio-Émeraude',
    ),

    // -------------------------------------------------------------
    // MONDE 4 : Examens Biologiques, Dépistage et Nutrition (Q13-Q17)
    // -------------------------------------------------------------
    GastroWorld(
      id: 4,
      name: 'MONDE 4',
      subtitle: 'Examens, Dépistage et Nutrition',
      theme: 'exams',
      description: 'Interprétez la CRP, les plaquettes, la calprotectine, la surveillance endoscopique et la nutrition entérale.',
      primaryColor: const Color(0xFF0284C7), // Bleu analytique
      secondaryColor: const Color(0xFF10B981), // Vert biologique
      questionIds: const [13, 14, 15, 16, 17],
      bossName: 'Calprotectin Behemoth',
      bossDescription: 'Le Sentinelle des Biomarqueurs. Cristallisation d\'enzymes leucocytaires et de marqueurs sérologiques.',
      environmentDescription: 'Laboratoire microscopique fluorescent, filtres fluorescents, gradients de densité et signaux biochimiques.',
      icon: Icons.science_rounded,
      guideWelcome: 'Au cœur du laboratoire et de l\'endoscopie : affûtez vos compétences diagnostiques et biologiques !',
      tunnelDeepColorCustom: const Color(0xFF06182B),
      tunnelWallColorCustom: const Color(0xFF0369A1),
      tunnelFringeColorCustom: const Color(0xFF34D399),
      unlockedWeaponNameCustom: 'Energy Shield Pulsé',
    ),

    // -------------------------------------------------------------
    // MONDE 5 : Hérédité, Fertilité, Grossesse et Allaitement (Q18-Q24)
    // -------------------------------------------------------------
    GastroWorld(
      id: 5,
      name: 'MONDE 5',
      subtitle: 'Hérédité, Grossesse et Allaitement',
      theme: 'family',
      description: 'Conseillez et sécurisez la conception, le suivi obstétrical, la transmission génétique et l\'allaitement.',
      primaryColor: const Color(0xFFDB2777), // Rose néon magenta
      secondaryColor: const Color(0xFFA855F7), // Violet lilas
      questionIds: const [18, 19, 20, 21, 22, 23, 24],
      bossName: 'Chromosoma Prime',
      bossDescription: 'L\'Archonte Génétique & Périnatal. Gardien des hélices génétiques et de la dynamique fœto-maternelle.',
      environmentDescription: 'Double hélice luminescente d\'ADN rose bonbon et lilas, vésicules membranaires et bulles protectrices.',
      icon: Icons.favorite_rounded,
      guideWelcome: 'Monde 5 : 7 questions cruciales sur la fertilité, la grossesse et l\'allaitement au cours des MICI !',
      tunnelDeepColorCustom: const Color(0xFF260517),
      tunnelWallColorCustom: const Color(0xFFBE185D),
      tunnelFringeColorCustom: const Color(0xFFC084FC),
      unlockedWeaponNameCustom: 'Ultimate Pulse Magenta',
    ),

    // -------------------------------------------------------------
    // MONDE 6 : Rôle Infirmier et Urgences CAG (Q25-Q27)
    // -------------------------------------------------------------
    GastroWorld(
      id: 6,
      name: 'MONDE 6',
      subtitle: 'Rôle Infirmier et Urgences MICI',
      theme: 'nursing',
      description: 'Pilotez la surveillance clinique rapprochée, les urgences de colite aiguë grave et la prévention thromboembolique.',
      primaryColor: const Color(0xFF2563EB), // Bleu clinique royal
      secondaryColor: const Color(0xFF38BDF8), // Ciel lumineux
      questionIds: const [25, 26, 27],
      bossName: 'Thrombosis Hydra',
      bossDescription: 'L\'Hydre des Complications Aiguës. Complexe thrombotique menaçant l\'équilibre vital hémodynamique.',
      environmentDescription: 'Station de monitorage clinique haute technologie, tracés d\'électrocardiogramme bleutés et débitmètres stériles.',
      icon: Icons.health_and_safety_rounded,
      guideWelcome: 'Monde 6 : L\'excellence clinique infirmière ! 3 défis cruciaux pour sauver vos patients en urgence !',
      tunnelDeepColorCustom: const Color(0xFF061432),
      tunnelWallColorCustom: const Color(0xFF1D4ED8),
      tunnelFringeColorCustom: const Color(0xFF67E8F9),
      unlockedWeaponNameCustom: 'Electric Wave Solaire',
    ),

    // -------------------------------------------------------------
    // MONDE 7 : Sanctuaire de Maîtrise & Mode de Révision Intelligent
    // -------------------------------------------------------------
    GastroWorld(
      id: 7,
      name: 'MONDE 7',
      subtitle: 'Sanctuaire de Maîtrise & Révision',
      theme: 'revision',
      description: 'Consolidation active de vos erreurs précédentes ou épreuve de perfection ultime avec évaluation PFE.',
      primaryColor: const Color(0xFF00E5FF), // Cyan étincelant
      secondaryColor: const Color(0xFFFFD700), // Or de victoire
      questionIds: const [], // Dynamiquement alimenté par progress.revisionQueue
      bossName: 'Alpha-Cure Prime',
      bossDescription: 'L\'Entité Suprême de la Guérison. Épreuve finale pour consacrer votre maîtrise totale des MICI.',
      environmentDescription: 'Sanctuaire cristallin doré et cyan, aurores énergétiques de guérison et matrice d\'apprentissage réussie.',
      icon: Icons.workspace_premium_rounded,
      guideWelcome: 'Monde 7 : L\'heure de vérité ! Maîtrisez vos points à consolider pour décrocher le titre suprême !',
      tunnelDeepColorCustom: const Color(0xFF031C24),
      tunnelWallColorCustom: const Color(0xFF0E7490),
      tunnelFringeColorCustom: const Color(0xFFFDE047),
      unlockedWeaponNameCustom: 'Quantum Biotherapy Beam',
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
