import 'package:flutter/material.dart';
import 'gastro_question.dart';
import 'game_progress.dart';
import '../theme/app_theme.dart';

class HospitalPatient {
  final int id;
  final String name;
  final int age;
  final String summary;
  final String pathology;
  final IconData avatarIcon;

  const HospitalPatient({
    required this.id,
    required this.name,
    required this.age,
    required this.summary,
    required this.pathology,
    required this.avatarIcon,
  });

  String get displayName => '$name ($age ans)';
}

class MedicalTool {
  final int id;
  final int serviceId;
  final String name;
  final String description;
  final IconData icon;

  const MedicalTool({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class HospitalService {
  final int id;
  final String name;
  final String theme;
  final String description;
  final HospitalPatient patient;
  final MedicalTool tool;
  final int startQuestionId;
  final int endQuestionId;
  final IconData serviceIcon;
  final Color themeColor;

  const HospitalService({
    required this.id,
    required this.name,
    required this.theme,
    required this.description,
    required this.patient,
    required this.tool,
    required this.startQuestionId,
    required this.endQuestionId,
    required this.serviceIcon,
    this.themeColor = AppColors.primaryTeal,
  });

  int get questionCount => endQuestionId - startQuestionId + 1;

  List<GastroQuestion> get questions {
    return allGastroQuestions.where((q) => q.id >= startQuestionId && q.id <= endQuestionId).toList();
  }

  bool isUnlocked(GameProgress progress) {
    if (id == 1) return true;
    return progress.isLevelUnlocked(startQuestionId);
  }

  bool isCompleted(GameProgress progress) {
    for (int qId = startQuestionId; qId <= endQuestionId; qId++) {
      if (!progress.completedLevels.contains(qId)) return false;
    }
    return true;
  }

  int getCompletedQuestionCount(GameProgress progress) {
    int count = 0;
    for (int qId = startQuestionId; qId <= endQuestionId; qId++) {
      if (progress.completedLevels.contains(qId)) count++;
    }
    return count;
  }

  double getStabilizationRate(GameProgress progress) {
    if (questionCount == 0) return 0.0;
    return (getCompletedQuestionCount(progress) / questionCount.toDouble()).clamp(0.0, 1.0);
  }

  /// Niveau d'inflammation résiduel du patient (100% au début -> 0% une fois guéri)
  int getResidualInflammation(GameProgress progress) {
    final double rate = getStabilizationRate(progress);
    return ((1.0 - rate) * 100).round();
  }

  static const List<HospitalService> services = [
    // Service 1
    HospitalService(
      id: 1,
      name: 'Unité d\'Endoscopie',
      theme: 'Anatomie, Physiologie et Lésions Intestinales',
      description: 'Explorez l\'anatomie des villosités, la fonction d\'absorption colique et identifiez les fistules.',
      patient: HospitalPatient(
        id: 1,
        name: 'Sami',
        age: 24,
        summary: 'Présente des douleurs de la fosse iliaque droite et suspicion de lésions transmurales.',
        pathology: 'Suspicion Maladie de Crohn iléale',
        avatarIcon: Icons.person_outline_rounded,
      ),
      tool: MedicalTool(
        id: 1,
        serviceId: 1,
        name: 'Endoscope HD',
        description: 'Visualisation haute définition de la muqueuse digestive et des replis muqueux.',
        icon: Icons.camera_enhance_rounded,
      ),
      startQuestionId: 1,
      endQuestionId: 4,
      serviceIcon: Icons.biotech_rounded,
      themeColor: AppColors.primaryTeal,
    ),

    // Service 2
    HospitalService(
      id: 2,
      name: 'Urgences Gastro',
      theme: 'Généralités, Symptômes et Manifestations',
      description: 'Prise en charge des poussées aiguës, évaluation de la rémission clinique et manifestations articulaires.',
      patient: HospitalPatient(
        id: 2,
        name: 'Nadia',
        age: 31,
        summary: 'Admise pour diarrhées glairo-sanglantes aiguës et arthralgies périphériques inflammatoires.',
        pathology: 'Poussée active de MICI',
        avatarIcon: Icons.person_rounded,
      ),
      tool: MedicalTool(
        id: 2,
        serviceId: 2,
        name: 'Stéthoscope Clinique',
        description: 'Examen clinique sémiologique rigoureux et surveillance de l\'auscultation.',
        icon: Icons.hearing_rounded,
      ),
      startQuestionId: 5,
      endQuestionId: 9,
      serviceIcon: Icons.medical_services_rounded,
      themeColor: AppColors.alertCoral,
    ),

    // Service 3
    HospitalService(
      id: 3,
      name: 'Pharmacie Clinique',
      theme: 'Traitements Médicamenteux et Observance',
      description: 'Gestion sécurisée des biothérapies anti-TNF, combothérapies et prévention des ruptures de traitement.',
      patient: HospitalPatient(
        id: 3,
        name: 'Karim',
        age: 28,
        summary: 'Initiation d\'une biothérapie anti-TNF sous surveillance cutanée et dermatologique.',
        pathology: 'MICI sous combothérapie',
        avatarIcon: Icons.person_outline_rounded,
      ),
      tool: MedicalTool(
        id: 3,
        serviceId: 3,
        name: 'Protocole Biothérapie',
        description: 'Optimisation pharmacocinétique et prévention de l\'immunisation aux anticorps.',
        icon: Icons.medication_rounded,
      ),
      startQuestionId: 10,
      endQuestionId: 14,
      serviceIcon: Icons.medication_liquid_rounded,
      themeColor: AppColors.accentCobalt,
    ),

    // Service 4
    HospitalService(
      id: 4,
      name: 'Laboratoire Biologique',
      theme: 'Examens, Marqueurs et Dépistage',
      description: 'Analyse fine de la CRP, thrombocytose réactionnelle et protocole de surveillance coloscopique.',
      patient: HospitalPatient(
        id: 4,
        name: 'Leila',
        age: 42,
        summary: 'Bilan biologique de surveillance pour une colite évoluant depuis plus de 8 ans.',
        pathology: 'Suivi biologique et dépistage',
        avatarIcon: Icons.person_rounded,
      ),
      tool: MedicalTool(
        id: 4,
        serviceId: 4,
        name: 'Analyseur Calprotectine',
        description: 'Dosage de l\'inflammation muqueuse locale et anticipation des rechutes.',
        icon: Icons.science_rounded,
      ),
      startQuestionId: 15,
      endQuestionId: 18,
      serviceIcon: Icons.analytics_rounded,
      themeColor: AppColors.primaryTeal,
    ),

    // Service 5
    HospitalService(
      id: 5,
      name: 'Consultation de Suivi',
      theme: 'Mode de Vie, Alimentation et Voyages',
      description: 'Conseils personnalisés : alimentation variée, gestion des voyages à l\'étranger et sevrage tabagique.',
      patient: HospitalPatient(
        id: 5,
        name: 'Youssef',
        age: 35,
        summary: 'Prépare un voyage à l\'étranger avec transport réfrigéré et démarche de sevrage tabagique.',
        pathology: 'Éducation thérapeutique & Voyages',
        avatarIcon: Icons.person_outline_rounded,
      ),
      tool: MedicalTool(
        id: 5,
        serviceId: 5,
        name: 'Passeport MICI',
        description: 'Certificats bilingues de voyage, chaîne du froid et conseils nutritionnels.',
        icon: Icons.card_travel_rounded,
      ),
      startQuestionId: 19,
      endQuestionId: 22,
      serviceIcon: Icons.health_and_safety_rounded,
      themeColor: AppColors.rewardAmber,
    ),

    // Service 6
    HospitalService(
      id: 6,
      name: 'Unité Maternité',
      theme: 'Hérédité, Fertilité, Grossesse et Allaitement',
      description: 'Sécurité de la procréation, maintien de la rémission préconceptionnelle et innocuité de l\'allaitement.',
      patient: HospitalPatient(
        id: 6,
        name: 'Amira',
        age: 29,
        summary: 'Projet de grossesse et suivi périnatal spécialisé sous traitement compatible continu.',
        pathology: 'Grossesse & Allaitement en rémission',
        avatarIcon: Icons.pregnant_woman_rounded,
      ),
      tool: MedicalTool(
        id: 6,
        serviceId: 6,
        name: 'Caducée Expert MICI',
        description: 'Maîtrise complète et certification des 6 volets de la prise en charge MICI.',
        icon: Icons.workspace_premium_rounded,
      ),
      startQuestionId: 23,
      endQuestionId: 30,
      serviceIcon: Icons.child_care_rounded,
      themeColor: Color(0xFFE11D48),
    ),
  ];

  static HospitalService getServiceForLevel(int level) {
    for (final service in services) {
      if (level >= service.startQuestionId && level <= service.endQuestionId) {
        return service;
      }
    }
    return services.first;
  }
}
