import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indevche/models/record_view.dart';
import 'package:provider/provider.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 6.0,
            top: 4.0,
            bottom: 4.0,
            left: 6.0,
          ),
          child: Container(
            padding: const EdgeInsets.only(left: 14.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 400,
                    child: TextField(
                      controller: controller,
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: const InputDecoration(
                        hintText: "Αναζήτηση",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        final view = context.read<RecordView>();
                        if (view.filterValue == value.toLowerCase()) {
                          return;
                        }
                        context
                            .read<RecordView>()
                            .setFilterValue(value.toLowerCase());
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(10.0),
                    ),
                  ),
                  child: DropdownMenu<COLUMN>(
                    initialSelection: COLUMN.name,
                    inputDecorationTheme: const InputDecorationTheme(
                      contentPadding: EdgeInsets.only(left: 16.0),
                      border: InputBorder.none,
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: COLUMN.name, label: "Πελάτης"),
                      DropdownMenuEntry(value: COLUMN.phone, label: "Τηλέφωνο"),
                      DropdownMenuEntry(value: COLUMN.product, label: "Είδος"),
                    ],
                    onSelected: (value) {
                      final view = context.read<RecordView>();
                      if (view.filterType == value) return;
                      context
                          .read<RecordView>()
                          .setFilterType(value ?? COLUMN.name);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
