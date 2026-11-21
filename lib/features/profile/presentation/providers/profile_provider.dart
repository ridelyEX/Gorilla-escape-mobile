import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../data/profile_repository.dart';
import '../../domain/models/athlete_models.dart';

final sharedPreferencesStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Initialized in main.dart ProviderScope overrides');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(sharedPreferencesStorageProvider);
  return ApiClient(storage);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final storage = ref.watch(sharedPreferencesStorageProvider);
  final api = ref.watch(apiClientProvider);
  return ProfileRepository(storage, api);
});

class ProfileState {
  final AthleteProfile profile;
  final ScoreboardDashboardData? dashboard;
  final bool isLoading;
  final bool isOfflineOrMock;
  final bool forceMockMode;
  final String apiBaseUrl;
  final String activeMatchId;
  final String statusBanner;
  final int pendingQueueCount;
  final int simulationSeed;

  const ProfileState({
    required this.profile,
    this.dashboard,
    this.isLoading = false,
    required this.isOfflineOrMock,
    required this.forceMockMode,
    required this.apiBaseUrl,
    this.activeMatchId = 'GOR-2026-FINAL',
    this.statusBanner = '',
    this.pendingQueueCount = 0,
    this.simulationSeed = 0,
  });

  ProfileState copyWith({
    AthleteProfile? profile,
    ScoreboardDashboardData? dashboard,
    bool? isLoading,
    bool? isOfflineOrMock,
    bool? forceMockMode,
    String? apiBaseUrl,
    String? activeMatchId,
    String? statusBanner,
    int? pendingQueueCount,
    int? simulationSeed,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      isOfflineOrMock: isOfflineOrMock ?? this.isOfflineOrMock,
      forceMockMode: forceMockMode ?? this.forceMockMode,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      activeMatchId: activeMatchId ?? this.activeMatchId,
      statusBanner: statusBanner ?? this.statusBanner,
      pendingQueueCount: pendingQueueCount ?? this.pendingQueueCount,
      simulationSeed: simulationSeed ?? this.simulationSeed,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final LocalStorageService _storage;
  final ApiClient _apiClient;

  ProfileNotifier(this._repository, this._storage, this._apiClient)
      : super(
          ProfileState(
            profile: _repository.loadOrInitLocalProfile(),
            isOfflineOrMock: _storage.forceMockMode,
            forceMockMode: _storage.forceMockMode,
            apiBaseUrl: _storage.apiBaseUrl,
          ),
        ) {
    refreshDashboard();
  }

  Future<void> refreshDashboard({String? customMatchId, bool nextSeed = false}) async {
    final targetMatch = customMatchId ?? state.activeMatchId;
    final nextSeedValue = nextSeed ? state.simulationSeed + 1 : state.simulationSeed;
    state = state.copyWith(
      isLoading: true,
      activeMatchId: targetMatch,
      simulationSeed: nextSeedValue,
    );

    final result = await _repository.syncAll(
      updatedProfile: state.profile,
      matchId: targetMatch,
      simulationSeed: nextSeedValue,
    );

    state = state.copyWith(
      profile: result.profile,
      dashboard: result.dashboard,
      isLoading: false,
      isOfflineOrMock: result.isOfflineOrMock,
      statusBanner: result.syncMessage,
      pendingQueueCount: result.pendingQueueCount,
    );
  }

  Future<void> updateAthleteProfile({
    required String fullName,
    required String nickname,
    required String avatarId,
    required String dominantHand,
  }) async {
    final updated = state.profile.copyWith(
      fullName: fullName.trim().isEmpty ? 'Atleta de la Selva' : fullName.trim(),
      nickname: nickname.trim().isEmpty
          ? 'KONG_PLAYER'
          : nickname.trim().toUpperCase(),
      avatarId: avatarId,
      dominantHand: dominantHand,
    );

    state = state.copyWith(profile: updated, isLoading: true);
    final result = await _repository.syncAll(
      updatedProfile: updated,
      matchId: state.activeMatchId,
      simulationSeed: state.simulationSeed,
    );

    state = state.copyWith(
      profile: result.profile,
      dashboard: result.dashboard,
      isLoading: false,
      isOfflineOrMock: result.isOfflineOrMock,
      statusBanner: result.syncMessage,
      pendingQueueCount: result.pendingQueueCount,
    );
  }

  Future<void> toggleForceMockMode(bool value) async {
    await _storage.setForceMockMode(value);
    state = state.copyWith(forceMockMode: value);
    await refreshDashboard();
  }

  Future<void> updateApiBaseUrl(String url) async {
    final cleaned = url.trim().isEmpty ? 'http://192.168.1.100:8080' : url.trim();
    await _storage.setApiBaseUrl(cleaned);
    _apiClient.updateBaseUrl(cleaned);
    state = state.copyWith(apiBaseUrl: cleaned);
    await refreshDashboard();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  final storage = ref.watch(sharedPreferencesStorageProvider);
  final api = ref.watch(apiClientProvider);
  return ProfileNotifier(repo, storage, api);
});
