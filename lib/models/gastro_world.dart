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
  final String theme; // 'anatomy', 'symptoms', 'treatment', 'exams', 'lifestyle', 'family', 'nursing'
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final List<int> questionIds; // which of the 33 question IDs belong here
  final String bossName;
  final String bossDescription;
  final String environmentDescription; // text describing the visual environment
  bool isUnlocked;
  bool isCompleted;
  int starsEarned; // 0-3

  // Additional backwards-compatible fields & getters
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
  int get endLevel => questionIds.isNotEmpty ? questionIds.last : 33;
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
    GastroWorld(
      id: 1,
      name: 'MONDE 1',
      subtitle: 'Anatomie, Physiologie et Lésions',
      theme: 'anatomy',
      description: 'Explorez la structure du tube digestif, les muqueuses et les mécanismes des lésions digestives.',
      primaryColor: const Color(0xFFD32F2F), // Deep red/maroon
      secondaryColor: const Color(0xFF880E4F),
      questionIds: const [1, 2, 3, 4],
      bossName: 'Helicobacter Rex',
      bossDescription: 'Le Fléau Flagellé de la Muqueuse. Colonise et détruit la barrière épithéliale gastrique.',
      environmentDescription: 'Vascularisation dense, villosités intestinales mouvantes, paroi gastrique rouge sang avec micro-cryptes.',
      isUnlocked: true,
      icon: Icons.biotech_rounded,
      guideWelcome: 'Bienvenue dans le premier Monde ! Commençons par les fondations : l\'anatomie et la physiologie digestive !',
      tunnelDeepColorCustom: const Color(0xFF2A0808),
      tunnelWallColorCustom: const Color(0xFFB71C1C),
      tunnelFringeColorCustom: const Color(0xFFFF8A80),
      unlockedWeaponNameCustom: 'Laser Médical MK-I',
    ),
    GastroWorld(
      id: 2,
      name: 'MONDE 2',
      subtitle: 'Généralités, Symptômes et Manifestations',
      theme: 'symptoms',
      description: 'Déchiffrez la sémiologie des MICI, poussées aiguës, sténoses et manifestations extra-digestives.',
      primaryColor: const Color(0xFF7B1FA2), // Purple/dark orange
      secondaryColor: const Color(0xFFE65100),
      questionIds: const [5, 6, 7, 8, 9],
      bossName: 'Colossus Inflammatio',
      bossDescription: 'Le Titan des Poussées Aiguës. Projette des décharges de cytokines inflammatoires destructrices.',
      environmentDescription: 'Zone d\'hyperthermie tissulaire, filaments d\'exsudat pourpre, spasmes musculaires et éruptions inflammatoires.',
      icon: Icons.medical_services_rounded,
      guideWelcome: 'Bravo pour votre avancée ! Analysons maintenant la présentation clinique et les symptômes systémiques.',
      tunnelDeepColorCustom: const Color(0xFF1E0A2A),
      tunnelWallColorCustom: const Color(0xFF6A1B9A),
      tunnelFringeColorCustom: const Color(0xFFFF9800),
      unlockedWeaponNameCustom: 'Double Laser Cyan',
    ),
    GastroWorld(
      id: 3,
      name: 'MONDE 3',
      subtitle: 'Traitements Médicamenteux et Observance',
      theme: 'treatment',
      description: 'Maîtrisez les biothérapies anti-TNF, les immunosuppresseurs, les corticoïdes et l\'observance.',
      primaryColor: const Color(0xFF00897B), // Blue/teal
      secondaryColor: const Color(0xFF0288D1),
      questionIds: const [10, 11, 12, 13, 14],
      bossName: 'Auto-Immuno Titan',
      bossDescription: 'Le Golem des Anticorps Dissidents. Complexe d\'anticorps aberrants réfractaire aux thérapies standards.',
      environmentDescription: 'Canaux pharmacologiques bleu-vert, flux de molécules synthétiques, barrières d\'immunosuppression étincelantes.',
      icon: Icons.medication_rounded,
      guideWelcome: 'Le Monde 3 vous plonge dans la pharmacologie : biothérapies et suivi de sécurité thérapeutique !',
      tunnelDeepColorCustom: const Color(0xFF032225),
      tunnelWallColorCustom: const Color(0xFF00796B),
      tunnelFringeColorCustom: const Color(0xFF4DD0E1),
      unlockedWeaponNameCustom: 'Plasma Shot Bio-Émeraude',
    ),
    GastroWorld(
      id: 4,
      name: 'MONDE 4',
      subtitle: 'Examens, Marqueurs Biologiques et Dépistage',
      theme: 'exams',
      description: 'Interprétez la CRP, la calprotectine fécale, les examens endoscopiques et les bilans hématologiques.',
      primaryColor: const Color(0xFF00BCD4), // Cyan/green
      secondaryColor: const Color(0xFF00C853),
      questionIds: const [15, 16, 17, 18],
      bossName: 'Calprotectin Behemoth',
      bossDescription: 'Le Sentinelle des Biomarqueurs. Cristallisation d\'enzymes leucocytaires et de marqueurs sérologiques.',
      environmentDescription: 'Laboratoire microscopique fluorescent, tubes de filtration fluorescents, gradients de densité et signaux biochimiques.',
      icon: Icons.science_rounded,
      guideWelcome: 'Au cœur du laboratoire et de l\'endoscopie : affûtez vos compétences diagnostiques et biologiques !',
      tunnelDeepColorCustom: const Color(0xFF002228),
      tunnelWallColorCustom: const Color(0xFF00838F),
      tunnelFringeColorCustom: const Color(0xFF69F0AE),
      unlockedWeaponNameCustom: 'Energy Shield Pulsé',
    ),
    GastroWorld(
      id: 5,
      name: 'MONDE 5',
      subtitle: 'Mode de Vie, Alimentation et Voyages',
      theme: 'lifestyle',
      description: 'Accompagnez l\'alimentation adaptée, l\'hydratation, la prévention des carences et la préparation aux voyages.',
      primaryColor: const Color(0xFFFFA000), // Warm amber/yellow
      secondaryColor: const Color(0xFFFF6F00),
      questionIds: const [19, 20, 21, 22],
      bossName: 'Dysbiosis Leviathan',
      bossDescription: 'Le Léviathan du Microbiote Altéré. Entité polymorphe alimentée par les déséquilibres nutritionnels.',
      environmentDescription: 'Milieu nutritif ambré, fibres végétales en suspension, métabolites dorés et courants microbiotiques tourbillonnants.',
      icon: Icons.restaurant_rounded,
      guideWelcome: 'La prise en charge globale passe par l\'hygiène de vie, la nutrition adaptée et l\'anticipation des voyages.',
      tunnelDeepColorCustom: const Color(0xFF281802),
      tunnelWallColorCustom: const Color(0xFFD97706),
      tunnelFringeColorCustom: const Color(0xFFFFD54F),
      unlockedWeaponNameCustom: 'Electric Wave Solaire',
    ),
    GastroWorld(
      id: 6,
      name: 'MONDE 6',
      subtitle: 'Hérédité, Fertilité, Grossesse et Allaitement',
      theme: 'family',
      description: 'Conseillez et sécurisez la conception, le suivi obstétrical, la transmission génétique et l\'allaitement.',
      primaryColor: const Color(0xFFE91E63), // Pink/rose/soft purple
      secondaryColor: const Color(0xFF9C27B0),
      questionIds: const [23, 24, 25, 26, 27, 28, 29, 30],
      bossName: 'Chromosoma Prime',
      bossDescription: 'L\'Archonte Génétique & Périnatal. Gardien des hélices génétiques et de la dynamique fœto-maternelle.',
      environmentDescription: 'Double hélice luminescente d\'ADN rose bonbon et lilas, vésicules membranaires et bulles de liquide amniotique protecteur.',
      icon: Icons.favorite_rounded,
      guideWelcome: 'Monde 6, 8 questions cruciales sur la fertilité, la grossesse et l\'allaitement au cours des MICI !',
      tunnelDeepColorCustom: const Color(0xFF27051B),
      tunnelWallColorCustom: const Color(0xFFC2185B),
      tunnelFringeColorCustom: const Color(0xFFCE93D8),
      unlockedWeaponNameCustom: 'Ultimate Pulse Magenta',
    ),
    GastroWorld(
      id: 7,
      name: 'MONDE 7',
      subtitle: 'Rôle Infirmier et Urgences MICI',
      theme: 'nursing',
      description: 'Pilotez la surveillance clinique rapprochée, les urgences de colite aiguë grave et la prévention thromboembolique.',
      primaryColor: const Color(0xFF0288D1), // Blue/white/professional
      secondaryColor: const Color(0xFF80DEEA),
      questionIds: const [31, 32, 33],
      bossName: 'Thrombosis Hydra',
      bossDescription: 'L\'Hydre des Complications Aiguës. Complexe thrombotique menaçant l\'équilibre vital hémodynamique.',
      environmentDescription: 'Station de monitorage clinique haute technologie, tracés d\'électrocardiogramme bleutés, cathéters et débitmètres stériles.',
      icon: Icons.health_and_safety_rounded,
      guideWelcome: 'Monde 7 : L\'excellence clinique infirmière ! 3 défis cruciaux pour sauver vos patients en urgence !',
      tunnelDeepColorCustom: const Color(0xFF021B2B),
      tunnelWallColorCustom: const Color(0xFF0277BD),
      tunnelFringeColorCustom: const Color(0xFFB2EBF2),
      unlockedWeaponNameCustom: 'Quantum Biotherapy Beam',
    ),
  ];

  static GastroWorld getWorldForLevel(int level) {
    for (final world in worlds) {
      if (world.questionIds.contains(level)) {
        return world;
      }
    }
    for (final world in worlds) {
      if (level >= world.startLevel && level <= world.endLevel) {
        return world;
      }
    }
    return worlds.first;
  }
}

List<GastroWorld> get allGastroWorlds => GastroWorld.worlds;
