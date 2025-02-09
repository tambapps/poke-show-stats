// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../utils.dart' as utils;

abstract final class Dimens {
  const Dimens();

  static const pokemonLogoSize = 60.0;

  static const teraSpriteSize = 64.0;

  static const itemSpriteSize = 50.0;

  bool get isMobile;
  /// screen bounds
  double get defaultScreenMargin;

  /* home config screen dimensions */
  double get sdNamesMaxCrossAxisExtent;
  double get sdNameMaxWidth;
  double get pokepastePokemonHeight;
  double get pokepastePokemonIconsOffset;
  double get homeConfigScreenTopPadding;
  int get pokemonArtworkFlex;
  int get pokemonSheetFlex;

  /* replay filters dimensions */
  double get replayFiltersContainerPadding;
  int get pokemonFiltersColumnsCount;
  double get pokemonFiltersHorizontalSpacing;
  double get pokemonFiltersTabViewHeight;
  double get pieChartAspectRatio;

  /* home screen */
  int get savesColumnCount;

  static const Dimens desktop = _DimensDesktop();
  static const Dimens mobile = _DimensMobile();

  /// Get dimensions definition based on screen size
  factory Dimens.of(BuildContext context) => utils.isMobile(context) ? mobile : desktop;

}

/// Mobile dimensions
final class _DimensMobile extends Dimens {
  @override
  final double defaultScreenMargin = 8.0;
  @override
  final double sdNamesMaxCrossAxisExtent = 270.0;
  @override
  final double sdNameMaxWidth = 110.0;
  @override
  final double pokepastePokemonHeight = 250.0;
  @override
  final double pokepastePokemonIconsOffset = 25.0;
  @override
  final double homeConfigScreenTopPadding = 0.0;
  @override
  final int pokemonFiltersColumnsCount = 2;
  @override
  final double pokemonFiltersTabViewHeight = 400.0;
  @override
  final double pokemonFiltersHorizontalSpacing = 8.0;
  @override
  final double replayFiltersContainerPadding = 8.0;

  @override
  final double pieChartAspectRatio = 1.0;

  @override
  final int pokemonArtworkFlex = 35;
  @override
  final int pokemonSheetFlex = 65;
  @override
  final int savesColumnCount = 1;

  @override
  final bool isMobile = true;

  const _DimensMobile();
}

/// Desktop/Web dimensions
final class _DimensDesktop extends Dimens {
  @override
  final double sdNamesMaxCrossAxisExtent = 200.0;
  @override
  final double sdNameMaxWidth = 200.0;
  @override
  final double defaultScreenMargin = 128.0;
  @override
  final double pokepastePokemonHeight = 250.0;
  @override
  final double pokepastePokemonIconsOffset = 25.0;
  @override
  final double homeConfigScreenTopPadding = 26.0;
  @override
  final int pokemonFiltersColumnsCount = 4;
  @override
  final double pokemonFiltersTabViewHeight = 200.0;
  @override
  final double pokemonFiltersHorizontalSpacing = 20.0;
  @override
  final double pieChartAspectRatio = 1.5;
  @override
  final double replayFiltersContainerPadding = 32.0;

  @override
  final int pokemonArtworkFlex = 45;
  @override
  final int pokemonSheetFlex = 55;

  @override
  final bool isMobile = false;
  @override
  final int savesColumnCount = 3;

  const _DimensDesktop();
}
