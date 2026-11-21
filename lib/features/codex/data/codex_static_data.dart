import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/jungle_theme.dart';
import '../domain/models/codex_models.dart';

class CodexStaticData {
  CodexStaticData._();

  static const List<ComicPanelItem> storyComicPanels = [
    ComicPanelItem(
      panelNumber: 1,
      title: 'Tormenta en Altamar',
      subtitle: 'CAPÍTULO I • EL NAUFRAGIO NOCTURNO',
      narrativeText:
          'Una tormenta eléctrica colosal partió el cielo del Pacífico Sur. Entre olas de diez metros y relámpagos turquesa, el velero del explorador crujió contra un arrecife oculto, hundiéndose en la oscuridad.',
      soundscapeLabel: '⛈️ Truenos, lluvia torrencial y crujido de madera',
      heroEmoji: '⛵',
      sceneEmojis: ['🌩️', '🌊', '🧭'],
      primaryColor: Color(0xFF38BDF8),
      secondaryColor: Color(0xFF0284C7),
      quote: '"¡El compás giraba sin control antes de que la gran ola nos alcanzara!"',
    ),
    ComicPanelItem(
      panelNumber: 2,
      title: 'Despertar en la Arena',
      subtitle: 'CAPÍTULO II • LA MÍTICA ISLA GORILA',
      narrativeText:
          'Al amanecer, el Náufrago despertó entre restos de bambú y arena dorada. Frente a él se alzaban tótems gigantes tallados en roca volcánica y una selva esmeralda que ningún mapa moderno registraba.',
      soundscapeLabel: '🌊 Olas suaves, aves tropicales y tambores lejanos',
      heroEmoji: '🏝️',
      sceneEmojis: ['🗿', '🌴', '🦀'],
      primaryColor: JungleColors.accentCyan,
      secondaryColor: Color(0xFF0D9488),
      quote: '"No era una isla desierta... la tierra vibraba al ritmo de tambores ancestrales."',
    ),
    ComicPanelItem(
      panelNumber: 3,
      title: 'El Encuentro',
      subtitle: 'CAPÍTULO III • LA TRIBU Y EL REY KONG',
      narrativeText:
          'De la espesura emergieron los Gorilas Guardianes y una banda de monos capuchinos. Las hojas se abrieron ante el colosal Rey Kong, portando su corona de oro ancestral sobre el trono del volcán.',
      soundscapeLabel: '🦍 Rugido real de Kong y cánticos tribales',
      heroEmoji: '🦍',
      sceneEmojis: ['👑', '🐒', '🥁'],
      primaryColor: JungleColors.accentGold,
      secondaryColor: Color(0xFFD97706),
      quote: '"El suelo tembló tres veces antes de que el Rey Kong posara su mirada sobre mí."',
    ),
    ComicPanelItem(
      panelNumber: 4,
      title: 'El Desafío de Kong',
      subtitle: 'CAPÍTULO IV • EL PACTO DE LA BALSA DE BAMBÚ',
      narrativeText:
          'Kong señaló el océano y lanzó un decreto sagrado: ningún forastero abandona la isla sin demostrar su honor atlético. Si el Náufrago triunfa en las Gorilimpiadas, toda la tribu construirá su balsa de bambú.',
      soundscapeLabel: '🔥 Antorchas encendidas y fanfarria de caracolas',
      heroEmoji: '👑',
      sceneEmojis: ['🎋', '🏆', '🔥'],
      primaryColor: JungleColors.alertCoral,
      secondaryColor: Color(0xFFEA580C),
      quote: '"¡Supera nuestras Pruebas Sagradas y el océano volverá a ser tuyo!"',
    ),
    ComicPanelItem(
      panelNumber: 5,
      title: 'Las Pruebas Sagradas',
      subtitle: 'CAPÍTULO V • COMIENZAN LAS GORILIMPIADAS',
      narrativeText:
          'Cuatro arenas legendarias abren el ritual: lanzar cocos a más de 25 metros en Coconut Throw, cortar frutas sin despertar al Bebé Gorila en Coconut Slice, frenar a los capuchinos en Gorilla Whack y dominar los 10 frames de Banana Bowling.',
      soundscapeLabel: '🏟️ Rugido del estadio selvático y gong de inicio',
      heroEmoji: '🏆',
      sceneEmojis: ['🥥', '⚔️', '🔨', '🍌'],
      primaryColor: JungleColors.emeraldSuccess,
      secondaryColor: JungleColors.accentCyan,
      quote: '"¡Calibra tu giroscopio, sujeta firme tu móvil y que comiencen las Gorilimpiadas!"',
    ),
  ];

  static const List<CharacterBioItem> characterBios = [
    CharacterBioItem(
      id: 'rey_kong',
      name: 'Rey Kong',
      role: 'Anfitrión Supremo y Juez de las Gorilimpiadas',
      emoji: '👑',
      accentColor: JungleColors.accentGold,
      biography:
          'Monarca indiscutible de la Isla Gorila. Justo pero implacable con las reglas olímpicas, Kong supervisa cada lanzamiento desde su trono totémico y premia la destreza física con bambú sagrado.',
      signatureMove: 'Golpe Sísmico del Trono Dorado',
      favoriteMinigame: 'Coconut Throw & Gorilla Boxing',
      attributes: {'Fuerza': 100, 'Autoridad': 98, 'Precisión': 88},
    ),
    CharacterBioItem(
      id: 'el_naufrago',
      name: 'El Náufrago',
      role: 'Atleta Humano y Explorador Sobreviviente',
      emoji: '🧭',
      accentColor: Color(0xFF38BDF8),
      biography:
          'Un intrépido navegante cuya embarcación naufragó durante la gran tormenta. Compensa la fuerza bruta de los primates con técnica depurada, cálculo de ángulos de 40°-45° y reflejos relámpago.',
      signatureMove: 'Swing Parabólico de 42.5°',
      favoriteMinigame: 'Banana Bowling & Log Balance',
      attributes: {'Técnica': 96, 'Equilibrio': 94, 'Reflejos': 92},
    ),
    CharacterBioItem(
      id: 'gorila_guardian',
      name: 'Gorila Guardián',
      role: 'Centinela del Estadio y Maestro del Dojo',
      emoji: '🦍',
      accentColor: JungleColors.accentCyan,
      biography:
          'Custodio de los tótems ancestrales y arquero invicto de la selva. Entrena a los aspirantes en el Dojo y protege la línea de meta contra lluvias de cocos explosivos.',
      signatureMove: 'Muralla Totémica Impenetrable',
      favoriteMinigame: 'Jungle Keeper & Jungle Baseball',
      attributes: {'Defensa': 99, 'Fuerza': 95, 'Reflejos': 90},
    ),
    CharacterBioItem(
      id: 'bebe_gorila',
      name: 'Bebé Gorila Dormilón',
      role: 'Riesgo Sagrado en Coconut Slice',
      emoji: '👶',
      accentColor: JungleColors.emeraldSuccess,
      biography:
          'El consentido de toda la tribu. Suele quedarse profundamente dormido cerca de la zona de corte de cocos; si un atleta lo golpea por accidente durante Coconut Slice, el Rey Kong decreta derrota instantánea.',
      signatureMove: 'Siesta Aérea Inesperada',
      favoriteMinigame: 'Coconut Slice (¡No lo toques!)',
      attributes: {'Ternura': 100, 'Sueño': 99, 'Peligro': 100},
    ),
    CharacterBioItem(
      id: 'monos_capuchinos',
      name: 'Monos Capuchinos Traviesos',
      role: 'Saboteadores Veloces de la Arena',
      emoji: '🐒',
      accentColor: JungleColors.alertCoral,
      biography:
          'Una pandilla hiperactiva que emerge de los troncos huecos para robar plátanos y distraer a los competidores. Son los protagonistas del frenético reto Gorilla Whack y marcan el compás en Jungle Drums.',
      signatureMove: 'Emboscada Sincronizada de 5 Hoyos',
      favoriteMinigame: 'Gorilla Whack & Jungle Drums',
      attributes: {'Velocidad': 97, 'Travesura': 100, 'Ritmo': 95},
    ),
  ];

  static const List<MinigameCodexEntry> minigamesEncyclopedia = [
    MinigameCodexEntry(
      id: 'banana_bowling',
      name: 'Banana Bowling',
      emoji: '🍌',
      category: 'Precisión & Efecto Curvo',
      sensorsUsed: 'Acelerómetro + Giroscopio (Swing frontal y muñeca)',
      howToPlay:
          'Sujeta el móvil como bola de boliche, realiza un péndulo hacia atrás y lanza hacia adelante girando levemente la muñeca para dar efecto banana contra los 10 pinos tótem.',
      storyVictoryRule:
          'Alcanzar o superar 80 puntos acumulados a lo largo de los 10 frames reglamentarios.',
      proSecretTip:
          'Un giro suave de 15° en el eje Z del giroscopio al soltar impacta el bolsillo entre los pinos 1 y 3 para lograr Strike (X).',
      accentColor: JungleColors.accentGold,
    ),
    MinigameCodexEntry(
      id: 'coconut_throw',
      name: 'Coconut Throw',
      emoji: '🥥',
      category: 'Potencia & Parabólica (Shot Put)',
      sensorsUsed: 'Acelerómetro Lineal + Giroscopio + Ángulo de Elevación',
      howToPlay:
          'Ejecuta un impulso explosivo hacia arriba y adelante. El juego calcula phonePower = |gyro| + 7 * |accel| junto con el ángulo de salida del brazo.',
      storyVictoryRule:
          'Lograr un tiro válido de al menos 25.0 metros en cualquiera de los 3 intentos reglamentarios.',
      proSecretTip:
          'Mantén el ángulo de salida exactamente entre 40° y 45° con phonePower > 280 para maximizar el alcance parabólico.',
      accentColor: JungleColors.accentCyan,
    ),
    MinigameCodexEntry(
      id: 'coconut_slice',
      name: 'Coconut Slice',
      emoji: '⚔️',
      category: 'Reflejos & Corte Aéreo',
      sensorsUsed: 'Giroscopio de Alta Frecuencia (Trazos rápidos en aire)',
      howToPlay:
          'Corta las ráfagas de cocos y frutas tropicales que saltan por la pantalla agitando el teléfono como una espada de bambú.',
      storyVictoryRule:
          'Alcanzar 1,600 puntos antes de que termine el tiempo. ¡PÉRDIDA INSTANTÁNEA si cortas al Bebé Gorila Dormilón!',
      proSecretTip:
          'Espera a que 3 o más cocos se alineen en el ápice de su salto para hacer un solo corte horizontal y ganar bono x3.',
      accentColor: JungleColors.emeraldSuccess,
    ),
    MinigameCodexEntry(
      id: 'gorilla_whack',
      name: 'Gorilla Whack',
      emoji: '🔨',
      category: 'Velocidad & Reacción (Whack-a-Mole)',
      sensorsUsed: 'Acelerómetro Vertical + Apuntado con Giroscopio',
      howToPlay:
          'Inclina el teléfono hacia el tronco hueco donde asoma el Mono Capuchino y da un golpe seco hacia abajo con el mazo totémico.',
      storyVictoryRule:
          'Acertar mínimo 10 golpes limpios sobre los Monos Capuchinos Traviesos dentro del tiempo reglamentario.',
      proSecretTip:
          'Regresa siempre la muñeca a la posición central neutra tras cada golpe para reducir el tiempo de viaje hacia las esquinas.',
      accentColor: JungleColors.alertCoral,
    ),
    MinigameCodexEntry(
      id: 'gorilla_boxing',
      name: 'Gorilla Boxing',
      emoji: '🥊',
      category: 'Combate & Contraataque',
      sensorsUsed: 'Acelerómetro Dual (Jabs, Ganchos y Esquives laterales)',
      howToPlay:
          'Lanza golpes rectos empujando el móvil al frente, ganchos con giro lateral e inclina el torso para esquivar los puños de coco del rival.',
      storyVictoryRule:
          'Noquear al oponente en 3 asaltos o superar los 2,500 puntos de combate.',
      proSecretTip:
          'Esquivar en el último instante abre una ventana de Cámara Lenta donde tus golpes causan el doble de daño.',
      accentColor: Color(0xFFF43F5E),
    ),
    MinigameCodexEntry(
      id: 'jungle_baseball',
      name: 'Jungle Baseball',
      emoji: '🏏',
      category: 'Swing Horizontal & Timing',
      sensorsUsed: 'Giroscopio Angular + Acelerómetro (phonePower > 280)',
      howToPlay:
          'Observa el coco lanzado por el pitcher capuchino y ejecuta un swing horizontal explosivo en el momento exacto en que cruza el plato.',
      storyVictoryRule:
          'Conectar al menos 3 Home Runs o acumular 120 metros de bateo limpio.',
      proSecretTip:
          'Inicia el armado del swing (phonePower < 160) cuando el pitcher levante la pierna para llegar a máxima velocidad al impacto.',
      accentColor: Color(0xFF38BDF8),
    ),
    MinigameCodexEntry(
      id: 'jungle_drums',
      name: 'Jungle Drums',
      emoji: '🥁',
      category: 'Ritmo Tribal & Precisión Musical',
      sensorsUsed: 'Acelerómetro de Impacto Rítmico / Toques Hápticos',
      howToPlay:
          'Sigue las ondas luminosas del tótem musical golpeando al compás de la percusión selvática sin romper la cadena de combo.',
      storyVictoryRule:
          'Completar el ritual con al menos 90% de precisión o una racha de Combo x40.',
      proSecretTip:
          'Guíate por el bajo profundo del tambor mayor más que por los efectos visuales para clavar los golpes "PERFECT".',
      accentColor: Color(0xFFA78BFA),
    ),
    MinigameCodexEntry(
      id: 'log_balance',
      name: 'Log Balance',
      emoji: '🪵',
      category: 'Equilibrio Físico & Inercia',
      sensorsUsed: 'Acelerómetro Lateral (Eje X de inclinación continua)',
      howToPlay:
          'Mantén el teléfono horizontal mientras cruzas un tronco resbaladizo sobre las pirañas del río. Compensa la deriva e inercia con micro-inclinaciones.',
      storyVictoryRule:
          'Cruzar los 15.0 metros completos del tronco sin que el indicador de peligro supere el límite y caigas al agua.',
      proSecretTip:
          'Evita corregir con movimientos bruscos: cuando danger >= 0.6, aplica toques cortos de contra-inclinación para amortiguar la velocidad angular.',
      accentColor: JungleColors.accentCyan,
    ),
    MinigameCodexEntry(
      id: 'jungle_keeper',
      name: 'Jungle Keeper',
      emoji: '🧤',
      category: 'Reflejos de Portero',
      sensorsUsed: 'Giroscopio de Orientación Rápida (Izquierda / Arriba / Derecha)',
      howToPlay:
          'Mueve los brazos rápidamente hacia el cuadrante de la portería de bambú hacia donde los cañones tribales disparan cocos veloces.',
      storyVictoryRule:
          'Bloquear 15 disparos en la tanda final permitiendo como máximo 2 goles.',
      proSecretTip:
          'Los cocos dorados describen una curva hacia el lado opuesto a mitad de vuelo; espera 0.2s antes de lanzarte.',
      accentColor: JungleColors.accentGold,
    ),
  ];
}
