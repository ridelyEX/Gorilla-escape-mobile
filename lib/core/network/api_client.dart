import 'package:dio/dio.dart';
import '../storage/local_storage_service.dart';

class ApiResponseResult<T> {
  final T data;
  final bool usedMockFallback;
  final String statusMessage;

  const ApiResponseResult({
    required this.data,
    required this.usedMockFallback,
    required this.statusMessage,
  });
}

class ApiClient {
  final LocalStorageService _storage;
  late Dio _dio;

  ApiClient(this._storage) {
    _configureDio(_storage.apiBaseUrl);
  }

  void _configureDio(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    _configureDio(newBaseUrl);
  }

  /// POST /api/v1/players
  Future<ApiResponseResult<Map<String, dynamic>>> registerOrUpdatePlayer(
    Map<String, dynamic> playerJson,
  ) async {
    if (_storage.forceMockMode) {
      return ApiResponseResult(
        data: {
          ...playerJson,
          'syncedAt': DateTime.now().toIso8601String(),
          'serverStatus': 'MOCK_OK',
        },
        usedMockFallback: true,
        statusMessage: 'Guardado en Modo Demo/Offline local.',
      );
    }

    try {
      final response = await _dio.post('/api/v1/players', data: playerJson);
      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {...playerJson, 'syncedAt': DateTime.now().toIso8601String()};

      // If we succeeded, also flush any pending sync items
      final queue = _storage.getPendingSyncQueue();
      if (queue.isNotEmpty) {
        await _storage.clearPendingSyncQueue();
      }

      return ApiResponseResult(
        data: body,
        usedMockFallback: false,
        statusMessage: 'Atleta sincronizado con servidor REST (POST /api/v1/players).',
      );
    } catch (e) {
      await _storage.enqueueSyncPayload({
        'endpoint': 'POST /api/v1/players',
        'payload': playerJson,
      });
      return ApiResponseResult(
        data: {
          ...playerJson,
          'syncedAt': DateTime.now().toIso8601String(),
          'serverStatus': 'OFFLINE_QUEUED',
        },
        usedMockFallback: true,
        statusMessage:
            'Servidor no disponible. Perfil guardado en cola Offline-First.',
      );
    }
  }

  /// GET /api/v1/players
  Future<ApiResponseResult<List<Map<String, dynamic>>>> fetchPlayers(
    Map<String, dynamic> currentLocalPlayer,
  ) async {
    if (_storage.forceMockMode) {
      return ApiResponseResult(
        data: _buildMockPlayersRoster(currentLocalPlayer),
        usedMockFallback: true,
        statusMessage: 'Roster cargado desde Modo Mock.',
      );
    }

    try {
      final response = await _dio.get('/api/v1/players');
      final list = (response.data as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return ApiResponseResult(
        data: list,
        usedMockFallback: false,
        statusMessage: 'Roster obtenido de GET /api/v1/players.',
      );
    } catch (_) {
      return ApiResponseResult(
        data: _buildMockPlayersRoster(currentLocalPlayer),
        usedMockFallback: true,
        statusMessage: 'Fallback automático: Roster local simulado.',
      );
    }
  }

  /// GET /api/v1/minigames
  Future<ApiResponseResult<List<Map<String, dynamic>>>> fetchMinigames() async {
    if (_storage.forceMockMode) {
      return ApiResponseResult(
        data: _mockMinigamesCatalog,
        usedMockFallback: true,
        statusMessage: 'Catálogo de 9 disciplinas (Modo Mock).',
      );
    }

    try {
      final response = await _dio.get('/api/v1/minigames');
      final list = (response.data as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return ApiResponseResult(
        data: list,
        usedMockFallback: false,
        statusMessage: 'Disciplinas sincronizadas desde GET /api/v1/minigames.',
      );
    } catch (_) {
      return ApiResponseResult(
        data: _mockMinigamesCatalog,
        usedMockFallback: true,
        statusMessage: 'Fallback Mock: Catálogo oficial de minijuegos.',
      );
    }
  }

  /// GET /api/v1/matches/{matchId}/results
  Future<ApiResponseResult<Map<String, dynamic>>> fetchMatchResults(
    String matchId, {
    int seedOffset = 0,
  }) async {
    if (_storage.forceMockMode) {
      return ApiResponseResult(
        data: _buildMockMatchResults(matchId, seedOffset: seedOffset),
        usedMockFallback: true,
        statusMessage: 'Marcador de partida $matchId (Simulación en Vivo).',
      );
    }

    try {
      final response = await _dio.get('/api/v1/matches/$matchId/results');
      final data = Map<String, dynamic>.from(response.data as Map);
      return ApiResponseResult(
        data: data,
        usedMockFallback: false,
        statusMessage:
            'Resultados en vivo obtenidos de GET /api/v1/matches/$matchId/results.',
      );
    } catch (_) {
      return ApiResponseResult(
        data: _buildMockMatchResults(matchId, seedOffset: seedOffset),
        usedMockFallback: true,
        statusMessage:
            'Fallback Offline: Mostrando datos simulados para partida $matchId.',
      );
    }
  }

  List<Map<String, dynamic>> _buildMockPlayersRoster(
    Map<String, dynamic> localPlayer,
  ) {
    return [
      localPlayer,
      {
        'id': 'kong-champion-001',
        'fullName': 'Kala Gorila',
        'nickname': 'KONG_CRUSHER',
        'avatarId': 'rey_kong',
        'dominantHand': 'Ambas',
        'totalTrophies': 14,
      },
      {
        'id': 'castaway-002',
        'fullName': 'Mateo Náufrago',
        'nickname': 'COCO_SNIPER',
        'avatarId': 'naufrago',
        'dominantHand': 'Diestro',
        'totalTrophies': 9,
      },
      {
        'id': 'capuchin-003',
        'fullName': 'Lia Selva',
        'nickname': 'DRUM_QUEEN',
        'avatarId': 'capuchino',
        'dominantHand': 'Zurdo',
        'totalTrophies': 11,
      },
    ];
  }

  static const List<Map<String, dynamic>> _mockMinigamesCatalog = [
    {
      'id': 'banana_bowling',
      'name': 'Banana Bowling',
      'category': 'Precisión & Giro',
      'targetStoryScore': '80 pts en 10 frames',
    },
    {
      'id': 'coconut_throw',
      'name': 'Coconut Throw',
      'category': 'Potencia & Ángulo',
      'targetStoryScore': '25.0 m (Ángulo 40°-45°)',
    },
    {
      'id': 'coconut_slice',
      'name': 'Coconut Slice',
      'category': 'Reflejos & Corte',
      'targetStoryScore': '1,600 pts sin despertar al gorila',
    },
    {
      'id': 'gorilla_whack',
      'name': 'Gorilla Whack',
      'category': 'Velocidad & Reacción',
      'targetStoryScore': '10 golpes certeros',
    },
    {
      'id': 'gorilla_boxing',
      'name': 'Gorilla Boxing',
      'category': 'Combate & Ritmo',
      'targetStoryScore': 'KO o 2,500 pts',
    },
    {
      'id': 'jungle_baseball',
      'name': 'Jungle Baseball',
      'category': 'Swing & Timing',
      'targetStoryScore': '3 Home Runs / 120 m',
    },
    {
      'id': 'jungle_drums',
      'name': 'Jungle Drums',
      'category': 'Ritmo & Combo',
      'targetStoryScore': '92% precisión / Combo x45',
    },
    {
      'id': 'log_balance',
      'name': 'Log Balance',
      'category': 'Equilibrio & Giroscopio',
      'targetStoryScore': 'Cruzar 15 m sin caer al río',
    },
    {
      'id': 'jungle_keeper',
      'name': 'Jungle Keeper',
      'category': 'Defensa & Reflejos',
      'targetStoryScore': 'Atajar 15 cocos explosivos',
    },
  ];

  Map<String, dynamic> _buildMockMatchResults(
    String matchId, {
    int seedOffset = 0,
  }) {
    final isAlt = seedOffset % 2 == 1;
    final bowlingFrames = isAlt
        ? [
            {'frame': 1, 'roll1': 'X', 'roll2': '', 'cumulative': 20},
            {'frame': 2, 'roll1': '7', 'roll2': '/', 'cumulative': 38},
            {'frame': 3, 'roll1': '8', 'roll2': '1', 'cumulative': 47},
            {'frame': 4, 'roll1': 'X', 'roll2': '', 'cumulative': 67},
            {'frame': 5, 'roll1': '9', 'roll2': '/', 'cumulative': 87},
            {'frame': 6, 'roll1': 'X', 'roll2': '', 'cumulative': 115},
            {'frame': 7, 'roll1': 'X', 'roll2': '', 'cumulative': 134},
            {'frame': 8, 'roll1': '8', 'roll2': '1', 'cumulative': 143},
            {'frame': 9, 'roll1': '9', 'roll2': '/', 'cumulative': 163},
            {'frame': 10, 'roll1': 'X', 'roll2': '9/', 'cumulative': 183},
          ]
        : [
            {'frame': 1, 'roll1': '9', 'roll2': '/', 'cumulative': 18},
            {'frame': 2, 'roll1': '8', 'roll2': '1', 'cumulative': 27},
            {'frame': 3, 'roll1': 'X', 'roll2': '', 'cumulative': 47},
            {'frame': 4, 'roll1': '7', 'roll2': '/', 'cumulative': 65},
            {'frame': 5, 'roll1': '8', 'roll2': '0', 'cumulative': 73},
            {'frame': 6, 'roll1': 'X', 'roll2': '', 'cumulative': 93},
            {'frame': 7, 'roll1': '9', 'roll2': '/', 'cumulative': 111},
            {'frame': 8, 'roll1': '8', 'roll2': '1', 'cumulative': 120},
            {'frame': 9, 'roll1': 'X', 'roll2': '', 'cumulative': 140},
            {'frame': 10, 'roll1': '9', 'roll2': '/', 'cumulative': 159},
          ];

    final coconutAttempts = isAlt
        ? [
            {
              'attemptNumber': 1,
              'distanceMeters': 24.8,
              'angleDeg': 39.5,
              'isValid': true,
              'note': 'Lanzamiento limpio',
            },
            {
              'attemptNumber': 2,
              'distanceMeters': 29.4,
              'angleDeg': 43.2,
              'isValid': true,
              'note': '¡Ángulo óptimo 43.2°!',
            },
            {
              'attemptNumber': 3,
              'distanceMeters': 27.1,
              'angleDeg': 41.0,
              'isValid': true,
              'note': 'Viento a favor',
            },
          ]
        : [
            {
              'attemptNumber': 1,
              'distanceMeters': 22.4,
              'angleDeg': 37.8,
              'isValid': true,
              'note': 'Buen arranque',
            },
            {
              'attemptNumber': 2,
              'distanceMeters': 0.0,
              'angleDeg': 51.0,
              'isValid': false,
              'note': 'Falta: Pisó línea de bambú',
            },
            {
              'attemptNumber': 3,
              'distanceMeters': 27.6,
              'angleDeg': 42.8,
              'isValid': true,
              'note': '¡Ángulo óptimo 42.8°!',
            },
          ];

    return {
      'matchId': matchId,
      'timestamp': DateTime.now().toIso8601String(),
      'bananaBowling': {
        'totalScore': isAlt ? 183 : 159,
        'storyGoalMet': true,
        'frames': bowlingFrames,
      },
      'coconutThrow': {
        'bestDistance': isAlt ? 29.4 : 27.6,
        'storyGoalMeters': 25.0,
        'attempts': coconutAttempts,
      },
      'jungleDrums': {
        'highScore': isAlt ? 14850 : 12420,
        'bestCombo': isAlt ? 64 : 52,
        'accuracyPercent': isAlt ? 96.4 : 93.8,
      },
      'gorillaWhack': {
        'highScore': isAlt ? 2150 : 1890,
        'bestCombo': isAlt ? 19 : 15,
        'accuracyPercent': isAlt ? 94.0 : 91.2,
        'totalHits': isAlt ? 28 : 24,
      },
      'coconutSlice': {
        'highScore': isAlt ? 2480 : 1950,
        'bestCombo': isAlt ? 22 : 17,
        'accuracyPercent': isAlt ? 95.0 : 89.5,
      },
      'historicalEvolution': [
        {'matchLabel': 'M-101', 'totalPoints': 620, 'rank': 'Bronce'},
        {'matchLabel': 'M-102', 'totalPoints': 745, 'rank': 'Plata'},
        {'matchLabel': 'M-103', 'totalPoints': 810, 'rank': 'Plata'},
        {'matchLabel': 'M-104', 'totalPoints': 930, 'rank': 'Oro'},
        {
          'matchLabel': matchId,
          'totalPoints': isAlt ? 1085 : 995,
          'rank': 'Rey Kong',
        },
      ],
    };
  }
}
