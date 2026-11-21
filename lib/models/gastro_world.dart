import 'package:flutter/material.dart';

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
      guideWelcome: 'Dernier Monde, 8 questions cruciales sur la fertilité, la grossesse et l\'allaitement au cours des MICI !',
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
