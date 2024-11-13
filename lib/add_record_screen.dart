import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  final _productNode = FocusNode();
  final _manufacturerNode = FocusNode();
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
  final notesReceivedController = TextEditingController();
  final notesRepairedController = TextEditingController();
  final feeController = TextEditingController();
  final advanceController = TextEditingController();
  final serialController = TextEditingController();
  final productController = TextEditingController();
  final manufacturerController = TextEditingController();
  final dateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()).toString(),
  );
  DateTime date = DateTime.now();
  final hasWarranty = ValueNotifier(false);
  DateTime warrantyDate = DateTime.now();
  final warrantyController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()).toString(),
  );
  String? photoUrl;
  String? tempPhotoPath;
  bool removePhoto = false;
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
    notesReceivedController.text = record.notesReceived ?? "";
    notesRepairedController.text = record.notesRepaired ?? "";
    feeController.text = record.fee.replaceAll(r'.', ',');
    advanceController.text = (record.advance ?? "").replaceAll(r'.', ',');
    serialController.text = record.serial ?? "";
    dateController.text =
        DateFormat('dd/MM/yyyy').format(record.date).toString();
    date = record.date;
    hasWarranty.value = record.hasWarranty;
    warrantyDate = record.warrantyDate;
    warrantyController.text =
        DateFormat('dd/MM/yyyy').format(record.warrantyDate).toString();
    photoUrl = record.photo;
    productController.text = record.product;
    manufacturerController.text = record.manufacturer;
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
              String? newPhotoUrl;
              if (tempPhotoPath != null) {
                final request =
                    http.MultipartRequest('POST', Uri.parse("$apiUrl/media"));
                request.files.add(
                  await http.MultipartFile.fromPath('file', tempPhotoPath!),
                );
                final response =
                    await http.Response.fromStream(await request.send());
                if (response.statusCode == 200) {
                  newPhotoUrl = response.body;
                }
              }
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
                "notesReceived": notesReceivedController.text.isNotEmpty
                    ? notesReceivedController.text
                    : null,
                "notesRepaired": notesRepairedController.text.isNotEmpty
                    ? notesRepairedController.text
                    : null,
                "serial": serialController.text.isNotEmpty
                    ? serialController.text
                    : null,
                "product": productController.text.isNotEmpty
                    ? productController.text
                    : null,
                "manufacturer": manufacturerController.text.isNotEmpty
                    ? manufacturerController.text
                    : null,
                "fee": feeController.text.isNotEmpty
                    ? feeController.text.replaceAll(r',', '.')
                    : null,
                "advance": advanceController.text.isNotEmpty
                    ? advanceController.text.replaceAll(r',', '.')
                    : null,
                "photo": newPhotoUrl ?? (removePhoto ? null : photoUrl),
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
                } else {
                  waiting.value = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Προέκυψε σφάλμα κατά το ανέβασμα των στοιχείων στον σέρβερ",
                      ),
                    ),
                  );
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
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          format: FormFieldFormat.integer,
                        ),
                        FormFieldItem(
                          label: "Κινητό τηλέφωνο",
                          controller: phoneMobileController,
                          format: FormFieldFormat.integer,
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
                          format: FormFieldFormat.integer,
                          required: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        CustomAutocomplete(
                          label: 'Είδος',
                          textEditingController: productController,
                          suggestions: suggestions.products.values,
                          required: true,
                          width: 250.0,
                          focusNode: _productNode,
                        ),
                        CustomAutocomplete(
                          label: 'Μάρκα',
                          textEditingController: manufacturerController,
                          suggestions: suggestions.manufacturers.values,
                          required: true,
                          focusNode: _manufacturerNode,
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
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Πληρωμή",
                          controller: feeController,
                          required: true,
                          format: FormFieldFormat.decimal,
                          width: 150,
                          prefixIcon: Icon(
                            Icons.euro,
                            size: 16.0,
                            color:
                                IconTheme.of(context).color!.withOpacity(0.6),
                          ),
                        ),
                        FormFieldItem(
                          label: "Προκαταβολή",
                          controller: advanceController,
                          format: FormFieldFormat.decimal,
                          width: 150,
                          prefixIcon: Icon(
                            Icons.euro_rounded,
                            size: 16.0,
                            color:
                                IconTheme.of(context).color!.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 32.0,
                      runSpacing: 16.0,
                      children: [
                        Column(
                          children: [
                            FormFieldItem(
                              label: "Παρατηρήσεις παραλαβής",
                              controller: notesReceivedController,
                              width: 500,
                              lines: 5,
                              maxLength: 500,
                            ),
                            FormFieldItem(
                              label: "Παρατηρήσεις επισκευής",
                              controller: notesRepairedController,
                              width: 500,
                              lines: 5,
                              maxLength: 500,
                            ),
                          ],
                        ),
                        CustomPhoto(
                          photoUrl: photoUrl,
                          onPhotoSet: (imagePath, removePhoto) {
                            tempPhotoPath = imagePath;
                            if (removePhoto) this.removePhoto = removePhoto;
                          },
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

enum FormFieldFormat { integer, decimal, any }

class FormFieldItem extends StatelessWidget {
  const FormFieldItem({
    super.key,
    required this.label,
    required this.controller,
    this.width = 200,
    this.lines = 1,
    this.maxLength,
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
            maxLength: maxLength,
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
              border: OutlineInputBorder(),
              prefixIcon: prefixIcon,
            ),
            textInputAction: TextInputAction.next,
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
                          Scrollable.ensureVisible(context, alignment: 0.5);
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

class CustomPhoto extends StatefulWidget {
  CustomPhoto({super.key, this.photoUrl, required this.onPhotoSet});

  final String? photoUrl;
  final void Function(String? imagePath, bool removePhoto) onPhotoSet;
  final picker = ImagePicker();

  @override
  State<CustomPhoto> createState() => CustomPhotoState();
}

class CustomPhotoState extends State<CustomPhoto> {
  String? imagePath;
  bool removePhoto = false;

  void pickGallery() async {
    final image = await widget.picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    Navigator.pop(context);
    if (image == null) return;
    setState(() => imagePath = image.path);
    widget.onPhotoSet(imagePath, removePhoto);
  }

  void pickCamera() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      Navigator.pop(context);
      return;
    }
    final image = await widget.picker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: false,
    );
    Navigator.pop(context);
    if (image == null) return;
    setState(() => imagePath = image.path);
    widget.onPhotoSet(imagePath, removePhoto);
  }

  void onRemovePressed() {
    setState(() {
      imagePath = null;
      removePhoto = true;
    });
    widget.onPhotoSet(imagePath, removePhoto);
  }

  void onTap(Widget child) async {
    await showDialog(
      context: context,
      builder: (context) => PhotoDialog(child: child),
    );
  }

  late final pickPhotoBottomSheet = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: const Icon(Icons.camera),
        title: const Text("Κάμερα"),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 6.0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        onTap: pickCamera,
      ),
      ListTile(
        title: const Text("Gallery"),
        leading: const Icon(Icons.photo),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 6.0,
        ),
        onTap: pickGallery,
      ),
    ],
  );

  void addPhoto() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => pickPhotoBottomSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (imagePath != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.file(
          File(imagePath!),
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
                : EditablePhoto(
                    onTap: () => onTap(
                      Image.file(File(imagePath!)),
                    ),
                    onLongPress: addPhoto,
                    onRemovePressed: onRemovePressed,
                    child: child,
                  ),
          ),
        ),
      );
    } else if (widget.photoUrl != null && !removePhoto) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          "$apiUrl/media/${widget.photoUrl!}",
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
                : EditablePhoto(
                    onTap: () => onTap(
                      Image.network("$apiUrl/media/${widget.photoUrl!}"),
                    ),
                    onLongPress: addPhoto,
                    onRemovePressed: onRemovePressed,
                    child: child,
                  ),
          ),
        ),
      );
    } else {
      child = TextButton.icon(
        onPressed: addPhoto,
        label: const Text("Προσθήκη εικόνας"),
        icon: const Icon(Icons.camera_alt),
      );
    }
    final decoration =
        imagePath == null && (widget.photoUrl == null || removePhoto)
            ? BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12.0),
              )
            : null;

    return Container(
      height: 350,
      width: 500,
      decoration: decoration,
      child: Center(child: child),
    );
  }
}

class EditablePhoto extends StatelessWidget {
  const EditablePhoto({
    super.key,
    required this.onTap,
    required this.onLongPress,
    required this.onRemovePressed,
    required this.child,
  });

  final void Function() onTap;
  final void Function() onLongPress;
  final void Function() onRemovePressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onLongPress: onLongPress,
              onTap: onTap,
              splashFactory: InkSplash.splashFactory,
            ),
          ),
        ),
        Positioned(
          top: 6.0,
          right: 6.0,
          child: SizedBox(
            height: 25.0,
            width: 25.0,
            child: IconButton(
              iconSize: 16.0,
              padding: EdgeInsets.zero,
              onPressed: onRemovePressed,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(backgroundColor: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }
}

class PhotoDialog extends StatelessWidget {
  const PhotoDialog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(onTap: () => Navigator.pop(context)),
        Positioned.fill(
          child: InteractiveViewer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: child,
            ),
          ),
        ),
        Positioned(
          left: 30,
          top: 30,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: Colors.white54),
          ),
        ),
      ],
    );
  }
}
