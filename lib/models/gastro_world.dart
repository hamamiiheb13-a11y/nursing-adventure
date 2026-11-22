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
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final int startLevel;
  final int endLevel;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final IconData icon;
  final String guideWelcome;
  final GastroBossInfo boss;
  final Color tunnelDeepColor;
  final Color tunnelWallColor;
  final Color tunnelFringeColor;
  final String unlockedWeaponName;

  const GastroWorld({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.startLevel,
    required this.endLevel,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.icon,
    required this.guideWelcome,
    required this.boss,
    required this.tunnelDeepColor,
    required this.tunnelWallColor,
    required this.tunnelFringeColor,
    required this.unlockedWeaponName,
  });

  int get questionCount => endLevel - startLevel + 1;

  static const List<GastroWorld> worlds = [
    GastroWorld(
      id: 1,
      title: 'MONDE 1',
      subtitle: 'Anatomie, Physiologie et Lésions Intestinales',
      description: 'Explorez la structure du tube digestif, les villosités et les mécanismes des lésions muqueuses.',
      startLevel: 1,
      endLevel: 4,
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFF0077B6),
      accentColor: Color(0xFF90E0EF),
      icon: Icons.biotech_rounded,
      guideWelcome: 'Bienvenue dans le premier Monde ! Commençons par les fondations : l\'anatomie et la physiologie digestive !',
      boss: GastroBossInfo(
        name: 'Helicobacter Rex',
        title: 'Le Fléau Flagellé de la Muqueuse',
        description: 'Une bactérie géante aux dents acérées qui colonise et ulcère les parois gastriques et digestives.',
        auraColor: Color(0xFF10B981),
        icon: Icons.coronavirus_rounded,
      ),
      tunnelDeepColor: Color(0xFF06111C),
      tunnelWallColor: Color(0xFFD44357),
      tunnelFringeColor: Color(0xFFFCA5A5),
      unlockedWeaponName: 'Laser Médical MK-I',
    ),
    GastroWorld(
      id: 2,
      title: 'MONDE 2',
      subtitle: 'Généralités, Symptômes et Manifestations',
      description: 'Déchiffrez la sémiologie des MICI, la rémission clinique et les manifestations extra-digestives.',
      startLevel: 5,
      endLevel: 9,
      primaryColor: Color(0xFF818CF8),
      secondaryColor: Color(0xFF4F46E5),
      accentColor: Color(0xFFC7D2FE),
      icon: Icons.medical_services_rounded,
      guideWelcome: 'Bravo pour votre avancée ! Analysons maintenant la présentation clinique et les symptômes systémiques.',
      boss: GastroBossInfo(
        name: 'Colossus Inflammatio',
        title: 'Le Titan des Poussées Aiguës',
        description: 'Entité flamboyante libérant des torrents de cytokines inflammatoires.',
        auraColor: Color(0xFFEF4444),
        icon: Icons.local_fire_department_rounded,
      ),
      tunnelDeepColor: Color(0xFF160824),
      tunnelWallColor: Color(0xFFB91C1C),
      tunnelFringeColor: Color(0xFFF87171),
      unlockedWeaponName: 'Double Laser Cyan',
    ),
    GastroWorld(
      id: 3,
      title: 'MONDE 3',
      subtitle: 'Traitements Médicamenteux et Observance',
      description: 'Maîtrisez les biothérapies anti-TNF, les immunosuppresseurs et l\'importance de l\'observance.',
      startLevel: 10,
      endLevel: 14,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF047857),
      accentColor: Color(0xFFA7F3D0),
      icon: Icons.medication_rounded,
      guideWelcome: 'Le Monde 3 vous plonge dans la pharmacologie : biothérapies et suivi de sécurité thérapeutique !',
      boss: GastroBossInfo(
        name: 'Auto-Immuno Titan',
        title: 'Le Golem des Anticorps Dissidents',
        description: 'Complexe immunitaire déchaîné défiant les thérapies conventionnelles.',
        auraColor: Color(0xFF06B6D4),
        icon: Icons.shield_rounded,
      ),
      tunnelDeepColor: Color(0xFF042018),
      tunnelWallColor: Color(0xFF0D9488),
      tunnelFringeColor: Color(0xFF6EE7B7),
      unlockedWeaponName: 'Plasma Shot Bio-Émeraude',
    ),
    GastroWorld(
      id: 4,
      title: 'MONDE 4',
      subtitle: 'Examens, Marqueurs Biologiques et Dépistage',
      description: 'Interprétez la CRP, la calprotectine, les données hématologiques et le dépistage endoscopique.',
      startLevel: 15,
      endLevel: 18,
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFF0284C7),
      accentColor: Color(0xFFBAE6FD),
      icon: Icons.science_rounded,
      guideWelcome: 'Au cœur du laboratoire et de l\'endoscopie : affûtez vos compétences diagnostiques et biologiques !',
      boss: GastroBossInfo(
        name: 'Calprotectin Behemoth',
        title: 'Le Sentinelle des Biomarqueurs',
        description: 'Gardien minéral et protéique scellant l\'accès aux profondeurs coliques.',
        auraColor: Color(0xFF3B82F6),
        icon: Icons.analytics_rounded,
      ),
      tunnelDeepColor: Color(0xFF081C38),
      tunnelWallColor: Color(0xFF0284C7),
      tunnelFringeColor: Color(0xFF7DD3FC),
      unlockedWeaponName: 'Energy Shield Pulsé',
    ),
    GastroWorld(
      id: 5,
      title: 'MONDE 5',
      subtitle: 'Mode de Vie, Alimentation et Voyages',
      description: 'Accompagnez le quotidien des patients : nutrition entérale, voyages sous biothérapie et sevrage tabagique.',
      startLevel: 19,
      endLevel: 22,
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFB45309),
      accentColor: Color(0xFFFDE68A),
      icon: Icons.restaurant_rounded,
      guideWelcome: 'La prise en charge globale passe par l\'hygiène de vie, la nutrition adaptée et l\'anticipation des voyages.',
      boss: GastroBossInfo(
        name: 'Dysbiosis Leviathan',
        title: 'Le Léviathan du Microbiote Altéré',
        description: 'Monstre tentaculaire né du déséquilibre de la flore et des toxines alimentaires.',
        auraColor: Color(0xFFF59E0B),
        icon: Icons.pest_control_rounded,
      ),
      tunnelDeepColor: Color(0xFF2C1604),
      tunnelWallColor: Color(0xFFD97706),
      tunnelFringeColor: Color(0xFFFCD34D),
      unlockedWeaponName: 'Electric Wave Solaire',
    ),
    GastroWorld(
      id: 6,
      title: 'MONDE 6',
      subtitle: 'Hérédité, Fertilité, Grossesse et Allaitement',
      description: 'Répondez aux enjeux capitaux de la procréation, du suivi obstétrical et de la sécurité néonatale.',
      startLevel: 23,
      endLevel: 30,
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFFBE185D),
      accentColor: Color(0xFFFBCFE8),
      icon: Icons.favorite_rounded,
      guideWelcome: 'Monde 6, 8 questions cruciales sur la fertilité, la grossesse et l\'allaitement au cours des MICI !',
      boss: GastroBossInfo(
        name: 'Chromosoma Prime',
        title: 'L\'Archonte Génétique & Périnatal',
        description: 'Gardien ancestral protégeant le sanctuaire de la transmission et de la vie naissante.',
        auraColor: Color(0xFFEC4899),
        icon: Icons.auto_awesome_rounded,
      ),
      tunnelDeepColor: Color(0xFF2D0623),
      tunnelWallColor: Color(0xFFBE185D),
      tunnelFringeColor: Color(0xFFF472B6),
      unlockedWeaponName: 'Ultimate Pulse Magenta',
    ),
    GastroWorld(
      id: 7,
      title: 'MONDE 7',
      subtitle: 'Rôle Infirmier & Urgences MICI',
      description: 'Prenez en main la surveillance clinique aigüe, les alertes de CAG, la thromboprophylaxie et les bilans.',
      startLevel: 31,
      endLevel: 33,
      primaryColor: Color(0xFF2DD4BF),
      secondaryColor: Color(0xFF0F766E),
      accentColor: Color(0xFF99F6E4),
      icon: Icons.health_and_safety_rounded,
      guideWelcome: 'Monde 7 : L\'excellence clinique infirmière ! 3 défis cruciaux pour sauver vos patients en urgence !',
      boss: GastroBossInfo(
        name: 'Thrombosis Hydra',
        title: 'L\'Hydre des Complications Aiguës',
        description: 'La menace suprême représentant les défaillances systémiques et les urgences thromboemboliques.',
        auraColor: Color(0xFF00E5FF),
        icon: Icons.warning_amber_rounded,
      ),
      tunnelDeepColor: Color(0xFF041C24),
      tunnelWallColor: Color(0xFF0E7490),
      tunnelFringeColor: Color(0xFF67E8F9),
      unlockedWeaponName: 'Quantum Biotherapy Beam',
    ),
  ];

  static GastroWorld getWorldForLevel(int level) {
    for (final world in worlds) {
      if (level >= world.startLevel && level <= world.endLevel) {
        return world;
      }
    }
    return worlds.first;
  }
}

const List<GastroWorld> allGastroWorlds = GastroWorld.worlds;
