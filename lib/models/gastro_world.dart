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
  final String organZone;
  final String stageMechanicHint;
  final List<String> acquiredSkills;
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
    this.organZone = '',
    this.stageMechanicHint = '',
    this.acquiredSkills = const [],
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
    // MONDE 1 : Œsophage & Cardia — Anatomie & Lésions (Q1-Q4)
    // -------------------------------------------------------------
    GastroWorld(
      id: 1,
      name: 'ŒSOPHAGE & CARDIA',
      subtitle: 'Anatomie, Physiologie et Lésions',
      theme: 'anatomy',
      description: 'Explorez l\'anatomie du tube digestif, les villosités et le mécanisme des fistules.',
      primaryColor: const Color(0xFFFB7185),
      secondaryColor: const Color(0xFF38BDF8),
      questionIds: const [1, 2, 3, 4],
      bossName: 'Helicobacter Rex',
      bossDescription: 'Fléau Flagellé du Cardia. Libère des enzymes corrosives et vagues péristaltiques.',
      bossDangerLevel: 'MODÉRÉ',
      environmentDescription: 'Parois œsophagiennes nacrées corail-azur et ondes péristaltiques douces.',
      organZone: 'Œsophage & Jonction Cardiale',
      stageMechanicHint: 'Courants péristaltiques doux facilitant la portance',
      acquiredSkills: const ['Fistule vs Sténose', 'Villosités absorbantes', 'Rôle du côlon & iléon'],
      isUnlocked: true,
      icon: Icons.biotech_rounded,
      guideWelcome: 'Bienvenue dans l\'Œsophage ! Maîtrisons l\'anatomie du tractus digestif.',
      tunnelDeepColorCustom: const Color(0xFF1D3E5E),
      tunnelWallColorCustom: const Color(0xFF287494),
      tunnelFringeColorCustom: const Color(0xFFFDA4AF),
      unlockedWeaponNameCustom: 'Double Laser Océan',
    ),

    // -------------------------------------------------------------
    // MONDE 2 : Estomac & Muqueuse — Symptômes & Manifestations (Q5-Q9)
    // -------------------------------------------------------------
    GastroWorld(
      id: 2,
      name: 'ESTOMAC & MUQUEUSE',
      subtitle: 'Symptômes et Manifestations MICI',
      theme: 'symptoms',
      description: 'Déchiffrez les symptômes cardinaux, la rémission et les atteintes articulaires.',
      primaryColor: const Color(0xFFFB923C),
      secondaryColor: const Color(0xFFFBBF24),
      questionIds: const [5, 6, 7, 8, 9],
      bossName: 'Colossus Inflammatio',
      bossDescription: 'Titan Gastrique des Poussées Aiguës. Projette des salves de cytokines acides.',
      bossDangerLevel: 'MODÉRÉ +',
      environmentDescription: 'Corridor gastrique chaud pêche-doré parsemé de replis muqueux et bulles.',
      organZone: 'Estomac & Antre Gastrique',
      stageMechanicHint: 'Gouttelettes gastriques et foyers inflammatoires à apaiser',
      acquiredSkills: const ['Rémission vs Guérison', 'Signes articulaires & généraux', 'Croissance pédiatrique'],
      icon: Icons.medical_services_rounded,
      guideWelcome: 'Cap sur l\'Estomac pour identifier la sémiologie des MICI.',
      tunnelDeepColorCustom: const Color(0xFF1A4363),
      tunnelWallColorCustom: const Color(0xFF0E7490),
      tunnelFringeColorCustom: const Color(0xFFFDBA74),
      unlockedWeaponNameCustom: 'Canon Antibactérien',
    ),

    // -------------------------------------------------------------
    // MONDE 3 : Intestin Grêle — Traitements & Observance (Q10-Q12)
    // -------------------------------------------------------------
    GastroWorld(
      id: 3,
      name: 'INTESTIN GRÊLE',
      subtitle: 'Traitements et Observance',
      theme: 'treatment',
      description: 'Maîtrisez les biothérapies anti-TNF, immunosuppresseurs et l\'importance de l\'observance.',
      primaryColor: const Color(0xFF14B8A6),
      secondaryColor: const Color(0xFF34D399),
      questionIds: const [10, 11, 12],
      bossName: 'Auto-Immuno Titan',
      bossDescription: 'Golem des Anticorps Dissidents. Bloque l\'action des thérapies biologiques.',
      bossDangerLevel: 'ÉLEVÉ',
      environmentDescription: 'Flux turquoise apaisant enrichi de villosités et nutriments absorbants.',
      organZone: 'Intestin Grêle (Jéjunum)',
      stageMechanicHint: 'Villosités nourricières accélérant la recharge énergétique',
      acquiredSkills: const ['Sécurité anti-TNF', 'Combothérapie immunomodulatrice', 'Observance stricte'],
      icon: Icons.medication_rounded,
      guideWelcome: 'Bienvenue dans l\'Intestin Grêle ! Place à la pharmacologie anti-TNF.',
      tunnelDeepColorCustom: const Color(0xFF0D444A),
      tunnelWallColorCustom: const Color(0xFF0F766E),
      tunnelFringeColorCustom: const Color(0xFF5EEAD4),
      unlockedWeaponNameCustom: 'Projectiles Thérapeutiques',
    ),

    // -------------------------------------------------------------
    // MONDE 4 : Iléon Terminal — Examens & Nutrition (Q13-Q17)
    // -------------------------------------------------------------
    GastroWorld(
      id: 4,
      name: 'ILÉON TERMINAL',
      subtitle: 'Examens, Dépistage et Nutrition',
      theme: 'exams',
      description: 'Interprétez CRP, plaquettes, dépistage coloscopique et nutrition entérale.',
      primaryColor: const Color(0xFF0EA5E9),
      secondaryColor: const Color(0xFF34D399),
      questionIds: const [13, 14, 15, 16, 17],
      bossName: 'Calprotectin Behemoth',
      bossDescription: 'Sentinelle des Biomarqueurs. Protégé par une carapace d\'enzymes leucocytaires.',
      bossDangerLevel: 'ÉLEVÉ',
      environmentDescription: 'Lumière iléale azur ponctuée de sténoses douces et plaques de Peyer.',
      organZone: 'Iléon Terminal & Valvule Iléo-Caecale',
      stageMechanicHint: 'Rétrécissements physiologiques à négocier avec précision',
      acquiredSkills: const ['Plaquettes & CRP en poussée', 'Coloscopie de dépistage', 'Nutrition entérale'],
      icon: Icons.science_rounded,
      guideWelcome: 'Analysons les marqueurs biologiques et la surveillance dans l\'Iléon Terminal.',
      tunnelDeepColorCustom: const Color(0xFF103763),
      tunnelWallColorCustom: const Color(0xFF0284C7),
      tunnelFringeColorCustom: const Color(0xFF6EE7B7),
      unlockedWeaponNameCustom: 'Onde Anti-Inflammatoire',
    ),

    // -------------------------------------------------------------
    // MONDE 5 : Côlon Transverse — Hérédité & Grossesse (Q18-Q24)
    // -------------------------------------------------------------
    GastroWorld(
      id: 5,
      name: 'CÔLON TRANSVERSE',
      subtitle: 'Hérédité, Fertilité et Allaitement',
      theme: 'family',
      description: 'Accompagnez les patientes : fertilité, grossesse sous contrôle et allaitement sécurisé.',
      primaryColor: const Color(0xFFA78BFA),
      secondaryColor: const Color(0xFFFB7185),
      questionIds: const [18, 19, 20, 21, 22, 23, 24],
      bossName: 'Chromosoma Prime',
      bossDescription: 'Archonte Périnatal. Déclenche des vagues circulaires autour des haustrations coliques.',
      bossDangerLevel: 'TRÈS ÉLEVÉ',
      environmentDescription: 'Chambre colique lavande et corail douce avec haustrations et flore symbiotique.',
      organZone: 'Côlon Transverse & Haustrations',
      stageMechanicHint: 'Vagues probiotiques protectrices et salves périnatales',
      acquiredSkills: const ['Prédisposition génétique', 'Rémission pré-conception', 'Accouchement & allaitement'],
      icon: Icons.favorite_rounded,
      guideWelcome: 'Sept questions clés sur la conception, la grossesse et l\'allaitement !',
      tunnelDeepColorCustom: const Color(0xFF2D2560),
      tunnelWallColorCustom: const Color(0xFF6D28D9),
      tunnelFringeColorCustom: const Color(0xFFFDA4AF),
      unlockedWeaponNameCustom: 'Bouclier Déflecteur Pulsé',
    ),

    // -------------------------------------------------------------
    // MONDE 6 : Rectum & Zone Périnéale — Rôle Infirmier (Q25-Q27)
    // -------------------------------------------------------------
    GastroWorld(
      id: 6,
      name: 'RECTUM & URGENCES',
      subtitle: 'Rôle Infirmier et Colite Aiguë Grave',
      theme: 'nursing',
      description: 'Repérez l\'urgence vitale (CAG), surveillez l\'azathioprine et assurez la thromboprophylaxie.',
      primaryColor: const Color(0xFF38BDF8),
      secondaryColor: const Color(0xFFFBBF24),
      questionIds: const [25, 26, 27],
      bossName: 'Thrombosis Hydra',
      bossDescription: 'Hydre des Complications Rectales. Multiplie les projectiles rapides et zones critiques.',
      bossDangerLevel: 'CRITIQUE',
      environmentDescription: 'Corridor rectal vascularisé avec signaux vitaux dorés et alertes cliniques.',
      organZone: 'Rectum & Zone Périnéale',
      stageMechanicHint: 'Signaux d\'alerte rapides demandant bouclier et réflexes',
      acquiredSkills: const ['Signes de Colite Aiguë Grave', 'Bilan azathioprine (NFS/foie)', 'HBPM préventive'],
      icon: Icons.health_and_safety_rounded,
      guideWelcome: 'Votre expertise infirmière fait la différence face aux urgences rectales !',
      tunnelDeepColorCustom: const Color(0xFF103563),
      tunnelWallColorCustom: const Color(0xFF1D4ED8),
      tunnelFringeColorCustom: const Color(0xFFFCD34D),
      unlockedWeaponNameCustom: 'Plasma Bio-Émeraude',
    ),

    // -------------------------------------------------------------
    // MONDE 7 : Sanctuaire Immunitaire — Révision & Maîtrise PFE
    // -------------------------------------------------------------
    GastroWorld(
      id: 7,
      name: 'SANCTUAIRE FINAL',
      subtitle: 'Révision Active & Maîtrise Totale',
      theme: 'revision',
      description: 'Consolidez vos points à revoir ou triomphez de l\'épreuve ultime de certification ISSIT.',
      primaryColor: const Color(0xFFFBBF24),
      secondaryColor: const Color(0xFF22D3EE),
      questionIds: const [],
      bossName: 'Alpha-Cure Prime',
      bossDescription: 'Gardien Suprême de la Rémission. Test ultime combinant agilité, bouclier et puissance.',
      bossDangerLevel: 'ULTIME',
      environmentDescription: 'Sanctuaire doré et turquoise baigné d\'aurores thérapeutiques apaisantes.',
      organZone: 'Tractus Digestif Complet — Certification',
      stageMechanicHint: 'Combinaison de toutes les mécaniques digestives',
      acquiredSkills: const ['Synthèse clinique MICI', 'Maîtrise thérapeutique', 'Certification ISSIT'],
      icon: Icons.workspace_premium_rounded,
      guideWelcome: 'L\'épreuve finale ! Transformez vos connaissances cliniques en puissance de guérison !',
      tunnelDeepColorCustom: const Color(0xFF134154),
      tunnelWallColorCustom: const Color(0xFF0E7490),
      tunnelFringeColorCustom: const Color(0xFFFDE047),
      unlockedWeaponNameCustom: 'Rayon Thérapeutique Ultime',
    ),
  ];

  static final GastroWorld revisionWorld = GastroWorld(
    id: 7,
    name: 'RÉVISION FINALE',
    subtitle: 'Consolidation Ciblée des 7 Stages',
    theme: 'revision',
    description:
        'Stage spécial consacré exclusivement aux questions manquées durant les 7 stages originaux.',
    primaryColor: const Color(0xFFFBBF24),
    secondaryColor: const Color(0xFF22D3EE),
    questionIds: const [],
    bossName: 'Gardien du Savoir • Synthèse',
    bossDescription:
        'Épreuve spéciale de révision consolidant vos connaissances cliniques MICI.',
    bossDangerLevel: 'SPÉCIAL',
    environmentDescription:
        'Sanctuaire saphir et or illuminé de courants thérapeutiques et filaments dorés.',
    organZone: 'Stage Spécial de Révision (Stages 1–7)',
    stageMechanicHint: 'Rappel ciblé des notions à consolider sans répétition inutile',
    acquiredSkills: const [
      'Consolidation des acquis MICI',
      'Maîtrise clinique complète',
    ],
    isUnlocked: true,
    icon: Icons.auto_stories_rounded,
    guideWelcome:
        'Bienvenue dans le Stage de Révision ! Revenons uniquement sur les notions à renforcer.',
    tunnelDeepColorCustom: const Color(0xFF103866),
    tunnelWallColorCustom: const Color(0xFFB45309),
    tunnelFringeColorCustom: const Color(0xFFFDE047),
    unlockedWeaponNameCustom: 'Rayon Thérapeutique Ultime',
  );

  static GastroWorld getWorldForLevel(int level) {
    if (level <= 0) return worlds.first;
    final clamped = level.clamp(1, worlds.length);
    return worlds[clamped - 1];
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
