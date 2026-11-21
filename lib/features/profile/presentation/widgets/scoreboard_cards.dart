import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/jungle_theme.dart';
import '../../../../core/widgets/jungle_glass_card.dart';
import '../../domain/models/athlete_models.dart';

class BananaBowlingScoreboardCard extends StatefulWidget {
  final int totalScore;
  final List<BowlingFrameScore> frames;

  const BananaBowlingScoreboardCard({
    super.key,
    required this.totalScore,
    required this.bowlingFrames,
  }) : frames = bowlingFrames;

  final List<BowlingFrameScore> bowlingFrames;

  @override
  State<BananaBowlingScoreboardCard> createState() =>
      _BananaBowlingScoreboardCardState();
}

class _BananaBowlingScoreboardCardState
    extends State<BananaBowlingScoreboardCard> {
  int _selectedFrameIndex = 9;

  @override
  Widget build(BuildContext context) {
    final frames = widget.frames;
    final selectedFrame = frames.isNotEmpty &&
            _selectedFrameIndex < frames.length
        ? frames[_selectedFrameIndex]
        : null;

    return JungleGlassCard(
      borderColor: JungleColors.accentGold.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JungleColors.accentGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🍌', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BANANA BOWLING • 10 FRAMES',
                      style: JungleTheme.displayStyle(
                        fontSize: 18,
                        color: JungleColors.accentGold,
                      ),
                    ),
                    Text(
                      'Meta Modo Historia: 80 pts • Toca un frame para detalle',
                      style: JungleTheme.bodyStyle(
                        fontSize: 12,
                        color: JungleColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: JungleColors.goldGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL',
                      style: JungleTheme.bodyStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: JungleColors.bgDeepJungle,
                      ),
                    ),
                    Text(
                      '${widget.totalScore}',
                      style: JungleTheme.displayStyle(
                        fontSize: 20,
                        color: JungleColors.bgDeepJungle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(frames.length, (index) {
                final f = frames[index];
                final isSelected = index == _selectedFrameIndex;
                final isStrikeOrSpare = f.isStrike || f.isSpare;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFrameIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 68,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? JungleColors.accentCyan.withValues(alpha: 0.22)
                          : JungleColors.bgDeepJungle.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? JungleColors.accentCyan
                            : (isStrikeOrSpare
                                ? JungleColors.accentGold.withValues(alpha: 0.5)
                                : JungleColors.textSecondary
                                    .withValues(alpha: 0.2)),
                        width: isSelected ? 2 : 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? JungleColors.accentCyan
                                : JungleColors.cardGlass,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                          ),
                          child: Text(
                            'F${f.frame}',
                            textAlign: TextAlign.center,
                            style: JungleTheme.bodyStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? JungleColors.bgDeepJungle
                                  : JungleColors.textSecondary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildRollBox(f.roll1, isStrike: f.isStrike),
                              _buildRollBox(
                                f.roll2.isEmpty && f.isStrike ? '-' : f.roll2,
                                isSpare: f.isSpare,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${f.cumulative}',
                            style: JungleTheme.displayStyle(
                              fontSize: 16,
                              color: isStrikeOrSpare
                                  ? JungleColors.accentGold
                                  : JungleColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          if (selectedFrame != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: JungleColors.bgDeepJungle.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: JungleColors.accentCyan.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedFrame.isStrike
                        ? Icons.bolt_rounded
                        : (selectedFrame.isSpare
                            ? Icons.auto_awesome_rounded
                            : Icons.sports_baseball_rounded),
                    color: selectedFrame.isStrike
                        ? JungleColors.accentGold
                        : JungleColors.accentCyan,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFrame.isStrike
                          ? 'Frame ${selectedFrame.frame}: ¡STRIKE TOTÉMICO (X)! Derribaste los 10 pinos en el primer tiro.'
                          : selectedFrame.isSpare
                              ? 'Frame ${selectedFrame.frame}: ¡SPARE SELVÁTICO (/)! Limpiaste la pista en el segundo tiro.'
                              : 'Frame ${selectedFrame.frame}: Tiro 1 (${selectedFrame.roll1}) + Tiro 2 (${selectedFrame.roll2}) • Acumulado: ${selectedFrame.cumulative} pts.',
                      style: JungleTheme.bodyStyle(
                        fontSize: 12,
                        color: JungleColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRollBox(
    String value, {
    bool isStrike = false,
    bool isSpare = false,
  }) {
    final highlightColor = isStrike
        ? JungleColors.accentGold
        : (isSpare ? JungleColors.accentCyan : JungleColors.textPrimary);

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (isStrike || isSpare)
            ? highlightColor.withValues(alpha: 0.18)
            : Colors.black26,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: JungleTheme.displayStyle(
          fontSize: 13,
          color: highlightColor,
        ),
      ),
    );
  }
}

class CoconutThrowScoreCard extends StatelessWidget {
  final double bestDistance;
  final List<CoconutThrowAttempt> attempts;

  const CoconutThrowScoreCard({
    super.key,
    required this.bestDistance,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    return JungleGlassCard(
      borderColor: JungleColors.accentCyan.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: JungleColors.accentCyan.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('🥥', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COCONUT THROW • 3 INTENTOS',
                      style: JungleTheme.displayStyle(
                        fontSize: 18,
                        color: JungleColors.accentCyan,
                      ),
                    ),
                    Text(
                      'Meta Historia: 25.0 m • Ángulo Óptimo: 40° a 45°',
                      style: JungleTheme.bodyStyle(
                        fontSize: 12,
                        color: JungleColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              JungleBadge(
                label: 'MEJOR: ${bestDistance.toStringAsFixed(1)} m',
                color: JungleColors.accentGold,
                icon: Icons.emoji_events_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...attempts.map((attempt) {
            final isBest = attempt.isValid &&
                (attempt.distanceMeters - bestDistance).abs() < 0.05;
            final borderColor = !attempt.isValid
                ? JungleColors.alertCoral
                : (isBest
                    ? JungleColors.accentGold
                    : JungleColors.accentCyan.withValues(alpha: 0.25));

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBest
                    ? JungleColors.accentGold.withValues(alpha: 0.12)
                    : JungleColors.bgDeepJungle.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                  width: isBest ? 1.8 : 1.2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: !attempt.isValid
                        ? JungleColors.alertCoral.withValues(alpha: 0.2)
                        : (isBest
                            ? JungleColors.accentGold
                            : JungleColors.cardGlass),
                    child: Text(
                      '#${attempt.attemptNumber}',
                      style: JungleTheme.displayStyle(
                        fontSize: 14,
                        color: !attempt.isValid
                            ? JungleColors.alertCoral
                            : (isBest
                                ? JungleColors.bgDeepJungle
                                : JungleColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              attempt.isValid
                                  ? '${attempt.distanceMeters.toStringAsFixed(1)} m'
                                  : 'NULO / FALTA',
                              style: JungleTheme.displayStyle(
                                fontSize: 17,
                                color: !attempt.isValid
                                    ? JungleColors.alertCoral
                                    : (isBest
                                        ? JungleColors.accentGold
                                        : JungleColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isBest)
                              const JungleBadge(
                                label: 'BEST ATTEMPT',
                                color: JungleColors.accentGold,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ángulo: ${attempt.angleDeg.toStringAsFixed(1)}° • ${attempt.note}',
                          style: JungleTheme.bodyStyle(
                            fontSize: 12,
                            color: JungleColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    attempt.isValid
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: attempt.isValid
                        ? JungleColors.emeraldSuccess
                        : JungleColors.alertCoral,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ArcadeComboStatsGrid extends StatelessWidget {
  final ArcadeDisciplineStat drums;
  final ArcadeDisciplineStat whack;
  final ArcadeDisciplineStat slice;

  const ArcadeComboStatsGrid({
    super.key,
    required this.drums,
    required this.whack,
    required this.slice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatTile(
          emoji: '🥁',
          stat: drums,
          accent: JungleColors.accentCyan,
          goalNote: 'Meta: Ritmo Tribal & Combo continuo',
        ),
        const SizedBox(height: 12),
        _buildStatTile(
          emoji: '🔨',
          stat: whack,
          accent: JungleColors.accentGold,
          goalNote: 'Meta Historia: 10 golpes certeros a Monos Traviesos',
        ),
        const SizedBox(height: 12),
        _buildStatTile(
          emoji: '⚔️',
          stat: slice,
          accent: JungleColors.emeraldSuccess,
          goalNote: 'Meta Historia: 1,600 pts (¡Cuidado con el Bebé Gorila!)',
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String emoji,
    required ArcadeDisciplineStat stat,
    required Color accent,
    required String goalNote,
  }) {
    return JungleGlassCard(
      borderColor: accent.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.disciplineName.toUpperCase(),
                      style: JungleTheme.displayStyle(
                        fontSize: 17,
                        color: accent,
                      ),
                    ),
                    Text(
                      goalNote,
                      style: JungleTheme.bodyStyle(
                        fontSize: 11,
                        color: JungleColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              JungleBadge(label: stat.extraBadge, color: accent),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metricBox(
                  'PUNTAJE MÁX',
                  '${stat.highScore}',
                  JungleColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricBox(
                  'BEST COMBO',
                  'x${stat.bestCombo}',
                  JungleColors.accentGold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricBox(
                  'PRECISIÓN',
                  '${stat.accuracyPercent.toStringAsFixed(1)}%',
                  JungleColors.accentCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: JungleColors.bgDeepJungle.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: JungleTheme.bodyStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: JungleColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: JungleTheme.displayStyle(
              fontSize: 18,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoricalEvolutionChartCard extends StatelessWidget {
  final List<HistoricalMatchPoint> points;

  const HistoricalEvolutionChartCard({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return JungleGlassCard(
      borderColor: JungleColors.accentCyan.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_graph_rounded,
                color: JungleColors.accentCyan,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'EVOLUCIÓN HISTÓRICA DE RÉCORDS (REST + CACHÉ)',
                  style: JungleTheme.displayStyle(
                    fontSize: 16,
                    color: JungleColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _HistoricalChartPainter(points),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points.map((p) {
              return Flexible(
                child: Column(
                  children: [
                    Text(
                      '${p.totalPoints}',
                      style: JungleTheme.displayStyle(
                        fontSize: 13,
                        color: JungleColors.accentGold,
                      ),
                    ),
                    Text(
                      p.matchLabel,
                      overflow: TextOverflow.ellipsis,
                      style: JungleTheme.bodyStyle(
                        fontSize: 10,
                        color: JungleColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HistoricalChartPainter extends CustomPainter {
  final List<HistoricalMatchPoint> points;

  _HistoricalChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = JungleColors.textSecondary.withValues(alpha: 0.14)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxScore = points
        .map((e) => e.totalPoints)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final minScore = points
        .map((e) => e.totalPoints)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    final range = (maxScore - minScore).clamp(100.0, 2000.0);

    final path = Path();
    final fillPath = Path();
    final coords = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : (i / (points.length - 1)) * (size.width - 24) + 12;
      final normalized = (points[i].totalPoints - minScore + 50) / (range + 100);
      final y = size.height - (normalized.clamp(0.1, 0.92) * size.height);
      coords.add(Offset(x, y));
    }

    path.moveTo(coords.first.dx, coords.first.dy);
    fillPath.moveTo(coords.first.dx, size.height);
    fillPath.lineTo(coords.first.dx, coords.first.dy);

    for (int i = 1; i < coords.length; i++) {
      final prev = coords[i - 1];
      final curr = coords[i];
      final ctrl1 = Offset((prev.dx + curr.dx) / 2, prev.dy);
      final ctrl2 = Offset((prev.dx + curr.dx) / 2, curr.dy);
      path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, curr.dx, curr.dy);
      fillPath.cubicTo(
        ctrl1.dx,
        ctrl1.dy,
        ctrl2.dx,
        ctrl2.dy,
        curr.dx,
        curr.dy,
      );
    }

    fillPath.lineTo(coords.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          JungleColors.accentCyan.withValues(alpha: 0.38),
          JungleColors.accentCyan.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = JungleColors.accentCyan
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = JungleColors.accentGold;
    for (final c in coords) {
      canvas.drawCircle(c, 5.5, dotPaint);
      canvas.drawCircle(
        c,
        2.5,
        Paint()..color = JungleColors.bgDeepJungle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HistoricalChartPainter oldDelegate) =>
      oldDelegate.points != points;
}
