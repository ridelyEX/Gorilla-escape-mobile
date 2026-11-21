import 'package:material_ui/material_ui.dart';

class ComicPanelItem {
  final int panelNumber;
  final String title;
  final String subtitle;
  final String narrativeText;
  final String soundscapeLabel;
  final String heroEmoji;
  final List<String> sceneEmojis;
  final Color primaryColor;
  final Color secondaryColor;
  final String quote;

  const ComicPanelItem({
    required this.panelNumber,
    required this.title,
    required this.subtitle,
    required this.narrativeText,
    required this.soundscapeLabel,
    required this.heroEmoji,
    required this.sceneEmojis,
    required this.primaryColor,
    required this.secondaryColor,
    required this.quote,
  });
}

class CharacterBioItem {
  final String id;
  final String name;
  final String role;
  final String emoji;
  final Color accentColor;
  final String biography;
  final String signatureMove;
  final String favoriteMinigame;
  final Map<String, int> attributes; // e.g., Fuerza, Agilidad, Carisma

  const CharacterBioItem({
    required this.id,
    required this.name,
    required this.role,
    required this.emoji,
    required this.accentColor,
    required this.biography,
    required this.signatureMove,
    required this.favoriteMinigame,
    required this.attributes,
  });
}

class MinigameCodexEntry {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final String sensorsUsed;
  final String howToPlay;
  final String storyVictoryRule;
  final String proSecretTip;
  final Color accentColor;

  const MinigameCodexEntry({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.sensorsUsed,
    required this.howToPlay,
    required this.storyVictoryRule,
    required this.proSecretTip,
    required this.accentColor,
  });
}
