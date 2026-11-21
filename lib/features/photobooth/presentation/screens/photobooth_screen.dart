import 'dart:io';
import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/jungle_theme.dart';
import '../../../../core/widgets/jungle_glass_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class JungleFrameStyle {
  final String id;
  final String name;
  final Color primaryBorder;
  final Color secondaryAccent;
  final String cornerEmoji;
  final String bannerTitle;

  const JungleFrameStyle({
    required this.id,
    required this.name,
    required this.primaryBorder,
    required this.secondaryAccent,
    required this.cornerEmoji,
    required this.bannerTitle,
  });

  static const List<JungleFrameStyle> frames = [
    JungleFrameStyle(
      id: 'bambu_tropical',
      name: 'Bambú Tropical',
      primaryBorder: JungleColors.emeraldSuccess,
      secondaryAccent: JungleColors.accentCyan,
      cornerEmoji: '🎋',
      bannerTitle: 'SOBREVIVIENTE DEL BAMBÚ',
    ),
    JungleFrameStyle(
      id: 'oro_rey_kong',
      name: 'Oro del Rey Kong',
      primaryBorder: JungleColors.accentGold,
      secondaryAccent: Color(0xFFD97706),
      cornerEmoji: '👑',
      bannerTitle: 'CAMPEÓN DORADO DE KONG',
    ),
    JungleFrameStyle(
      id: 'naufrago_sobreviviente',
      name: 'Náufrago Sobreviviente',
      primaryBorder: Color(0xFF38BDF8),
      secondaryAccent: JungleColors.accentCyan,
      cornerEmoji: '🧭',
      bannerTitle: 'LEYENDA DEL ARRECIFE',
    ),
    JungleFrameStyle(
      id: 'campeon_gorilimpiadas',
      name: 'Campeón Gorilimpiadas',
      primaryBorder: JungleColors.alertCoral,
      secondaryAccent: JungleColors.accentGold,
      cornerEmoji: '🏆',
      bannerTitle: 'GRAN CAMPEÓN GORILIMPIADAS',
    ),
  ];
}

class PlacedJungleSticker {
  final String id;
  final String emoji;
  final String label;
  Offset position;
  double scale;

  PlacedJungleSticker({
    required this.id,
    required this.emoji,
    required this.label,
    required this.position,
    this.scale = 1.0,
  });
}

class PhotoboothScreen extends ConsumerStatefulWidget {
  const PhotoboothScreen({super.key});

  @override
  ConsumerState<PhotoboothScreen> createState() => _PhotoboothScreenState();
}

class _PhotoboothScreenState extends ConsumerState<PhotoboothScreen> {
  final GlobalKey _cardBoundaryKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _capturedPhotoBytes;
  int _selectedPresetBackdrop = 0;
  int _selectedFrameIndex = 1; // Default: Oro del Rey Kong
  String _selectedDiscipline = 'Banana Bowling';
  bool _isExporting = false;

  final List<PlacedJungleSticker> _placedStickers = [
    PlacedJungleSticker(
      id: 'init_crown',
      emoji: '👑',
      label: 'Corona de Kong',
      position: const Offset(135, 32),
      scale: 1.25,
    ),
    PlacedJungleSticker(
      id: 'init_medal',
      emoji: '🥇',
      label: 'Medalla',
      position: const Offset(235, 175),
      scale: 1.15,
    ),
  ];

  static const List<(String, String)> _availableStickers = [
    ('🥥', 'Cocos Partidos'),
    ('🗿', 'Pinos Tótem'),
    ('🥊', 'Guantes Boxeo'),
    ('👑', 'Corona de Kong'),
    ('🍌', 'Plátano Dorado'),
    ('🥇', 'Medalla'),
  ];

  static const List<(String, String, Color)> _presetBackdrops = [
    ('🦍', 'Trono Volcánico de Kong', JungleColors.accentGold),
    ('🏝️', 'Arena Sagrada de Bambú', JungleColors.accentCyan),
    ('🌩️', 'Arrecife de la Tormenta', Color(0xFF38BDF8)),
    ('🏟️', 'Estadio Nocturno Totémico', JungleColors.emeraldSuccess),
  ];

  Future<void> _pickImage(ImageSource source) async {
    HapticFeedback.mediumImpact();
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() => _capturedPhotoBytes = bytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cámara no disponible en este entorno. Usando plantilla ilustrada de Campeón.',
            ),
          ),
        );
      }
    }
  }

  void _addSticker(String emoji, String label) {
    HapticFeedback.lightImpact();
    setState(() {
      _placedStickers.add(
        PlacedJungleSticker(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          emoji: emoji,
          label: label,
          position: Offset(
            90.0 + (_placedStickers.length * 22) % 120,
            95.0 + (_placedStickers.length * 18) % 90,
          ),
          scale: 1.15,
        ),
      );
    });
  }

  Future<void> _exportAndShareChampionCard() async {
    HapticFeedback.heavyImpact();
    setState(() => _isExporting = true);

    try {
      final boundary = _cardBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isExporting = false);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        setState(() => _isExporting = false);
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/gorilimpiadas_champion_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Tarjeta PNG generada (${(pngBytes.lengthInBytes / 1024).toStringAsFixed(0)} KB)! Abriendo menú para compartir...',
            ),
          ),
        );
      }

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text:
            '🏆 ¡Mi Tarjeta Oficial de Campeón en Jungle Party: Gorilimpiadas! ($_selectedDiscipline)',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarjeta capturada lista: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final recordsMap =
        profileState.dashboard?.championRecordByDiscipline ??
            {
              'Banana Bowling': '159 pts (10 Frames)',
              'Coconut Throw': '27.6 m Récord',
              'Jungle Drums': '12,420 pts • Combo x52',
              'Gorilla Whack': '1,890 pts • 91.2% Precisión',
              'Coconut Slice': '1,950 pts • Combo x17',
            };

    final activeRecordText =
        recordsMap[_selectedDiscipline] ?? 'Campeón Oficial Gorilimpiadas';
    final frame = JungleFrameStyle.frames[_selectedFrameIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildCameraActionRow(),
            const SizedBox(height: 16),
            // REPAINT BOUNDARY: CHAMPION CARD CANVAS
            Center(
              child: RepaintBoundary(
                key: _cardBoundaryKey,
                child: _buildChampionCardCanvas(
                  profileNickname: profile.nickname,
                  avatarEmoji: profile.avatar.emoji,
                  avatarTitle: profile.avatar.name,
                  frame: frame,
                  recordText: activeRecordText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFrameSelector(),
            const SizedBox(height: 14),
            _buildStickerStudio(),
            const SizedBox(height: 14),
            _buildDisciplineOverlaySelector(recordsMap.keys.toList()),
            const SizedBox(height: 18),
            JungleArcadeButton(
              label: _isExporting
                  ? 'GENERANDO PNG DE ALTA RESOLUCIÓN...'
                  : 'EXPORTAR Y COMPARTIR TARJETA PNG',
              icon: Icons.ios_share_rounded,
              gradient: JungleColors.goldGradient,
              isExpanded: true,
              onPressed: _isExporting ? null : _exportAndShareChampionCard,
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
            gradient: JungleColors.cyanGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.camera_enhance_rounded,
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
                'JUNGLE PHOTO BOOTH',
                style: JungleTheme.displayStyle(
                  fontSize: 22,
                  color: JungleColors.textPrimary,
                ),
              ),
              Text(
                'Generador de Tarjetas de Campeón • Marcos, Stickers & Récord',
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

  Widget _buildCameraActionRow() {
    return Row(
      children: [
        Expanded(
          child: JungleArcadeButton(
            label: 'SELFIE CÁMARA',
            icon: Icons.photo_camera_rounded,
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: JungleArcadeButton(
            label: 'GALERÍA',
            icon: Icons.photo_library_rounded,
            gradient: JungleColors.goldGradient,
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Cambiar Fondo Ilustrado (Emulador)',
          style: IconButton.styleFrom(
            backgroundColor: JungleColors.cardGlass,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _capturedPhotoBytes = null;
              _selectedPresetBackdrop =
                  (_selectedPresetBackdrop + 1) % _presetBackdrops.length;
            });
          },
          icon: const Icon(
            Icons.wallpaper_rounded,
            color: JungleColors.accentCyan,
          ),
        ),
      ],
    );
  }

  Widget _buildChampionCardCanvas({
    required String profileNickname,
    required String avatarEmoji,
    required String avatarTitle,
    required JungleFrameStyle frame,
    required String recordText,
  }) {
    final preset = _presetBackdrops[_selectedPresetBackdrop];

    return Container(
      width: 330,
      height: 410,
      decoration: BoxDecoration(
        color: JungleColors.bgDeepJungle,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: frame.primaryBorder,
          width: 4.5,
        ),
        boxShadow: [
          BoxShadow(
            color: frame.primaryBorder.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // 1. Photo or Illustrated Jungle Backdrop
            Positioned.fill(
              child: _capturedPhotoBytes != null
                  ? Image.memory(
                      _capturedPhotoBytes!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.2),
                          radius: 0.95,
                          colors: [
                            preset.$3.withValues(alpha: 0.42),
                            JungleColors.bgCanopy,
                            JungleColors.bgDeepJungle,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            preset.$1,
                            style: const TextStyle(fontSize: 88),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              preset.$2,
                              style: JungleTheme.bodyStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: JungleColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 55),
                        ],
                      ),
                    ),
            ),

            // 2. Top Thematic Frame Header
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: frame.primaryBorder, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(frame.cornerEmoji, style: const TextStyle(fontSize: 18)),
                    Flexible(
                      child: Text(
                        frame.bannerTitle,
                        overflow: TextOverflow.ellipsis,
                        style: JungleTheme.displayStyle(
                          fontSize: 13,
                          color: frame.primaryBorder,
                        ),
                      ),
                    ),
                    Text(frame.cornerEmoji, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),

            // 3. Draggable & Scalable Interactive Stickers
            ..._placedStickers.map((sticker) {
              return Positioned(
                left: sticker.position.dx,
                top: sticker.position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      sticker.position = Offset(
                        (sticker.position.dx + details.delta.dx)
                            .clamp(4.0, 265.0),
                        (sticker.position.dy + details.delta.dy)
                            .clamp(4.0, 275.0),
                      );
                    });
                  },
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      sticker.scale =
                          sticker.scale >= 1.6 ? 0.9 : sticker.scale + 0.22;
                    });
                  },
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _placedStickers.removeWhere((s) => s.id == sticker.id);
                    });
                  },
                  child: Transform.scale(
                    scale: sticker.scale,
                    child: Text(
                      sticker.emoji,
                      style: const TextStyle(
                        fontSize: 42,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // 4. Automatic Athlete Record Overlay Footer
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JungleColors.bgDeepJungle.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: frame.primaryBorder.withValues(alpha: 0.8),
                    width: 1.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor:
                              frame.primaryBorder.withValues(alpha: 0.2),
                          child: Text(
                            avatarEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileNickname,
                                overflow: TextOverflow.ellipsis,
                                style: JungleTheme.displayStyle(
                                  fontSize: 18,
                                  color: JungleColors.textPrimary,
                                ),
                              ),
                              Text(
                                '$avatarTitle • $_selectedDiscipline',
                                overflow: TextOverflow.ellipsis,
                                style: JungleTheme.bodyStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: frame.primaryBorder,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            frame.primaryBorder.withValues(alpha: 0.25),
                            frame.secondaryAccent.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: frame.primaryBorder,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'RÉCORD: $recordText',
                              overflow: TextOverflow.ellipsis,
                              style: JungleTheme.displayStyle(
                                fontSize: 13,
                                color: JungleColors.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameSelector() {
    return JungleGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. MARCO TEMÁTICO SELVÁTICO',
            style: JungleTheme.displayStyle(
              fontSize: 15,
              color: JungleColors.accentCyan,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(JungleFrameStyle.frames.length, (index) {
                final f = JungleFrameStyle.frames[index];
                final isSelected = index == _selectedFrameIndex;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFrameIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? f.primaryBorder.withValues(alpha: 0.22)
                          : JungleColors.bgDeepJungle,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? f.primaryBorder : Colors.white12,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(f.cornerEmoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          f.name,
                          style: JungleTheme.bodyStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? f.primaryBorder
                                : JungleColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerStudio() {
    return JungleGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '2. STICKERS (ARRASTRAR / TOCAR PARA ESCALAR)',
                  style: JungleTheme.displayStyle(
                    fontSize: 15,
                    color: JungleColors.accentGold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _placedStickers.clear());
                },
                child: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableStickers.map((s) {
              return ActionChip(
                backgroundColor: JungleColors.bgDeepJungle,
                side: BorderSide(
                  color: JungleColors.accentGold.withValues(alpha: 0.4),
                ),
                avatar: Text(s.$1, style: const TextStyle(fontSize: 16)),
                label: Text(
                  s.$2,
                  style: JungleTheme.bodyStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () => _addSticker(s.$1, s.$2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineOverlaySelector(List<String> disciplines) {
    return JungleGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3. OVERLAY AUTOMÁTICO DE RÉCORD POR DISCIPLINA',
            style: JungleTheme.displayStyle(
              fontSize: 15,
              color: JungleColors.emeraldSuccess,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: disciplines.map((d) {
                final isSelected = d == _selectedDiscipline;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d),
                    selected: isSelected,
                    selectedColor: JungleColors.emeraldSuccess,
                    labelStyle: JungleTheme.bodyStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? JungleColors.bgDeepJungle
                          : JungleColors.textPrimary,
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDiscipline = d);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
