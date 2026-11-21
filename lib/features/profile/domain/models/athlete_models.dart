import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/jungle_theme.dart';

class JungleAvatarOption {
  final String id;
  final String name;
  final String title;
  final String emoji;
  final Color accentColor;
  final IconData icon;

  const JungleAvatarOption({
    required this.id,
    required this.name,
    required this.title,
    required this.emoji,
    required this.accentColor,
    required this.icon,
  });

  static const List<JungleAvatarOption> allAvatars = [
    JungleAvatarOption(
      id: 'gorila_guardian',
      name: 'Gorila Guardián',
      title: 'Protector del Tótem',
      emoji: '🦍',
      accentColor: JungleColors.accentCyan,
      icon: Icons.shield_rounded,
    ),
    JungleAvatarOption(
      id: 'rey_kong',
      name: 'Rey Kong',
      title: 'Monarca de la Isla',
      emoji: '👑',
      accentColor: JungleColors.accentGold,
      icon: Icons.workspace_premium_rounded,
    ),
    JungleAvatarOption(
      id: 'naufrago',
      name: 'Náufrago Explorador',
      title: 'Sobreviviente Humano',
      emoji: '🧭',
      accentColor: Color(0xFF38BDF8),
      icon: Icons.explore_rounded,
    ),
    JungleAvatarOption(
      id: 'capuchino',
      name: 'Mono Capuchino',
      title: 'Maestro del Ritmo',
      emoji: '🐒',
      accentColor: Color(0xFFA78BFA),
      icon: Icons.music_note_rounded,
    ),
    JungleAvatarOption(
      id: 'boxeador',
      name: 'Gorila Boxeador',
      title: 'Puño de Coco',
      emoji: '🥊',
      accentColor: JungleColors.alertCoral,
      icon: Icons.sports_mma_rounded,
    ),
    JungleAvatarOption(
      id: 'bebe_gorila',
      name: 'Bebé Dormilón',
      title: 'Soñador de Plátanos',
      emoji: '🍌',
      accentColor: JungleColors.emeraldSuccess,
      icon: Icons.bedtime_rounded,
    ),
  ];

  static JungleAvatarOption fromId(String id) {
    return allAvatars.firstWhere(
      (a) => a.id == id,
      orElse: () => allAvatars.first,
    );
  }
}

class AthleteProfile {
  final String id;
  final String fullName;
  final String nickname;
  final String avatarId;
  final String dominantHand; // 'Diestro' | 'Zurdo' | 'Ambas'
  final String lastSyncedAt;

  const AthleteProfile({
    required this.id,
    required this.fullName,
    required this.nickname,
    required this.avatarId,
    required this.dominantHand,
    required this.lastSyncedAt,
  });

  JungleAvatarOption get avatar => JungleAvatarOption.fromId(avatarId);

  AthleteProfile copyWith({
    String? id,
    String? fullName,
    String? nickname,
    String? avatarId,
    String? dominantHand,
    String? lastSyncedAt,
  }) {
    return AthleteProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      avatarId: avatarId ?? this.avatarId,
      dominantHand: dominantHand ?? this.dominantHand,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'nickname': nickname,
        'avatarId': avatarId,
        'dominantHand': dominantHand,
        'lastSyncedAt': lastSyncedAt,
      };

  factory AthleteProfile.fromJson(Map<String, dynamic> json) {
    return AthleteProfile(
      id: (json['id'] ?? '') as String,
      fullName: (json['fullName'] ?? 'Atleta de la Selva') as String,
      nickname: (json['nickname'] ?? 'KONG_RUNNER') as String,
      avatarId: (json['avatarId'] ?? 'gorila_guardian') as String,
      dominantHand: (json['dominantHand'] ?? 'Diestro') as String,
      lastSyncedAt: (json['lastSyncedAt'] ?? 'Local') as String,
    );
  }
}

class BowlingFrameScore {
  final int frame;
  final String roll1;
  final String roll2;
  final int cumulative;

  const BowlingFrameScore({
    required this.frame,
    required this.roll1,
    required this.roll2,
    required this.cumulative,
  });

  bool get isStrike => roll1.toUpperCase() == 'X';
  bool get isSpare => roll2.contains('/');

  factory BowlingFrameScore.fromJson(Map<String, dynamic> json) {
    return BowlingFrameScore(
      frame: (json['frame'] as num?)?.toInt() ?? 1,
      roll1: (json['roll1'] ?? '').toString(),
      roll2: (json['roll2'] ?? '').toString(),
      cumulative: (json['cumulative'] as num?)?.toInt() ?? 0,
    );
  }
}

class CoconutThrowAttempt {
  final int attemptNumber;
  final double distanceMeters;
  final double angleDeg;
  final bool isValid;
  final String note;

  const CoconutThrowAttempt({
    required this.attemptNumber,
    required this.distanceMeters,
    required this.angleDeg,
    required this.isValid,
    required this.note,
  });

  factory CoconutThrowAttempt.fromJson(Map<String, dynamic> json) {
    return CoconutThrowAttempt(
      attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 1,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      angleDeg: (json['angleDeg'] as num?)?.toDouble() ?? 0.0,
      isValid: (json['isValid'] as bool?) ?? true,
      note: (json['note'] ?? '').toString(),
    );
  }
}

class ArcadeDisciplineStat {
  final String disciplineName;
  final int highScore;
  final int bestCombo;
  final double accuracyPercent;
  final String extraBadge;

  const ArcadeDisciplineStat({
    required this.disciplineName,
    required this.highScore,
    required this.bestCombo,
    required this.accuracyPercent,
    required this.extraBadge,
  });
}

class HistoricalMatchPoint {
  final String matchLabel;
  final int totalPoints;
  final String rank;

  const HistoricalMatchPoint({
    required this.matchLabel,
    required this.totalPoints,
    required this.rank,
  });

  factory HistoricalMatchPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalMatchPoint(
      matchLabel: (json['matchLabel'] ?? 'M-100').toString(),
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] ?? 'Bronce').toString(),
    );
  }
}

class ScoreboardDashboardData {
  final String matchId;
  final int bowlingTotalScore;
  final List<BowlingFrameScore> bowlingFrames;
  final double coconutBestDistance;
  final List<CoconutThrowAttempt> coconutAttempts;
  final ArcadeDisciplineStat jungleDrums;
  final ArcadeDisciplineStat gorillaWhack;
  final ArcadeDisciplineStat coconutSlice;
  final List<HistoricalMatchPoint> historicalEvolution;
  final List<Map<String, dynamic>> remotePlayers;
  final List<Map<String, dynamic>> syncedMinigames;

  const ScoreboardDashboardData({
    required this.matchId,
    required this.bowlingTotalScore,
    required this.bowlingFrames,
    required this.coconutBestDistance,
    required this.coconutAttempts,
    required this.jungleDrums,
    required this.gorillaWhack,
    required this.coconutSlice,
    required this.historicalEvolution,
    required this.remotePlayers,
    required this.syncedMinigames,
  });

  /// Returns a map of top score summaries per discipline for the Photo Booth overlay
  Map<String, String> get championRecordByDiscipline => {
        'Banana Bowling': '$bowlingTotalScore pts (10 Frames)',
        'Coconut Throw': '${coconutBestDistance.toStringAsFixed(1)} m Récord',
        'Jungle Drums':
            '${jungleDrums.highScore} pts • Combo x${jungleDrums.bestCombo}',
        'Gorilla Whack':
            '${gorillaWhack.highScore} pts • ${gorillaWhack.accuracyPercent.toStringAsFixed(1)}% Precisión',
        'Coconut Slice':
            '${coconutSlice.highScore} pts • Combo x${coconutSlice.bestCombo}',
        'Gorilla Boxing': '2,640 pts • KO Técnico R2',
        'Jungle Baseball': '134.5 m Home Run • 3/3',
        'Log Balance': '15.0 m • Cruce Perfecto 11.4s',
        'Jungle Keeper': '18/18 Atajadas • Muralla Kong',
      };
}
