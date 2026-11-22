import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';

class CapsuleWarriorsReviewScreen extends StatefulWidget {
  final GameProgress progress;

  const CapsuleWarriorsReviewScreen({super.key, required this.progress});

  @override
  State<CapsuleWarriorsReviewScreen> createState() => _CapsuleWarriorsReviewScreenState();
}

class _CapsuleWarriorsReviewScreenState extends State<CapsuleWarriorsReviewScreen> {
  int _selectedWorldFilter = 0; // 0 = all
  String _statusFilter = 'all'; // all, mastered, revision

  List<GastroQuestion> get _filteredQuestions {
    return allGastroQuestions.where((q) {
      if (_selectedWorldFilter != 0 && q.worldId != _selectedWorldFilter) {
        return false;
      }
      if (_statusFilter == 'mastered' && !widget.progress.masteredQuestions.contains(q.id)) {
        return false;
      }
      if (_statusFilter == 'revision' && !widget.progress.revisionQueue.contains(q.id)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;
    final questions = _filteredQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          'CENTRE DE RÉVISION (33 QUESTIONS PFE)',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 14 : 17,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('all', 'Toutes (${allGastroQuestions.length})', Icons.list_alt_rounded),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        'mastered',
                        'Maîtrisées (${widget.progress.masteredQuestions.length})',
                        Icons.check_circle_rounded,
                        activeColor: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        'revision',
                        'En Révision (${widget.progress.revisionQueue.length})',
                        Icons.sync_problem_rounded,
                        activeColor: const Color(0xFFF87171),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // World Filter Dropdown / Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildWorldChip(0, 'Tous les mondes'),
                      ...allGastroWorlds.map((w) => _buildWorldChip(w.id, 'Monde ${w.id}')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Question List
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, color: Color(0xFF64748B), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune question ne correspond à ce filtre.',
                          style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 24,
                      vertical: 16,
                    ),
                    itemCount: questions.length,
                    itemBuilder: (context, idx) {
                      final q = questions[idx];
                      return _buildQuestionCard(q, isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String key, String label, IconData icon, {Color? activeColor}) {
    final isSelected = _statusFilter == key;
    final color = activeColor ?? const Color(0xFF00E5FF);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _statusFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : const Color(0xFF94A3B8), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorldChip(int worldId, String label) {
    final isSelected = _selectedWorldFilter == worldId;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedWorldFilter = worldId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(GastroQuestion q, bool isMobile) {
    final isMastered = widget.progress.masteredQuestions.contains(q.id);
    final inRevision = widget.progress.revisionQueue.contains(q.id);
    final world = GastroWorld.getWorldForLevel(q.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMastered
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : inRevision
                  ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                  : const Color(0xFF1E293B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: world.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: world.primaryColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'QUESTION ${q.id} • MONDE ${q.worldId}',
                  style: GoogleFonts.plusJakartaSans(
                    color: world.primaryColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                q.anatomicalTheme,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isMastered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Maîtrisée',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else if (inRevision)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_problem_rounded, color: Color(0xFFEF4444), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'À réviser',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFF87171),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Statement
          Text(
            q.questionText,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Options
          Column(
            children: List.generate(q.options.length, (optIdx) {
              final isCorrect = optIdx == q.correctOptionIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFF1E293B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect ? const Color(0xFF10B981) : const Color(0xFF334155),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isCorrect ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q.options[optIdx],
                        style: GoogleFonts.inter(
                          color: isCorrect ? Colors.white : const Color(0xFFCBD5E1),
                          fontSize: 12.5,
                          fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BONNE RÉPONSE',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Clinical Explanation Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RATIONNEL CLINIQUE VALIDÉ (ISSIT PFE) :',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        q.explanation,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
