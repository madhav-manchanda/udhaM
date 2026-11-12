import 'package:flutter/material.dart';

/// UdhaM design color palette — Industrial Precision.
/// Light-mode only as per design specification.
class UdhamColors {
  const UdhamColors._();

  static const surface = Color(0xFFFBF9F2);
  static const surfaceDim = Color(0xFFDBDAD3);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F4ED);
  static const surfaceContainer = Color(0xFFEFEEE7);
  static const surfaceContainerHigh = Color(0xFFE9E8E1);
  static const surfaceContainerHighest = Color(0xFFE3E3DC);
  static const onSurface = Color(0xFF1B1C18);
  static const onSurfaceVariant = Color(0xFF444845);
  static const inverseSurface = Color(0xFF30312C);
  static const inverseOnSurface = Color(0xFFF2F1EA);
  static const outline = Color(0xFF747875);
  static const outlineVariant = Color(0xFFC4C7C3);

  static const primary = Color(0xFF0A0D0B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF202321);
  static const onPrimaryContainer = Color(0xFF888A87);
  static const inversePrimary = Color(0xFFC5C7C4);

  static const secondary = Color(0xFF904D00);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFF9F49);
  static const onSecondaryContainer = Color(0xFF6E3A00);
  static const secondaryFixed = Color(0xFFFFDCC3);
  static const secondaryFixedDim = Color(0xFFFFB77D);

  static const tertiary = Color(0xFF050F08);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF1A251D);
  static const onTertiaryContainer = Color(0xFF818D82);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Semantic convenience
  static const positive = Color(0xFF904D00); // secondarty (orange = surplus)
  static const negative = Color(0xFFBA1A1A); // error (red = deficit)
  static const settled = Color(0xFF444845); // muted = settled
}
