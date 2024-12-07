import 'package:flutter/material.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/suggestions.dart';

enum COLUMN { id, name, phone, product, date, status, store }

class RecordView extends ChangeNotifier {
  RecordView({required this.suggestions, required this.records})
      : filtered = List.from(records);

  Suggestions suggestions;
  List<Record> records;
  List<Record> filtered;

  COLUMN column = COLUMN.date;
  bool reverse = true;
  Comparator<Record> sorterInner = (a, b) => a.date.compareTo(b.date);
  Comparator<Record> sorter = (a, b) => a.date.compareTo(b.date);
  String filterValue = '';
  COLUMN filterType = COLUMN.name;
  bool Function(Record, String) filter = (record, value) =>
      record.name.toLowerCase().contains(value.toLowerCase());

  void update(Suggestions suggestions, Records records) {
    this.suggestions = suggestions;
    this.records = records.records;
    filtered = this
        .records
        .where((record) => filter(record, filterValue))
        .toList()
      ..sort(sorter);
    notifyListeners();
  }

  void setSort(COLUMN column) {
    if (this.column == column) {
      reverse = !reverse;
    } else {
      this.column = column;
      reverse = false;
      sorterInner = switch (column) {
        COLUMN.id => (a, b) => a.id.compareTo(b.id),
        COLUMN.name => (a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        COLUMN.product => (a, b) =>
            a.product.toLowerCase().compareTo(b.product.toLowerCase()),
        COLUMN.store => (a, b) => suggestions.stores[a.store]!
            .compareTo(suggestions.stores[a.store]!),
        COLUMN.date => (a, b) => a.date.compareTo(b.date),
        COLUMN.status => (a, b) => a.status.compareTo(b.status),
        _ => (a, b) => -1,
      };
    }
    sorter = (a, b) =>
        sorterInner(a, b) != 0 ? sorterInner(a, b) : b.date.compareTo(a.date);
    filtered.sort(sorter);
    notifyListeners();
  }

  void setFilterValue(String filterValue) {
    this.filterValue = filterValue;
    filtered = records
        .where((record) => filterValue.isEmpty || filter(record, filterValue))
        .toList()
      ..sort(sorter);
    notifyListeners();
  }

  void setFilterType(COLUMN filterType) {
    this.filterType = filterType;
    filter = switch (filterType) {
      COLUMN.id => (record, value) => record.id == int.tryParse(value),
      COLUMN.name => (record, value) =>
          record.name.toLowerCase().contains(value.toLowerCase()),
      COLUMN.phone => (record, value) =>
          record.phoneMobile.toLowerCase().contains(value.toLowerCase()),
      COLUMN.product => (record, value) =>
          record.product.toLowerCase().contains(value.toLowerCase()),
      COLUMN.store => (record, value) => suggestions.stores[record.store]!
          .toLowerCase()
          .contains(value.toLowerCase()),
      COLUMN.status => (record, value) => suggestions.statuses[record.status]!
          .toLowerCase()
          .contains(value.toLowerCase()),
      _ => (record, value) => true,
    };
    if (filterValue.isNotEmpty) {
      filtered = records.where((record) => filter(record, filterValue)).toList()
        ..sort(sorter);
      notifyListeners();
    }
  }
}
