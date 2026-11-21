import 'dart:async';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/theme/jungle_theme.dart';
import '../../../../core/widgets/jungle_glass_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class DojoScreen extends ConsumerStatefulWidget {
  const DojoScreen({super.key});

  @override
  ConsumerState<DojoScreen> createState() => _DojoScreenState();
}

class _DojoScreenState extends ConsumerState<DojoScreen> {
  int _activeTab = 0; // 0: Laboratorio de Swing, 1: Tronco en el Río (Log Balance)

  // --- SWING LAB STATE ---
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  double _rawGyroMag = 0.0;
  double _rawLinearAccelMag = 0.0;
  double _currentPhonePower = 0.0;
  double _currentAngleDeg = 42.0;

  double _peakSwingPower = 0.0;
  double _peakSwingAngle = 42.5;
  List<double> _lastSwingCurve = [
    25, 48, 82, 135, 210, 295, 338, 310, 220, 140, 75, 30
  ];
  final List<double> _liveRingBuffer = [];
  bool _isCapturingSwing = false;

  // --- LOG BALANCE 2D STATE ---
  Timer? _balanceLoopTimer;
  bool _isBalanceGameRunning = false;
  bool _balanceVictory = false;
  bool _balanceGameOver = false;
  double _distanceCrossedMeters = 0.0; // Goal: 15.0m
  double _balancePosition = 0.0; // -1.0 (left water) to +1.0 (right water)
  double _balanceVelocity = 0.0;
  double _sensorTiltInput = 0.0;
  double _manualTiltBias = 0.0;
  double _elapsedSeconds = 0.0;
  DateTime _lastHapticAlert = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _startSensors();
  }

  void _startSensors() {
    try {
      _gyroSub = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          // Convert rad/s angular velocity magnitude to game scale
          final magRad = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          _rawGyroMag = magRad * 18.0;
          _recalculateSwingMetrics();
        },
        onError: (_) {},
      );

      _accelSub = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final totalAccel = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          // Subtract Earth gravity (~9.81 m/s^2) to isolate linear acceleration
          final linear = math.max(0.0, totalAccel - 9.81);
          _rawLinearAccelMag = linear * 1.45;

          // Compute elevation angle in degrees (0° to 90°)
          final pitchRad = math.atan2(
            event.y.abs(),
            math.sqrt(event.x * event.x + event.z * event.z) + 0.001,
          );
          final deg = (pitchRad * 180.0 / math.pi).clamp(5.0, 85.0);
          _currentAngleDeg = _currentAngleDeg * 0.75 + deg * 0.25;

          // Lateral tilt for Log Balance (-1.0 to 1.0)
          _sensorTiltInput = (-event.x / 6.5).clamp(-1.2, 1.2);

          _recalculateSwingMetrics();
        },
        onError: (_) {},
      );
    } catch (_) {
      // Safe fallback on desktop/web environments without physical IMU
    }
  }

  void _recalculateSwingMetrics() {
    if (!mounted) return;
    // Game formula: phonePower = |gyro| + 7 * |linearAccel|
    final power = (_rawGyroMag + 7.0 * _rawLinearAccelMag).clamp(0.0, 450.0);

    setState(() {
      _currentPhonePower = power;
      _liveRingBuffer.add(power);
      if (_liveRingBuffer.length > 24) {
        _liveRingBuffer.removeAt(0);
      }

      if (power > 120 && !_isCapturingSwing) {
        _isCapturingSwing = true;
        _peakSwingPower = power;
        _peakSwingAngle = _currentAngleDeg;
      } else if (_isCapturingSwing) {
        if (power > _peakSwingPower) {
          _peakSwingPower = power;
          _peakSwingAngle = _currentAngleDeg;
          if (power >= 280) {
            HapticFeedback.heavyImpact();
            ref
                .read(sharedPreferencesStorageProvider)
                .setDojoBestSwing(power);
          }
        }
        if (power < 65) {
          _isCapturingSwing = false;
          _lastSwingCurve = List<double>.from(_liveRingBuffer);
        }
      }
    });
  }

  /// Allows testing the exact swing physics on emulator or desktop without shaking hardware
  void _triggerSimulatedSwing({required bool optimal}) {
    HapticFeedback.heavyImpact();
    final targetPeak = optimal ? 342.0 : 215.0;
    final targetAngle = optimal ? 42.8 : 29.5;
    final simulatedCurve = <double>[];
    for (int i = 0; i < 16; i++) {
      final t = i / 15.0;
      final bell = math.sin(t * math.pi);
      simulatedCurve.add((targetPeak * bell * bell).clamp(15.0, 440.0));
    }

    ref.read(sharedPreferencesStorageProvider).setDojoBestSwing(targetPeak);

    setState(() {
      _rawGyroMag = optimal ? 132.0 : 85.0;
      _rawLinearAccelMag = optimal ? 30.0 : 18.5;
      _currentPhonePower = targetPeak;
      _currentAngleDeg = targetAngle;
      _peakSwingPower = targetPeak;
      _peakSwingAngle = targetAngle;
      _lastSwingCurve = simulatedCurve;
    });
  }

  // --- LOG BALANCE 2D ENGINE ---
  void _startLogBalanceGame() {
    HapticFeedback.mediumImpact();
    _balanceLoopTimer?.cancel();
    setState(() {
      _isBalanceGameRunning = true;
      _balanceVictory = false;
      _balanceGameOver = false;
      _distanceCrossedMeters = 0.0;
      _balancePosition = 0.0;
      _balanceVelocity = 0.08; // Initial slight river push
      _manualTiltBias = 0.0;
      _elapsedSeconds = 0.0;
    });

    const dt = 0.05; // 20 Hz physics loop
    _balanceLoopTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted || !_isBalanceGameRunning) {
        t.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds += dt;
        // Advance forward across the 15-meter log
        final stabilityFactor = (1.0 - _balancePosition.abs() * 0.45).clamp(0.4, 1.0);
        _distanceCrossedMeters += 1.35 * dt * stabilityFactor;

        // River current wave + gravity instability (log tends to roll away from center)
        final riverWave = math.sin(_elapsedSeconds * 2.3) * 0.42 +
            math.cos(_elapsedSeconds * 3.7) * 0.22;
        final gravityRoll = _balancePosition * 1.15;

        // Player tilt correction (physical sensor + optional on-screen buttons)
        final playerControl = (_sensorTiltInput + _manualTiltBias) * 1.85;

        final angularAccel = riverWave + gravityRoll + playerControl;
        _balanceVelocity = (_balanceVelocity + angularAccel * dt) * 0.94;
        _balancePosition += _balanceVelocity * dt;

        // Decay manual button bias smoothly
        _manualTiltBias *= 0.88;

        final danger = _balancePosition.abs();
        if (danger >= 0.6) {
          final now = DateTime.now();
          if (now.difference(_lastHapticAlert).inMilliseconds > 380) {
            _lastHapticAlert = now;
            HapticFeedback.heavyImpact();
          }
        }

        // Check fall into water
        if (danger >= 1.0) {
          _balancePosition = _balancePosition.sign * 1.0;
          _isBalanceGameRunning = false;
          _balanceGameOver = true;
          HapticFeedback.vibrate();
          t.cancel();
        } else if (_distanceCrossedMeters >= 15.0) {
          _distanceCrossedMeters = 15.0;
          _isBalanceGameRunning = false;
          _balanceVictory = true;
          HapticFeedback.heavyImpact();
          ref
              .read(sharedPreferencesStorageProvider)
              .setDojoBestBalanceTime(_elapsedSeconds);
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _balanceLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(sharedPreferencesStorageProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: _buildHeader(storage.dojoBestSwing),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildTabSelector(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _activeTab == 0
                    ? _buildSwingLaboratoryView()
                    : _buildLogBalanceTrainerView(storage.dojoBestBalanceTime),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double bestSwing) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: JungleColors.coralGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.attractions_rounded,
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
                'DOJO DE LA SELVA (SENSORES)',
                style: JungleTheme.displayStyle(
                  fontSize: 22,
                  color: JungleColors.textPrimary,
                ),
              ),
              Text(
                'Entrenamiento Standalone • Giroscopio & Acelerómetro',
                style: JungleTheme.bodyStyle(
                  fontSize: 12,
                  color: JungleColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (bestSwing > 0)
          JungleBadge(
            label: 'MÁX: ${bestSwing.toStringAsFixed(0)}',
            color: JungleColors.accentGold,
            icon: Icons.bolt_rounded,
          ),
      ],
    );
  }

  Widget _buildTabSelector() {
    final tabs = [
      ('🏏 Laboratorio de Swing', 0),
      ('🪵 Tronco en el Río (15m)', 1),
    ];

    return Row(
      children: tabs.map((t) {
        final isSelected = _activeTab == t.$2;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeTab = t.$2);
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
                      : JungleColors.accentCyan.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                t.$1,
                textAlign: TextAlign.center,
                style: JungleTheme.displayStyle(
                  fontSize: 14,
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

  // ===========================================================================
  // TAB 1: LABORATORIO DE SWING
  // ===========================================================================
  Widget _buildSwingLaboratoryView() {
    final displayPower =
        _peakSwingPower > _currentPhonePower ? _peakSwingPower : _currentPhonePower;
    final displayAngle =
        _peakSwingPower > 0 ? _peakSwingAngle : _currentAngleDeg;

    final String powerClassification;
    final Color classificationColor;
    if (displayPower < 160) {
      powerClassification = 'ARMADO (< 160)';
      classificationColor = JungleColors.accentGold;
    } else if (displayPower <= 280) {
      powerClassification = 'IMPULSO MEDIO (160 - 280)';
      classificationColor = const Color(0xFF38BDF8);
    } else {
      powerClassification = '¡LANZAMIENTO VÁLIDO (> 280)!';
      classificationColor = JungleColors.emeraldSuccess;
    }

    final isOptimalAngle = displayAngle >= 40.0 && displayAngle <= 45.0;

    return ListView(
      key: const ValueKey('swing_lab_tab'),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
      children: [
        JungleGlassCard(
          enableGlow: displayPower > 280,
          borderColor: classificationColor.withValues(alpha: 0.55),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  JungleBadge(
                    label: powerClassification,
                    color: classificationColor,
                    icon: Icons.speed_rounded,
                  ),
                  JungleBadge(
                    label: isOptimalAngle
                        ? 'ÁNGULO ÓPTIMO ${displayAngle.toStringAsFixed(1)}° (40°-45°)'
                        : 'ÁNGULO: ${displayAngle.toStringAsFixed(1)}°',
                    color: isOptimalAngle
                        ? JungleColors.emeraldSuccess
                        : JungleColors.accentGold,
                    icon: Icons.architecture_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 190,
                width: 240,
                child: CustomPaint(
                  painter: _SwingSpeedometerPainter(
                    power: displayPower,
                    accentColor: classificationColor,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 38),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayPower.toStringAsFixed(0),
                            style: JungleTheme.displayStyle(
                              fontSize: 44,
                              color: classificationColor,
                            ),
                          ),
                          Text(
                            'PHONE POWER',
                            style: JungleTheme.bodyStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: JungleColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JungleColors.bgDeepJungle.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      'FÓRMULA FÍSICA EN TIEMPO REAL',
                      style: JungleTheme.bodyStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: JungleColors.accentCyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'phonePower = |ω_gyro| (${_rawGyroMag.toStringAsFixed(1)}) + 7 × |a_lineal| (${_rawLinearAccelMag.toStringAsFixed(1)})',
                      textAlign: TextAlign.center,
                      style: JungleTheme.bodyStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: JungleColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: JungleArcadeButton(
                      label: 'SIMULAR TIRO ÓPTIMO',
                      icon: Icons.bolt_rounded,
                      onPressed: () => _triggerSimulatedSwing(optimal: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: JungleArcadeButton(
                      label: 'REINICIAR PICO',
                      icon: Icons.refresh_rounded,
                      gradient: JungleColors.goldGradient,
                      onPressed: () {
                        setState(() {
                          _peakSwingPower = 0.0;
                          _currentPhonePower = 0.0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        JungleGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.show_chart_rounded,
                    color: JungleColors.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CURVA DINÁMICA DEL ÚLTIMO SWING',
                      style: JungleTheme.displayStyle(
                        fontSize: 17,
                        color: JungleColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Línea punteada verde: Umbral de Lanzamiento Válido (> 280) • Amarilla: Armado (< 160)',
                style: JungleTheme.bodyStyle(
                  fontSize: 11,
                  color: JungleColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SwingCurvePainter(_lastSwingCurve),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: RETO DE EQUILIBRIO 2D ("TRONCO EN EL RÍO" - LOG BALANCE)
  // ===========================================================================
  Widget _buildLogBalanceTrainerView(double bestTime) {
    final danger = _balancePosition.abs().clamp(0.0, 1.0);
    final isHighDanger = danger >= 0.6;
    final progressRatio = (_distanceCrossedMeters / 15.0).clamp(0.0, 1.0);

    return ListView(
      key: const ValueKey('log_balance_tab'),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
      children: [
        JungleGlassCard(
          enableGlow: isHighDanger,
          borderColor: isHighDanger
              ? JungleColors.alertCoral
              : JungleColors.accentCyan.withValues(alpha: 0.5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  JungleBadge(
                    label:
                        'PROGRESO: ${_distanceCrossedMeters.toStringAsFixed(1)} / 15.0 m',
                    color: JungleColors.accentCyan,
                    icon: Icons.straighten_rounded,
                  ),
                  JungleBadge(
                    label: 'PELIGRO: ${(danger * 100).toStringAsFixed(0)}%',
                    color: isHighDanger
                        ? JungleColors.alertCoral
                        : JungleColors.emeraldSuccess,
                    icon: isHighDanger
                        ? Icons.warning_amber_rounded
                        : Icons.shield_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 10,
                  backgroundColor: Colors.black38,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    JungleColors.accentGold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 2D River & Log Canvas
              Container(
                height: 225,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isHighDanger
                        ? JungleColors.alertCoral
                        : JungleColors.accentCyan.withValues(alpha: 0.35),
                    width: isHighDanger ? 2.5 : 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    painter: _LogBalance2DPainter(
                      balanceOffset: _balancePosition,
                      danger: danger,
                      distanceMeters: _distanceCrossedMeters,
                      elapsedSeconds: _elapsedSeconds,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (isHighDanger && _isBalanceGameRunning)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: JungleColors.alertCoral.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: JungleColors.alertCoral),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.vibration_rounded,
                        color: JungleColors.alertCoral,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '¡ALERTA DE CAÍDA (danger ≥ 0.6)! INCLINA AL CENTRO',
                        style: JungleTheme.displayStyle(
                          fontSize: 13,
                          color: JungleColors.alertCoral,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_balanceVictory)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JungleColors.emeraldSuccess.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: JungleColors.emeraldSuccess),
                  ),
                  child: Text(
                    '🏆 ¡CRUCE COMPLETADO! 15.0 m en ${_elapsedSeconds.toStringAsFixed(1)}s',
                    textAlign: TextAlign.center,
                    style: JungleTheme.displayStyle(
                      fontSize: 16,
                      color: JungleColors.emeraldSuccess,
                    ),
                  ),
                ),
              if (_balanceGameOver)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JungleColors.alertCoral.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: JungleColors.alertCoral),
                  ),
                  child: Text(
                    '💦 ¡CAÍSTE AL RÍO A LOS ${_distanceCrossedMeters.toStringAsFixed(1)} m!',
                    textAlign: TextAlign.center,
                    style: JungleTheme.displayStyle(
                      fontSize: 16,
                      color: JungleColors.alertCoral,
                    ),
                  ),
                ),
              // Touch assist buttons for desktop/emulator + physical accelerometer
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: JungleColors.accentCyan),
                      ),
                      onPressed: _isBalanceGameRunning
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _manualTiltBias -= 0.48);
                            }
                          : null,
                      icon: const Icon(Icons.rotate_left_rounded),
                      label: const Text('Inclinar Izq'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: JungleColors.accentCyan),
                      ),
                      onPressed: _isBalanceGameRunning
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _manualTiltBias += 0.48);
                            }
                          : null,
                      icon: const Icon(Icons.rotate_right_rounded),
                      label: const Text('Inclinar Der'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              JungleArcadeButton(
                label: _isBalanceGameRunning
                    ? 'REINICIAR CRUCE DE 15 METROS'
                    : 'INICIAR RETO DEL TRONCO (15M)',
                icon: Icons.play_arrow_rounded,
                isExpanded: true,
                gradient: _isBalanceGameRunning
                    ? JungleColors.goldGradient
                    : JungleColors.cyanGradient,
                onPressed: _startLogBalanceGame,
              ),
              if (bestTime > 0) ...[
                const SizedBox(height: 10),
                Text(
                  'Mejor tiempo histórico en el Dojo: ${bestTime.toStringAsFixed(1)} s',
                  style: JungleTheme.bodyStyle(
                    fontSize: 12,
                    color: JungleColors.accentGold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SwingSpeedometerPainter extends CustomPainter {
  final double power;
  final Color accentColor;

  _SwingSpeedometerPainter({
    required this.power,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.78);
    final radius = math.min(size.width, size.height) * 0.65;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = math.pi * 0.85;
    const sweepTotal = math.pi * 1.3;

    final trackPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);

    // Draw zone segments: <160 (gold), 160-280 (cyan), >280 (emerald)
    final ratio = (power / 420.0).clamp(0.02, 1.0);
    final activePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepTotal * ratio, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _SwingSpeedometerPainter oldDelegate) =>
      oldDelegate.power != power || oldDelegate.accentColor != accentColor;
}

class _SwingCurvePainter extends CustomPainter {
  final List<double> samples;

  _SwingCurvePainter(this.samples);

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    // Threshold line for Valid Throw (280) and Armed (160)
    final validY = size.height * (1.0 - (280.0 / 450.0));
    final armedY = size.height * (1.0 - (160.0 / 450.0));

    final validLinePaint = Paint()
      ..color = JungleColors.emeraldSuccess.withValues(alpha: 0.45)
      ..strokeWidth = 1.5;
    final armedLinePaint = Paint()
      ..color = JungleColors.accentGold.withValues(alpha: 0.45)
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(0, validY), Offset(size.width, validY), validLinePaint);
    canvas.drawLine(Offset(0, armedY), Offset(size.width, armedY), armedLinePaint);

    final path = Path();
    for (int i = 0; i < samples.length; i++) {
      final x = samples.length == 1
          ? size.width / 2
          : (i / (samples.length - 1)) * size.width;
      final y = size.height * (1.0 - (samples[i] / 450.0).clamp(0.05, 0.95));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final curvePaint = Paint()
      ..color = JungleColors.accentCyan
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(covariant _SwingCurvePainter oldDelegate) => true;
}

class _LogBalance2DPainter extends CustomPainter {
  final double balanceOffset; // -1.0 to 1.0
  final double danger;
  final double distanceMeters;
  final double elapsedSeconds;

  _LogBalance2DPainter({
    required this.balanceOffset,
    required this.danger,
    required this.distanceMeters,
    required this.elapsedSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. River background
    final riverPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF062C36),
          Color(0xFF0A4D5C),
          Color(0xFF05232B),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), riverPaint);

    // 2. Animated water ripples
    final ripplePaint = Paint()
      ..color = JungleColors.accentCyan.withValues(alpha: 0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final y = ((i * 45.0 + elapsedSeconds * 40) % size.height);
      canvas.drawLine(
        Offset(24, y),
        Offset(size.width - 24, y),
        ripplePaint,
      );
    }

    // 3. Tilting Wooden Log & Athlete
    final center = Offset(size.width / 2, size.height * 0.58);
    canvas.save();
    canvas.translate(center.dx + balanceOffset * 55, center.dy);
    canvas.rotate(balanceOffset * 0.48);

    // Log body
    final logRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-75, -14, 150, 28),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      logRect,
      Paint()..color = const Color(0xFF8B5A2B),
    );
    canvas.drawRRect(
      logRect,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Athlete balancing pole
    canvas.drawLine(
      const Offset(-58, -36),
      const Offset(58, -36),
      Paint()
        ..color = JungleColors.accentGold
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Athlete body circle
    canvas.drawCircle(
      const Offset(0, -38),
      18,
      Paint()
        ..color = danger >= 0.6
            ? JungleColors.alertCoral
            : JungleColors.accentCyan,
    );

    canvas.restore();

    // 4. Top Balance Gauge Bar
    final barWidth = size.width - 48;
    const barLeft = 24.0;
    const barTop = 18.0;

    final barBgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barLeft, barTop, barWidth, 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(barBgRect, Paint()..color = Colors.black54);

    // Safe center zone
    final safeZoneWidth = barWidth * 0.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barLeft + (barWidth - safeZoneWidth) / 2,
          barTop,
          safeZoneWidth,
          16,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = JungleColors.emeraldSuccess.withValues(alpha: 0.28),
    );

    // Marker position
    final markerX =
        barLeft + (barWidth / 2) + (balanceOffset.clamp(-1.0, 1.0) * (barWidth / 2));
    canvas.drawCircle(
      Offset(markerX, barTop + 8),
      9,
      Paint()
        ..color = danger >= 0.6
            ? JungleColors.alertCoral
            : JungleColors.accentGold,
    );
  }

  @override
  bool shouldRepaint(covariant _LogBalance2DPainter oldDelegate) => true;
}
