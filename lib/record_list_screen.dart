import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:indevche/add_record_screen.dart';
import 'package:indevche/record.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  int counter = 1;

  void onAddPressed(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRecordScreen(),
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Records()),
        ChangeNotifierProvider(create: (context) => RecordView()),
      ],
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Επισκευές"),
          actions: [
            IconButton(
              onPressed: () async {
                final records = context.read<Records>();
                // records.records[0].setName("$counter");
                // records.addRecord(Record("Name $counter", "id $counter"));
                // counter++;
                final response = await http
                    .get(Uri.parse('http://192.168.1.22/api/records/all'));
                final json = (jsonDecode(response.body) as List)
                    .cast<Map<String, dynamic>>();
                final list =
                    json.map((element) => Record.fromJSON(element)).toList();
                records.addRecords(list);
                records.addRecords(list);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchBar(),
            const Expanded(child: RecordList()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => onAddPressed(context),
          label: const Text("Νέα επισκευή"),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class RecordList extends StatefulWidget {
  const RecordList({super.key});

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  @override
  Widget build(BuildContext context) {
    final records = context.watch<Records>().records;
    final recordView = context.watch<RecordView>();
    final filtered = records
        .where((record) => recordView.filter(record, recordView.filterValue))
        .toList();
    filtered.sort(recordView.sorter);

    return Scrollbar(
      child: CustomScrollView(
        slivers: [
          const SliverRecordListHeader(),
          SliverList.builder(
            key: UniqueKey(),
            itemCount: filtered.length,
            itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: filtered[index],
              builder: (context, child) => RecordRow(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordRow extends StatelessWidget {
  const RecordRow({super.key, this.index = 0});

  final int index;

  @override
  Widget build(BuildContext context) {
    final record = context.watch<Record>();

    return InkWell(
      splashFactory: InkSparkle.splashFactory,
      onTap: () => log(record.name),
      child: Ink(
        color: index % 2 == 0
            ? Colors.white
            : Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            RecordCell(text: record.name),
            RecordCell(text: record.phoneMobile),
            RecordCell(text: record.product),
            RecordCell(text: record.manufacturer),
            RecordCell(
              flex: 1,
              text: DateFormat('dd/MM/yyyy | hh:mm:ss').format(record.date),
            ),
            RecordCell(flex: 1, text: record.status),
          ],
        ),
      ),
    );
  }
}

class RecordCell extends StatelessWidget {
  const RecordCell({
    super.key,
    required this.text,
    this.flex = 1,
  });

  final int flex;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          text,
          style: const TextStyle(),
        ),
      ),
    );
  }
}

class SliverRecordListHeader extends StatelessWidget {
  const SliverRecordListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final sorter = context.watch<RecordView>();
    return SliverPersistentHeader(
      key: UniqueKey(),
      pinned: true,
      floating: false,
      delegate: SliverRecordListHeaderDelegate(
        height: 50,
        columns: [
          RecordListHeaderItem(
            title: "Πελάτης",
            onTap: () => sorter.setSort(COLUMN.name),
            visible: sorter.column == COLUMN.name,
            reverse: sorter.reverse,
          ),
          RecordListHeaderItem(
            title: "Τηλέφωνο",
            onTap: () => sorter.setSort(COLUMN.phone),
            visible: sorter.column == COLUMN.phone,
            reverse: sorter.reverse,
          ),
          RecordListHeaderItem(
            title: "Είδος",
            onTap: () => sorter.setSort(COLUMN.product),
            visible: sorter.column == COLUMN.product,
            reverse: sorter.reverse,
          ),
          RecordListHeaderItem(
            title: "Μάρκα",
            onTap: () => sorter.setSort(COLUMN.manufacturer),
            visible: sorter.column == COLUMN.manufacturer,
            reverse: sorter.reverse,
          ),
          RecordListHeaderItem(
            title: "Ημερομηνία",
            onTap: () => sorter.setSort(COLUMN.date),
            visible: sorter.column == COLUMN.date,
            reverse: sorter.reverse,
          ),
          RecordListHeaderItem(
            title: "Κατάσταση",
            onTap: () => sorter.setSort(COLUMN.status),
            visible: sorter.column == COLUMN.status,
            reverse: sorter.reverse,
          ),
        ],
      ),
    );
  }
}

class SliverRecordListHeaderDelegate implements SliverPersistentHeaderDelegate {
  const SliverRecordListHeaderDelegate({
    required this.height,
    required this.columns,
  })  : maxExtent = height,
        minExtent = height;

  final double height;
  @override
  final double minExtent;
  @override
  final double maxExtent;

  final List<RecordListHeaderItem> columns;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columns,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;

  @override
  get showOnScreenConfiguration => null;

  @override
  get snapConfiguration => null;

  @override
  get stretchConfiguration => null;

  @override
  get vsync => null;
}

class RecordListHeaderItem extends StatelessWidget {
  const RecordListHeaderItem({
    super.key,
    required this.title,
    this.onTap,
    this.flex = 1,
    required this.visible,
    required this.reverse,
  });

  final String title;
  final int flex;
  final void Function()? onTap;
  final bool visible;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Material(
        child: InkWell(
          splashFactory: InkSparkle.splashFactory,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Visibility(
                  visible: visible,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Icon(
                    reverse ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    size: 30,
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

class SearchBar extends StatelessWidget {
  SearchBar({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu<COLUMN>(
              initialSelection: COLUMN.name,
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
              ),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: COLUMN.name, label: "Πελάτης"),
                DropdownMenuEntry(value: COLUMN.phone, label: "Τηλέφωνο"),
              ],
              onSelected: (value) => context
                  .read<RecordView>()
                  .setFilterType(value ?? COLUMN.name),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 400,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Αναζήτηση"),
                onChanged: (value) => context
                    .read<RecordView>()
                    .setFilterValue(controller.text.toLowerCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
