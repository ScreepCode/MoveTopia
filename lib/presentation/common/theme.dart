import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282476597),
      surfaceTint: Color(4282476597),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4290899886),
      onPrimaryContainer: Color(4278329600),
      secondary: Color(4284242065),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4293124095),
      onSecondaryContainer: Color(4279767626),
      tertiary: Color(4286336638),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294956796),
      onTertiaryContainer: Color(4281403702),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294507505),
      onSurface: Color(4279835927),
      onSurfaceVariant: Color(4282599487),
      outline: Color(4285757806),
      outlineVariant: Color(4291020988),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217579),
      inversePrimary: Color(4289123220),
      primaryFixed: Color(4290899886),
      onPrimaryFixed: Color(4278329600),
      primaryFixedDim: Color(4289123220),
      onPrimaryFixedVariant: Color(4280962847),
      secondaryFixed: Color(4293124095),
      onSecondaryFixed: Color(4279767626),
      secondaryFixedDim: Color(4291150079),
      onSecondaryFixedVariant: Color(4282663032),
      tertiaryFixed: Color(4294956796),
      onTertiaryFixed: Color(4281403702),
      tertiaryFixedDim: Color(4293702891),
      onTertiaryFixedVariant: Color(4284626789),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294507505),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112747),
      surfaceContainer: Color(4293717989),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292994266),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4280699676),
      surfaceTint: Color(4282476597),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283858761),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282399859),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285689513),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4284363617),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287915158),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      surface: Color(4294507505),
      onSurface: Color(4279835927),
      onSurfaceVariant: Color(4282336571),
      outline: Color(4284178774),
      outlineVariant: Color(4286020977),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217579),
      inversePrimary: Color(4289123220),
      primaryFixed: Color(4283858761),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282279219),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285689513),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4284044687),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4287915158),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4286139516),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294507505),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112747),
      surfaceContainer: Color(4293717989),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292994266),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278397184),
      surfaceTint: Color(4282476597),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280699676),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280228433),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282399859),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281930046),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4284363617),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      surface: Color(4294507505),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4280296733),
      outline: Color(4282336571),
      outlineVariant: Color(4282336571),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217579),
      inversePrimary: Color(4291557815),
      primaryFixed: Color(4280699676),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279186439),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282399859),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280886620),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4284363617),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282719305),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292402130),
      surfaceBright: Color(4294507505),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294112747),
      surfaceContainer: Color(4293717989),
      surfaceContainerHigh: Color(4293323232),
      surfaceContainerHighest: Color(4292994266),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289123220),
      surfaceTint: Color(4289123220),
      onPrimary: Color(4279449610),
      primaryContainer: Color(4280962847),
      onPrimaryContainer: Color(4290899886),
      secondary: Color(4291150079),
      onSecondary: Color(4281149792),
      secondaryContainer: Color(4282663032),
      onSecondaryContainer: Color(4293124095),
      tertiary: Color(4293702891),
      onTertiary: Color(4282982477),
      tertiaryContainer: Color(4284626789),
      onTertiaryContainer: Color(4294956796),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279309327),
      onSurface: Color(4292994266),
      onSurfaceVariant: Color(4291020988),
      outline: Color(4287468423),
      outlineVariant: Color(4282599487),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292994266),
      inversePrimary: Color(4282476597),
      primaryFixed: Color(4290899886),
      onPrimaryFixed: Color(4278329600),
      primaryFixedDim: Color(4289123220),
      onPrimaryFixedVariant: Color(4280962847),
      secondaryFixed: Color(4293124095),
      onSecondaryFixed: Color(4279767626),
      secondaryFixedDim: Color(4291150079),
      onSecondaryFixedVariant: Color(4282663032),
      tertiaryFixed: Color(4294956796),
      onTertiaryFixed: Color(4281403702),
      tertiaryFixedDim: Color(4293702891),
      onTertiaryFixedVariant: Color(4284626789),
      surfaceDim: Color(4279309327),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480751),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289386392),
      surfaceTint: Color(4289123220),
      onPrimary: Color(4278262528),
      primaryContainer: Color(4285701219),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4291479039),
      onSecondary: Color(4279372869),
      secondaryContainer: Color(4287597255),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294031600),
      onTertiary: Color(4281008945),
      tertiaryContainer: Color(4289953971),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279309327),
      onSurface: Color(4294573298),
      onSurfaceVariant: Color(4291284416),
      outline: Color(4288652697),
      outlineVariant: Color(4286547322),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292994266),
      inversePrimary: Color(4281028896),
      primaryFixed: Color(4290899886),
      onPrimaryFixed: Color(4278261248),
      primaryFixedDim: Color(4289123220),
      onPrimaryFixedVariant: Color(4279844368),
      secondaryFixed: Color(4293124095),
      onSecondaryFixed: Color(4279043392),
      secondaryFixedDim: Color(4291150079),
      onSecondaryFixedVariant: Color(4281544550),
      tertiaryFixed: Color(4294956796),
      onTertiaryFixed: Color(4280614955),
      tertiaryFixedDim: Color(4293702891),
      onTertiaryFixedVariant: Color(4283442771),
      surfaceDim: Color(4279309327),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480751),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4294115303),
      surfaceTint: Color(4289123220),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289386392),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294900223),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4291479039),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4294031600),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      surface: Color(4279309327),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294442479),
      outline: Color(4291284416),
      outlineVariant: Color(4291284416),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292994266),
      inversePrimary: Color(4278923525),
      primaryFixed: Color(4291228850),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289386392),
      onPrimaryFixedVariant: Color(4278262528),
      secondaryFixed: Color(4293453055),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4291479039),
      onSecondaryFixedVariant: Color(4279372869),
      tertiaryFixed: Color(4294958331),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4294031600),
      onTertiaryFixedVariant: Color(4281008945),
      surfaceDim: Color(4279309327),
      surfaceBright: Color(4281743924),
      surfaceContainerLowest: Color(4278914826),
      surfaceContainerLow: Color(4279835927),
      surfaceContainer: Color(4280099099),
      surfaceContainerHigh: Color(4280757029),
      surfaceContainerHighest: Color(4281480751),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
