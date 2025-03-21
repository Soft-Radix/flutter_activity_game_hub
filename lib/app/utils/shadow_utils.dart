import 'package:flutter/material.dart';

/// Utility class for enhanced shadow effects across the app
class ShadowUtils {
  /// Get enhanced card shadow for light mode that looks more prominent
  static List<BoxShadow> getLightModeCardShadow({
    double opacity = 0.15,
    double blurRadius = 10.0,
    double spreadRadius = 1.0,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: offset,
      ),
    ];
  }

  /// Get enhanced container shadow for light mode
  static List<BoxShadow> getEnhancedContainerShadow({
    Color color = Colors.black,
    double opacity = 0.12,
    double blurRadius = 12.0,
    double spreadRadius = 2.0,
    Offset offset = const Offset(0, 6),
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: offset,
      ),
    ];
  }

  /// Get subtle shadow for smaller UI elements
  static List<BoxShadow> getSubtleShadow({
    double opacity = 0.08,
    double blurRadius = 6.0,
    double spreadRadius = 0.5,
    Offset offset = const Offset(0, 2),
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: offset,
      ),
    ];
  }

  /// Get colored shadow matching a specific color (useful for buttons, etc)
  static List<BoxShadow> getColoredShadow({
    required Color color,
    double opacity = 0.3,
    double blurRadius = 8.0,
    double spreadRadius = 0.0,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: offset,
      ),
    ];
  }
} 