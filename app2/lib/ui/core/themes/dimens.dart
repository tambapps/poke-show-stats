// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

abstract final class Dimens {
  const Dimens();

  static const pokemonLogoSize = 60.0;

  static const teraSpriteSize = 64.0;

  static const itemSpriteSize = 50.0;

  /// screen bounds
  double get screenBoundsTopMargin;
  double get defaultScreenMargin;

  static const Dimens desktop = _DimensDesktop();
  static const Dimens mobile = _DimensMobile();

  /// Get dimensions definition based on screen size
  factory Dimens.of(BuildContext context) =>
      switch (MediaQuery.sizeOf(context).width) {
        > 600 => desktop,
        _ => mobile,
      };
}

/// Mobile dimensions
final class _DimensMobile extends Dimens {
  @override
  final double defaultScreenMargin = 8.0;

  @override
  final double screenBoundsTopMargin = 32.0;

  const _DimensMobile();
}

/// Desktop/Web dimensions
final class _DimensDesktop extends Dimens {
  @override
  final double defaultScreenMargin = 128.0;

  @override
  final double screenBoundsTopMargin = 0.0;

  const _DimensDesktop();
}
