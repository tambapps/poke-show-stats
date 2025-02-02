

import 'package:app2/ui/core/localization/applocalization.dart';
import 'package:app2/ui/core/themes/dimens.dart';
import 'package:app2/ui/core/utils.dart';
import 'package:flutter/material.dart';

import '../widgets.dart';

class TileCard extends AbstractStatelessWidget {

  final String title;
  final String? tooltip;
  final Widget content;
  const TileCard({super.key, required this.title, required this.content, this.tooltip});

  @override
  Widget doBuild(BuildContext context, AppLocalization localization, Dimens dimens, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey,
            width: 2.0
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: _content(isMobile(context), theme),
    );

  }

  Widget _content(bool isMobile, ThemeData theme) {
    return isMobile ? _mobileContent(theme) : _desktopContent(theme);
  }

  Widget _desktopContent(ThemeData theme) {
    return Column(
      children: [
      _title(theme),
      Expanded(child: SingleChildScrollView(child: Padding(padding: EdgeInsets.only(bottom: 8.0), child: content,),))
    ],);
  }

  Widget _mobileContent(ThemeData theme) {
    return ExpansionTile(
      title: _title(theme),
      children: [content, const SizedBox(height: 8.0,)],
    );
  }

  Widget _title(ThemeData theme) {
    final text = Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),);
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: text,);
    }
    return text;
  }

}