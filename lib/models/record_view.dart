import 'package:flutter/material.dart';
import 'package:rodis_service/models/record.dart';
import 'package:rodis_service/models/suggestions.dart';

enum COLUMN { id, name, phone, product, date, status }

class RecordView extends ChangeNotifier {
  RecordView({required this.suggestions, required this.records})
      : filtered = List.from(records);

  Suggestions suggestions;
  List<Record> records;
  List<Record> filtered;

  COLUMN column = COLUMN.date;
  bool reverse = true;
  Comparator<Record> sorterInner = (p0, p1) => p0.date.compareTo(p1.date);
  Comparator<Record> sorter = (p0, p1) => p0.date.compareTo(p1.date);
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
      switch (column) {
        case COLUMN.id:
          sorterInner = (p0, p1) => p0.id.compareTo(p1.id);
          break;
        case COLUMN.name:
          sorterInner = (p0, p1) =>
              p0.name.toLowerCase().compareTo(p1.name.toLowerCase());
          break;
        case COLUMN.phone:
          sorterInner = (p0, p1) => p0.phoneMobile.compareTo(p1.phoneMobile);
          break;
        case COLUMN.product:
          sorterInner = (p0, p1) =>
              p0.product.toLowerCase().compareTo(p1.product.toLowerCase());
          break;
        case COLUMN.date:
          sorterInner = (p0, p1) => p0.date.compareTo(p1.date);
          break;
        case COLUMN.status:
          sorterInner = (p0, p1) => suggestions.statuses[p0.status]!
              .toLowerCase()
              .compareTo(suggestions.statuses[p1.status]!.toLowerCase());
          break;
      }
    }
    sorter = (a, b) =>
        sorterInner(a, b) != 0 ? sorterInner(a, b) : b.date.compareTo(a.date);
    filtered.sort(sorter);
    notifyListeners();
  }

  void setFilterValue(String filterValue) {
    this.filterValue = filterValue;
    filtered = records.where((record) => filter(record, filterValue)).toList()
      ..sort(sorter);
    notifyListeners();
  }

  void setFilterType(COLUMN filterType) {
    this.filterType = filterType;
    switch (filterType) {
      case COLUMN.id:
        filter = (record, value) => record.id == int.tryParse(value);
        break;
      case COLUMN.name:
        filter = (record, value) =>
            record.name.toLowerCase().contains(value.toLowerCase());
        break;
      case COLUMN.phone:
        filter = (record, value) =>
            record.phoneMobile.toLowerCase().contains(value.toLowerCase());
        break;
      case COLUMN.product:
        filter = (record, value) =>
            record.product.toLowerCase().contains(value.toLowerCase());
        break;
      case COLUMN.date:
        //filter = (record,value) => record.date.toLowerCase().contains(value);
        break;
      case COLUMN.status:
        filter = (record, value) => suggestions.statuses[record.status]!
            .toLowerCase()
            .contains(value.toLowerCase());
        break;
    }
    if (filterValue.isNotEmpty) {
      filtered = records.where((record) => filter(record, filterValue)).toList()
        ..sort(sorter);
      notifyListeners();
    }
  }
}
