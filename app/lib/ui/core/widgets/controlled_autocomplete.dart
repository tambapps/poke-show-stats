import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// AutoComplete that allows to provide a TextEditingController
class ControlledAutoComplete<T extends Object> extends StatefulWidget {

  final TextEditingController controller;
  final AutocompleteOptionToString<T> displayStringForOption;
  final OptionsViewOpenDirection optionsViewOpenDirection;
  final TextEditingValue? initialValue;
  final AutocompleteOnSelected<T>? onSelected;
  final AutocompleteFieldViewBuilder? fieldViewBuilder;
  final List<T> suggestions;
  final FocusNode _focusNode = FocusNode();
  final double optionsMaxHeight;

  ControlledAutoComplete({super.key,
    required this.controller, required this.suggestions,
    this.displayStringForOption = defaultStringForOption, this.initialValue,
    this.onSelected, this.fieldViewBuilder, this.optionsMaxHeight = 200.0,
    this.optionsViewOpenDirection = OptionsViewOpenDirection.down
  });

  static String defaultStringForOption(Object? option) {
    return option.toString();
  }
  @override
  State<StatefulWidget> createState() => _ControlledAutoCompleteState<T>();
}

class _ControlledAutoCompleteState<T extends Object> extends State<ControlledAutoComplete<T>> {
  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: widget.controller,
      focusNode: widget._focusNode,
      displayStringForOption: widget.displayStringForOption,
      fieldViewBuilder: widget.fieldViewBuilder,
      initialValue: widget.initialValue,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return widget.suggestions.where((T option) {
          return widget.displayStringForOption(option).toLowerCase().contains(textEditingValue.text.toLowerCase());
        }).toList();
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
        return _AutocompleteOptions<T>(
          displayStringForOption: widget.displayStringForOption,
          onSelected: onSelected,
          options: options,
          openDirection: widget.optionsViewOpenDirection,
          maxOptionsHeight: widget.optionsMaxHeight,
        );
      },
      onSelected: widget.onSelected,
    );
  }
}

// copied from material/autocomplete.dart
class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    super.key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.openDirection,
    required this.options,
    required this.maxOptionsHeight,
  });

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;
  final OptionsViewOpenDirection openDirection;

  final Iterable<T> options;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    final AlignmentDirectional optionsAlignment = switch (openDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
    };
    return Align(
      alignment: optionsAlignment,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxOptionsHeight),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(
                    builder: (BuildContext context) {
                      final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                      if (highlight) {
                        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        }, debugLabel: 'AutocompleteOptions.ensureVisible');
                      }
                      return Container(
                        color: highlight ? Theme.of(context).focusColor : null,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(displayStringForOption(option)),
                      );
                    }
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
