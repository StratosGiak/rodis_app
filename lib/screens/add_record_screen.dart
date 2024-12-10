import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:popover/popover.dart';
import 'package:rodis_service/api_handler.dart';
import 'package:rodis_service/components/form_field.dart';
import 'package:rodis_service/components/history.dart';
import 'package:rodis_service/components/photo_field.dart';
import 'package:rodis_service/constants.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/suggestions.dart';
import 'package:rodis_service/models/user.dart';
import 'package:provider/provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key, this.record});

  final Record? record;

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  late final apiHandler = context.read<ApiHandler>();
  late final userId = context.read<User>().id;
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
    text: dateFormat.format(DateTime.now()).toString(),
  );
  DateTime date = DateTime.now();
  final hasWarranty = ValueNotifier(false);
  DateTime? warrantyDate;
  late final warrantyController = TextEditingController(
    text: warrantyDate != null
        ? dateFormat.format(warrantyDate!).toString()
        : null,
  );
  List<History> newHistory = [];
  final photos = <Photo>[];
  int status = 1;
  int? mechanic;
  int store = 1;
  final waiting = ValueNotifier(false);

  final photoErrorSnackbar = const SnackBar(
    content: Text(
      "Σφάλμα κατά το ανέβασμα της φωτογραφίας. Δοκιμάστε ξανά ή αφαιρέστε τη φωτογραφία.",
    ),
  );

  final deleteErrorSnackbar = const SnackBar(
    content: Text("Προέκυψε σφάλμα κατά τη διαγραφή της εντολής"),
  );

  final requiredFieldsSnackbar = const SnackBar(
    content: Text("Συμπληρώστε όλα τα υποχρεωτικά πεδία"),
  );

  final uploadErrorSnackbar = const SnackBar(
    content: Text(
      "Προέκυψε σφάλμα κατά το ανέβασμα των στοιχείων στον σέρβερ",
    ),
  );

  String smsTypeToLabel(SmsType type) {
    return switch (type) {
      SmsType.repaired => "Επισκευασμένο",
      SmsType.unrepairable => "Ανεπισκεύαστο",
      SmsType.thanks => "Ευχαριστήριο",
    };
  }

  bool notEqualOrEmpty(String? a, String? b) {
    if (a == null && b == null) return false;
    if (a == null) return b!.isNotEmpty;
    return a != b;
  }

  bool hasChanges() {
    final record = widget.record;
    if (record == null) {
      return nameController.text.isNotEmpty ||
          phoneHomeController.text.isNotEmpty ||
          phoneMobileController.text.isNotEmpty ||
          emailController.text.isNotEmpty ||
          postalCodeController.text.isNotEmpty ||
          cityController.text.isNotEmpty ||
          areaController.text.isNotEmpty ||
          addressController.text.isNotEmpty ||
          notesReceivedController.text.isNotEmpty ||
          notesRepairedController.text.isNotEmpty ||
          feeController.text.isNotEmpty ||
          advanceController.text.isNotEmpty ||
          serialController.text.isNotEmpty ||
          productController.text.isNotEmpty ||
          manufacturerController.text.isNotEmpty ||
          photos.isNotEmpty;
    }
    return notEqualOrEmpty(record.name, nameController.text) ||
        notEqualOrEmpty(record.phoneHome, phoneHomeController.text) ||
        notEqualOrEmpty(record.phoneMobile, phoneMobileController.text) ||
        notEqualOrEmpty(record.email, emailController.text) ||
        notEqualOrEmpty(record.postalCode, postalCodeController.text) ||
        notEqualOrEmpty(record.city, cityController.text) ||
        notEqualOrEmpty(record.area, areaController.text) ||
        notEqualOrEmpty(record.address, addressController.text) ||
        notEqualOrEmpty(record.notesReceived, notesReceivedController.text) ||
        notEqualOrEmpty(record.notesRepaired, notesRepairedController.text) ||
        notEqualOrEmpty(
          record.fee,
          feeController.text.replaceAll(r',', '.'),
        ) ||
        notEqualOrEmpty(
          record.advance,
          advanceController.text.replaceAll(r',', '.'),
        ) ||
        notEqualOrEmpty(record.serial, serialController.text) ||
        notEqualOrEmpty(record.product, productController.text) ||
        notEqualOrEmpty(record.manufacturer, manufacturerController.text) ||
        record.date != date ||
        record.hasWarranty != hasWarranty.value ||
        record.warrantyDate != warrantyDate ||
        record.status != status ||
        record.store != store ||
        listEquals(photos.map((p) => p.url).toList(), record.photos) ||
        newHistory.isNotEmpty;
  }

  Future<void> sendSms(
    BuildContext dialogContext,
    ValueNotifier<bool> waiting,
    SmsType smsType,
  ) async {
    if (widget.record == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    waiting.value = true;
    final success = await apiHandler.postSMS(id!, smsType);
    waiting.value = false;
    if (dialogContext.mounted) Navigator.pop(dialogContext);
    final type = switch (smsType) {
      SmsType.repaired => "επισκευής",
      SmsType.unrepairable => "ανεπισκεύαστου",
      SmsType.thanks => "ευχαριστίας"
    };
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Επιτυχής αποστολή SMS $type στον πελάτη ${widget.record!.name} (${widget.record!.phoneMobile})"
              : "Αποτυχία αποστολής SMS $type στον πελάτη ${widget.record!.name} (${widget.record!.phoneMobile})",
        ),
      ),
    );
  }

  Future<bool> showDiscardDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Απόρριψη αλλαγών;"),
        content: const SizedBox(
          width: 300,
          child: Text(
            "Έχετε πραγματοποιήσει αλλαγές στη φόρμα οι οποίες θα χαθούν αν συνεχίσετε.",
            textAlign: TextAlign.justify,
          ),
        ),
        icon: const Icon(Icons.error_outline),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Απόρριψη αλλαγών",
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Ακύρωση"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> showDeleteDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Διαγραφή εντολής;"),
        content: const SizedBox(
          width: 300,
          child: Text(
            "Είστε σίγουροι ότι θέλετε να διαγράψετε την παρούσα εντολή;\nΑυτή η πράξη δεν μπορεί να αναιρεθεί.",
            textAlign: TextAlign.justify,
          ),
        ),
        icon: const Icon(Icons.delete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Διαγραφή",
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Ακύρωση"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<SmsType?> showSmsDialog(BuildContext dialogContext) async {
    final waiting = ValueNotifier(false);

    final type = await showPopover<SmsType>(
      context: dialogContext,
      barrierColor: Colors.transparent,
      direction: PopoverDirection.top,
      bodyBuilder: (context) => SizedBox(
        width: 180,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: SmsType.values.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(smsTypeToLabel(SmsType.values[index])),
            onTap: () => Navigator.pop(context, SmsType.values[index]),
          ),
        ),
      ),
    );
    if (type == null) return null;
    final result = showDialog<SmsType>(
      context: dialogContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Αποστολή SMS;"),
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
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3.0),
                  )
                : const Icon(Icons.email),
          ),
        ),
        content: SizedBox(
          width: 300,
          child: RichText(
            text: TextSpan(
              text: "Είστε σίγουρος ότι θέλετε να αποστείλετε το SMS ",
              style: DefaultTextStyle.of(dialogContext).style,
              children: [
                TextSpan(
                  text: switch (type) {
                    SmsType.repaired => "ολοκλήρωσης επισκευής",
                    SmsType.unrepairable => "αδυναμίας επισκευής",
                    SmsType.thanks => "ευχαριστίας"
                  },
                  style: DefaultTextStyle.of(dialogContext)
                      .style
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " στον αριθμό ${widget.record!.phoneMobile};",
                  style: DefaultTextStyle.of(dialogContext).style,
                ),
              ],
            ),
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: waiting,
            builder: (_, value, __) => TextButton(
              onPressed:
                  value ? null : () => sendSms(dialogContext, waiting, type),
              child: const Text("Αποστολή"),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: waiting,
            builder: (_, value, __) => TextButton(
              onPressed: value ? null : () => Navigator.pop(dialogContext),
              child: const Text("Ακύρωση"),
            ),
          ),
        ],
      ),
    );
    return result;
  }

  Future<String?> showDamagesDialog() async {
    final damages = context.read<Suggestions>().damages.values.toList();
    final result = showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          child: ListView.builder(
            itemCount: damages.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: ListTile(
                title: Text(damages[index]),
                onTap: () => Navigator.pop(
                  context,
                  damages[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return result;
  }

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
    postalCodeController.text = record.postalCode ?? "";
    cityController.text = record.city ?? "";
    areaController.text = record.area ?? "";
    addressController.text = record.address ?? "";
    notesReceivedController.text = record.notesReceived;
    notesRepairedController.text = record.notesRepaired ?? "";
    feeController.text = record.fee?.replaceAll(r'.', ',') ?? "";
    advanceController.text = record.advance.replaceAll(r'.', ',');
    serialController.text = record.serial ?? "";
    dateController.text = dateFormat.format(record.date).toString();
    date = record.date;
    hasWarranty.value = record.hasWarranty;
    warrantyDate = record.warrantyDate;
    warrantyController.text = record.warrantyDate != null
        ? dateFormat.format(record.warrantyDate!).toString()
        : "";
    photos.addAll(record.photos.map((p) => (url: p, file: null)));
    productController.text = record.product;
    manufacturerController.text = record.manufacturer ?? "";
    status = record.status;
    mechanic = record.mechanic;
    store = record.store;
  }

  @override
  void dispose() {
    _node.dispose();
    _productNode.dispose();
    _manufacturerNode.dispose();
    nameController.dispose();
    phoneHomeController.dispose();
    phoneMobileController.dispose();
    emailController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    areaController.dispose();
    addressController.dispose();
    notesReceivedController.dispose();
    notesRepairedController.dispose();
    feeController.dispose();
    advanceController.dispose();
    serialController.dispose();
    productController.dispose();
    warrantyController.dispose();
    hasWarranty.dispose();
    waiting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!hasChanges() || await showDiscardDialog()) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_node),
        child: Scaffold(
          appBar: AppBar(
            title: id != null
                ? Text("Ενημέρωση εντολής (ID $id)")
                : const Text("Νέα εντολή"),
            actions: [
              if (widget.record != null && userId == 0)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: IconButton(
                    tooltip: "Διαγραφή",
                    icon: Icon(
                      Icons.delete,
                      size: 26,
                      color: Colors.red.shade700,
                    ),
                    onPressed: () async {
                      final delete = await showDeleteDialog();
                      if (!delete) return;
                      final success = await apiHandler.deleteRecord(id!);
                      if (!success) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(deleteErrorSnackbar);
                        return;
                      }
                      context.read<Records>().removeRecord(id!);
                      Navigator.pop(context);
                    },
                  ),
                ),
              if (widget.record != null)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: IconButton(
                    tooltip: "Λήψη δελτίου",
                    icon: const Icon(Icons.print, size: 26),
                    onPressed: () async {
                      await apiHandler.getForm(widget.record!.id);
                    },
                  ),
                ),
              if (widget.record != null)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        tooltip: "Αποστολή SMS",
                        icon: const Icon(Icons.email, size: 26),
                        onPressed: () async {
                          await showSmsDialog(context);
                        },
                      );
                    },
                  ),
                ),
              if (widget.record != null)
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: IconButton(
                    tooltip: "Ιστορικό",
                    icon: const Icon(Icons.history_edu_rounded, size: 26),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => HistoryDialog(
                          history: widget.record!.history,
                          newHistory: newHistory,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 6.0),
            ],
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
                ScaffoldMessenger.of(context)
                    .showSnackBar(requiredFieldsSnackbar);
                return;
              }
              waiting.value = true;
              final newPhotos = photos
                  .where((e) => e.file != null)
                  .map((e) => e.file)
                  .toList()
                  .cast<XFile>();
              final newPhotoUrls = [];
              if (newPhotos.isNotEmpty) {
                final compressed = await newPhotos.map((p) async {
                  try {
                    return await FlutterImageCompress.compressAndGetFile(
                          p.path,
                          "${p.path}_compressed.jpg",
                        ) ??
                        p;
                  } catch (error) {
                    return p;
                  }
                }).wait;
                try {
                  newPhotoUrls.addAll(await apiHandler.postPhotos(compressed));
                } catch (error) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(photoErrorSnackbar);
                  waiting.value = false;
                  return;
                }
              }
              final finalPhotos = <String>[];
              int index = 0;
              for (final p in photos) {
                if (p.file != null) {
                  finalPhotos.add(newPhotoUrls[index++]);
                } else {
                  finalPhotos.add(p.url!);
                }
              }
              final record = {
                "date": dateTimeFormatDB.format(date),
                "name": nameController.text,
                "phoneHome": phoneHomeController.text.isNotEmpty
                    ? phoneHomeController.text
                    : null,
                "phoneMobile": phoneMobileController.text,
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
                "notesReceived": notesReceivedController.text,
                "notesRepaired": notesRepairedController.text.isNotEmpty
                    ? notesRepairedController.text
                    : null,
                "serial": serialController.text.isNotEmpty
                    ? serialController.text
                    : null,
                "product": productController.text,
                "manufacturer": manufacturerController.text.isNotEmpty
                    ? manufacturerController.text
                    : null,
                "fee": feeController.text.isNotEmpty
                    ? feeController.text.replaceAll(r',', '.')
                    : null,
                "advance": advanceController.text.replaceAll(r',', '.'),
                "photos": finalPhotos,
                "mechanic": userId == 0 ? mechanic : userId,
                "hasWarranty": hasWarranty.value,
                "warrantyDate": hasWarranty.value && warrantyDate != null
                    ? dateTimeFormatDB.format(warrantyDate!)
                    : null,
                "status": status,
                "store": store,
                "newHistory": newHistory.map((e) => e.toJSON()).toList(),
              };
              try {
                if (id == null) {
                  final response = await apiHandler.postRecord(record);
                  if (response != null) {
                    context.read<Records>().add(Record.fromJSON(response));
                    Navigator.pop(context);
                  }
                } else {
                  final response = await apiHandler.putRecord(id!, record);
                  if (response != null) {
                    context
                        .read<Records>()
                        .setRecord(Record.fromJSON(response));
                    Navigator.pop(context);
                  }
                }
              } catch (err) {
                ScaffoldMessenger.of(context).showSnackBar(uploadErrorSnackbar);
              } finally {
                waiting.value = false;
              }
            },
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 20.0,
                  bottom: 65.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Ημερομηνία",
                          controller: dateController,
                          textInputType: TextInputType.datetime,
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
                                dateFormat.format(date).toString();
                          },
                        ),
                        Selector<Suggestions, Map<int, String>>(
                          selector: (context, suggestions) =>
                              suggestions.statuses,
                          builder: (context, statuses, child) => FormComboItem(
                            label: "Κατάσταση",
                            initialSelection: status,
                            options: statuses,
                            onSelected: (value) => status = value ?? 1,
                            required: true,
                          ),
                        ),
                        Selector<Suggestions, Map<int, String>>(
                          selector: (context, suggestions) =>
                              suggestions.stores,
                          builder: (context, stores, child) => FormComboItem(
                            label: "Κατάστημα",
                            initialSelection: store,
                            options: stores,
                            onSelected: (value) => store = value ?? 1,
                            required: true,
                          ),
                        ),
                        if (userId == 0)
                          Selector<Suggestions, Map<int, String>>(
                            selector: (context, suggestions) =>
                                suggestions.mechanics,
                            builder: (context, mechanics, child) =>
                                FormComboItem(
                              label: "Αποστολή σε",
                              initialSelection: mechanic,
                              options: mechanics,
                              onSelected: (value) => mechanic = value ?? 1,
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
                          label: "Κόστος ελέγχου",
                          controller: advanceController,
                          required: true,
                          textInputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          format: FormFieldFormat.decimal,
                          width: 150,
                          prefixIcon: Icon(
                            Icons.euro_rounded,
                            size: 16.0,
                            color:
                                IconTheme.of(context).color!.withOpacity(0.6),
                          ),
                        ),
                        FormFieldItem(
                          label: "Πληρωμή",
                          controller: feeController,
                          textInputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          format: FormFieldFormat.decimal,
                          width: 150,
                          prefixIcon: Icon(
                            Icons.euro,
                            size: 16.0,
                            color:
                                IconTheme.of(context).color!.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Wrap(
                      children: [
                        FormFieldItem(
                          label: "Όνομα πελάτη",
                          controller: nameController,
                          textInputType: TextInputType.name,
                          width: 300,
                          required: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        FormFieldItem(
                          label: "Σταθερό τηλέφωνο",
                          controller: phoneHomeController,
                          textInputType: TextInputType.phone,
                          format: FormFieldFormat.integer,
                        ),
                        FormFieldItem(
                          label: "Κινητό τηλέφωνο",
                          controller: phoneMobileController,
                          textInputType: TextInputType.phone,
                          format: FormFieldFormat.integer,
                          required: true,
                        ),
                        FormFieldItem(
                          label: "Email",
                          controller: emailController,
                          textInputType: TextInputType.emailAddress,
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
                          textInputType: TextInputType.streetAddress,
                          width: 300,
                        ),
                        FormFieldItem(
                          label: "Πόλη",
                          controller: cityController,
                        ),
                        FormFieldItem(
                          label: "Περιοχή",
                          controller: areaController,
                        ),
                        FormFieldItem(
                          label: "ΤΚ",
                          controller: postalCodeController,
                          textInputType: TextInputType.number,
                          width: 100,
                          format: FormFieldFormat.integer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Wrap(
                      spacing: 30,
                      runSpacing: 10,
                      children: [
                        Selector<Suggestions, Map<int, String>>(
                          selector: (context, suggestions) =>
                              suggestions.products,
                          builder: (context, products, child) =>
                              CustomAutocomplete(
                            label: 'Είδος',
                            textEditingController: productController,
                            suggestions: products.values,
                            required: true,
                            width: 250.0,
                            focusNode: _productNode,
                          ),
                        ),
                        Selector<Suggestions, Map<int, String>>(
                          selector: (context, suggestions) =>
                              suggestions.manufacturers,
                          builder: (context, manufacturers, child) =>
                              CustomAutocomplete(
                            label: 'Μάρκα',
                            textEditingController: manufacturerController,
                            suggestions: manufacturers.values,
                            focusNode: _manufacturerNode,
                          ),
                        ),
                        FormFieldItem(
                          label: "Σειριακός αριθμός",
                          controller: serialController,
                          width: 250,
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
                              keyboardType: TextInputType.datetime,
                              enabled: value,
                              readOnly: true,
                              canRequestFocus: false,
                              mouseCursor: WidgetStateMouseCursor.clickable,
                              onTap: () async {
                                final newDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099),
                                );
                                if (newDate == null) return;
                                warrantyDate = newDate;
                                warrantyController.text =
                                    dateFormat.format(newDate).toString();
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FormFieldItem(
                              label: "Παρατηρήσεις βλάβης",
                              controller: notesReceivedController,
                              textInputType: TextInputType.multiline,
                              required: true,
                              width: 500,
                              lines: 5,
                              maxLength: 500,
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final damage = await showDamagesDialog();
                                if (damage == null) return;
                                // ignore: prefer_interpolation_to_compose_strings
                                notesReceivedController.text = damage +
                                    '\n' +
                                    notesReceivedController.text;
                              },
                              label: const Text("Προσθήκη συμπτώματος"),
                              icon: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 16.0),
                            FormFieldItem(
                              label: "Παρατηρήσεις επισκευής",
                              controller: notesRepairedController,
                              textInputType: TextInputType.multiline,
                              width: 500,
                              lines: 5,
                              maxLength: 500,
                            ),
                          ],
                        ),
                        PhotoField(photos: photos),
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
