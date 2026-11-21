import 'package:uuid/uuid.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../domain/models/athlete_models.dart';

class ProfileRepositoryResult {
  final AthleteProfile profile;
  final ScoreboardDashboardData dashboard;
  final bool isOfflineOrMock;
  final String syncMessage;
  final int pendingQueueCount;

  const ProfileRepositoryResult({
    required this.profile,
    required this.dashboard,
    required this.isOfflineOrMock,
    required this.syncMessage,
    required this.pendingQueueCount,
  });
}

class ProfileRepository {
  final LocalStorageService _storage;
  final ApiClient _apiClient;
  final Uuid _uuid = const Uuid();

  ProfileRepository(this._storage, this._apiClient);

  AthleteProfile loadOrInitLocalProfile() {
    final existing = _storage.getPlayerProfileJson();
    if (existing != null &&
        existing['id'] != null &&
        (existing['id'] as String).isNotEmpty) {
      return AthleteProfile.fromJson(existing);
    }

    final initial = AthleteProfile(
      id: _uuid.v4(),
      fullName: 'Arturo Explorador',
      nickname: 'KING_BANANA',
      avatarId: 'rey_kong',
      dominantHand: 'Diestro',
      lastSyncedAt: 'Inicializado localmente',
    );
    _storage.savePlayerProfileJson(initial.toJson());
    return initial;
  }

  Future<ProfileRepositoryResult> syncAll({
    AthleteProfile? updatedProfile,
    String matchId = 'GOR-2026-FINAL',
    int simulationSeed = 0,
  }) async {
    AthleteProfile activeProfile = updatedProfile ?? loadOrInitLocalProfile();
    await _storage.savePlayerProfileJson(activeProfile.toJson());

    // 1. POST /api/v1/players
    final postResult = await _apiClient.registerOrUpdatePlayer(
      activeProfile.toJson(),
    );
    activeProfile = activeProfile.copyWith(
      lastSyncedAt: DateTime.now().toIso8601String().substring(11, 19),
    );
    await _storage.savePlayerProfileJson(activeProfile.toJson());

    // 2. GET /api/v1/players
    final playersResult = await _apiClient.fetchPlayers(activeProfile.toJson());

    // 3. GET /api/v1/minigames
    final minigamesResult = await _apiClient.fetchMinigames();

    // 4. GET /api/v1/matches/{matchId}/results
    final matchResult = await _apiClient.fetchMatchResults(
      matchId,
      seedOffset: simulationSeed,
    );

    final rawMatch = matchResult.data;
    await _storage.saveCachedDashboardJson(rawMatch);

    final dashboard = _parseDashboard(
      rawMatch,
      playersResult.data,
      minigamesResult.data,
    );

    final usedMock = postResult.usedMockFallback ||
        matchResult.usedMockFallback ||
        _storage.forceMockMode;

    return ProfileRepositoryResult(
      profile: activeProfile,
      dashboard: dashboard,
      isOfflineOrMock: usedMock,
      syncMessage: postResult.statusMessage,
      pendingQueueCount: _storage.getPendingSyncQueue().length,
    );
  }

  ScoreboardDashboardData _parseDashboard(
    Map<String, dynamic> rawMatch,
    List<Map<String, dynamic>> players,
    List<Map<String, dynamic>> minigames,
  ) {
    final bowlingMap =
        Map<String, dynamic>.from((rawMatch['bananaBowling'] ?? {}) as Map);
    final framesList = (bowlingMap['frames'] as List<dynamic>? ?? [])
        .map((e) => BowlingFrameScore.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final coconutMap =
        Map<String, dynamic>.from((rawMatch['coconutThrow'] ?? {}) as Map);
    final attemptsList = (coconutMap['attempts'] as List<dynamic>? ?? [])
        .map((e) =>
            CoconutThrowAttempt.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final drumsMap =
        Map<String, dynamic>.from((rawMatch['jungleDrums'] ?? {}) as Map);
    final whackMap =
        Map<String, dynamic>.from((rawMatch['gorillaWhack'] ?? {}) as Map);
    final sliceMap =
        Map<String, dynamic>.from((rawMatch['coconutSlice'] ?? {}) as Map);

    final evolutionList = (rawMatch['historicalEvolution'] as List<dynamic>? ?? [])
        .map((e) =>
            HistoricalMatchPoint.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ScoreboardDashboardData(
      matchId: (rawMatch['matchId'] ?? 'GOR-2026-FINAL').toString(),
      bowlingTotalScore: (bowlingMap['totalScore'] as num?)?.toInt() ?? 159,
      bowlingFrames: framesList,
      coconutBestDistance:
          (coconutMap['bestDistance'] as num?)?.toDouble() ?? 27.6,
      coconutAttempts: attemptsList,
      jungleDrums: ArcadeDisciplineStat(
        disciplineName: 'Jungle Drums',
        highScore: (drumsMap['highScore'] as num?)?.toInt() ?? 12420,
        bestCombo: (drumsMap['bestCombo'] as num?)?.toInt() ?? 52,
        accuracyPercent:
            (drumsMap['accuracyPercent'] as num?)?.toDouble() ?? 93.8,
        extraBadge: 'S-RANK RITMO',
      ),
      gorillaWhack: ArcadeDisciplineStat(
        disciplineName: 'Gorilla Whack',
        highScore: (whackMap['highScore'] as num?)?.toInt() ?? 1890,
        bestCombo: (whackMap['bestCombo'] as num?)?.toInt() ?? 15,
        accuracyPercent:
            (whackMap['accuracyPercent'] as num?)?.toDouble() ?? 91.2,
        extraBadge: '${(whackMap['totalHits'] as num?)?.toInt() ?? 24} Golpes',
      ),
      coconutSlice: ArcadeDisciplineStat(
        disciplineName: 'Coconut Slice',
        highScore: (sliceMap['highScore'] as num?)?.toInt() ?? 1950,
        bestCombo: (sliceMap['bestCombo'] as num?)?.toInt() ?? 17,
        accuracyPercent:
            (sliceMap['accuracyPercent'] as num?)?.toDouble() ?? 89.5,
        extraBadge: 'Gorila Dormido Intacto',
      ),
      historicalEvolution: evolutionList,
      remotePlayers: players,
      syncedMinigames: minigames,
    );
  }
}
