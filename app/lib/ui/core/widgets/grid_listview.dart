import 'package:flutter/material.dart';

typedef RowBuilder = GridListViewRow Function(BuildContext context, int index);

class GridListView extends StatelessWidget {

  final Map<int, int?> columnWeights;
  final List<Widget> headRow;
  final RowBuilder rowBuilder;
  final int itemCount;

  const GridListView({super.key, required this.columnWeights, required this.headRow, required this.rowBuilder, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _row(headRow),
      Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) {
                final row = rowBuilder(context, index);
                return _row(row.children, decoration: row.decoration);
              },
              separatorBuilder: (context, index) => SizedBox(height: 1,),
              itemCount: itemCount
          )

      )
    ],
    );
  }

  Widget _row(List<Widget> rowWidgets, {Decoration? decoration}) => Container(
    decoration: decoration,
    child: Row(children:
    rowWidgets.asMap()
        .entries.map((entry) => Expanded(flex: columnWeights[entry.key] ?? 1, child: entry.value)).toList(),),
  );
}


class GridListViewRow {
  final Decoration? decoration;
  final List<Widget> children;

  GridListViewRow({required this.decoration, required this.children});
}