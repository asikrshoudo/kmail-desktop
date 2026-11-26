import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/app/bootstrap.dart';
import 'package:kmail_desktop/design_system/motion/app_motion.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DensitySetting { compact, comfortable, spacious }

enum RemoteImagesPolicy { blocked, allowed }

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.density = DensitySetting.comfortable,
    this.animation = AnimationSetting.full,
    this.blurEnabled = false,
    this.remoteImages = RemoteImagesPolicy.blocked,
    this.textScale = 1.0,
  });

  final ThemeMode themeMode;
  final DensitySetting density;
  final AnimationSetting animation;
  final bool blurEnabled;
  final RemoteImagesPolicy remoteImages;
  final double textScale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    DensitySetting? density,
    AnimationSetting? animation,
    bool? blurEnabled,
    RemoteImagesPolicy? remoteImages,
    double? textScale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      density: density ?? this.density,
      animation: animation ?? this.animation,
      blurEnabled: blurEnabled ?? this.blurEnabled,
      remoteImages: remoteImages ?? this.remoteImages,
      textScale: textScale ?? this.textScale,
    );
  }

  double get densityScale {
    switch (density) {
      case DensitySetting.compact:
        return 0.88;
      case DensitySetting.comfortable:
        return 1.0;
      case DensitySetting.spacious:
        return 1.14;
    }
  }
}

class SettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'settings.themeMode';
  static const _densityKey = 'settings.density';
  static const _animationKey = 'settings.animation';
  static const _blurKey = 'settings.blur';
  static const _remoteImagesKey = 'settings.remoteImages';
  static const _textScaleKey = 'settings.textScale';

  SharedPreferences? get _prefs => ref.read(sharedPreferencesProvider).valueOrNull;

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
    if (prefs == null) return const AppSettings();
    return AppSettings(
      themeMode: ThemeMode.values[prefs.getInt(_themeKey) ?? ThemeMode.system.index],
      density: DensitySetting.values[prefs.getInt(_densityKey) ?? DensitySetting.comfortable.index],
      animation: AnimationSetting.values[prefs.getInt(_animationKey) ?? AnimationSetting.full.index],
      blurEnabled: prefs.getBool(_blurKey) ?? false,
      remoteImages: RemoteImagesPolicy.values[prefs.getInt(_remoteImagesKey) ?? RemoteImagesPolicy.blocked.index],
      textScale: prefs.getDouble(_textScaleKey) ?? 1.0,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs?.setInt(_themeKey, mode.index);
  }

  Future<void> setDensity(DensitySetting density) async {
    state = state.copyWith(density: density);
    await _prefs?.setInt(_densityKey, density.index);
  }

  Future<void> setAnimation(AnimationSetting animation) async {
    state = state.copyWith(animation: animation);
    await _prefs?.setInt(_animationKey, animation.index);
  }

  Future<void> setBlurEnabled(bool enabled) async {
    state = state.copyWith(blurEnabled: enabled);
    await _prefs?.setBool(_blurKey, enabled);
  }

  Future<void> setRemoteImages(RemoteImagesPolicy policy) async {
    state = state.copyWith(remoteImages: policy);
    await _prefs?.setInt(_remoteImagesKey, policy.index);
  }

  Future<void> setTextScale(double scale) async {
    final clamped = scale.clamp(0.9, 1.3);
    state = state.copyWith(textScale: clamped);
    await _prefs?.setDouble(_textScaleKey, clamped);
  }
}

final settingsControllerProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
