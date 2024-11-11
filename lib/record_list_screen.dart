import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indevche/add_record_screen.dart';
import 'package:indevche/record.dart';
import 'package:indevche/welcome.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  final _node = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<Suggestions, Records, RecordView>(
      create: (context) {
        final records = context.read<Records>().records;
        final suggestions = context.read<Suggestions>();
        return RecordView(suggestions: suggestions, records: records);
      },
      // TODO: FIX (UPDATE IS CALLED DURING BUILD OF RECORDHEADER)
      update: (context, suggestions, records, recordView) =>
          recordView!..update(suggestions, records),
      builder: (context, child) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_node),
        child: Scaffold(
          appBar: AppBar(
            title: Consumer<User>(
              builder: (context, value, child) =>
                  Text("Επισκευές (${value.name})"),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SearchBar(),
              const RecordListHeader(),
              const Expanded(child: RecordList()),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 18.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Consumer<RecordView>(
                    builder: (context, value, child) {
                      final text = value.filtered.isEmpty
                          ? "Δε βρέθηκαν αποτελέσματα"
                          : value.filtered.length == 1
                              ? "Βρέθηκε ${value.filtered.length} αποτέλεσμα"
                              : "Βρέθηκαν ${value.filtered.length} αποτελέσματα";
                      return Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final suggestions = context.read<Suggestions>();
              final records = context.read<Records>();
              final user = context.read<User>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: suggestions),
                      ChangeNotifierProvider.value(value: records),
                      Provider.value(value: user),
                    ],
                    builder: (context, child) => const AddRecordScreen(),
                  ),
                ),
              );
              FocusManager.instance.primaryFocus?.unfocus();
            },
            label: const Text("Νέα επισκευή"),
            icon: const Icon(Icons.add),
          ),
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
    final reverse = context.watch<RecordView>().reverse;
    final filtered = reverse
        ? context.watch<RecordView>().filtered.reversed.toList()
        : context.watch<RecordView>().filtered;
    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "Δε βρέθηκαν επισκευές",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Scrollbar(
      child: ListView.builder(
        primary: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) => ChangeNotifierProvider.value(
          value: filtered[index],
          builder: (context, child) => RecordRow(index: index),
        ),
      ),
    );
  }
}

class RecordRow extends StatefulWidget {
  const RecordRow({
    super.key,
    this.index = 0,
    this.initialExpanded = false,
  });

  final int index;
  final bool initialExpanded;
  @override
  State<RecordRow> createState() => _RecordRowState();
}

class _RecordRowState extends State<RecordRow> {
  late var _expanded = widget.initialExpanded;

  @override
  void didUpdateWidget(covariant RecordRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialExpanded != widget.initialExpanded) {
      _expanded = widget.initialExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = context.watch<Record>();
    final suggestions = context.watch<Suggestions>();
    return Material(
      color: widget.index % 2 == 0
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            splashFactory: InkSparkle.splashFactory,
            onTap: () async {
              final records = context.read<Records>();
              final user = context.read<User>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: suggestions),
                      ChangeNotifierProvider.value(value: records),
                      Provider.value(value: user),
                    ],
                    builder: (context, child) =>
                        AddRecordScreen(record: record),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: IconButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        turns: _expanded ? 0.25 : 0,
                        child: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ),
                ),
                RecordCell(text: record.name),
                RecordCell(text: record.phoneMobile),
                RecordCell(text: record.product),
                RecordCell(text: record.manufacturer),
                RecordCell(
                  text: DateFormat('dd/MM/yyyy | hh:mm').format(record.date),
                ),
                RecordCell(text: suggestions.statuses[record.status]!),
              ],
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              alignment: Alignment.bottomCenter,
              heightFactor: _expanded ? 1 : 0,
              child: const HistoryList(),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordCell extends StatelessWidget {
  const RecordCell({
    super.key,
    required this.text,
    this.flex = 7,
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
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class RecordListHeader extends StatelessWidget {
  const RecordListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final sorter = context.watch<RecordView>();
    return Material(
      child: Container(
        height: 50,
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
          children: [
            const Expanded(
              flex: 2,
              child: SizedBox(
                width: 48,
              ),
            ),
            RecordListHeaderItem(
              title: "Πελάτης",
              onTap: () => context.read<RecordView>().setSort(COLUMN.name),
              visible: sorter.column == COLUMN.name,
              reverse: sorter.reverse,
            ),
            RecordListHeaderItem(
              title: "Τηλέφωνο",
              onTap: () => context.read<RecordView>().setSort(COLUMN.phone),
              visible: sorter.column == COLUMN.phone,
              reverse: sorter.reverse,
            ),
            RecordListHeaderItem(
              title: "Είδος",
              onTap: () => context.read<RecordView>().setSort(COLUMN.product),
              visible: sorter.column == COLUMN.product,
              reverse: sorter.reverse,
            ),
            RecordListHeaderItem(
              title: "Μάρκα",
              onTap: () =>
                  context.read<RecordView>().setSort(COLUMN.manufacturer),
              visible: sorter.column == COLUMN.manufacturer,
              reverse: sorter.reverse,
            ),
            RecordListHeaderItem(
              title: "Ημερομηνία",
              onTap: () => context.read<RecordView>().setSort(COLUMN.date),
              visible: sorter.column == COLUMN.date,
              reverse: sorter.reverse,
            ),
            RecordListHeaderItem(
              title: "Κατάσταση",
              onTap: () => context.read<RecordView>().setSort(COLUMN.status),
              visible: sorter.column == COLUMN.status,
              reverse: sorter.reverse,
            ),
          ],
        ),
      ),
    );
  }
}

class RecordListHeaderItem extends StatelessWidget {
  const RecordListHeaderItem({
    super.key,
    required this.title,
    this.onTap,
    this.flex = 7,
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
      child: InkWell(
        splashFactory: InkSparkle.splashFactory,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
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
          padding: const EdgeInsets.only(right: 6.0, top: 4.0, bottom: 4.0),
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

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<Record>().history;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: history.isEmpty
            ? const Text(
                'Δε βρέθηκε ιστορικό',
                style: TextStyle(fontSize: 16.0),
              )
            : ListView(
                shrinkWrap: true,
                children: history.map((e) => HistoryRow(history: e)).toList(),
              ),
      ),
    );
  }
}

class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.history,
  });

  final History history;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Expanded(
            child: Text(
              DateFormat('dd/MM/yyyy | hh:mm').format(history.date),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              history.status,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
