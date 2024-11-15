import 'package:flutter/material.dart';
import 'package:indevche/components/record_list.dart';
import 'package:indevche/models/user.dart';
import 'package:indevche/screens/add_record_screen.dart';
import 'package:indevche/models/record.dart';
import 'package:indevche/models/record_view.dart';
import 'package:indevche/models/suggestions.dart';
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
