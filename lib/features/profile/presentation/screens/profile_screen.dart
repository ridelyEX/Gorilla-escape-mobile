import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/jungle_theme.dart';
import '../../../../core/widgets/jungle_glass_card.dart';
import '../../domain/models/athlete_models.dart';
import '../providers/profile_provider.dart';
import '../widgets/scoreboard_cards.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedScoreTab = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final profile = state.profile;
    final avatar = profile.avatar;
    final dashboard = state.dashboard;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: JungleColors.accentCyan,
          backgroundColor: JungleColors.cardGlass,
          onRefresh: () =>
              ref.read(profileProvider.notifier).refreshDashboard(nextSeed: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
            children: [
              _buildTopHeader(context, state),
              const SizedBox(height: 16),
              _buildAthleteIdCard(context, profile, avatar, state),
              const SizedBox(height: 16),
              _buildRestControlBar(context, state),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'MARCADOR PERSONAL & VIVO',
                      style: JungleTheme.displayStyle(
                        fontSize: 20,
                        color: JungleColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(profileProvider.notifier)
                          .refreshDashboard(nextSeed: true);
                    },
                    icon: const Icon(
                      Icons.sync_rounded,
                      size: 18,
                      color: JungleColors.accentCyan,
                    ),
                    label: Text(
                      'Simular Ronda',
                      style: JungleTheme.bodyStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: JungleColors.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildScoreTabs(),
              const SizedBox(height: 14),
              if (dashboard == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: JungleColors.accentCyan,
                    ),
                  ),
                )
              else ...[
                if (_selectedScoreTab == 0) ...[
                  BananaBowlingScoreboardCard(
                    totalScore: dashboard.bowlingTotalScore,
                    bowlingFrames: dashboard.bowlingFrames,
                  ),
                  const SizedBox(height: 16),
                  CoconutThrowScoreCard(
                    bestDistance: dashboard.coconutBestDistance,
                    attempts: dashboard.coconutAttempts,
                  ),
                ] else if (_selectedScoreTab == 1) ...[
                  ArcadeComboStatsGrid(
                    drums: dashboard.jungleDrums,
                    whack: dashboard.gorillaWhack,
                    slice: dashboard.coconutSlice,
                  ),
                ] else ...[
                  HistoricalEvolutionChartCard(
                    points: dashboard.historicalEvolution,
                  ),
                  const SizedBox(height: 16),
                  _buildRestEndpointsSummaryCard(dashboard, state),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, ProfileState state) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: JungleColors.cyanGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.sports_kabaddi_rounded,
            color: JungleColors.bgDeepJungle,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GORILIMPIADAS COMPANION',
                style: JungleTheme.displayStyle(
                  fontSize: 22,
                  color: JungleColors.textPrimary,
                ),
              ),
              Text(
                'Perfil de Atleta • Match ${state.activeMatchId}',
                style: JungleTheme.bodyStyle(
                  fontSize: 12,
                  color: JungleColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Configurar Backend REST / Offline',
          onPressed: () => _showNetworkSettingsSheet(context, state),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JungleColors.cardGlass,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: state.isOfflineOrMock
                    ? JungleColors.accentGold
                    : JungleColors.emeraldSuccess,
              ),
            ),
            child: Icon(
              state.isOfflineOrMock
                  ? Icons.cloud_off_rounded
                  : Icons.cloud_done_rounded,
              color: state.isOfflineOrMock
                  ? JungleColors.accentGold
                  : JungleColors.emeraldSuccess,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteIdCard(
    BuildContext context,
    AthleteProfile profile,
    JungleAvatarOption avatar,
    ProfileState state,
  ) {
    return JungleGlassCard(
      enableGlow: true,
      borderColor: avatar.accentColor.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatar.accentColor.withValues(alpha: 0.18),
                  border: Border.all(color: avatar.accentColor, width: 2.4),
                ),
                child: Text(
                  avatar.emoji,
                  style: const TextStyle(fontSize: 34),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.nickname,
                            overflow: TextOverflow.ellipsis,
                            style: JungleTheme.displayStyle(
                              fontSize: 24,
                              color: avatar.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        JungleBadge(
                          label: profile.dominantHand,
                          color: JungleColors.accentCyan,
                          icon: Icons.back_hand_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.fullName} • ${avatar.name}',
                      style: JungleTheme.bodyStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: JungleColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UUID: ${profile.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: JungleTheme.bodyStyle(
                        fontSize: 11,
                        color: JungleColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: JungleArcadeButton(
                  label: 'PERSONALIZAR ATLETA',
                  icon: Icons.edit_rounded,
                  onPressed: () => _showEditAthleteModal(context, profile),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestControlBar(BuildContext context, ProfileState state) {
    return JungleGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: state.isOfflineOrMock
          ? JungleColors.accentGold.withValues(alpha: 0.4)
          : JungleColors.emeraldSuccess.withValues(alpha: 0.4),
      child: Row(
        children: [
          Icon(
            state.isOfflineOrMock
                ? Icons.bolt_rounded
                : Icons.wifi_tethering_rounded,
            color: state.isOfflineOrMock
                ? JungleColors.accentGold
                : JungleColors.emeraldSuccess,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.forceMockMode
                      ? 'MODO DEMO / OFFLINE-FIRST ACTIVO'
                      : 'CONECTANDO A REST: ${state.apiBaseUrl}',
                  style: JungleTheme.displayStyle(
                    fontSize: 13,
                    color: state.isOfflineOrMock
                        ? JungleColors.accentGold
                        : JungleColors.emeraldSuccess,
                  ),
                ),
                Text(
                  state.statusBanner.isEmpty
                      ? 'Sincronización instantánea lista.'
                      : state.statusBanner,
                  style: JungleTheme.bodyStyle(
                    fontSize: 11,
                    color: JungleColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.forceMockMode,
            activeThumbColor: JungleColors.accentGold,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              ref.read(profileProvider.notifier).toggleForceMockMode(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTabs() {
    final tabs = [
      ('🎳 Pista & Tiro', 0),
      ('🥁 Combos Arcade', 1),
      ('📈 Récords & API', 2),
    ];

    return Row(
      children: tabs.map((t) {
        final isSelected = _selectedScoreTab == t.$2;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedScoreTab = t.$2);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? JungleColors.cyanGradient : null,
                color: isSelected ? null : JungleColors.cardGlass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? JungleColors.accentCyan
                      : JungleColors.accentCyan.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                t.$1,
                textAlign: TextAlign.center,
                style: JungleTheme.displayStyle(
                  fontSize: 13,
                  color: isSelected
                      ? JungleColors.bgDeepJungle
                      : JungleColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRestEndpointsSummaryCard(
    ScoreboardDashboardData dashboard,
    ProfileState state,
  ) {
    return JungleGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTRATO REST SINCRONIZADO',
            style: JungleTheme.displayStyle(
              fontSize: 17,
              color: JungleColors.accentCyan,
            ),
          ),
          const SizedBox(height: 8),
          _endpointRow(
            'POST /api/v1/players',
            'UUID ${state.profile.id.substring(0, 8)}... registrado',
          ),
          _endpointRow(
            'GET /api/v1/players',
            '${dashboard.remotePlayers.length} atletas en sala activa',
          ),
          _endpointRow(
            'GET /api/v1/minigames',
            '${dashboard.syncedMinigames.length} disciplinas oficiales verificadas',
          ),
          _endpointRow(
            'GET /api/v1/matches/${dashboard.matchId}/results',
            'Último sync: ${state.profile.lastSyncedAt} • Cola offline: ${state.pendingQueueCount}',
          ),
        ],
      ),
    );
  }

  Widget _endpointRow(String endpoint, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.api_rounded,
            size: 16,
            color: JungleColors.accentGold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endpoint,
                  style: JungleTheme.bodyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: JungleColors.textPrimary,
                  ),
                ),
                Text(
                  detail,
                  style: JungleTheme.bodyStyle(
                    fontSize: 11,
                    color: JungleColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAthleteModal(BuildContext context, AthleteProfile current) {
    final nameCtrl = TextEditingController(text: current.fullName);
    final nickCtrl = TextEditingController(text: current.nickname);
    String selectedAvatar = current.avatarId;
    String selectedHand = current.dominantHand;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: JungleColors.bgDeepJungle,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGISTRO Y AVATAR DE ATLETA',
                      style: JungleTheme.displayStyle(
                        fontSize: 22,
                        color: JungleColors.accentCyan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nickCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Apodo de Atleta (Nickname)',
                        prefixIcon: Icon(Icons.bolt_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SELECCIONA TU AVATAR SELVÁTICO',
                      style: JungleTheme.displayStyle(
                        fontSize: 15,
                        color: JungleColors.accentGold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: JungleAvatarOption.allAvatars.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (_, idx) {
                        final item = JungleAvatarOption.allAvatars[idx];
                        final isChosen = item.id == selectedAvatar;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setModalState(() => selectedAvatar = item.id);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? item.accentColor.withValues(alpha: 0.22)
                                  : JungleColors.cardGlass,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isChosen
                                    ? item.accentColor
                                    : Colors.white12,
                                width: isChosen ? 2.2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: JungleTheme.bodyStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isChosen
                                        ? item.accentColor
                                        : JungleColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MANO DOMINANTE',
                      style: JungleTheme.displayStyle(
                        fontSize: 15,
                        color: JungleColors.accentCyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Diestro', 'Zurdo', 'Ambas'].map((hand) {
                        final isSelected = selectedHand == hand;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  hand,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: JungleColors.accentCyan,
                              labelStyle: JungleTheme.bodyStyle(
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? JungleColors.bgDeepJungle
                                    : JungleColors.textPrimary,
                              ),
                              onSelected: (_) {
                                HapticFeedback.selectionClick();
                                setModalState(() => selectedHand = hand);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    JungleArcadeButton(
                      label: 'GUARDAR Y SINCRONIZAR (POST /api/v1/players)',
                      icon: Icons.cloud_upload_rounded,
                      isExpanded: true,
                      onPressed: () {
                        ref
                            .read(profileProvider.notifier)
                            .updateAthleteProfile(
                              fullName: nameCtrl.text,
                              nickname: nickCtrl.text,
                              avatarId: selectedAvatar,
                              dominantHand: selectedHand,
                            );
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNetworkSettingsSheet(BuildContext context, ProfileState state) {
    final urlCtrl = TextEditingController(text: state.apiBaseUrl);
    final matchCtrl = TextEditingController(text: state.activeMatchId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: JungleColors.bgDeepJungle,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONEXIÓN BACKEND REST & MODO MOCK',
                style: JungleTheme.displayStyle(
                  fontSize: 20,
                  color: JungleColors.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL Base del Backend REST (Unity/Server)',
                  hintText: 'http://192.168.1.100:8080',
                  prefixIcon: Icon(Icons.dns_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: matchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Match ID a consultar',
                  hintText: 'GOR-2026-FINAL',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
              ),
              const SizedBox(height: 18),
              JungleArcadeButton(
                label: 'APLICAR Y SINCRONIZAR',
                icon: Icons.check_circle_rounded,
                isExpanded: true,
                onPressed: () async {
                  final notifier = ref.read(profileProvider.notifier);
                  await notifier.updateApiBaseUrl(urlCtrl.text);
                  await notifier.refreshDashboard(
                    customMatchId: matchCtrl.text.trim().isEmpty
                        ? 'GOR-2026-FINAL'
                        : matchCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
