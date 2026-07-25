import 'package:flutter/services.dart';

/// 触觉反馈封装。Android 端 light/medium/heavy 是 no-op，只有 vibrate 有效
class Haptics {
  Haptics._();

  static void impactLight() {
    HapticFeedback.lightImpact();
  }

  static void impactMedium() {
    HapticFeedback.mediumImpact();
  }

  static void impactHeavy() {
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Android 用 vibrate，iOS 上 HapticFeedback 没有原生对应
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  static void notificationSuccess() => vibrate();
  static void notificationWarning() => vibrate();
  static void notificationError() => vibrate();
}