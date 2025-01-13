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
  double get screenBoundsTopMargin;
  double get defaultScreenMargin;

  /** home config screen dimensions **/
  double get sdNamesMaxCrossAxisExtent;
  double get sdNameMaxWidth;
  int get pokemonArtworkFlex;
  int get pokemonSheetFlex;

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
  final double screenBoundsTopMargin = 32.0;

  @override
  final int pokemonArtworkFlex = 1;
  @override
  final int pokemonSheetFlex = 1;

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
  final double screenBoundsTopMargin = 0.0;

  @override
  final int pokemonArtworkFlex = 15;
  @override
  final int pokemonSheetFlex = 10;

  @override
  final bool isMobile = false;

  const _DimensDesktop();
}
