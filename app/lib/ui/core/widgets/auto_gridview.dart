

import '../utils.dart';
import 'package:flutter/material.dart';

class AutoGridView extends StatelessWidget {

  final int columnsCount;
  final List<Widget> children;
  final double horizontalCellSpacing;
  final double verticalCellSpacing;
  final CrossAxisAlignment rowCrossAxisAlignment;

  const AutoGridView({super.key, required this.columnsCount, required this.children, this.horizontalCellSpacing = 0.0,
    this.verticalCellSpacing = 0.0, this.rowCrossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = computeEffectiveChildren();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.collateBy(columnsCount)
          .map((rowChildren) => Padding(padding: EdgeInsets.symmetric(vertical: verticalCellSpacing),
      child: Row(
        crossAxisAlignment: rowCrossAxisAlignment,
        children: rowChildren.map((child) =>
            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: horizontalCellSpacing), child: child,))
        ).toList(),
      ),))
          .toList(),
    );
  }

  List<Widget> computeEffectiveChildren() {
    if (children.length % columnsCount == 0) return children;
    List<Widget> effectiveChildren = children.toList();
    while (effectiveChildren.length % columnsCount != 0) {
      effectiveChildren.add(Container());
    }
    return effectiveChildren;
  }
}