import 'package:flutter/material.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../models/game_progress.dart';
import '../audio/audio_service.dart';

class ReviewAnswersScreen extends StatefulWidget {
  final GameProgress progress;

  const ReviewAnswersScreen({
    super.key,
    required this.progress,
  });

  @override
  State<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen> {
  int _selectedWorldId = 0; // 0 for All, 1-6 for specific world
  final AudioService _audio = AudioService();

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _selectedWorldId == 0
        ? allGastroQuestions
        : allGastroQuestions.where((q) => q.worldId == _selectedWorldId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08172D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            _audio.playClick();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'REVUE PÉDAGOGIQUE (30 QUESTIONS)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs (Tous + 6 Mondes)
          Container(
            height: 52,
            color: const Color(0xFF08172D),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              children: [
                _buildFilterChip(0, 'Tous (30)'),
                ...GastroWorld.worlds.map((w) => _buildFilterChip(w.id, '${w.title} (${w.questionCount})')),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredQuestions.length,
              itemBuilder: (context, index) {
                final q = filteredQuestions[index];
                final world = GastroWorld.getWorldForLevel(q.id);
                final userAnswerIndex = widget.progress.userAnswers[q.id];
                final isAnswered = userAnswerIndex != null;
                final isCorrect = widget.progress.isCorrectMap[q.id] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1E38),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isAnswered
                          ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                          : Colors.white12,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: world.primaryColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Niv. ${q.id} • ${world.title}',
                              style: TextStyle(
                                color: world.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAnswered
                                  ? (isCorrect ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFEF4444).withOpacity(0.2))
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAnswered
                                      ? (isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded)
                                      : Icons.remove_circle_outline_rounded,
                                  color: isAnswered
                                      ? (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                      : Colors.white38,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isAnswered ? (isCorrect ? 'Correct' : 'Erreur') : 'Non joué',
                                  style: TextStyle(
                                    color: isAnswered
                                        ? (isCorrect ? const Color(0xFFA7F3D0) : const Color(0xFFFCA5A5))
                                        : Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Question prompt
                      Text(
                        q.questionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // User selection vs correct answer
                      if (isAnswered && !isCorrect) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B1219),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5)),
                          ),
                          child: Text(
                            'Votre choix : ${q.options[userAnswerIndex]}',
                            style: const TextStyle(
                              color: Color(0xFFFCA5A5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF063A2F),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6)),
                        ),
                        child: Text(
                          'Bonne réponse : ${q.options[q.correctOptionIndex]}',
                          style: const TextStyle(
                            color: Color(0xFFA7F3D0),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Medical explanation
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF040D1A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          q.explanation,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int worldId, String label) {
    final isSelected = _selectedWorldId == worldId;
    return GestureDetector(
      onTap: () {
        _audio.playClick();
        setState(() => _selectedWorldId = worldId);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF0B1E38),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF040D1A) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
