import 'package:flutter/material.dart';
import 'package:rodis_service/components/record_list.dart';
import 'package:rodis_service/components/searchbar.dart';
import 'package:rodis_service/models/user.dart';
import 'package:rodis_service/screens/add_record_screen.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/record_view.dart';
import 'package:rodis_service/models/suggestions.dart';
import 'package:provider/provider.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  final _node = FocusNode();
  void onRefresh(BuildContext context) async {
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<Suggestions, Records, RecordView>(
      lazy: false,
      create: (context) {
        final records = context.read<Records>().records;
        final suggestions = context.read<Suggestions>();
        return RecordView(suggestions: suggestions, records: records);
      },
      update: (context, suggestions, records, recordView) =>
          recordView!..update(suggestions, records),
      builder: (context, child) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_node),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Επισκευές (${context.read<User>().name})"),
            actions: [
              if (!Platform.isAndroid && !Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () async => onRefresh(context),
                    icon: const Icon(Icons.refresh),
                  ),
                ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomSearchBar(),
              const RecordListHeader(),
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () async => onRefresh(context),
                  child: const RecordList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 18.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Selector<RecordView, List<Record>>(
                    selector: (_, recordView) => recordView.filtered,
                    builder: (context, filtered, child) {
                      final text = filtered.isEmpty
                          ? "Δε βρέθηκαν αποτελέσματα"
                          : filtered.length == 1
                              ? "Βρέθηκε ${filtered.length} αποτέλεσμα"
                              : "Βρέθηκαν ${filtered.length} αποτελέσματα";
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
