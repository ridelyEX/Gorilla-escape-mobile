import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/theme/jungle_theme.dart';
import '../../../../core/widgets/jungle_glass_card.dart';
import '../../data/codex_static_data.dart';
import '../../domain/models/codex_models.dart';

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  int _selectedSection = 0; // 0: Cómic, 1: Personajes, 2: 9 Disciplinas
  int _currentComicIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.93);
  final FlutterTts _flutterTts = FlutterTts();
  bool _isNarrating = false;
  bool _autoNarrateOnSwipe = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('es-MX');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(0.95);
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _isNarrating = false);
      });
      _flutterTts.setCancelHandler(() {
        if (mounted) setState(() => _isNarrating = false);
      });
      _flutterTts.setErrorHandler((_) {
        if (mounted) setState(() => _isNarrating = false);
      });
    } catch (_) {
      // Safe fallback on platforms without TTS engine configured
    }
  }

  Future<void> _toggleNarration(ComicPanelItem panel) async {
    HapticFeedback.mediumImpact();
    if (_isNarrating) {
      try {
        await _flutterTts.stop();
      } catch (_) {}
      if (mounted) setState(() => _isNarrating = false);
      return;
    }

    setState(() => _isNarrating = true);
    try {
      await _flutterTts.speak(
        'Viñeta ${panel.panelNumber}: ${panel.title}. ${panel.narrativeText} ${panel.quote}',
      );
    } catch (_) {
      // Simulate narration duration if TTS engine isn't active on desktop/emulator
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _isNarrating = false);
      });
    }
  }

  @override
  void dispose() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: _buildHeader(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildSectionSelector(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _selectedSection == 0
                    ? _buildInteractiveComicView()
                    : (_selectedSection == 1
                        ? _buildCharacterBiosView()
                        : _buildDisciplinesEncyclopediaView()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: JungleColors.goldGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
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
                'CÓDICE DE LA ISLA GORILA',
                style: JungleTheme.displayStyle(
                  fontSize: 22,
                  color: JungleColors.textPrimary,
                ),
              ),
              Text(
                'Cómic Oficial • Biografías • Enciclopedia de 9 Disciplinas',
                style: JungleTheme.bodyStyle(
                  fontSize: 12,
                  color: JungleColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSelector() {
    final sections = [
      ('📖 Cómic (5 Viñetas)', 0),
      ('🦍 Personajes (5)', 1),
      ('🏆 9 Disciplinas', 2),
    ];

    return Row(
      children: sections.map((s) {
        final isSelected = _selectedSection == s.$2;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedSection = s.$2);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? JungleColors.goldGradient : null,
                color: isSelected ? null : JungleColors.cardGlass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? JungleColors.accentGold
                      : JungleColors.accentCyan.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                s.$1,
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

  Widget _buildInteractiveComicView() {
    final panels = CodexStaticData.storyComicPanels;
    final activePanel = panels[_currentComicIndex];

    return ListView(
      key: const ValueKey('comic_view'),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: JungleGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            borderColor: activePanel.primaryColor.withValues(alpha: 0.5),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _toggleNarration(activePanel),
                  icon: CircleAvatar(
                    backgroundColor: _isNarrating
                        ? JungleColors.alertCoral
                        : activePanel.primaryColor,
                    child: Icon(
                      _isNarrating
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                      color: JungleColors.bgDeepJungle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isNarrating
                            ? 'NARRANDO VIÑETA ${activePanel.panelNumber}...'
                            : 'NARRADOR DE AMBIENTE & VOZ (TTS)',
                        style: JungleTheme.displayStyle(
                          fontSize: 14,
                          color: _isNarrating
                              ? JungleColors.accentGold
                              : JungleColors.textPrimary,
                        ),
                      ),
                      Text(
                        activePanel.soundscapeLabel,
                        style: JungleTheme.bodyStyle(
                          fontSize: 11,
                          color: JungleColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Auto-Voz',
                      style: JungleTheme.bodyStyle(
                        fontSize: 10,
                        color: JungleColors.textSecondary,
                      ),
                    ),
                    Switch(
                      value: _autoNarrateOnSwipe,
                      activeThumbColor: JungleColors.accentCyan,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _autoNarrateOnSwipe = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 440,
          child: PageView.builder(
            controller: _pageController,
            itemCount: panels.length,
            onPageChanged: (index) {
              HapticFeedback.lightImpact();
              setState(() => _currentComicIndex = index);
              if (_autoNarrateOnSwipe) {
                _toggleNarration(panels[index]);
              }
            },
            itemBuilder: (context, index) {
              final panel = panels[index];
              final isCurrent = index == _currentComicIndex;
              return AnimatedScale(
                scale: isCurrent ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 240),
                child: _buildComicPanelCard(panel),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: JungleColors.cardGlass,
                ),
                onPressed: _currentComicIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Row(
                children: List.generate(panels.length, (idx) {
                  final active = idx == _currentComicIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: active
                          ? activePanel.primaryColor
                          : JungleColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: JungleColors.cardGlass,
                ),
                onPressed: _currentComicIndex < panels.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComicPanelCard(ComicPanelItem panel) {
    return JungleGlassCard(
      enableGlow: true,
      borderColor: panel.primaryColor.withValues(alpha: 0.65),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              JungleBadge(
                label: 'VIÑETA ${panel.panelNumber} DE 5',
                color: panel.primaryColor,
                icon: Icons.auto_stories_rounded,
              ),
              Row(
                children: panel.sceneEmojis
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(e, style: const TextStyle(fontSize: 18)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Illustrated Comic Artwork Frame
          Container(
            height: 155,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  panel.primaryColor.withValues(alpha: 0.32),
                  panel.secondaryColor.withValues(alpha: 0.18),
                  JungleColors.bgDeepJungle,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: panel.primaryColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: -10,
                  bottom: -15,
                  child: Opacity(
                    opacity: 0.14,
                    child: Text(
                      panel.heroEmoji,
                      style: const TextStyle(fontSize: 130),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      panel.heroEmoji,
                      style: const TextStyle(fontSize: 58),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        panel.subtitle,
                        style: JungleTheme.bodyStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: panel.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            panel.title.toUpperCase(),
            style: JungleTheme.displayStyle(
              fontSize: 22,
              color: panel.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              panel.narrativeText,
              style: JungleTheme.bodyStyle(
                fontSize: 14,
                height: 1.38,
                color: JungleColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: JungleColors.bgDeepJungle.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: JungleColors.accentGold.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              panel.quote,
              style: JungleTheme.bodyStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: JungleColors.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBiosView() {
    final chars = CodexStaticData.characterBios;
    return ListView.separated(
      key: const ValueKey('characters_view'),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
      itemCount: chars.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final c = chars[index];
        return JungleGlassCard(
          borderColor: c.accentColor.withValues(alpha: 0.45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.accentColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: c.accentColor, width: 2),
                    ),
                    child: Text(c.emoji, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name.toUpperCase(),
                          style: JungleTheme.displayStyle(
                            fontSize: 20,
                            color: c.accentColor,
                          ),
                        ),
                        Text(
                          c.role,
                          style: JungleTheme.bodyStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: JungleColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                c.biography,
                style: JungleTheme.bodyStyle(
                  fontSize: 13.5,
                  height: 1.38,
                  color: JungleColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  JungleBadge(
                    label: 'Especial: ${c.signatureMove}',
                    color: c.accentColor,
                    icon: Icons.flash_on_rounded,
                  ),
                  JungleBadge(
                    label: 'Arena: ${c.favoriteMinigame}',
                    color: JungleColors.accentGold,
                    icon: Icons.stadium_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: c.attributes.entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: JungleTheme.bodyStyle(
                                  fontSize: 11,
                                  color: JungleColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: JungleTheme.displayStyle(
                                  fontSize: 12,
                                  color: c.accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: entry.value / 100.0,
                              minHeight: 6,
                              backgroundColor: Colors.black38,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(c.accentColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisciplinesEncyclopediaView() {
    final allGames = CodexStaticData.minigamesEncyclopedia;
    final filtered = _searchQuery.trim().isEmpty
        ? allGames
        : allGames
            .where(
              (m) =>
                  m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  m.category
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  m.storyVictoryRule
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Column(
      key: const ValueKey('disciplines_view'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(
              hintText: 'Buscar disciplina, sensor o regla (ej. 40°, 1600)...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final game = filtered[index];
              return JungleGlassCard(
                borderColor: game.accentColor.withValues(alpha: 0.45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: game.accentColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            game.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${game.name.toUpperCase()}',
                                style: JungleTheme.displayStyle(
                                  fontSize: 19,
                                  color: game.accentColor,
                                ),
                              ),
                              Text(
                                game.category,
                                style: JungleTheme.bodyStyle(
                                  fontSize: 12,
                                  color: JungleColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      icon: Icons.sensors_rounded,
                      label: 'SENSORES FÍSICOS:',
                      value: game.sensorsUsed,
                      color: JungleColors.accentCyan,
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      icon: Icons.sports_esports_rounded,
                      label: 'CÓMO SE JUEGA:',
                      value: game.howToPlay,
                      color: JungleColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: JungleColors.accentGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: JungleColors.accentGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: _infoRow(
                        icon: Icons.emoji_events_rounded,
                        label: 'REGLA DE VICTORIA (MODO HISTORIA):',
                        value: game.storyVictoryRule,
                        color: JungleColors.accentGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: JungleColors.bgDeepJungle.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _infoRow(
                        icon: Icons.tips_and_updates_rounded,
                        label: 'SECRETO DEL DOJO:',
                        value: game.proSecretTip,
                        color: JungleColors.emeraldSuccess,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: JungleTheme.bodyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: JungleTheme.bodyStyle(
                    fontSize: 12.5,
                    color: JungleColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
