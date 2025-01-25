

import 'package:app2/ui/core/utils.dart';
import 'package:flutter/material.dart';

class AutoGridView extends StatelessWidget {

  final int columnsCount;
  final List<Widget> children;
  final double horizontalCellSpacing;
  final double verticalCellSpacing;

  const AutoGridView({super.key, required this.columnsCount, required this.children, this.horizontalCellSpacing = 0.0,
    this.verticalCellSpacing = 0.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.collateBy(columnsCount)
          .map((rowChildren) => Padding(padding: EdgeInsets.symmetric(vertical: verticalCellSpacing),
      child: Row(
        children: rowChildren.map((child) =>
            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: horizontalCellSpacing), child: child,))
        ).toList(),
      ),))
          .toList(),
    );
  }
}