import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

enum FormFieldFormat { integer, decimal, any }

class FormFieldItem extends StatelessWidget {
  const FormFieldItem({
    super.key,
    required this.label,
    required this.controller,
    this.width = 200,
    this.lines = 1,
    this.maxLength,
    this.textInputType,
    this.format = FormFieldFormat.any,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.required = false,
    this.prefixIcon,
    this.focusNode,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final double width;
  final int lines;
  final int? maxLength;
  final TextInputType? textInputType;
  final FormFieldFormat format;
  final bool readOnly;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final bool required;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size.fromWidth(width)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontSize: 16.0, fontWeight: FontWeight.w500),
              children: [
                if (required)
                  TextSpan(
                    text: "*",
                    style: TextStyle(color: Colors.red.shade900),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: controller,
            maxLines: lines,
            canRequestFocus: !readOnly,
            mouseCursor: readOnly ? WidgetStateMouseCursor.clickable : null,
            maxLength: maxLength,
            keyboardType: textInputType,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            validator: validator ??
                (required
                    ? (value) => value == null || value.isEmpty ? "" : null
                    : null),
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxLength),
              if (format == FormFieldFormat.integer)
                FilteringTextInputFormatter.digitsOnly,
              if (format == FormFieldFormat.decimal)
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[0-9]+[.|,]?[0-9]{0,2}'),
                ),
            ],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorStyle: const TextStyle(height: 0.001),
              prefixIcon: prefixIcon,
            ),
            textInputAction: textInputType == TextInputType.multiline
                ? null
                : TextInputAction.next,
            focusNode: focusNode,
          ),
        ],
      ),
    );
  }
}

class FormComboItem extends StatefulWidget {
  const FormComboItem({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    this.validator,
    this.required = false,
    this.initialSelection,
    this.sortBy,
  });

  final String label;
  final Map<int, String> options;
  final void Function(int?) onSelected;
  final String? Function(int?)? validator;
  final bool required;
  final int? initialSelection;
  final int Function(MapEntry<int, String>, MapEntry<int, String>)? sortBy;

  @override
  State<FormComboItem> createState() => _FormComboItemState();
}

class _FormComboItemState extends State<FormComboItem> {
  late final sorted = widget.sortBy == null
      ? widget.options.entries.toList()
      : (widget.options.entries.toList()..sort(widget.sortBy));
  late final options = sorted
      .map(
        (entry) => DropdownMenuEntry<int>(value: entry.key, label: entry.value),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: DefaultTextStyle.of(context)
                .style
                .copyWith(fontSize: 16.0, fontWeight: FontWeight.w500),
            children: [
              if (widget.required)
                TextSpan(
                  text: "*",
                  style: TextStyle(color: Colors.red.shade900),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        DropdownMenuFormField(
          initialSelection: widget.initialSelection,
          dropdownMenuEntries: options,
          onSelected: widget.onSelected,
          validator: widget.validator ??
              (widget.required ? (value) => value == null ? "" : null : null),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            errorStyle: TextStyle(height: 0.001),
          ),
        ),
      ],
    );
  }
}

class DropdownMenuFormField<T> extends FormField<T> {
  DropdownMenuFormField({
    super.key,
    bool enabled = true,
    double? width,
    double? menuHeight,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Widget? label,
    String? hintText,
    String? helperText,
    String? errorText,
    Widget? selectedTrailingIcon,
    bool enableFilter = false,
    bool enableSearch = true,
    TextStyle? textStyle,
    InputDecorationTheme? inputDecorationTheme,
    MenuStyle? menuStyle,
    this.controller,
    T? initialSelection,
    this.onSelected,
    bool? requestFocusOnTap,
    EdgeInsets? expandedInsets,
    required List<DropdownMenuEntry<T>> dropdownMenuEntries,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.validator,
  }) : super(
          initialValue: initialSelection,
          builder: (FormFieldState<T> field) {
            final _DropdownMenuFormFieldState<T> state =
                field as _DropdownMenuFormFieldState<T>;
            void onSelectedHandler(T? value) {
              field.didChange(value);
              onSelected?.call(value);
            }

            return DropdownMenu<T>(
              key: key,
              enabled: enabled,
              width: width,
              menuHeight: menuHeight,
              leadingIcon: leadingIcon,
              trailingIcon: trailingIcon,
              label: label,
              hintText: hintText,
              helperText: helperText,
              errorText: state.errorText,
              selectedTrailingIcon: selectedTrailingIcon,
              enableFilter: enableFilter,
              enableSearch: enableSearch,
              textStyle: textStyle,
              inputDecorationTheme: inputDecorationTheme,
              menuStyle: menuStyle,
              controller: controller,
              initialSelection: state.value,
              onSelected: onSelectedHandler,
              requestFocusOnTap: false,
              expandedInsets: expandedInsets,
              dropdownMenuEntries: dropdownMenuEntries,
            );
          },
        );

  final ValueChanged<T?>? onSelected;

  final TextEditingController? controller;

  @override
  FormFieldState<T> createState() => _DropdownMenuFormFieldState<T>();
}

class _DropdownMenuFormFieldState<T> extends FormFieldState<T> {
  DropdownMenuFormField<T> get _dropdownMenuFormField =>
      widget as DropdownMenuFormField<T>;

  @override
  void didChange(T? value) {
    super.didChange(value);
    _dropdownMenuFormField.onSelected!(value);
  }

  @override
  void didUpdateWidget(DropdownMenuFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _dropdownMenuFormField.onSelected!(value);
  }
}

class CustomAutocomplete extends StatelessWidget {
  const CustomAutocomplete({
    super.key,
    required this.label,
    required this.textEditingController,
    required this.suggestions,
    required this.focusNode,
    this.width = 200.0,
    this.required = false,
  });

  final String label;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final Iterable<String> suggestions;
  final double width;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      focusNode: focusNode,
      textEditingController: textEditingController,
      optionsBuilder: (textEditingValue) => suggestions
          .where(
            (product) => product.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
          )
          .toList(),
      optionsViewBuilder: (context, onSelected, options) => AutocompleteOption(
        options: options,
        width: width,
        onSelected: onSelected,
      ),
      onSelected: (option) => textEditingController.text = option,
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) =>
          FormFieldItem(
        label: label,
        controller: textEditingController,
        width: width,
        required: required,
        focusNode: focusNode,
      ),
    );
  }
}

class AutocompleteOption extends StatelessWidget {
  const AutocompleteOption({
    super.key,
    required this.options,
    required this.onSelected,
    required this.width,
  });
  final Iterable<String> options;
  final AutocompleteOnSelected<String> onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 200.0, maxWidth: width),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(
                  builder: (BuildContext context) {
                    final bool highlight =
                        AutocompleteHighlightedOption.of(context) == index;
                    if (highlight) {
                      SchedulerBinding.instance.addPostFrameCallback(
                        (Duration timeStamp) {
                          if (context.mounted) {
                            Scrollable.ensureVisible(context, alignment: 0.5);
                          }
                        },
                        debugLabel: 'AutocompleteOptions.ensureVisible',
                      );
                    }
                    return Container(
                      color: highlight ? Theme.of(context).focusColor : null,
                      padding: const EdgeInsets.all(16.0),
                      child:
                          Text(RawAutocomplete.defaultStringForOption(option)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
