# 🦍 Jungle Party: Gorilimpiadas Companion App (`gorilla_escape_companion`)

Aplicación móvil oficial (Flutter 3.x / Dart 3.x) diseñada como compañero independiente del party game físico **"Gorilla Escape: Gorilimpiadas / Jungle Party"**.

Construida bajo una arquitectura **Feature-First + Clean Architecture**, con estética **Selva Tropical / Arcade** (Dark Mode nativo, glassmorphism `#0C3437`, acentos neón `#26E0CF` y oro `#FFD13D`, tipografías `Lilita One` y `Nunito Sans`), soporte **Offline-First** y simulación física mediante sensores (`sensors_plus`).

---

## 📁 Estructura de Arquitectura Modular

```text
lib/
├── main.dart                                      # Punto de entrada, ProviderScope y BottomNavigationBar (4 módulos)
├── core/
│   ├── network/
│   │   └── api_client.dart                        # Cliente Dio REST + Fallback Mock automático y cola Offline
│   ├── storage/
│   │   └── local_storage_service.dart             # Persistencia local (SharedPreferences): UUID, caché y récords
│   ├── theme/
│   │   └── jungle_theme.dart                      # Paleta Selva Tropical/Arcade y tipografía Google Fonts
│   └── widgets/
│       └── jungle_glass_card.dart                 # Tarjetas Glassmorphism, botones arcade con HapticFeedback y badges
└── features/
    ├── profile/                                   # MÓDULO 1: Perfil de Atleta, Avatar y Scoreboard REST
    │   ├── domain/models/athlete_models.dart
    │   ├── data/profile_repository.dart
    │   └── presentation/
    │       ├── providers/profile_provider.dart
    │       ├── screens/profile_screen.dart
    │       └── widgets/scoreboard_cards.dart
    ├── codex/                                     # MÓDULO 2: Códice de la Isla, Cómic (5 Viñetas) y 9 Disciplinas
    │   ├── domain/models/codex_models.dart
    │   ├── data/codex_static_data.dart
    │   └── presentation/screens/codex_screen.dart
    ├── dojo/                                      # MÓDULO 3: Dojo de la Selva (Laboratorio de Swing y Tronco 2D)
    │   └── presentation/screens/dojo_screen.dart
    └── photobooth/                                # MÓDULO 4: Jungle Photo Booth y Exportador PNG
        └── presentation/screens/photobooth_screen.dart
```

---

## 🚀 Inicialización del Repositorio Git Independiente

Este proyecto está diseñado para vivir en su propio repositorio Git, completamente desacoplado del repositorio de Unity:

```bash
# 1. Inicializar repositorio Git limpio en la raíz del proyecto Flutter
git init
git branch -M main

# 2. Agregar archivos y crear el primer commit
git add .
git commit -m "feat: initial release of gorilla_escape_companion mobile app"

# 3. Vincular con tu repositorio remoto independiente (GitHub / GitLab)
git remote add origin https://github.com/tu-usuario/gorilla-escape-companion.git
git push -u origin main
```

---

## ⚙️ Instalación de Dependencias y Ejecución

### Requisitos Previos
- **Flutter SDK:** `>= 3.24.0` (compatible con Flutter 3.x / Dart 3.x)
- **Dispositivo físico Android o iOS** recomendado para experimentar al máximo el acelerómetro, giroscopio, vibración háptica y cámara (también incluye controles de simulación para usar en emulador al 100%).

### Comandos de Instalación y Ejecución

```bash
# 1. Descargar e instalar paquetes desde pub.dev
flutter pub get

# 2. Verificar análisis estático y tests
flutter analyze
flutter test

# 3. Ejecutar en dispositivo Android / iOS conectado o emulador activo
flutter run

# 4. Compilar APK de distribución (Android)
flutter build apk --release
```

---

## 🌐 Integración con Backend REST y Modo Offline / Mock

La aplicación consume el contrato REST del servidor principal de la partida:
- `POST /api/v1/players` — Registro y actualización del atleta (UUID local persistente, nombre, nickname, avatar y mano dominante).
- `GET /api/v1/players` — Roster de atletas activos en la sala.
- `GET /api/v1/minigames` — Catálogo técnico de las 9 disciplinas oficiales.
- `GET /api/v1/matches/{matchId}/results` — Marcador en vivo e historial de rondas.

> **Modo Demo / Offline-First:** Desde la pantalla **Perfil & Score**, puedes alternar el interruptor de **Modo Demo / Offline-First** o pulsar el icono de nube arriba a la derecha para editar la URL base (por defecto `http://192.168.1.100:8080`). Si el servidor de Unity/Backend no está disponible en la red, la app activa automáticamente el fallback Mock y encola los cambios localmente sin interrumpir la experiencia.
