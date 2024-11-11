import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indevche/constants.dart';
import 'package:indevche/record.dart';
import 'package:http/http.dart' as http;
import 'package:indevche/welcome.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key, this.record});

  final Record? record;

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _node = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int? id;
  final nameController = TextEditingController();
  final phoneHomeController = TextEditingController();
  final phoneMobileController = TextEditingController();
  final emailController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  final serialController = TextEditingController();
  final dateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()).toString(),
  );
  DateTime date = DateTime.now();
  final hasWarranty = ValueNotifier(false);
  DateTime warrantyDate = DateTime.now();
  final warrantyController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()).toString(),
  );
  final photo = ValueNotifier<String?>(null);
  int? product;
  int? manufacturer;
  int? status;
  final waiting = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.record == null) return;
    final record = widget.record!;
    id = record.id;
    nameController.text = record.name;
    phoneHomeController.text = record.phoneHome ?? "";
    phoneMobileController.text = record.phoneMobile;
    emailController.text = record.email ?? "";
    postalCodeController.text = record.postalCode;
    cityController.text = record.city;
    areaController.text = record.area;
    addressController.text = record.address;
    notesController.text = record.notes ?? "";
    serialController.text = record.serial ?? "";
    dateController.text =
        DateFormat('dd/MM/yyyy').format(record.date).toString();
    date = record.date;
    hasWarranty.value = record.hasWarranty;
    warrantyDate = record.warrantyDate;
    warrantyController.text =
        DateFormat('dd/MM/yyyy').format(record.warrantyDate).toString();
    photo.value = record.photo;
    product = record.product;
    manufacturer = record.manufacturer;
    status = record.status;
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = context.watch<Suggestions>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_node),
      child: ChangeNotifierProvider.value(
        value: suggestions,
        child: Scaffold(
          appBar: AppBar(
            title: id != null
                ? const Text("Ενημέρωση επισκευής")
                : const Text("Νέα επισκευή"),
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: const Text('Υποβολή'),
            icon: ValueListenableBuilder(
              valueListenable: waiting,
              builder: (context, value, child) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: value
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(strokeWidth: 3.0),
                      )
                    : const Icon(Icons.check),
              ),
            ),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Παρακαλώ συμπληρώστε όλα τα απαραίτητα στοιχεία"),
                  ),
                );
                return;
              }
              waiting.value = true;
              final record = {
                if (id != null) "id": id,
                "date": DateFormat("yyyy-MM-dd hh:mm:ss").format(date),
                "name":
                    nameController.text.isNotEmpty ? nameController.text : null,
                "phoneHome": phoneHomeController.text.isNotEmpty
                    ? phoneHomeController.text
                    : null,
                "phoneMobile": phoneMobileController.text.isNotEmpty
                    ? phoneMobileController.text
                    : null,
                "email": emailController.text.isNotEmpty
                    ? emailController.text
                    : null,
                "postalCode": postalCodeController.text.isNotEmpty
                    ? postalCodeController.text
                    : null,
                "city":
                    cityController.text.isNotEmpty ? cityController.text : null,
                "area":
                    areaController.text.isNotEmpty ? areaController.text : null,
                "address": addressController.text.isNotEmpty
                    ? addressController.text
                    : null,
                "notes": notesController.text.isNotEmpty
                    ? notesController.text
                    : null,
                "serial": serialController.text.isNotEmpty
                    ? serialController.text
                    : null,
                "product": product,
                "manufacturer": manufacturer,
                "photo": photo.value,
                "mechanic": context.read<User>().id,
                "hasWarranty": hasWarranty.value,
                "warrantyDate": hasWarranty.value
                    ? DateFormat("yyyy-MM-dd hh:mm:ss").format(warrantyDate)
                    : null,
                "status": status,
              };
              if (id == null) {
                final response = await http.post(
                  Uri.parse("$apiUrl/records/new"),
                  headers: {'Content-Type': 'application/json; charset=UTF-8'},
                  body: jsonEncode(record),
                );
                if (response.statusCode == 200) {
                  context
                      .read<Records>()
                      .addRecord(Record.fromJSON(jsonDecode(response.body)));
                  waiting.value = false;
                  Navigator.pop(context);
                }
              } else {
                final response = await http.put(
                  Uri.parse("$apiUrl/records/$id/edit"),
                  headers: {'Content-Type': 'application/json; charset=UTF-8'},
                  body: jsonEncode(record),
                );
                if (response.statusCode == 200) {
                  context
                      .read<Records>()
                      .setRecord(Record.fromJSON(jsonDecode(response.body)));
                  waiting.value = false;
                  Navigator.pop(context);
                }
              }
            },
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FormFieldItem(
                        label: "Ημερομηνία",
                        controller: dateController,
                        required: true,
                        width: 150,
                        readOnly: true,
                        onTap: () async {
                          final newDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2099),
                          );
                          if (newDate == null) return;
                          date = newDate;
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(date).toString();
                        },
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FormFieldItem(
                        label: "Όνομα πελάτη",
                        controller: nameController,
                        width: 300,
                        required: true,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Σταθερό τηλέφωνο",
                          controller: phoneHomeController,
                          numeric: true,
                        ),
                        FormFieldItem(
                          label: "Κινητό τηλέφωνο",
                          controller: phoneMobileController,
                          numeric: true,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "Email",
                          controller: emailController,
                          width: 300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Διεύθυνση",
                          controller: addressController,
                          width: 300,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "Πόλη",
                          controller: cityController,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "Περιοχή",
                          controller: areaController,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "ΤΚ",
                          controller: postalCodeController,
                          width: 100,
                          numeric: true,
                          required: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        Consumer<Suggestions>(
                          builder: (context, value, child) => FormComboItem(
                            label: "Είδος",
                            initialSelection: product,
                            options: value.products,
                            onSelected: (value) => product = value,
                            required: true,
                          ),
                        ),
                        Consumer<Suggestions>(
                          builder: (context, value, child) => FormComboItem(
                            label: "Μάρκα",
                            initialSelection: manufacturer,
                            options: value.manufacturers,
                            onSelected: (value) => manufacturer = value,
                            required: true,
                          ),
                        ),
                        FormFieldItem(
                          label: "Σειριακός αριθμός",
                          controller: serialController,
                          width: 250,
                        ),
                        Consumer<Suggestions>(
                          builder: (context, value, child) => FormComboItem(
                            label: "Κατάσταση",
                            initialSelection: status,
                            options: value.statuses,
                            onSelected: (value) => status = value,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 32.0,
                      runSpacing: 16.0,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: hasWarranty,
                          builder: (context, value, child) => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Εγγύηση",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    child: Checkbox(
                                      value: value,
                                      onChanged: (newValue) =>
                                          hasWarranty.value = newValue ?? false,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 150,
                                child: TextFormField(
                                  controller: warrantyController,
                                  enabled: value,
                                  readOnly: true,
                                  onTap: () async {
                                    final newDate = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2099),
                                    );
                                    if (newDate == null) return;
                                    warrantyDate = newDate;
                                    warrantyController.text =
                                        DateFormat('dd/MM/yyyy')
                                            .format(warrantyDate)
                                            .toString();
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32.0),
                              FormFieldItem(
                                label: "Παρατηρήσεις",
                                controller: notesController,
                                width: 500,
                                lines: 5,
                                maxLength: 500,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 300,
                          width: 500,
                          child: Center(
                            child: Image.network(
                              'https://images.pexels.com/photos/3774243/pexels-photo-3774243.jpeg',
                              frameBuilder: (
                                context,
                                child,
                                frame,
                                wasSynchronouslyLoaded,
                              ) =>
                                  AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: frame == null
                                    ? const CircularProgressIndicator()
                                    : Stack(
                                        children: [
                                          child,
                                          Positioned.fill(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {},
                                                splashFactory:
                                                    InkSplash.splashFactory,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormFieldItem extends StatelessWidget {
  const FormFieldItem({
    super.key,
    required this.label,
    required this.controller,
    this.width = 200,
    this.lines = 1,
    this.maxLength,
    this.numeric = false,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.required = false,
  });

  final String label;
  final TextEditingController controller;
  final double width;
  final int lines;
  final int? maxLength;
  final bool numeric;
  final bool readOnly;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final bool required;

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
            maxLength: maxLength,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator ??
                (required
                    ? (value) => value == null || value.isEmpty ? "" : null
                    : null),
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxLength),
              if (numeric) FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              errorStyle: TextStyle(height: 0),
            ),
            textInputAction: TextInputAction.next,
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
  });

  final String label;
  final Map<int, String> options;
  final void Function(int?) onSelected;
  final String? Function(int?)? validator;
  final bool required;
  final int? initialSelection;

  @override
  State<FormComboItem> createState() => _FormComboItemState();
}

class _FormComboItemState extends State<FormComboItem> {
  late final options = widget.options.entries
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
            errorStyle: TextStyle(height: 0),
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
              requestFocusOnTap: requestFocusOnTap,
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
    // _dropdownMenuFormField.onSelected!(value);
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
