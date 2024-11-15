import 'package:flutter/material.dart';
import 'package:indevche/constants.dart';
import 'package:indevche/models/record.dart';

class HistoryDialog extends StatefulWidget {
  const HistoryDialog({
    super.key,
    required this.history,
    required this.newHistory,
    required this.onHistoryChange,
  });

  final List<History> history;
  final List<History> newHistory;
  final void Function(List<History> newHistory) onHistoryChange;

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<HistoryDialog> {
  final _textFieldNode = FocusNode();
  final _backNode = FocusNode();
  bool expand = false;
  late final newHistory = widget.newHistory;
  final notesController = TextEditingController();
  final date = ValueNotifier(DateTime.now());
  final animatedListKey = GlobalKey<AnimatedListState>();

  @override
  void dispose() {
    _textFieldNode.dispose();
    _backNode.dispose();
    notesController.dispose();
    date.dispose();
    super.dispose();
  }

  Widget buildAddedItem(BuildContext context, int index, Animation animation) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1, 0), end: const Offset(0, 0)),
      ),
      child: ListTile(
        title: Text(
          dateTimeFormat.format(newHistory[index].date),
        ),
        subtitle: Text(newHistory[index].notes),
        trailing: IconButton(
          onPressed: () {
            final history = newHistory[index];
            setState(() {
              newHistory.removeAt(index);
            });
            widget.onHistoryChange(newHistory);
            AnimatedList.of(context).removeItem(
              index,
              (context, animation) => buildRemovedItem(history, animation),
              duration: const Duration(milliseconds: 150),
            );
          },
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }

  Widget buildRemovedItem(History history, Animation animation) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1, 0), end: const Offset(0, 0)),
      ),
      child: ListTile(
        title: Text(dateTimeFormat.format(history.date)),
        subtitle: Text(history.notes),
        trailing: const IconButton(
          onPressed: null,
          icon: Icon(Icons.delete),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_backNode),
      child: Dialog(
        child: ClipRect(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 450,
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: expand
                            ? null
                            : () {
                                setState(() => expand = true);
                                date.value = DateTime.now();
                                FocusScope.of(context)
                                    .requestFocus(_textFieldNode);
                              },
                        label: const Text('Προσθήκη νέου'),
                        icon: const Icon(Icons.add),
                      ),
                      ClipRect(
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                          alignment: Alignment.bottomCenter,
                          heightFactor: expand ? 1 : 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                maxLines: 3,
                                focusNode: _textFieldNode,
                                maxLength: 200,
                                controller: notesController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () async {
                                      FocusScope.of(context)
                                          .requestFocus(_backNode);
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2099),
                                      );
                                      if (date == null) return;
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time == null) return;
                                      this.date.value = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    },
                                    label: ValueListenableBuilder(
                                      valueListenable: date,
                                      builder: (context, value, child) => Text(
                                        dateTimeFormat.format(date.value),
                                      ),
                                    ),
                                    icon: const Icon(Icons.watch_later),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context)
                                          .requestFocus(_backNode);
                                      setState(() {
                                        expand = false;
                                      });
                                      notesController.clear();
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                  const SizedBox(width: 12.0),
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context)
                                          .requestFocus(_backNode);
                                      if (notesController.text.isEmpty) return;
                                      setState(() {
                                        newHistory.add(
                                          History(
                                            date: date.value,
                                            notes: notesController.text,
                                          ),
                                        );
                                        expand = false;
                                      });
                                      widget.onHistoryChange(newHistory);
                                      animatedListKey.currentState!.insertItem(
                                        newHistory.length - 1,
                                        duration:
                                            const Duration(milliseconds: 200),
                                      );
                                      notesController.clear();
                                    },
                                    icon: const Icon(Icons.done),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (newHistory.isNotEmpty)
                        Divider(
                          thickness: 1.5,
                          color: Theme.of(context).primaryColor,
                        ),
                      if (newHistory.isNotEmpty)
                        const Text(
                          "Νέες προσθήκες",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      AnimatedList(
                        key: animatedListKey,
                        shrinkWrap: true,
                        initialItemCount: newHistory.length,
                        itemBuilder: (context, index, animation) =>
                            buildAddedItem(context, index, animation),
                      ),
                      Divider(
                        thickness: 1.5,
                        color: Theme.of(context).primaryColor,
                      ),
                      const Text(
                        "Ιστορικό",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      widget.history.isNotEmpty
                          ? ConstrainedBox(
                              constraints: BoxConstraints.loose(
                                const Size.fromHeight(400),
                              ),
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(scrollbars: true),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: widget.history.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) => ListTile(
                                    title: Text(
                                      dateTimeFormat
                                          .format(widget.history[index].date),
                                    ),
                                    subtitle: Text(widget.history[index].notes),
                                  ),
                                ),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Δεν βρέθηκε ιστορικό",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
