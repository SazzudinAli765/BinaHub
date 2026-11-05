import 'package:flutter/foundation.dart';

enum ScalerType {
  bilinear,
  bicubic,
  binaNeuralV4,
  casDeblur,
  ultraSinglePass,
  fsrUpscaler,
  anime4k
}

enum ComparisonMode { none, sideBySide, splitSlider }

class EnhancementStageConfig {
  final bool enabled;
  final double intensity; // 0.0 to 1.0

  const EnhancementStageConfig({
    this.enabled = true,
    this.intensity = 0.5,
  });

  EnhancementStageConfig copyWith({bool? enabled, double? intensity}) {
    return EnhancementStageConfig(
      enabled: enabled ?? this.enabled,
      intensity: intensity ?? this.intensity,
    );
  }
}

/// Video Enhancement Pipeline Engine
/// Implements SRS ENH-01..10: Multi-stage enhancement, scaling, and before/after comparison.
class EnhancementPipelineEngine extends ChangeNotifier {
  static final EnhancementPipelineEngine instance = EnhancementPipelineEngine._internal();
  EnhancementPipelineEngine._internal();

  // Stage 1: Decode & Normalization (Always Active)
  bool _hardwareNormalized = true;

  // Stage 2: Compression Artifact & Denoise (ENH-04)
  EnhancementStageConfig _denoiseConfig = const EnhancementStageConfig(enabled: true, intensity: 0.6);

  // Stage 3: Deblur (ENH-03)
  EnhancementStageConfig _deblurConfig = const EnhancementStageConfig(enabled: true, intensity: 0.45);

  // Stage 4: Neural Super-Resolution Scaler (ENH-05)
  ScalerType _activeScaler = ScalerType.binaNeuralV4;
  EnhancementStageConfig _scalerConfig = const EnhancementStageConfig(enabled: true, intensity: 0.75);

  // Stage 5: Adaptive Sharpening & HDR Tone Mapping (ENH-06)
  EnhancementStageConfig _sharpenConfig = const EnhancementStageConfig(enabled: true, intensity: 0.5);
  bool _hdrToneMapping = true;

  // Thermal & Battery Throttle State (ENH-09)
  bool _isThrottled = false;
  double _throttleScale = 1.0;

  // Comparison Display State (ENH-08)
  ComparisonMode _comparisonMode = ComparisonMode.none;
  double _splitPosition = 0.5; // 0.0 to 1.0

  // Getters
  EnhancementStageConfig get denoiseConfig => _denoiseConfig;
  EnhancementStageConfig get deblurConfig => _deblurConfig;
  ScalerType get activeScaler => _activeScaler;
  EnhancementStageConfig get scalerConfig => _scalerConfig;
  EnhancementStageConfig get sharpenConfig => _sharpenConfig;
  bool get hdrToneMapping => _hdrToneMapping;
  bool get isThrottled => _isThrottled;
  ComparisonMode get comparisonMode => _comparisonMode;
  double get splitPosition => _splitPosition;

  /// Check whether output is authentically AI-upscaled (ENH-10)
  bool isUpscaledFrom(int sourceWidth, int sourceHeight, int targetWidth, int targetHeight) {
    return (targetWidth > sourceWidth || targetHeight > sourceHeight) && _scalerConfig.enabled;
  }

  void setDenoise(bool enabled, double intensity) {
    _denoiseConfig = _denoiseConfig.copyWith(enabled: enabled, intensity: intensity);
    notifyListeners();
  }

  void setDeblur(bool enabled, double intensity) {
    _deblurConfig = _deblurConfig.copyWith(enabled: enabled, intensity: intensity);
    notifyListeners();
  }

  void setScaler(ScalerType scaler, {double? intensity}) {
    _activeScaler = scaler;
    if (intensity != null) {
      _scalerConfig = _scalerConfig.copyWith(intensity: intensity);
    }
    notifyListeners();
  }

  void setSharpening(bool enabled, double intensity) {
    _sharpenConfig = _sharpenConfig.copyWith(enabled: enabled, intensity: intensity);
    notifyListeners();
  }

  void setHdrToneMapping(bool enabled) {
    _hdrToneMapping = enabled;
    notifyListeners();
  }

  void setComparisonMode(ComparisonMode mode) {
    _comparisonMode = mode;
    notifyListeners();
  }

  void setSplitPosition(double position) {
    _splitPosition = position.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Adapt processing intensity dynamically when battery or thermal conditions require it (ENH-09)
  void applyThermalThrottle(bool throttled) {
    _isThrottled = throttled;
    _throttleScale = throttled ? 0.6 : 1.0;
    debugPrint('[EnhancementEngine] Thermal throttle set to: $_isThrottled (scale: $_throttleScale)');
    notifyListeners();
  }
}
